#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Erase user data for GDPR "Right to Erasure" requests.
This script deletes the two fixed keys (PLAYER_DATASTORE_LIVE, PLAYER_DATASTORE_LIVE_BACKUP)
inside the DataStore <userId>_Game_Data.
"""

import os
import sys
import argparse
import urllib.parse
import time
import requests

API_BASE = "https://apis.roblox.com/cloud/v2"

def log(msg, verbose=False, force=False):
    """Print messages depending on verbosity or if forced."""
    if verbose or force:
        print(msg)

def delete_entry(universe_id: str, datastore: str, scope: str, entry_id: str,
                 api_key: str, verbose: bool=False, max_retries: int=5) -> tuple[bool, str]:
    """
    Delete a single entry (key) from a DataStore via Roblox Open Cloud API.
    Returns (ok, message).
    """
    ds_enc = urllib.parse.quote(datastore, safe='')
    scope_enc = urllib.parse.quote(scope, safe='')
    entry_enc = urllib.parse.quote(entry_id, safe='')
    url = f"{API_BASE}/universes/{universe_id}/data-stores/{ds_enc}/scopes/{scope_enc}/entries/{entry_enc}"

    headers = {
        "x-api-key": api_key,
        "Accept": "application/json",
    }

    attempt = 0
    while attempt < max_retries:
        attempt += 1
        try:
            resp = requests.delete(url, headers=headers, timeout=30)
        except requests.RequestException as e:
            if attempt >= max_retries:
                return False, f"Network error (final): {e}"
            sleep_s = min(2 ** attempt, 30)
            log(f"[retry] Network error, attempt {attempt}/{max_retries}, retrying in {sleep_s}s… ({e})", verbose=True)
            time.sleep(sleep_s)
            continue

        if resp.status_code in (200, 204):
            return True, "Deleted"
        if resp.status_code == 404:
            return True, "Already absent (404)"
        if resp.status_code == 401:
            return False, "Unauthorized (401): check API key and permissions"
        if resp.status_code == 403:
            return False, "Forbidden (403): key does not have DELETE permission"
        if resp.status_code == 429:
            retry_after = resp.headers.get("Retry-After")
            delay = float(retry_after) if retry_after else min(2 ** attempt, 60)
            log(f"[429] Rate limited, waiting {delay}s…", verbose=True)
            time.sleep(delay)
            continue

        return False, f"HTTP {resp.status_code}: {resp.text}"

    return False, f"Failed after {max_retries} attempts"

def main():
    parser = argparse.ArgumentParser(description="GDPR Erasure – delete the 2 fixed keys of <userId>_Game_Data DataStore.")
    parser.add_argument("--user-id", type=int, required=True, help="Roblox UserId to erase.")
    parser.add_argument("--scope", type=str, default="global", help="DataStore scope (default: global).")
    parser.add_argument("--verbose", action="store_true", help="Enable verbose logging.")
    args = parser.parse_args()

    api_key = os.getenv("ROBLOX_API_KEY")
    universe_id = os.getenv("ROBLOX_UNIVERSE_ID")
    if not api_key or not universe_id:
        print("Error: ROBLOX_API_KEY and ROBLOX_UNIVERSE_ID must be set as environment variables.", file=sys.stderr)
        sys.exit(2)

    # DataStore is derived from the userId
    datastore = f"{args.user_id}_Game_Data"
    keys_to_delete = ["PLAYER_DATASTORE_LIVE", "PLAYER_DATASTORE_LIVE_BACKUP"]

    log(f"Universe : {universe_id}", force=True)
    log(f"DataStore: {datastore}", force=True)
    log(f"Scope    : {args.scope}", force=True)
    log(f"Keys     : {', '.join(keys_to_delete)}", force=True)

    failures = 0
    for entry_id in keys_to_delete:
        ok, msg = delete_entry(universe_id, datastore, args.scope, entry_id, api_key, verbose=args.verbose)
        status = "OK" if ok else "ERR"
        print(f"[{status}] {datastore}/{entry_id} → {msg}")
        if not ok:
            failures += 1

    sys.exit(0 if failures == 0 else 1)

if __name__ == "__main__":
    main()
