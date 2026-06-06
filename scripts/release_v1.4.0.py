#!/usr/bin/env python3
"""Create GitHub release for économ v1.4.0 and upload APK."""

import os
import json
import urllib.request
import mimetypes

REPO = "Paul-Carouge/econome"
TAG = "v1.4.0"
APK_PATH = "/home/atlas/econome/econome-v1.4.0.apk"

def get_token():
    env_path = os.path.expanduser("~/.hermes/.env")
    with open(env_path) as f:
        for line in f:
            if line.startswith("GITHUB_TOKEN="):
                return line.strip().split("=", 1)[1]
    raise Exception("GITHUB_TOKEN not found")

def api(method, path, data=None):
    token = get_token()
    url = f"https://api.github.com/repos/{REPO}/{path}"
    body = json.dumps(data).encode() if data else None
    req = urllib.request.Request(url, data=body, method=method)
    req.add_header("Authorization", f"token {token}")
    req.add_header("Accept", "application/vnd.github.v3+json")
    if body:
        req.add_header("Content-Type", "application/json")
    try:
        with urllib.request.urlopen(req) as resp:
            if resp.status in (201, 200, 204):
                text = resp.read()
                return json.loads(text) if text else {}
    except urllib.error.HTTPError as e:
        body = e.read().decode()
        if e.code == 404:
            return None
        print(f"HTTP {e.code}: {body}")
        raise

# ── Step 1: Delete old release if it exists ──
existing = api("GET", f"releases/tags/{TAG}")
if existing and existing.get("id"):
    print(f"Deleting old release #{existing['id']}")
    api("DELETE", f"releases/{existing['id']}")
    print("Deleted.")

# ── Step 2: Create release ──
release = api("POST", "releases", {
    "tag_name": TAG,
    "name": f"Économe v1.4.0",
    "body": (
        "## 🎯 v1.4.0 — Widgets multiples + Analyses\n\n"
        "### 📱 Nouveaux widgets (4 types)\n"
        "- **Compact** (2×1) : solde uniquement, grand format\n"
        "- **Budget** (4×1) : barre de progression + pourcentage\n"
        "- **Épargne** (4×1) : objectif d'épargne avec progrès\n"
        "- **Full** (4×1) : solde + budget + 3 transactions\n\n"
        "### 📊 Nouvel écran Analyses\n"
        "- Courbe d'évolution revenus/dépenses sur 6 mois\n"
        "- Statistiques du mois (nb transactions, moyenne, taux d'épargne)\n"
        "- Projections quotidiennes et fin de mois\n"
        "- Navigation accessible depuis la BottomNavBar\n\n"
        "### ⚙️ Améliorations\n"
        "- Mise à jour automatique de tous les widgets après chaque transaction\n"
        "- Réglages déplacés dans l'AppBar du Tableau de bord\n"
        "- Onglet Analyses dans la barre de navigation"
    ),
    "draft": False,
    "prerelease": False,
})
release_id = release["id"]
print(f"Release created: #{release_id}")

# ── Step 3: Upload APK ──
print("Uploading APK...")
upload_url = f"https://uploads.github.com/repos/{REPO}/releases/{release_id}/assets?name=econome-v1.4.0.apk"
token = get_token()

with open(APK_PATH, "rb") as f:
    apk_data = f.read()

req = urllib.request.Request(upload_url, data=apk_data, method="POST")
req.add_header("Authorization", f"token {token}")
req.add_header("Accept", "application/vnd.github.v3+json")
req.add_header("Content-Type", "application/vnd.android.package-archive")

with urllib.request.urlopen(req) as resp:
    result = json.loads(resp.read())
    print(f"APK uploaded: {result['browser_download_url']}")

print(f"\n✅ Release {TAG} publiée !")
print(f"https://github.com/{REPO}/releases/tag/{TAG}")
