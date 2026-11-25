#!/usr/bin/env python3
"""
DSH npm-only submitter. Replicates the official DSH checker / submit page
(plugin-submit.js) flow: fetch npm metadata, download the tarball, run the
client-side security scan, build the exact POST payload that the checker sends,
then POST to https://www.dsh.so/api/submit.

For npm-only entries (no repository resolved server-side), the entry id is the
slugified unscoped npm package name -> each package gets an independent DSH
entry. This is what lets monorepo sub-packages avoid being merged into the root
repository entry.

IMPORTANT: DSH server-side re-fetches the npm package's real metadata at submit
time and uses its actual `repository` field. Setting repository="" in this
payload does NOT make an entry independent — the published npm package must
already have no `repository` field (and the CDN must have synced). Use
wait-npm-sync.py first.

Usage:
  python3 dsh-submit.py <package>            # scan-only, prints scan + entry (no POST)
  python3 dsh-submit.py <package> --submit   # actually POST to /api/submit
"""
import sys, json, re, io, urllib.request, urllib.parse, urllib.error, tarfile, time

# ---- scan rules (from plugin-submit.js `q`) ----
# (id, severity, category, compiled pattern); patterns kept close to source
RULES = [
 ("eval","critical","code-exec", r"(?<!\.)\beval\s*\("),
 ("newFunction","critical","code-exec", r"\bnew\s+Function\s*\("),
 ("childProcess","warning","code-exec", r"\b(?:spawnSync|fork)\s*\(|\bspawn\s*\((?![\s\S]*\bshell\s*:\s*true)"),
 ("shellExec","critical","shell", r"\b(?:execSync|execFileSync|execFile)\s*\(|(?<!\.)\bexec\s*\("),
 ("spawnShell","critical","shell", r"\bspawn(?:Sync)?\s*\([^)]*shell\s*:\s*true"),
 ("pipeShell","critical","shell", r"\b(?:curl|wget|iwr)\b[^\n|]*\|\s*(?:sudo\s+)?(?:ba)?sh\b"),
 ("osSystem","critical","shell", r"\bos\.system\s*\("),
 ("subprocessShell","critical","shell", r"subprocess\.(?:Popen|call|run|check_call|check_output)\([^)]*shell\s*:\s*True"),
 ("installScript","critical","install", r'"(?:postinstall|preinstall|install|prepare)"\s*:\s*"[^"]*(?:curl|wget)'),
 ("exfilEndpoint","critical","network", r"(?:webhook\.site|requestbin\.(?:com|net)|pipe\.pw|pipedream\.net|beebotte)"),
 ("secretPem","critical","secrets", r"-----BEGIN (?:RSA |EC |OPENSSH |DSA )?PRIVATE KEY-----"),
 ("destructiveRm","critical","destructive", r"\brm\s+-rf\s+(?:/|~|\$HOME|C:\\|/[a-z]+/)"),
 ("chmodRoot","critical","destructive", r"\bchmod\s+-R\s777\s+[/\.]"),
 ("sshWrite","critical","destructive", r"\.ssh[/\\](?:authorized_keys|id_rsa|id_ed25519)"),
 ("mining","warning","mining", r"(?:xmrig|nicehash|cryptonight|ethminer|minerd|stratum\+tcp|supportxmr)"),
 ("remoteImport","warning","network", r"\b(?:import\s*\(|require\s*\()\s*['\"`]https?:"),
 ("fsWrite","warning","files", r"\bfs\.(?:writeFile|writeFileSync|appendFile|appendFileSync|createWriteStream)"),
 ("base64Decode","warning","obfuscation", r"\bbase64\s+(?:-d|--decode)\b|\[Convert\]::FromBase64String"),
 ("curlDownload","warning","network", r"\b(?:curl|wget|iwr|Invoke-WebRequest)\b[^\n]*(?:\s-o\s|\s--output\s)"),
 ("envAccess","info","env", r"\bprocess\.env\b"),
 ("cookieAccess","info","browser", r"document\.cookie"),
 ("localStorageAccess","info","browser", r"\blocalStorage\b"),
 ("fetchNet","info","network", r"\b(?:fetch|axios|XMLHttpRequest|WebSocket)\s*\("),
 ("windowOpen","info","browser", r"window\.open\s*\("),
]
RULE_RE = [(rid, sev, cat, re.compile(pat, re.I)) for (rid, sev, cat, pat) in RULES]

