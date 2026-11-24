#!/usr/bin/env python3
"""
Fetch download / indexing stats for the 7 published skills across channels.

Channels handled here (pure HTTP, no browser):
  - npm        : api.npmjs.org /downloads/point/{last-week,last-month}/<pkg>
  - SkillHub   : api.skillhub.cn /api/v1/skills/<slug>?namespace=user_95900c57
  - skills.sh  : skills.sh/yumingtao/agent-skills  (indexed-skill count only)
  - DSH        : artifact page HTTP status + search-index-core.json hit count

ClawHub is NOT handled here: it is an SPA and the owner-filter API params are
ignored, so it must be scraped via a rendered browser page. See SKILL.md.

Run:  python3 fetch-stats.py
Output: plain-text sections; safe to paste into a summary table.
"""
import json
import re
import sys
import urllib.parse
import urllib.request

UA = "channel-stats/1.0 (+https://github.com/yumingtao/agent-skills)"
TIMEOUT = 30

# The 7 published skills, in display order. key = short slug used everywhere;
# npm pkg and skillhub slug both derived from it.
SKILLS = [
    "diagram-generator",
    "clarify-before-acting",
    "insight-challenge",
    "workflow-skill-designer",
    "defect-detective",
    "session-retrospective",
    "skill-maintainer",
]
NPM_PKG = lambda s: f"yumingtao-{s}"
SH_SLUG = lambda s: f"yumingtao-{s}"
SH_NAMESPACE = "user_95900c57"
SH_BASE = "https://api.skillhub.cn"
DSH_PKG = lambda s: f"yumingtao-{s}"


def _get(url):
    req = urllib.request.Request(url, headers={"User-Agent": UA})
    with urllib.request.urlopen(req, timeout=TIMEOUT) as r:
        return r.read()


def _get_json(url):
    return json.loads(_get(url))


def _http_code(url):
    req = urllib.request.Request(url, method="HEAD", headers={"User-Agent": UA})
    try:
        with urllib.request.urlopen(req, timeout=TIMEOUT) as r:
            return r.status
    except urllib.error.HTTPError as e:
        return e.code
    except Exception:
        return -1


def section(title):
    print()
    print("=" * 70)
    print(title)
    print("=" * 70)


def fetch_npm():
    section("NPM (api.npmjs.org) — last-week / last-month downloads")
    tw = tm = 0
    for s in SKILLS:
        pkg = NPM_PKG(s)
        row = {}
        for period in ("last-week", "last-month"):
            try:
                d = _get_json(
                    f"https://api.npmjs.org/downloads/point/{period}/"
                    f"{urllib.parse.quote(pkg)}"
                )
                row[period] = d.get("downloads")
            except Exception as e:
                row[period] = f"ERR:{e}"
        try:
            tw += int(row["last-week"])
        except (TypeError, ValueError):
            pass
        try:
            tm += int(row["last-month"])
        except (TypeError, ValueError):
            pass
        print(f"  {pkg:36s} last-week={str(row['last-week']):>6}  "
              f"last-month={str(row['last-month']):>6}")
    print(f"  {'TOTAL':36s} last-week={tw:>6}  last-month={tm:>6}")
    # root package is private -> expect 404
    try:
        _get_json("https://api.npmjs.org/downloads/point/last-month/"
                  "@yumingtao/agent-skills")
        root = "unexpectedly public!"
    except urllib.error.HTTPError as e:
        root = f"{e.code} (private, expected)"
    except Exception as e:
        root = f"ERR:{e}"
    print(f"  [root @yumingtao/agent-skills last-month = {root}]")


def fetch_skillhub():
    section(f"SkillHub (api.skillhub.cn, namespace={SH_NAMESPACE})")
    total = 0
    for s in SKILLS:
        slug = SH_SLUG(s)
        url = (f"{SH_BASE}/api/v1/skills/{urllib.parse.quote(slug)}"
               f"?namespace={SH_NAMESPACE}")
        try:
            d = _get_json(url)
            sk = d.get("skill") or {}
            stats = (sk.get("stats") or {}) if isinstance(sk, dict) else {}
            # NOTE: API 'installs' field is always 0; the on-page install count
            # is the 'downloads' field under skill.stats.
            downloads = stats.get("downloads", 0)
            installs = stats.get("installs", 0)
            ver = (d.get("latestVersion") or {}).get("version", "?")
            try:
                total += int(downloads)
            except (TypeError, ValueError):
                pass
            print(f"  {slug:36s} downloads={str(downloads):>5}  "
                  f"installs={str(installs):>4}  ver={ver}")
        except Exception as e:
            print(f"  {slug:36s} ERR: {e}")
    print(f"  {'TOTAL (downloads)':36s} {total}")
    print("  (note: SkillHub 'installs' field reads 0; page count = downloads)")


def fetch_skills_sh():
    section("skills.sh (indexed-skill count only)")
    try:
        html = _get("https://skills.sh/yumingtao/agent-skills").decode(
            "utf-8", "replace")
        slugs = set(re.findall(r"/yumingtao/agent-skills/([a-z0-9-]+)", html))
        slugs.discard("opengraph-image")  # static asset, not a skill
        print(f"  indexed skills: {len(slugs)}")
        for slug in sorted(slugs):
            print(f"    - {slug}")
        print("  (skills.sh does not expose per-skill download counts publicly)")
    except Exception as e:
        print(f"  ERR: {e}")


def fetch_dsh():
    section("DSH (artifact pages + search index)")
    live = 0
    for s in SKILLS:
        pkg = DSH_PKG(s)
        code = _http_code(f"https://www.dsh.so/artifact/{pkg}/")
        status = "LIVE" if code == 200 else (
            "404" if code == 404 else f"HTTP {code}")
        if code == 200:
            live += 1
        print(f"  {pkg:36s} {status}")
    try:
        idx = _get("https://www.dsh.so/search-index-core.json").decode(
            "utf-8", "replace")
        hits = sum(idx.count(DSH_PKG(s)) for s in SKILLS)
        root = idx.count("agent-skills-3")
        print(f"  search-index yumingtao-* hits : {hits}")
        print(f"  root agent-skills-3 in index  : {root}")
    except Exception as e:
        print(f"  search-index ERR: {e}")
    print(f"  sub-packages live: {live}/7  "
          f"(ok:true submissions go to a maintainer review queue before "
          f"artifact pages are generated)")


def main():
    print("channel-stats fetch — data sources queried live.")
    errors = []
    for fn in (fetch_npm, fetch_skillhub, fetch_skills_sh, fetch_dsh):
        try:
            fn()
        except Exception as e:
            errors.append(f"{fn.__name__}: {e}")
            print(f"  [section {fn.__name__} failed: {e}]")
    if errors:
        print()
        print("ERRORS:", "; ".join(errors))
        sys.exit(1)


if __name__ == "__main__":
    main()
