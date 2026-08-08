"""Assemble all screens into batches and dump to batches/."""
import json
import os

from screens_community import community_screen
from screens_reels import reels_screen
from screens_chat import chat_list_screen, single_chat_screen, group_chat_screen
from screens_profile import my_profile_screen, other_profile_screen
from screens_spec import tokens_page, states_page, motion_notes_page


def build_all():
    plan = [
        ("community-light", community_screen("light", 0, 0)),
        ("community-dark", community_screen("dark", 430, 0)),
        ("reels-light", reels_screen("light", 860, 0)),
        ("reels-dark", reels_screen("dark", 1290, 0)),
        ("chat-list-light", chat_list_screen("light", 0, 900)),
        ("chat-list-dark", chat_list_screen("dark", 430, 900)),
        ("chat-single-light", single_chat_screen("light", 860, 900)),
        ("chat-single-dark", single_chat_screen("dark", 1290, 900)),
        ("chat-group-light", group_chat_screen(0, 1800)),
        ("profile-mine-light", my_profile_screen("light", 430, 1800)),
        ("profile-mine-dark", my_profile_screen("dark", 860, 1800)),
        ("profile-other-light", other_profile_screen("light", 1290, 1800)),
        ("profile-other-dark", other_profile_screen("dark", 0, 2700)),
        ("tokens", tokens_page(430, 2700)),
        ("states", states_page(1290, 2700)),
        ("motion", motion_notes_page(1600, 2700)),
    ]
    os.makedirs("batches", exist_ok=True)
    manifest = []
    for name, batches in plan:
        entry = {"name": name, "batches": []}
        for bi, b in enumerate(batches):
            fn = f"batches/{name}_{bi}.json"
            with open(fn, "w", encoding="utf-8") as f:
                json.dump({"ops": "".join(b["ops"])}, f, ensure_ascii=False)
            entry["batches"].append(fn)
        manifest.append(entry)
    with open("batches/manifest.json", "w", encoding="utf-8") as f:
        json.dump(manifest, f, ensure_ascii=False, indent=1)
    total = sum(len(b) for _, b in plan)
    print(f"{len(plan)} screens, {total} batches written")


if __name__ == "__main__":
    build_all()

