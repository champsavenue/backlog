# This script builds a zip from the data/export.rbxmx which results
# from the plugin ExportScripts.lua in Roblox Studio

import xml.etree.ElementTree as ET
import zipfile, os, sys, datetime

RBXMX = "data/export.rbxmx"  # fichier sauvegardé en **.rbxmx**
OUTPUT_DIR = "output"  # dossier où mettre le zip

# Vérif format du fichier
with open(RBXMX, "rb") as f:
    head = f.read(20).strip()
if not head.startswith(b"<roblox"):
    sys.exit("Erreur: fichier pas en XML .rbxmx. Re-sauvegarde en 'Model (*.rbxmx)'.")


def walk(item, path_parts, files):
    cls = item.attrib.get("class", "")
    props = item.find("Properties")
    # Récupérer Name
    name = "Unnamed"
    if props is not None:
        n = props.find("./string[@name='Name']")
        if n is not None and n.text is not None:
            name = n.text
    # Folder -> descendre
    if cls == "Folder":
        new_path = path_parts + [name]
        for child in item.findall("./Item"):
            walk(child, new_path, files)
        return
    # ModuleScript -> extraire Source
    if cls == "ModuleScript":
        filename = name  # plugin a déjà mis l’extension
        src = ""
        if props is not None:
            s = props.find("./ProtectedString[@name='Source']")
            if s is not None and s.text is not None:
                src = s.text
        files.append(("/".join(path_parts + [filename]), src))
        return
    # Autres -> descendre
    for child in item.findall("./Item"):
        walk(child, path_parts + [name], files)


tree = ET.parse(RBXMX)
root = tree.getroot()
files = []
for item in root.findall("./Item"):
    walk(item, [], files)

# Créer le répertoire output si besoin
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Générer nom avec timestamp
timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
OUTPUT_ZIP = os.path.join(OUTPUT_DIR, f"roblox_scripts_export_{timestamp}.zip")

with zipfile.ZipFile(OUTPUT_ZIP, "w", zipfile.ZIP_DEFLATED) as z:
    for path, src in files:
        parts = path.split("/")
        # enlever _ScriptExport si présent
        if parts and parts[0].lower() == "_scriptexport":
            parts = parts[1:]
        norm = "/".join(parts)
        z.writestr(norm, src)

print(f"✅ OK → {OUTPUT_ZIP} ({len(files)} fichiers)")
