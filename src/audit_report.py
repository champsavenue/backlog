import xml.etree.ElementTree as ET
import ast
import json
import sys
from pathlib import Path

def rbxmx_to_json(path_in, path_out=None):
    tree = ET.parse(path_in)
    root = tree.getroot()

    # Find the ModuleScript named "AuditReport"
    mod = root.find(".//Item[@class='ModuleScript']")
    if mod is None:
        print("❌ No ModuleScript found in file.")
        return

    source_node = mod.find("./Properties/ProtectedString[@name='Source']")
    if source_node is None or not source_node.text:
        print("❌ No Source found in ModuleScript.")
        return

    lua_code = source_node.text
    if "return" not in lua_code:
        print("❌ Source does not contain 'return'.")
        return

    # Extract JSON string after 'return'
    json_str = lua_code.split("return", 1)[1].strip()

    try:
        # Convert Lua string literal to Python str (e.g. return "....")
        parsed_str = ast.literal_eval(json_str)
        data = json.loads(parsed_str)
    except Exception as e:
        print(f"❌ Failed to decode JSON: {e}")
        return

    # Determine output path
    if path_out is None:
        path_out = str(Path(path_in).with_suffix(".json"))

    with open(path_out, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    print(f"✅ JSON exported to {path_out}")

# Usage example:
rbxmx_to_json("data/AuditReport.rbxmx", "output/audit/AuditReport.json")
