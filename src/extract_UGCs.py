import pandas as pd
import requests
import time

SEARCH_URL = "https://catalog.roblox.com/v1/search/items"
DETAILS_URL = "https://economy.roblox.com/v2/assets"
THUMBNAIL_URL = "https://thumbnails.roblox.com/v1/assets"

params = {
    "Category": 1,
    "CreatorName": "CHAMPS AVENUE x Exclusible",
    "CreatorType": "Group",
    "salesTypeFilter": 1,
    "Limit": 30
}

# Step 1: Get all UGC IDs
def fetch_all_ids():
    ids = []
    cursor = None
    while True:
        if cursor:
            params["cursor"] = cursor
        res = requests.get(SEARCH_URL, params=params)
        res.raise_for_status()
        data = res.json()
        for item in data.get("data", []):
            ids.append(item.get("id"))
        cursor = data.get("nextPageCursor")
        if not cursor:
            break
    return ids

# Step 2: Get details for each ID with rate limiting + retry
def fetch_item_details(ids):
    items = []
    for item_id in ids:
        url = f"{DETAILS_URL}/{item_id}/details"
        retries = 3
        while retries > 0:
            res = requests.get(url)
            if res.status_code == 200:
                d = res.json()
                name = d.get("Name", "Unknown")
                price = d.get("PriceInRobux") if d.get("PriceInRobux") is not None else "Free"
                items.append({
                    "ID": item_id,
                    "Name": name,
                    "Price": price,
                    "Link": f"https://www.roblox.com/catalog/{item_id}/{name.replace(' ', '-') if name else ''}"
                })
                break
            elif res.status_code == 429:
                print(f"Rate limit hit for {item_id}, waiting...")
                time.sleep(2)  # wait 2s before retry
                retries -= 1
            else:
                print(f"Error fetching {item_id}: {res.status_code}")
                break
        time.sleep(0.3)  # slow down requests globally
    return items

# Step 3: Fetch thumbnails
def fetch_thumbnails(items):
    ids = [str(i["ID"]) for i in items]
    if not ids:
        return items
    url = f"{THUMBNAIL_URL}?assetIds={','.join(ids)}&size=420x420&format=Png&isCircular=false"
    res = requests.get(url)
    res.raise_for_status()
    data = res.json()
    thumb_map = {d["targetId"]: d["imageUrl"] for d in data.get("data", [])}
    for i in items:
        i["Image"] = thumb_map.get(i["ID"], "")
    return items

# Step 4: Save to Excel
def save_to_excel(items, filename="ugc_catalog.xlsx"):
    df = pd.DataFrame(items)
    df.to_excel(filename, index=False)
    print(f"Saved {len(items)} items to {filename}")

# Main
def main():
    ids = fetch_all_ids()
    print(f"Found {len(ids)} items")
    items = fetch_item_details(ids)
    items = fetch_thumbnails(items)
    save_to_excel(items)

if __name__ == "__main__":
    main()
