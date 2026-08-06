"""Screenshot all screens and save PNGs to previews/."""
import base64
import json
import os
import sys

from run import init_session, call_tool_content


def main():
    ids = json.load(open("batches/ids.json", encoding="utf-8"))
    session = init_session()
    os.makedirs("previews", exist_ok=True)
    msg_id = 1000
    for name, nid in ids.items():
        msg_id += 1
        try:
            content = call_tool_content(session, msg_id, "get_screenshot",
                                        {"guid": nid})
            img = None
            for c in content:
                if c.get("type") == "image":
                    img = c.get("data")
                elif c.get("type") == "text":
                    obj = json.loads(c["text"])
                    img = obj.get("base64") or obj.get("data")
            if not img:
                print(f"[{name}] no image")
                continue
            path = f"previews/{name}.png"
            with open(path, "wb") as f:
                f.write(base64.b64decode(img))
            print(f"[{name}] {path}")
        except Exception as e:
            print(f"[{name}] FAILED: {e}")


if __name__ == "__main__":
    main()
