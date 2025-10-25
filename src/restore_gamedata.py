import requests
import json

API_KEY = "YOUR_API_KEY"
UNIVERSE_ID = "7436965994"
DATASTORE_NAME = "7837461859_Game_Data"
ENTRY_KEY = "PLAYER_DATASTORE_LIVE"
JSON_FILE_PATH = "gamedata/7837461859_Game_Data.json"

# === LOAD JSON DATA ===
with open(JSON_FILE_PATH, "r", encoding="utf-8") as f:
    data = json.load(f)

# === WRITE TO DATASTORE ===
url = f"https://apis.roblox.com/datastores/v1/universes/{UNIVERSE_ID}/standard-datastores/datastore/entries/entry"
headers = {"x-api-key": API_KEY, "Content-Type": "application/json"}
params = {"datastoreName": DATASTORE_NAME, "entryKey": ENTRY_KEY}

response = requests.post(url, headers=headers, params=params, data=json.dumps(data, separators=(',', ':')))

# === OUTPUT ===
print("Status:", response.status_code)
print("Response:", response.text)