# sync_roblox_scripts.py
# Export des scripts Roblox via Engine Open Cloud (Instances API)
# Anti-429 + opérations éphémères: Retry-After, backoff, throttle, poll tolérant au 404, cache get_instance
#
# Prérequis:
#  - Team Create activé sur le place
#  - Clé Open Cloud avec le scope: universe.place.instance:read
#  - Variables d'env: RBX_API_KEY, ROBLOX_UNIVERSE_ID, PLACE_ID
#
# Options (env):
#  - ROBLOX_RATE_LIMIT_DELAY (float, défaut 0.3s) : throttle entre requêtes
#  - ROBLOX_POLL_INTERVAL   (float, défaut 2.0s)  : intervalle de polling des opérations
#  - ROBLOX_HTTP_MAX_RETRIES (int, défaut 5)      : nb max de retries HTTP
#  - ROBLOX_HTTP_TIMEOUT     (int, défaut 60)     : timeout socket par requête

import os
import time
import requests
from pathlib import Path

API_KEY = os.getenv("RBX_API_KEY") or os.getenv("ROBLOX_READ_API_KEY")
UNIVERSE_ID = os.getenv("ROBLOX_UNIVERSE_ID") or "7436965994"
PLACE_ID = os.getenv("PLACE_ID") or "134152435409940"

ROOT_API = "https://apis.roblox.com/cloud/v2"
BASE_INSTANCES = f"{ROOT_API}/universes/{UNIVERSE_ID}/places/{PLACE_ID}/instances"
HEADERS = {"x-api-key": API_KEY}

RATE_LIMIT_DELAY    = float(os.getenv("ROBLOX_RATE_LIMIT_DELAY", "0.3"))
POLL_INTERVAL       = float(os.getenv("ROBLOX_POLL_INTERVAL", "2.0"))
HTTP_MAX_RETRIES    = int(os.getenv("ROBLOX_HTTP_MAX_RETRIES", "5"))
HTTP_TIMEOUT        = int(os.getenv("ROBLOX_HTTP_TIMEOUT", "60"))

session = requests.Session()
_instance_cache = {}  # cache simple pour get_instance(id)

# ---------- Utils HTTP / logging ----------

def _debug_response(resp, label="[DEBUG]"):
    body = resp.text
    if len(body) > 2000:
        body = body[:2000] + "...(truncated)"
    print(f"{label} {resp.status_code} {resp.url}")
    print(f"[DEBUG BODY] {body}")

def _sleep_safely(seconds: float, reason: str = ""):
    if seconds > 0:
        if reason:
            print(f"[WAIT] {seconds:.2f}s ({reason})")
        time.sleep(seconds)

def _do_request(method: str, url: str, *, headers=None, timeout=None, **kwargs):
    """
    Wrapper HTTP robuste:
      - throttle global entre requêtes
      - gestion 429 + Retry-After
      - retries exponentiels sur 429/5xx/erreurs réseau
    """
    headers = headers or {}
    timeout = timeout or HTTP_TIMEOUT

    attempt = 0
    backoff_base = 1.5
    while True:
        attempt += 1
        _sleep_safely(RATE_LIMIT_DELAY, reason="throttle")
        try:
            resp = session.request(method, url, headers=headers, timeout=timeout, **kwargs)
        except requests.RequestException as e:
            if attempt >= HTTP_MAX_RETRIES:
                raise
            delay = min(8.0, (backoff_base ** (attempt - 1)))
            print(f"[RETRY] Network error: {e} → retry in {delay:.2f}s (attempt {attempt}/{HTTP_MAX_RETRIES})")
            _sleep_safely(delay, reason="net error backoff")
            continue

        if resp.status_code == 429:
            retry_after = resp.headers.get("Retry-After")
            if retry_after is not None:
                try:
                    delay = float(retry_after)
                except ValueError:
                    delay = 2.0
            else:
                delay = min(16.0, (backoff_base ** (attempt - 1)))
            if attempt >= HTTP_MAX_RETRIES:
                _debug_response(resp, label="[HTTP 429 FINAL]")
                resp.raise_for_status()
            print(f"[RATE LIMIT] 429 → sleep {delay:.2f}s (attempt {attempt}/{HTTP_MAX_RETRIES})")
            _sleep_safely(delay, reason="Retry-After/backoff")
            continue

        if 500 <= resp.status_code < 600:
            if attempt >= HTTP_MAX_RETRIES:
                _debug_response(resp, label="[HTTP 5xx FINAL]")
                resp.raise_for_status()
            delay = min(10.0, (backoff_base ** (attempt - 1)))
            print(f"[RETRY] {resp.status_code} server error → retry in {delay:.2f}s (attempt {attempt}/{HTTP_MAX_RETRIES})")
            _sleep_safely(delay, reason="server backoff")
            continue

        return resp

