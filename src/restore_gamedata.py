import requests
import json

API_KEY = "PBF4EJkDg0a+zRQDPPybasn8kBA++MI8YegPRlZrfEcbLgSCZXlKaGJHY2lPaUpTVXpJMU5pSXNJbXRwWkNJNkluTnBaeTB5TURJeExUQTNMVEV6VkRFNE9qVXhPalE1V2lJc0luUjVjQ0k2SWtwWFZDSjkuZXlKaGRXUWlPaUpTYjJKc2IzaEpiblJsY201aGJDSXNJbWx6Y3lJNklrTnNiM1ZrUVhWMGFHVnVkR2xqWVhScGIyNVRaWEoyYVdObElpd2lZbUZ6WlVGd2FVdGxlU0k2SWxCQ1JqUkZTbXRFWnpCaEszcFNVVVJRVUhsaVlYTnVPR3RDUVNzclRVazRXV1ZuVUZKc1duSm1SV05pVEdkVFF5SXNJbTkzYm1WeVNXUWlPaUk0TlRJd01qVXdOREkySWl3aVpYaHdJam94TnpZeE5ESXdNelV5TENKcFlYUWlPakUzTmpFME1UWTNOVElzSW01aVppSTZNVGMyTVRReE5qYzFNbjAuQllsSEFRWElrTGpzWjNmOTlCZ0k3bWZlR0w0Qk5BNWFOY3RwTnFWTklzY1lkZnFMd25qVHNCaDVFNDJsQzZBN3JvZEJpZ2tJd1gxb3gwVXZ3emRRQWplUEl1dEh3YXhtc0t6bGZEVmhwQ1hYVFhuTTl0Ni1RbHRYYkI3QV8yR3ZhVUF3WnktWno5NWhNdDJfM1BkRkVGNm1LZkp2WUJsNFdNdXBBZFZIWVU0ejBYTEQ1YVpPbEJ6eVRhalhfb1N2YnF2OGRZWHV4NkN3N0pzX0s2NlA1bF8tcGlVN09GdFNUV0FzOVhiYmZZTjM1eHlmLWJHUmNpd3EtZEZTVXlMbnlsblBta29EM0ZHRUpJVDBadXFSSVZHeDRFZEZscUpaVkZHcVpZYzFUZEVtdEJmaVRWeTR0NGxJZzNjQkxtY282V3dVLVRCb1J5UFMyMTctZ0U1NDZB"
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