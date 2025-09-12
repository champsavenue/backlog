import requests
from typing import Optional, List

API_KEY    = "yourAPIKey"
GUILD_ID   = "1371423884921933837"
TIMEOUT    = 30

def get_roblox_id(username: str) -> Optional[int]:

    url = "https://users.roblox.com/v1/usernames/users"
    payload = {"usernames": [username], "excludeBannedUsers": True}

    try:
        resp = requests.post(url, json=payload, timeout=TIMEOUT)
        resp.raise_for_status()
        users = resp.json().get("data", [])
        if not users:
            print("❌ Aucun utilisateur Roblox trouvé pour le pseudo donné.")
            return None
        return users[0]["id"]

    except requests.Timeout:
        raise RuntimeError("⚠️ Requête API Roblox expirée.")
    except requests.HTTPError as e:
        raise RuntimeError(f"⚠️ Erreur HTTP API Roblox : {e}")
    except requests.RequestException as e:
        raise RuntimeError(f"⚠️ Erreur réseau/API Roblox : {e}")

def is_discord_and_roblox_linked(discord_id: str, roblox_username: str) -> bool:
    # Étape 1 : Récupérer l'ID Roblox depuis le nom d'utilisateur
    try:
        roblox_resp = requests.post(
            "https://users.roblox.com/v1/usernames/users",
            json={"usernames": [roblox_username], "excludeBannedUsers": True},
            timeout=TIMEOUT
        )
        roblox_resp.raise_for_status()
        users = roblox_resp.json().get("data", [])
        if not users:
            return False
        roblox_id = users[0]["id"]
    except requests.RequestException:
        return False

    # Étape 2 : Vérifier si le Roblox ID est lié à ce Discord ID via Bloxlink
    try:
        url = f"https://api.blox.link/v4/public/guilds/{GUILD_ID}/roblox-to-discord/{roblox_id}"
        headers = {
            "Authorization": API_KEY,
            "User-Agent": "Mozilla/5.0"
        }
        resp = requests.get(url, headers=headers, timeout=TIMEOUT)
        if resp.status_code == 404:
            return False
        resp.raise_for_status()
        discord_ids = resp.json().get("discordIDs", [])
        return discord_id in discord_ids
    except requests.RequestException:
        return False

if __name__ == "__main__":
    linked = is_discord_and_roblox_linked("212496712772616192", "Cr1s714nCristian")
    print("✔️ Liés !" if linked else "❌ Pas liés.")