# ---------- Opérations async ----------

class OperationNotFound(Exception):
    pass

def _poll_operation(op_path, timeout=180, interval=POLL_INTERVAL):
    """
    Poll une Operation jusqu'à done:true.
    - Gère 429/5xx via _do_request
    - Tolère des 404 éphémères (ressources d'opération purgées)
    """
    url = f"{ROOT_API}/{op_path.lstrip('/')}"
    start = time.time()
    consecutive_404 = 0

    while True:
        r = _do_request("GET", url, headers=HEADERS)
        if r.status_code == 404:
            consecutive_404 += 1
            if consecutive_404 >= 2:
                raise OperationNotFound(f"Operation resource not found: {url}")
            _sleep_safely(interval, reason="op 404 retry")
            continue

        _debug_response(r, label="[OP]")
        r.raise_for_status()
        try:
            op = r.json() or {}
        except Exception:
            op = {}

        if op.get("done"):
            return op.get("response", {}) or {}

        if time.time() - start > timeout:
            raise TimeoutError(f"Operation timeout ({timeout}s): {url}")

        _sleep_safely(interval, reason="op poll")

# ---------- Normalisation Instances ----------

def _normalize_engine_instance(obj):
    eng = obj.get("engineInstance", obj) or {}
    return {
        "id": eng.get("Id"),
        "name": eng.get("Name"),
        "details": eng.get("Details", {}) or {},
        "hasChildren": obj.get("hasChildren", False),
    }

def _normalize_children_payload(data):
    if "instances" in data:  # ListInstanceChildrenResponse
        return [_normalize_engine_instance(x) for x in data["instances"]], data.get("nextPageToken")
    if "children" in data:
        return data["children"], data.get("nextPageToken")
    return [], None

# ---------- API Instances ----------

def list_children_page(instance_id="root", page_token=None, max_page_size=200):
    url = f"{BASE_INSTANCES}/root:listChildren" if instance_id == "root" else f"{BASE_INSTANCES}/{instance_id}:listChildren"
    params = {"maxPageSize": max_page_size}
    if page_token:
        params["pageToken"] = page_token

    def _once():
        r = _do_request("GET", url, headers=HEADERS, params=params)
        _debug_response(r)
        r.raise_for_status()
        data = r.json() if r.text else {}
        if "path" in data and not data.get("done", False):
            data = _poll_operation(data["path"])
        return _normalize_children_payload(data)

    try:
        children, token = _once()
    except OperationNotFound:
        print("[WARN] Operation 404 → relance listChildren")
        children, token = _once()

    return children, token

def list_children_all(instance_id="root", max_page_size=200):
    all_children = []
    token = None
    while True:
        children, token = list_children_page(instance_id, token, max_page_size)
        all_children.extend(children)
        if not token:
            break
    return all_children

