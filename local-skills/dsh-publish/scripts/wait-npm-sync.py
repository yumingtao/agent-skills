#!/usr/bin/env python3
"""
Wait until the npm CDN has fully synced one or more freshly-published packages:
the registry metadata must show NO `repository` field AND the tarball must be
downloadable (HTTP 200).

Why this matters: after `npm publish`, the registry metadata and the tarball
binary propagate to CDN edge nodes at different speeds. If you submit to DSH
before both are ready, the server-side re-fetch fails with a misleading
"The repository could not be re-fetched server-side" error.

Usage:
  python3 wait-npm-sync.py <package> [<package> ...]
  python3 wait-npm-sync.py yumingtao-clarify-before-acting yumingtao-insight-challenge

Polls every 30s until all packages are ready (or --timeout minutes elapsed).
"""
import sys, json, time, urllib.request, urllib.parse, urllib.error

POLL_INTERVAL = 30  # seconds
DEFAULT_TIMEOUT_MIN = 20

def fetch(url):
    req = urllib.request.Request(url, headers={"User-Agent": "wait-npm-sync/1.0"})
    with urllib.request.urlopen(req, timeout=30) as r:
        return r.read()

def check(pkg):
    """Return (ready: bool, info: str)."""
    try:
        meta = json.loads(fetch(f"https://registry.npmjs.org/{urllib.parse.quote(pkg)}"))
    except Exception as e:
        return False, f"metadata-ERR({e})"
    latest = meta.get("dist-tags", {}).get("latest")
    if not latest:
        return False, "no-latest"
    v = meta.get("versions", {}).get(latest, {})
    has_repo = "repository" in v
    tar_url = f"https://registry.npmjs.org/{pkg}/-/{pkg}-{latest}.tgz"
    try:
        req = urllib.request.Request(tar_url, method="HEAD",
                                      headers={"User-Agent": "wait-npm-sync/1.0"})
        with urllib.request.urlopen(req, timeout=30) as tr:
            tar = tr.status
    except urllib.error.HTTPError as e:
        tar = e.code
    except Exception as e:
        tar = f"ERR({e})"
    ready = (not has_repo) and tar == 200
    info = f"latest={latest} repo={'Y' if has_repo else 'N'} tar={tar}"
    return ready, info

def main():
    pkgs = [a for a in sys.argv[1:] if not a.startswith("--")]
    if not pkgs:
        print("usage: wait-npm-sync.py <package> [<package> ...] [--timeout MIN]", file=sys.stderr)
        sys.exit(2)
    timeout_min = DEFAULT_TIMEOUT_MIN
    for a in sys.argv[1:]:
        if a.startswith("--timeout="):
            timeout_min = int(a.split("=", 1)[1])
    max_rounds = max(1, (timeout_min * 60) // POLL_INTERVAL)
    print(f"Waiting up to {timeout_min} min for {len(pkgs)} package(s) to sync on npm CDN")
    print(f"(ready = no repository field + tarball HTTP 200; poll every {POLL_INTERVAL}s)\n")
    for round_i in range(1, max_rounds + 1):
        print(f"[{time.strftime('%H:%M:%S')}] round {round_i}/{max_rounds}")
        all_ready = True
        for pkg in pkgs:
            ready, info = check(pkg)
            all_ready = all_ready and ready
            mark = "✅" if ready else "⏳"
            print(f"  {mark} {pkg:38s} {info}")
        if all_ready:
            print(f"\n[{time.strftime('%H:%M:%S')}] ALL {len(pkgs)} PACKAGE(S) READY — safe to submit to DSH")
            return
        if round_i < max_rounds:
            time.sleep(POLL_INTERVAL)
    print(f"\nTIMEOUT: not all ready after {timeout_min} min. Re-run later; do NOT submit to DSH yet.")
    sys.exit(1)

if __name__ == "__main__":
    main()
