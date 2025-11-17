# scripts/fetch_wakatime.py

import os
import requests
import json

# Récupère la clé API depuis les "Secrets" de GitHub Actions.
# La variable 'WAKATIME_API_KEY' doit être configurée dans les paramètres de votre dépôt.
API_KEY = os.getenv('WAKATIME_API_KEY')

# URL de l'API pour les statistiques des 7 derniers jours.
# Remplacez 'current' par votre nom d'utilisateur WakaTime si nécessaire,
# mais 'current' fonctionne avec la clé API.
STATS_URL = 'https://wakatime.com/api/v1/users/current/stats/last_7_days'

# Chemin où sauvegarder le fichier JSON de sortie.
# Le script se trouve dans 'scripts/', donc on remonte d'un niveau ('..')
# pour aller dans 'assets/data/'.
OUTPUT_PATH = 'assets/data/wakatime_stats.json'

def fetch_and_save_stats():
    """
    Récupère les statistiques de WakaTime et les sauvegarde dans un fichier JSON.
    """
    if not API_KEY:
        print("Erreur: La variable d'environnement WAKATIME_API_KEY n'est pas définie.")
        # On quitte avec un code d'erreur pour que la GitHub Action échoue.
        exit(1)

    print(f"Appel à l'API WakaTime: {STATS_URL}")

    # On ajoute la clé API dans le header de la requête pour l'authentification.
    headers = {
        'Authorization': f'Bearer {API_KEY}'
    }

    try:
        # On exécute la requête GET. Le timeout est une bonne pratique.
        response = requests.get(STATS_URL, headers=headers, timeout=10)

        # Lève une exception si la requête a échoué (ex: 401, 404, 500).
        response.raise_for_status()

        print("Réponse de l'API reçue avec succès.")
        stats_data = response.json()

        # Crée les dossiers parents si ils n'existent pas.
        os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)

        # Ouvre le fichier de sortie en mode écriture ('w') et sauvegarde les données.
        # 'indent=4' formate le JSON pour qu'il soit lisible.
        with open(OUTPUT_PATH, 'w', encoding='utf-8') as f:
            json.dump(stats_data, f, ensure_ascii=False, indent=4)

        print(f"Les statistiques ont été sauvegardées avec succès dans: {OUTPUT_PATH}")

    except requests.exceptions.RequestException as e:
        print(f"Erreur lors de l'appel à l'API WakaTime: {e}")
        exit(1)

# Point d'entrée du script
if __name__ == "__main__":
    fetch_and_save_stats()
