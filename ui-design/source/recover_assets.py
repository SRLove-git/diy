#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Re-export rasterized design nodes as local assets for the Flutter pages."""
import json
import os
import re
import subprocess

ROOT = "/Users/srlove/Documents/Code/diy-ui"
APP = os.path.join(ROOT, "app")
MAPPING = json.load(open("/tmp/pixso_ids.json"))
REV = {v: k for k, v in MAPPING.items()}

NAME_RULES = [
    (re.compile(r"^divbtnbtnsm$"), "div.btn btn-sm"),
    (re.compile(r"^divcamtool\d*$"), "div.camtool"),
    (re.compile(r"^divcardcardpad\d*$"), "div.card card-pad"),
    (re.compile(r"^divphotop2$"), "div.photo p2"),
    (re.compile(r"^divrowgap3\d*$"), "div.row gap3"),
    (re.compile(r"^divtabwrap\d*$"), "div.tabwrap"),
    (re.compile(r"^spanchipsm$"), "span.chip sm"),
    (re.compile(r"^div$"), "div"),
    (re.compile(r"^margin_wrapper\d+$"), None),  # exact name
]


def tool(name, args):
    r = subprocess.run(
        ["python3", "ui-design/source/pixso_mcp.py", name, json.dumps(args)],
        capture_output=True, text=True, cwd=ROOT,
    )
    return r.stdout


def node_name_for(filename):
    base = filename[:-4] if filename.endswith(".png") else filename
    for rx, mapped in NAME_RULES:
        if rx.match(base):
            return mapped if mapped else base
    return base


def find_node(screen_guid, node_name):
    out = tool("query_nodes", {
        "parentId": screen_guid,
        "searchDepth": 8,
        "patterns": [{"name": node_name}],
        "readDepth": 1,
    })
    try:
        rows = json.loads(out)
    except Exception:  # noqa: BLE001
        return None
    for r in rows:
        if r.get("type") in ("frame", "group", "rectangle", "ellipse", "line", "polygon", "path", "text"):
            return r["guid"]
    return None


def export_asset(screen_guid, filename):
    node_name = node_name_for(filename)
    guid = find_node(screen_guid, node_name)
    if not guid:
        return False, f"node '{node_name}' not found in {REV.get(screen_guid, screen_guid)}"
    out = tool("get_export_image", {
        "guid": guid,
        "exportSettings": {"imageType": 1, "constraint": {"type": 1, "value": 2}},
    })
    m = re.search(r"http://localhost:\d+/export/[^\s]+", out or "")
    if not m:
        return False, f"export failed for {node_name}"
    subprocess.run(["curl", "-sS", "-o", os.path.join(APP, "assets", filename), m.group(0)], check=True)
    return True, None


def main():
    os.makedirs(os.path.join(APP, "assets"), exist_ok=True)
    stats = {}
    for sub in ("pages", "custom_widget"):
        _process_dir(os.path.join(APP, "lib", sub), stats)
    ok = sum(1 for v in stats.values() if v == "ok")
    print("assets:", ok, "of", len(stats))
    for k, v in stats.items():
        if v != "ok":
            print("  ", k, "->", v)


def screen_for_node(gid):
    try:
        num = int(gid.split(":")[1])
    except Exception:  # noqa: BLE001
        return None
    best = None
    for s, g in MAPPING.items():
        try:
            n = int(g.split(":")[1])
        except Exception:  # noqa: BLE001
            continue
        if n <= num and (best is None or n > best[1]):
            best = (s, n)
    return MAPPING[best[0]] if best else None


def _process_dir(dirpath, stats):
    for f in sorted(os.listdir(dirpath)):
        if not f.endswith(".dart"):
            continue
        fp = os.path.join(dirpath, f)
        src = open(fp, encoding="utf-8").read()
        urls = re.findall(r"http://localhost:\d+/assets/[^\"'\)]+", src)
        if not urls:
            continue
        gid = f.replace(".dart", "")
        if gid.startswith("CustomWidget_"):
            gid = gid[len("CustomWidget_"):].replace("_", ":")
            screen_guid = screen_for_node(gid)
        elif gid == "Reels":
            gid = MAPPING["16-Reels"]
            screen_guid = gid
        elif gid.startswith("Frame_"):
            gid = gid[6:].replace("_", ":")
            screen_guid = gid
        else:
            screen_guid = None
        for u in set(urls):
            fn = u.split("/")[-1]
            while fn.endswith(".png"):
                fn = fn[:-4]
            fn += ".png"
            dst = os.path.join(APP, "assets", fn)
            if os.path.exists(dst):
                src = src.replace(f'"{u}"', f'"assets/{fn}"')
                stats.setdefault(fn, "ok")
                continue
            ok, err = export_asset(screen_guid, fn) if screen_guid else (False, "no guid")
            stats[fn] = "ok" if ok else err
            if ok:
                src = src.replace(f'"{u}"', f'"assets/{fn}"')
            else:
                print("FAIL", f, fn, err)
        open(fp, "w", encoding="utf-8").write(src)


if __name__ == "__main__":
    main()
