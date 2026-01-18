#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
GDPR Right to Erasure – Roblox Open Cloud

Deletes the entire player profile stored in:
- DataStore  : PLAYER_DATASTORE_LIVE
- Scope      : global
- Entry ID   : <userId>

This matches the NEW datastore paradigm used in DS_Handle.lua
(one datastore, one entry per player).
"""

import os
import sys
import argparse
import urllib.parse
import time
import requests

API_BASE = "https://apis.roblox.com/cloud/v2"
DATASTORE_NAME = "PLAYER_DATASTORE_LIVE"
DEFAULT_SCOPE = "global"


def log(msg: str, verbose: bool = False, force: bool = False):
    """Print messages depending on verbosity or force flag."""
    if verbose or force:
        print(msg)


def delete_player_entry(
    universe_id: str,
    user_id: int,
    api_key: str,
    scope: str = DEFAULT_SCOPE,
    verbose: bool = False,
    max_retries: int = 5,
) -> tuple[bool, str]:
    """
    Delete a player entry from PLAYER_DATASTORE_LIVE.

    Returns:
        (success: bool, message: str)
    """
    ds_enc = urllib.parse.quote(DATASTORE_NAME, safe="")
    scope_enc = urllib.parse.quote(scope, safe="")
    entry_enc = urllib.parse.quote(str(user_id), safe="")

    url = (
        f"{API_BASE}/universes/{universe_id}"
        f"/data-stores/{ds_enc}"
        f"/scopes/{scope_enc}"
        f"/entries/{entry_enc}"
    )

    headers = {
        "x-api-key": api_key,
        "Accept": "application/json",
    }

    for attempt in range(1, max_retries + 1):
        try:
            resp = requests.delete(url, headers=headers, timeout=30)
        except requests.RequestException as exc:
            if attempt >= max_retries:
                return False, f"Network error (final): {exc}"
            delay = min(2 ** attempt, 30)
            log(
                f"[retry] Network error ({exc}), retrying in {delay}s "
                f"({attempt}/{max_retries})",
                verbose,
            )
            time.sleep(delay)
            continue

        if resp.status_code in (200, 204):
            return True, "Deleted"
        if resp.status_code == 404:
            return True, "Already absent (404)"
        if resp.status_code == 401:
            return False, "Unauthorized (401): invalid API key"
        if resp.status_code == 403:
            return False, "Forbidden (403): missing DELETE permission"
        if resp.status_code == 429:
            delay = float(resp.headers.get("Retry-After", 2 ** attempt))
            log(f"[429] Rate limited, waiting {delay}s…", verbose)
            time.sleep(delay)
            continue

        return False, f"HTTP {resp.status_code}: {resp.text}"

    return False, f"Failed after {max_retries} attempts"


def main():
    parser = argparse.ArgumentParser(
        description="GDPR Erasure – delete a player profile from PLAYER_DATASTORE_LIVE."
    )
    parser.add_argument("--user-id", type=int, required=True, help="Roblox UserId to erase")
    parser.add_argument("--scope", type=str, default=DEFAULT_SCOPE, help="DataStore scope")
    parser.add_argument("--verbose", action="store_true", help="Verbose output")
    args = parser.parse_args()

    api_key = os.getenv("ROBLOX_API_KEY")
    universe_id = os.getenv("ROBLOX_UNIVERSE_ID")

    if not api_key or not universe_id:
        print(
            "Error: ROBLOX_API_KEY and ROBLOX_UNIVERSE_ID must be set.",
            file=sys.stderr,
        )
        sys.exit(2)

    log(f"Universe  : {universe_id}", force=True)
    log(f"DataStore : {DATASTORE_NAME}", force=True)
    log(f"Scope     : {args.scope}", force=True)
    log(f"UserId    : {args.user_id}", force=True)

    ok, msg = delete_player_entry(
        universe_id=universe_id,
        user_id=args.user_id,
        api_key=api_key,
        scope=args.scope,
        verbose=args.verbose,
    )

    status = "OK" if ok else "ERR"
    print(f"[{status}] {DATASTORE_NAME}/{args.user_id} → {msg}")
    sys.exit(0 if ok else 1)


if __name__ == "__main__":
    main()