def get_instance(instance_id):
    if instance_id in _instance_cache:
        return _instance_cache[instance_id]

    url = f"{BASE_INSTANCES}/{instance_id}"

    def _once():
        r = _do_request("GET", url, headers=HEADERS)
        _debug_response(r)
        r.raise_for_status()
        data = r.json() if r.text else {}
        if "path" in data and not data.get("done", False):
            data = _poll_operation(data["path"])
        if "engineInstance" in data:
            return _normalize_engine_instance(data)
        if {"id","name","details"}.issubset(set(data.keys())):
            return data
        return {"id": instance_id, "name": "", "details": {}}

    try:
        norm = _once()
    except OperationNotFound:
        print("[WARN] Operation 404 sur get_instance → relance")
        norm = _once()

    _instance_cache[instance_id] = norm
    return norm

# ---------- Helpers scripts ----------

SCRIPT_KINDS = ("Script", "LocalScript", "ModuleScript")

def _kind_of(node):
    details = node.get("details", {}) or {}
    for k in details.keys():
        return k
    return None

def is_script(node):
    return _kind_of(node) in SCRIPT_KINDS

def safe_name(name):
    return "".join(c if c.isalnum() or c in "._- " else "_" for c in (name or ""))

def script_filename(node):
    k = _kind_of(node)
    name = safe_name(node.get("name", "Unnamed"))
    if k == "Script":
        return f"{name}.server.luau"
    if k == "LocalScript":
        return f"{name}.client.luau"
    if k == "ModuleScript":
        return f"{name}.luau"
    return None

# ---------- Parcours récursif ----------

def walk(node, path_parts, out_dir: Path):
    node_id = node.get("id")
    if not node_id:
        print("[SKIP] Node sans id:", node)
        return
    node_name = safe_name(node.get("name", ""))

    next_path = path_parts
    if not is_script(node) and node_name:
        next_path = path_parts + [node_name]
        (out_dir / Path(*next_path)).mkdir(parents=True, exist_ok=True)

    if is_script(node):
        inst = get_instance(node_id)  # cache + anti-429 / 404
        k = _kind_of(inst)
        d = inst.get("details", {}).get(k, {}) if k else {}
        src = d.get("source") or d.get("Source") or ""
        fname = script_filename(inst) or script_filename(node) or f"{node_id}.luau"
        target_dir = out_dir / Path(*path_parts)
        target_dir.mkdir(parents=True, exist_ok=True)
        (target_dir / fname).write_text(src, encoding="utf-8")
        print(f"[SCRIPT] {('/'.join(path_parts) or '.')}/{fname}  ({len(src)} chars)")

    # Descente enfants
    children = list_children_all(node_id)
    for child in children:
        walk(child, next_path, out_dir)

# ---------- Main ----------

def main():
    if not API_KEY:
        raise SystemExit("⚠️  Définis RBX_API_KEY (scope: universe.place.instance:read).")

    out_dir = Path("out")
    if out_dir.exists():
        for p in sorted(out_dir.rglob("*"), reverse=True):
            if p.is_file():
                try: p.unlink()
                except Exception: pass
            elif p.is_dir():
                try: p.rmdir()
                except Exception: pass
    out_dir.mkdir(exist_ok=True)

    roots = list_children_all("root")
    print(f"[INFO] Root count: {len(roots)} names={[c.get('name') for c in roots]}")

    if not roots:
        print("🔎  Pas d’enfants sous root. Vérifie:")
        print("   • Team Create activé sur le place")
        print("   • Clé Open Cloud avec scope universe.place.instance:read")
        print("   • La clé est bien restreinte au bon Universe/Place")
        return

    for node in roots:
        walk(node, [], out_dir)

    files = list(out_dir.rglob("*.luau"))
    print(f"\n✅ Terminé. Fichiers exportés: {len(files)}")
    if not files:
        print("ℹ️ Aucun script trouvé (l’arbre ne contient peut-être pas de Script/LocalScript/ModuleScript).")

if __name__ == "__main__":
    main()
