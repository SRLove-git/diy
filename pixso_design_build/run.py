"""Post generated batches to the Pixso MCP server and record node ids."""
import json
import re
import sys
import time
import urllib.request

URL = "http://127.0.0.1:3667/mcp"


def rpc(session, msg_id, method, params=None):
    payload = {"jsonrpc": "2.0", "id": msg_id, "method": method}
    if params is not None:
        payload["params"] = params
    headers = {"Content-Type": "application/json",
               "Accept": "application/json, text/event-stream"}
    if session:
        headers["Mcp-Session-Id"] = session
    req = urllib.request.Request(URL, data=json.dumps(payload).encode(),
                                 headers=headers)
    resp = urllib.request.urlopen(req, timeout=180)
    data = resp.read().decode()
    for line in data.splitlines():
        if line.startswith("data: "):
            return json.loads(line[6:])
    return json.loads(data)


def init_session():
    res = rpc(None, 1, "initialize", {
        "protocolVersion": "2025-03-26",
        "capabilities": {},
        "clientInfo": {"name": "codex-builder", "version": "1.0"},
    })
    # re-request headers to get session id
    payload = {"jsonrpc": "2.0", "id": 1, "method": "initialize",
               "params": {"protocolVersion": "2025-03-26",
                          "capabilities": {},
                          "clientInfo": {"name": "codex-builder", "version": "1.0"}}}
    req = urllib.request.Request(URL, data=json.dumps(payload).encode(),
                                 headers={"Content-Type": "application/json",
                                          "Accept": "application/json, text/event-stream"})
    resp = urllib.request.urlopen(req, timeout=60)
    session = resp.headers.get("Mcp-Session-Id")
    rpc(session, 2, "notifications/initialized")
    return session


def call_tool(session, msg_id, name, arguments):
    res = rpc(session, msg_id, "tools/call",
              {"name": name, "arguments": arguments})
    if "error" in res:
        raise RuntimeError(f"RPC error: {res['error']}")
    text = ""
    for c in res.get("result", {}).get("content", []):
        text += c.get("text", "")
    return text


def call_tool_content(session, msg_id, name, arguments):
    res = rpc(session, msg_id, "tools/call",
              {"name": name, "arguments": arguments})
    if "error" in res:
        raise RuntimeError(f"RPC error: {res['error']}")
    return res.get("result", {}).get("content", [])


def parse_inserted(text):
    ids = re.findall(r"Inserted node `([0-9:]+)`", text)
    return ids


def main(manifest_path="batches/manifest.json", session=None):
    if session is None:
        session = init_session()
    manifest = json.load(open(manifest_path, encoding="utf-8"))
    results = {}
    msg_id = 100
    for entry in manifest:
        name = entry["name"]
        root_id = None
        for bi, fn in enumerate(entry["batches"]):
            ops = json.load(open(fn, encoding="utf-8"))["ops"]
            if root_id:
                ops = ops.replace("{{ROOT}}", root_id)
            msg_id += 1
            text = call_tool(session, msg_id, "apply_design", {"operations": ops})
            inserted = parse_inserted(text)
            if bi == 0:
                root_id = inserted[0] if inserted else None
            ok = "Successfully executed all operations" in text
            flags = ""
            if not ok:
                flags = " [WARN]"
                print(f"[{name}] batch {bi}: {text[:400]}", file=sys.stderr)
            print(f"[{name}] batch {bi}{flags}: inserted={inserted}")
            if "Validation failures" in text or "Potential issues" in text:
                print(f"    -> feedback: {text[-500:]}", file=sys.stderr)
            time.sleep(0.2)
        results[name] = root_id
    with open("batches/ids.json", "w", encoding="utf-8") as f:
        json.dump(results, f, ensure_ascii=False, indent=1)
    print("\nScreen root ids:")
    for k, v in results.items():
        print(f"  {k}: {v}")
    return results


if __name__ == "__main__":
    main()
