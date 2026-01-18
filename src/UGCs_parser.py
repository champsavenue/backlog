import re
import requests
from datetime import datetime

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
    """
    rows must contain: Key, Name, Asset ID, Price, Category, Priority
    """
    lines = []
    existing_keys = set(existing_by_id.values())

    for r in rows:
        # Only keep rows explicitly published
        published = str(r.get("Published", "")).strip().upper()
        if published != "X":
            continue

        raw_id = r.get("ID")

        # Skip rows without a valid ID
        if raw_id is None or str(raw_id).strip() == "":
            continue

        asset_id = parse_id(raw_id)
        name = r["NAME"]
        price = int(r["PRICE"])
        category = r.get("CATEGORY", "")
        priority = parse_int(r.get("PRIORITY"), 0)

        # Keep existing key if ID already exists
        if asset_id in existing_by_id:
            key = existing_by_id[asset_id]
        else:
            key = generate_key(existing_keys)
            existing_keys.add(key)

        lua = (
            f'    ["{key}"] = {{ '
            f'Name = "{name}", '
            f'ID = {asset_id}, '
            f'Price = {price}, '
            f'Category = "{category}", '
            f'Priority = {priority}, '
            f'Thumbnail = "rbxthumb://type=Asset&Id={asset_id}&w=150&h=150" '
            f'}},'
        )
        lines.append(lua)

    return "\n".join(lines)


def main():
    existing_by_id = load_existing_ugc(EXISTING_LUA_PATH)
    rows = fetch_sheet_rows()

    lua_block = generate_lua_block(rows, existing_by_id)

    with open("ugcs/Monetization_Mod_updated.lua", "w", encoding="utf-8") as f:
        f.write("local UGC_Data = {\n")
        f.write(lua_block)
        f.write("\n}\n")

    print("UGC_Data.generated.lua created.")


if __name__ == "__main__":
    main()
