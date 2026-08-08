#!/usr/bin/env python3
"""Minimal MCP streamable-HTTP client for the local Pixso MCP server."""
import json
import sys
import urllib.request

ENDPOINT = "http://127.0.0.1:3667/mcp"
SESSION_FILE = "/tmp/pixso_session.txt"


def get_session():
    try:
        with open(SESSION_FILE) as f:
            return f.read().strip()
    except FileNotFoundError:
        return None


def save_session(sid):
    with open(SESSION_FILE, "w") as f:
        f.write(sid)


def rpc(method, params=None, timeout=600):
    body = {"jsonrpc": "2.0", "id": 100, "method": method}
    if params is not None:
        body["params"] = params
    data = json.dumps(body).encode()
    headers = {
        "Content-Type": "application/json",
        "Accept": "application/json, text/event-stream",
    }
    sid = get_session()
    if sid:
        headers["Mcp-Session-Id"] = sid
    req = urllib.request.Request(ENDPOINT, data=data, headers=headers)
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            sid = resp.headers.get("mcp-session-id")
            if sid:
                save_session(sid)
            raw = resp.read().decode("utf-8", errors="replace")
    except urllib.error.HTTPError as e:
        return {"_http_error": e.code, "_body": e.read().decode("utf-8", errors="replace")}
    except Exception as e:  # noqa: BLE001
        return {"_error": str(e)}

    # SSE stream: lines "data: {...}"
    for line in raw.splitlines():
        line = line.strip()
        if line.startswith("data:"):
            try:
                msg = json.loads(line[5:].strip())
            except json.JSONDecodeError:
                continue
            if "result" in msg:
                return msg["result"]
            if "error" in msg:
                return {"_rpc_error": msg["error"]}
    try:
        return json.loads(raw)
    except json.JSONDecodeError:
        return {"_raw": raw[:4000]}


def main():
    if len(sys.argv) < 2:
        print("usage: pixso_mcp.py <tool-name> [json-args] | pixso_mcp.py code_to_design --html <file>")
        sys.exit(2)
    tool = sys.argv[1]
    if tool == "code_to_design" and len(sys.argv) == 4 and sys.argv[2] == "--html":
        with open(sys.argv[3], encoding="utf-8") as f:
            args = {"htmlStr": f.read()}
    else:
        args = json.loads(sys.argv[2]) if len(sys.argv) > 2 else {}
    result = rpc("tools/call", {"name": tool, "arguments": args})
    if isinstance(result, dict) and "content" in result:
        # MCP tool result: flatten text content for readability
        parts = []
        for item in result["content"]:
            if item.get("type") == "text":
                parts.append(item["text"])
            else:
                parts.append(json.dumps(item, ensure_ascii=False))
        print("\n".join(parts))
        sys.exit(0)
    print(json.dumps(result, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