DOC_EXT = re.compile(r"\.(md|markdown|txt|rst|html?|yml|yaml|json|toml|lock|log)$", re.I)
CODE_EXT = re.compile(r"\.(js|mjs|cjs|ts|tsx|jsx|py|sh|bash|zsh|ps1)$", re.I)
MAX_FILE = 400000
MAX_LINES_PER_FILE = 3
MAX_FINDINGS = 250
# dev-only paths (downgrade critical->warning, warning->info)
DEV_PATH = re.compile(r"(?:^|/)(?:scripts?|tests?|__tests__|specs?|tools?|benchmarks?|dev|examples?)", re.I)
DEV_CATS = {"code-exec","shell","install","obfuscation","files","env","browser"}
SEV_DOWN = {"critical":"warning","warning":"info","info":"info"}

def slugify(s):
    return re.sub(r"[^a-z0-9]+","-", s.lower()).strip("-")

def fetch_json(url):
    req = urllib.request.Request(url, headers={"User-Agent":"dsh-submit/1.0"})
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.loads(r.read().decode())

def npm_meta(pkg):
    d = fetch_json(f"https://registry.npmjs.org/{urllib.parse.quote(pkg)}")
    latest = d["dist-tags"]["latest"]
    v = d["versions"][latest]
    return {
        "name": v["name"], "version": latest,
        "description": v.get("description",""),
        "license": v.get("license"),
        "author": v.get("author"),
        "homepage": v.get("homepage"),
        "repository": v.get("repository"),
        "tarball": v["dist"]["tarball"],
        "publishedAt": d.get("time",{}).get(latest),
    }

def download_tarball(url):
    req = urllib.request.Request(url, headers={"User-Agent":"dsh-submit/1.0"})
    with urllib.request.urlopen(req, timeout=60) as r:
        data = r.read()
    return data

def extract_files(tarbytes):
    """Return dict path->text for text files in the tarball (strip package/ prefix)."""
    files = {}
    tf = tarfile.open(fileobj=io.BytesIO(tarbytes), mode="r:gz")
    for m in tf.getmembers():
        if not m.isfile(): continue
        name = m.name
        # strip leading "<pkg>/" or "package/"
        if "/" in name:
            name = name.split("/",1)[1]
        if not name: continue
        try:
            raw = tf.extractfile(m).read()
        except Exception:
            continue
        if len(raw) > MAX_FILE: continue
        try:
            text = raw.decode("utf-8", errors="replace")
        except Exception:
            continue
        files[name] = text
    return files

def scan(files):
    findings = []
    counts = {"critical":0,"warning":0,"info":0}
    files_scanned = 0
    capped = False
    rules_checked = set()
    for path in sorted(files):
        content = files[path]
        files_scanned += 1
        is_doc = bool(DOC_EXT.search(path))
        lines = content.split("\n")
        for rid, sev, cat, rx in RULE_RE:
            if is_doc:
                if cat in ("code-exec","shell","install","obfuscation","files","secrets","destructive","mining"):
                    continue
            rules_checked.add(rid)
            hit = 0
            for li, line in enumerate(lines):
                if hit >= MAX_LINES_PER_FILE: break
                if len(line) > 2000: continue
                if rx.search(line):
                    hit += 1
                    d = sev
                    if DEV_PATH.search(path) and cat in DEV_CATS:
                        d = SEV_DOWN[d]
                    f = {"ruleId":rid,"severity":d,"category":cat,
                         "message":rid,"file":path,"line":li+1,
                         "snippet":line.strip()[:140]}
                    if len(findings) < MAX_FINDINGS:
                        findings.append(f); counts[d]+=1
                    else:
                        capped = True
    fail_cats = {"secrets","network","destructive","mining"}
    has_critical_failcat = any(x["severity"]=="critical" and x["category"] in fail_cats for x in findings)
    has_mining = any(x["category"]=="mining" for x in findings)
    has_critical = counts["critical"]>0
    if has_critical_failcat or has_mining: verdict="fail"
    elif (has_critical and not has_critical_failcat and not has_mining) or counts["warning"]>0: verdict="warn"
    else: verdict="pass"
    return {"verdict":verdict,"counts":counts,"findings":findings,
            "filesScanned":files_scanned,"capped":capped,"rulesChecked":len(rules_checked)}

