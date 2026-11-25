#!/usr/bin/env python3
"""
Check whether one or more DSH npm-only entries have gone live (artifact page
returns HTTP 200 + appears in the search index). One-shot query; safe to run
repeatedly while waiting for maintainer review.

Usage:
  python3 check-dsh-live.py <package> [<package> ...]
  python3 check-dsh-live.py yumingtao-diagram-generator yumingtao-clarify-before-acting
"""
import sys, json, urllib.request

def http_status(url):
    try:
        req = urllib.request.Request(url, method="HEAD",
                                     headers={"User-Agent": "check-dsh-live/1.0"})
        with urllib.request.urlopen(req, timeout=20) as r:
            return r.status
    except urllib.error.HTTPError as e:
        return e.code
    except Exception as e:
        return f"ERR({e})"

def fetch(url):
    req = urllib.request.Request(url, headers={"User-Agent": "check-dsh-live/1.0"})
    with urllib.request.urlopen(req, timeout=30) as r:
        return r.read().decode("utf-8", errors="replace")

def main():
    pkgs = [a for a in sys.argv[1:] if not a.startswith("--")]
    if not pkgs:
        print("usage: check-dsh-live.py <package> [<package> ...]", file=sys.stderr)
        sys.exit(2)

    # Fetch the search index once and count occurrences of each package.
    try:
        idx = fetch("https://www.dsh.so/search-index-core.json")
    except Exception as e:
        idx = ""
        print(f"(warn: could not fetch search-index-core.json: {e})")

    print(f"{'package':40s} {'artifact':>9s} {'idx_hits':>9s}  status")
    print("-" * 78)
    live = 0
    for pkg in pkgs:
        artifact = f"https://www.dsh.so/artifact/{pkg}/"
        code = http_status(artifact)
        hits = idx.count(f'"{pkg}"')
        is_live = code == 200
        if is_live:
            live += 1
        status = "LIVE ✅" if is_live else ("in-review ⏳" if code == 404 else f"? ({code})")
        print(f"{pkg:40s} {str(code):>9s} {hits:>9d}  {status}")
    print("-" * 78)
    print(f"live: {live}/{len(pkgs)}")
    if live < len(pkgs):
        print("(404 = still in maintainer review queue; this is normal for hours to 1-2 days)")

if __name__ == "__main__":
    main()
