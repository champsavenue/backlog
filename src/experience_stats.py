import requests
import datetime
import os

API_KEY = "mrghkaeOEkO3CwVF4Y2PJ7SzoTHnyxoS6K4UTaP4a2SNR/OTZXlKaGJHY2lPaUpTVXpJMU5pSXNJbXRwWkNJNkluTnBaeTB5TURJeExUQTNMVEV6VkRFNE9qVXhPalE1V2lJc0luUjVjQ0k2SWtwWFZDSjkuZXlKaGRXUWlPaUpTYjJKc2IzaEpiblJsY201aGJDSXNJbWx6Y3lJNklrTnNiM1ZrUVhWMGFHVnVkR2xqWVhScGIyNVRaWEoyYVdObElpd2lZbUZ6WlVGd2FVdGxlU0k2SW0xeVoyaHJZV1ZQUld0UE0wTjNWa1kwV1RKUVNqZFRlbTlVU0c1NWVHOVROa3MwVlZSaFVEUmhNbE5PVWk5UFZDSXNJbTkzYm1WeVNXUWlPaUl6TlRjNE5EWTBNU0lzSW1WNGNDSTZNVGMxT1RBMk16UTNNQ3dpYVdGMElqb3hOelU1TURVNU9EY3dMQ0p1WW1ZaU9qRTNOVGt3TlRrNE56QjkuT3ZfVzRwVmFJRWpGR0JYT3Q4NlJyWDU2VWoxMnFSMVptZzZ4Zng5blZ4dld4Mnh2Sko0b0tJTzFkYWk1N0VEaEZUazJYelFKX0xfeDNWN3lfaWNDekcwWUVtUmZOZlhzSHpUZkhTbUQxeXBiOHEzSk40SENKRmRqNWRVV1oxb1E3RkRtYld2a1h1eHFaYTVmbk5NdU1uZzBJVWhGREJ3VG5ZTjJrUm9PeWVQLUtpcUxBWDQ0UlpaaXQ5WTZ2WjBRVTRnWVg2UnJQNVcyMlVKcldoSjZYQ0l3WEdfT2Z3NHhjeGxLdXltQlloWnVvNzV1aEQ5eTR2VFlYd0pGdFhTVjdHY0N3aE5NMG1vclJURzdSYW1TdG1WbmtrUW4tVVF5amlQRVQ3bGM5T0dMLWJxYXNPY2NnTFBCUWV4LV96UjdQNlFkSEU1dE9xMkJUYlFMcjR0Q3ZB"
# os.getenv("ROBLOX_API_KEY")
if not API_KEY:
    raise ValueError("❌ ROBLOX_API_KEY n'est pas défini")

UNIVERSE_ID = "7436965994"   # ton universeId
PLACE_ID = "117620200631077"      # ton placeId

end_date = datetime.date.today()
start_date = end_date - datetime.timedelta(days=7)

url = f"https://apis.roblox.com/analytics/v1/universes/{UNIVERSE_ID}/metrics"

headers = {
    "x-api-key": API_KEY,
    "Content-Type": "application/json"
}

params = {
    "granularity": "Day",
    "startTime": start_date.isoformat(),
    "endTime": end_date.isoformat(),
    "metricNames": "visits,avgSessionLength,revenue,dau",
    "placeId": PLACE_ID  # 👈 ici tu filtres sur une place
}

resp = requests.get(url, headers=headers, params=params)

if resp.status_code == 200:
    print(resp.json())
else:
    print("❌ Erreur:", resp.status_code, resp.text)


# import requests
# import datetime
# import statistics
# import os
#
# # === CONFIG ===
# API_KEY = os.getenv("ROBLOX_API_KEY")
# if not API_KEY:
#     raise ValueError("❌ La variable d'environnement ROBLOX_API_KEY n'est pas définie")
#
# UNIVERSE_ID = "7436965994"   # ID de ton jeu
# PLACE_ID = "117620200631077"      # ID de la place
#
# BASE_URL = f"https://apis.roblox.com/universes/v1/{UNIVERSE_ID}/stats/places"
# HEADERS = {
#     "x-api-key": API_KEY,
#     "Content-Type": "application/json"
# }
#
# ALL_METRICS = [
#     "Visits",
#     "DAU",
#     "MAU",
#     "NewUsers",
#     "Revenue",
#     "Payers",
#     "AvgSessionLength",
#     "MedianSessionLength",
#     "SessionsPerUser",
#     "ConcurrentUsersPeak",
#     "RevenuePerDAU",
#     "EngagementTime",
# ]
#
# def fetch_stats(days: int):
#     end_date = datetime.date.today()
#     start_date = end_date - datetime.timedelta(days=days)
#
#     params = {
#         "placeId": PLACE_ID,
#         "startTime": start_date.isoformat(),
#         "endTime": end_date.isoformat(),
#         "granularity": "Day",
#         "metricNames": ",".join(ALL_METRICS),
#     }
#
#     resp = requests.get(BASE_URL, headers=HEADERS, params=params)
#     if resp.status_code == 200:
#         return resp.json().get("data", [])
#     else:
#         print("❌ Erreur:", resp.status_code, resp.text)
#         return []
#
# def compute_avg(stats):
#     """Return average per metric from list of daily stats"""
#     if not stats:
#         return {}
#     metrics = {}
#     for m in ALL_METRICS:
#         values = [day.get(m.lower(), 0) for day in stats if m.lower() in day]
#         if values:
#             metrics[m] = statistics.mean(values)
#     return metrics
#
# def compare_7d_14d():
#     stats_7d = fetch_stats(7)
#     stats_14d = fetch_stats(14)
#
#     avg_7d = compute_avg(stats_7d)
#     avg_14d = compute_avg(stats_14d)
#
#     print("📊 Moyennes sur 7 jours vs 14 jours (et variation %):\n")
#     for m in ALL_METRICS:
#         v7 = avg_7d.get(m, None)
#         v14 = avg_14d.get(m, None)
#         if v7 is not None and v14 is not None:
#             if v14 != 0:
#                 variation = ((v7 - v14) / v14) * 100
#             else:
#                 variation = float("inf")
#             print(f"{m:20} | 7j: {v7:.2f} | 14j: {v14:.2f} | Δ {variation:+.1f}%")
#
# # === RUN ===
# compare_7d_14d()