def dsh_manifest_type(pkg_json_text):
    try:
        d = json.loads(pkg_json_text)
    except Exception:
        return None
    dsh = d.get("dsh")
    if not isinstance(dsh, dict): return None
    if dsh.get("bundle"): return "bundle"
    if dsh.get("profile") or dsh.get("client"): return "client"
    return None

def build_entry(meta, files, scan_result):
    name = meta["name"]
    unscoped = name.split("/")[-1]
    id_ = slugify(unscoped) or "plugin"
    pkgjson = files.get("package.json","")
    manifest = dsh_manifest_type(pkgjson)
    lic = meta.get("license") or "NOASSERTION"
    if isinstance(lic, dict): lic = lic.get("type","NOASSERTION")
    author = meta.get("author")
    author_name = None
    if isinstance(author, dict): author_name = author.get("name")
    elif isinstance(author, str): author_name = author
    scope = name[1:name.index("/")] if name.startswith("@") and "/" in name else None
    homepage = meta.get("homepage")
    registry_url = f"https://www.npmjs.com/package/{name}"
    doc_url = homepage or registry_url
    published = meta.get("publishedAt")
    now = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
    entry = {
        "id": id_,
        "name": name,
        "description": (meta.get("description") or "")[:300],
        "repository": None,
        "author": {"name": author_name or scope or unscoped, "github": None, "avatar": None},
        "license": lic,
        "category": "tool",
        "status": "unverified",
        "declaredCompatibility": "not stated",
        "verifiedVersions": [],
        "lastVerifiedAt": None,
        "installCommand": None,
        "npm": {"packageName": name, "registryUrl": registry_url},
        "documentationUrl": doc_url,
        "stars": 0, "forks": 0,
        "lastCommitAt": published or now,
        "indexedAt": now, "updatedAt": now,
        "source": "npm-registry",
        "dshManifest": manifest,
        "topics": [],
    }
    return entry

def build_payload(meta, files):
    sr = scan(files)
    entry = build_entry(meta, files, sr)
    now = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
    payload = {
        "entry": entry,
        "repository": "",
        "npmPackage": meta["name"],
        "name": meta["name"],
        "formatPass": True,
        "generatedAt": now,
        "headCommitSha": None,
        "scan": {
            "verdict": sr["verdict"],
            "filesScanned": sr["filesScanned"],
            "counts": sr["counts"],
            "findings": [{"severity":f["severity"],"file":f["file"],"line":f["line"],"message":f["message"]} for f in sr["findings"][:20]],
        },
    }
    return payload, sr

def submit(payload):
    data = json.dumps(payload).encode()
    req = urllib.request.Request("https://www.dsh.so/api/submit", data=data,
        headers={"Content-Type":"application/json","User-Agent":"dsh-submit/1.0"}, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            body = r.read().decode()
            return r.status, body
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode()

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("usage: dsh-submit.py <package> [--submit]", file=sys.stderr)
        sys.exit(2)
    pkg = sys.argv[1]
    do_submit = "--submit" in sys.argv
    meta = npm_meta(pkg)
    print(f"npm: {meta['name']}@{meta['version']}  repository={meta['repository']}  tarball={meta['tarball']}")
    tar = download_tarball(meta["tarball"])
    files = extract_files(tar)
    print(f"extracted {len(files)} files")
    payload, sr = build_payload(meta, files)
    print(f"\nSCAN verdict={sr['verdict']} counts={sr['counts']} filesScanned={sr['filesScanned']} rulesChecked={sr['rulesChecked']}")
    if sr["findings"]:
        for f in sr["findings"][:20]:
            print(f"  [{f['severity']}] {f['ruleId']} {f['file']}:{f['line']}  {f['snippet'][:60]}")
    e = payload["entry"]
    print(f"\nENTRY id={e['id']} name={e['name']} source={e['source']} dshManifest={e['dshManifest']}")
    print(f"      (id should be the package name, NOT 'agent-skills'; source should be 'npm-registry')")
    if do_submit:
        print("\n>>> SUBMITTING...")
        status, body = submit(payload)
        print(f"HTTP {status}: {body}")
    else:
        print("\n(scan-only; pass --submit to POST)")
