import xml.etree.ElementTree as ET
import ast
import json
import sys
from pathlib import Path

def rbxmx_to_json(path_in, path_out=None):
    tree = ET.parse(path_in)
    root = tree.getroot()

    # Collect all parts
    parts = []
    for mod in root.findall(".//Item[@class='ModuleScript']"):
        name_node = mod.find("./Properties/string[@name='Name']")
        if name_node is None:
            continue
        name = name_node.text
        if name and name.startswith("AuditReport_Part"):
            source_node = mod.find("./Properties/ProtectedString[@name='Source']")
            if source_node is None or not source_node.text:
                continue
            lua_code = source_node.text
            try:
                parsed = ast.literal_eval(lua_code.split("return",1)[1].strip())
                index = parsed["index"]
                data = parsed["data"]
                parts.append((index, data))
            except Exception as e:
                print(f"⚠️ Failed to parse part {name}: {e}")

    if not parts:
        print("❌ No AuditReport_Part found in file.")
        return

    # Sort and concat
    parts.sort(key=lambda x: x[0])
    json_str = "".join(p[1] for p in parts)

    try:
        data = json.loads(json_str)
    except Exception as e:
        print(f"❌ Failed to decode JSON: {e}")
        return

    if path_out is None:
        path_out = str(Path(path_in).with_suffix(".json"))

    with open(path_out, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

    print(f"✅ JSON exported to {path_out}")

# Usage
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python rbxmx_to_json.py input.rbxmx [output.json]")
    else:
        inp = sys.argv[1]
        outp = sys.argv[2] if len(sys.argv) > 2 else None
        rbxmx_to_json(inp, outp)
