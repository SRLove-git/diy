#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Batch-convert Pixso screens to Flutter code, downloading pages, widgets and assets immediately."""
import json
import os
import re
import subprocess
import urllib.request

ROOT = "/Users/srlove/Documents/Code/diy-ui"
APP = os.path.join(ROOT, "app")
MAPPING = json.load(open("/tmp/pixso_ids.json"))
ORDER = list(MAPPING.keys())


def call(guids):
    args = json.dumps({"guids": guids, "clientFrameworks": "flutter"})
    r = subprocess.run(
        ["python3", "ui-design/source/pixso_mcp.py", "design_to_code", args],
        capture_output=True, text=True, cwd=ROOT,
    )
    if r.returncode != 0 or "pageEntries" not in r.stdout:
        raise RuntimeError((r.stderr or "")[:300] + r.stdout[-400:])
    return r.stdout


def parse_entries(out):
    pm = re.search(r'"pageEntries":\s*(\[.*?\])\s*\n', out, re.S)
    cm = re.search(r'"codeEntries":\s*(\[.*?\])\s*\n', out, re.S)
    return json.loads(pm.group(1)), json.loads(cm.group(1))


def grab(url):
    return urllib.request.urlopen(url, timeout=180).read()


def main():
    BATCH = 6
    ok = 0
    fails = []
    for i in range(0, len(ORDER), BATCH):
        batch = ORDER[i:i + BATCH]
        guids = [MAPPING[k] for k in batch]
        try:
            out = call(guids)
        except Exception as e:  # noqa: BLE001
            fails.append((batch[0], str(e)))
            print("CALL FAIL", batch[0], e)
            continue
        pages, codes = parse_entries(out)
        new_files = []
        for p in pages:
            gid = p["url"].rstrip("/").split("/")[-1]
            try:
                body = grab(p["url"])
                fp = os.path.join(APP, "lib", "pages", f"{gid}.dart")
                open(fp, "wb").write(body)
                new_files.append(fp)
            except Exception as e:  # noqa: BLE001
                fails.append((gid, str(e)))
        for e in codes:
            if not e.get("path"):
                continue
            try:
                body = grab(e["url"])
                fp = os.path.join(APP, e["path"])
                os.makedirs(os.path.dirname(fp), exist_ok=True)
                open(fp, "wb").write(body)
                new_files.append(fp)
            except Exception as e2:  # noqa: BLE001
                fails.append((e.get("id"), str(e2)))
        # assets referenced by this batch's files
        assets = set()
        for fp in new_files:
            src = open(fp, encoding="utf-8").read()
            for m in re.findall(r"http://localhost:\d+/assets/[^\"'\)]+", src):
                assets.add(m)
        for u in assets:
            name = "assets/" + u.split("/assets/")[1].replace("/", "_")
            try:
                data = grab(u)
                open(os.path.join(APP, name), "wb").write(data)
            except Exception as e:  # noqa: BLE001
                fails.append((u, str(e)))
                continue
            for fp in new_files:
                src = open(fp, encoding="utf-8").read()
                if u in src:
                    open(fp, "w", encoding="utf-8").write(
                        src.replace(f'"{u}"', f'"{name}"')
                    )
        ok += len(batch)
        print(f"batch {i // BATCH + 1}: ok={len(batch)} assets={len(assets)}")
    print("TOTAL", ok, "fails", len(fails), fails[:5])


if __name__ == "__main__":
    main()
