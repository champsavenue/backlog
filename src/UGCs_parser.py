import re
import requests
from datetime import datetime
import time

# ---- CONFIG -------------------------------------------------------------

SHEET_ID = "1LKraOAYZHdQdy9btaJUhLKnSV3jKDUCjEELOPNwvxZ0"
GID = "1675198613"
API_KEY = "AIzaSyBvR9oacU-rTPeU3qK5sBdtXY_R-DqTLEY"

EXISTING_LUA_PATH = "ugcs/Monetization_Mod.lua"

# ------------------------------------------------------------------------

def load_existing_ugc(lua_path: str):
    """
    Parse existing UGC_Data from a Lua file and return:
    - by_id: { asset_id: key }
    """
    with open(lua_path, "r", encoding="utf-8") as f:
        content = f.read()

    pattern = re.compile(
        r'\["(?P<key>[^"]+)"\]\s*=\s*\{\s*Name\s*=\s*"[^"]*",\s*ID\s*=\s*(?P<id>\d+)',
        re.MULTILINE
    )

    by_id = {}
    for m in pattern.finditer(content):
        by_id[int(m.group("id"))] = m.group("key")

    return by_id


def fetch_sheet_rows():
    url = (
        f"https://sheets.googleapis.com/v4/spreadsheets/{SHEET_ID}/values/"
        f"UGC?key={API_KEY}"
    )
    r = requests.get(url)
    r.raise_for_status()

    values = r.json()["values"]
    headers = values[0]
    rows = values[1:]

    data = []
    for row in rows:
        item = dict(zip(headers, row))
        data.append(item)

    return data

def generate_key(existing_keys):
    """
    Pattern: YEAR-MM-XXX (e.g. 2026-01-001)
    """
    now = datetime.utcnow()
    prefix = f"{now.year}-{now.month:02d}-"

    used = []
    for k in existing_keys:
        if k.startswith(prefix):
            try:
                used.append(int(k.split("-")[-1]))
            except ValueError:
                pass

    next_num = max(used, default=0) + 1
    if next_num > 999:
        raise RuntimeError("Key overflow for current month")

    return f"{prefix}{next_num:03d}"

def parse_id(value):
    if value is None:
        raise ValueError("Empty ID")

    s = str(value).strip()
    if not s.isdigit():
        raise ValueError(f"Invalid ID: {value}")

    return int(s)

def parse_int(value, default=0):
    try:
        s = str(value).strip()
        return int(s) if s != "" else default
    except ValueError:
        return default

def generate_lua_block(rows, existing_by_id):
    entries = {}
    existing_keys = set(existing_by_id.values())

    for r in rows:
        # Only keep rows explicitly for sale
        for_sale = str(r.get("FOR SALE", "")).strip().upper()
        if for_sale != "X":
            continue

        raw_id = r.get("ID")
        if raw_id is None or str(raw_id).strip() == "":
            continue

        asset_id = parse_id(raw_id)

        name = r.get("NAME", "").strip()
        price = parse_int(r.get("PRICE"), 0)
        category = r.get("CATEGORY", "").strip()
        priority = parse_int(r.get("PRIORITY"), 0)

        # Keep existing key if ID already exists
        if asset_id in existing_by_id:
            key = existing_by_id[asset_id]
        else:
            key = generate_key(existing_keys)
            existing_keys.add(key)

        entries[key] = (
            f'    ["{key}"] = {{ '
            f'Name = "{name}", '
            f'ID = {asset_id}, '
            f'Price = {price}, '
            f'Category = "{category}", '
            f'Priority = {priority}, '
            f'Thumbnail = "rbxthumb://type=Asset&Id={asset_id}&w=150&h=150" '
            f'}},'
        )

    # Sort by key (alphabetical)
    return "\n".join(entries[k] for k in sorted(entries.keys()))


def main():
    existing_by_id = load_existing_ugc(EXISTING_LUA_PATH)
    rows = fetch_sheet_rows()

    lua_block = generate_lua_block(rows, existing_by_id)

    with open("ugcs/Monetization_Mod_updated.lua", "w", encoding="utf-8") as f:
        f.write("local UGC_Data = {\n")
        f.write(lua_block)
        f.write("\n}\n")

if __name__ == "__main__":
    main()
