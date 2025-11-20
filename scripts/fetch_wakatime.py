import os
import json
import base64
import requests

# 1. Récupère la clé API de l'environnement
# C'est la variable fournie par GitHub Actions (WAKATIME_API_KEY: ***)
WAKATIME_API_KEY = os.environ.get('WAKATIME_API_KEY')
OUTPUT_FILE = 'assets/data/wakatime_stats.json'
API_URL = "https://wakatime.com/api/v1/users/current/stats/last_7_days"

if not WAKATIME_API_KEY:
    # Cette erreur ne devrait plus se produire si le secret est défini dans GitHub
    print("Erreur: La variable d'environnement WAKATIME_API_KEY n'est pas définie.")
    exit(1)

# --- Authentification WakaTime ---
# L'API WakaTime utilise l'Authentification Basique (Basic Authentication)
# Le token est généré à partir de la clé API, encodée en Base64.
# Format: 'Authorization: Basic <Base64 de la clé API>'
# WakaTime ne nécessite pas de mot de passe, donc nous encodons seulement la clé.
# Parfois, l'encodage est 'api_key:password', mais pour WakaTime, c'est souvent juste la clé.
# Le script standard WakaTime utilise l'en-tête 'Authorization' avec la clé encodée en Base64.

# Encodage de la clé API en Base64
# Note: La librairie 'requests' gère souvent Basic Auth plus facilement.
# Si le script utilise Basic Auth (méthode simple):
try:
    # Tente d'utiliser l'authentification de base de requests
    print(f"Appel à l'API WakaTime: {API_URL}")
    
    # Utilise la fonction auth=(user, password) où user est la clé API et password est vide
    response = requests.get(API_URL, auth=(WAKATIME_API_KEY, ''), timeout=10)

    # Vérifie si la requête a réussi (code 200 OK) ou échoué (401 Unauthorized)
    response.raise_for_status() 

    # 2. Traitement des données
    data = response.json()
    
    # 3. Sauvegarde dans un fichier JSON
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4)
    
    print(f"✅ Succès : Statistiques WakaTime enregistrées dans {OUTPUT_FILE}")

except requests.exceptions.HTTPError as err:
    # Capture le code 401 UNAUTHORIZED
    print(f"Erreur lors de l'appel à l'API WakaTime: {err}")
    # Relance l'erreur pour que GitHub Actions échoue
    exit(1)
except requests.exceptions.RequestException as e:
    print(f"Erreur de connexion à l'API WakaTime: {e}")
    exit(1)
