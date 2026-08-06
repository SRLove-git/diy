#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Re-run design_to_code per batch and merge pix_base64_string.dart declarations."""
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
    if r.returncode != 0 or "codeEntries" not in r.stdout:
        raise RuntimeError((r.stderr or "")[:300] + r.stdout[-400:])
    return r.stdout


def fetch_base64(out):
    cm = re.search(r'"codeEntries":\s*(\[.*?\])\s*\n', out, re.S)
    for e in json.loads(cm.group(1)):
        if e["id"] == "pix_base64_string.dart":
            return urllib.request.urlopen(e["url"], timeout=180).read().decode("utf-8")
    return None


def main():
    decls = {}
    BATCH = 6
    for i in range(0, len(ORDER), BATCH):
        batch = ORDER[i:i + BATCH]
        guids = [MAPPING[k] for k in batch]
        try:
            out = call(guids)
            text = fetch_base64(out)
        except Exception as e:  # noqa: BLE001
            print("BATCH FAIL", batch[0], e)
            continue
        if not text:
            print("no base64 file in batch", i)
            continue
        n = 0
        for m in re.finditer(r'final String (imageStr_\w+) = ("(?:[^"\\]|\\.)*");', text):
            decls[m.group(1)] = f"final String {m.group(1)} = {m.group(2)};"
            n += 1
        print(f"batch {i // BATCH + 1}: +{n}")
    # verify coverage against references
    refs = set()
    for root_dir, _, files in os.walk(os.path.join(APP, "lib")):
        for f in files:
            if f.endswith(".dart"):
                src = open(os.path.join(root_dir, f), encoding="utf-8").read()
                refs.update(re.findall(r"\b(imageStr_\w+)\b", src))
    missing = sorted(r for r in refs if r not in decls)
    print("decls:", len(decls), "refs:", len(refs), "missing:", missing)
    body = "\n".join(decls[k] for k in sorted(decls)) + "\n"
    open(os.path.join(APP, "lib", "utils", "pix_base64_string.dart"), "w", encoding="utf-8").write(body)
    print("written", len(decls), "declarations")


if __name__ == "__main__":
    main()
