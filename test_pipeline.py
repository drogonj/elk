import requests
import json
from datetime import datetime

url = "http://localhost:3055"
headers = {
    "Content-Type": "application/json",
    "Accept": "application/json"
}

log_data = {
    "timestamp": datetime.utcnow().isoformat() + "Z",
    "level": "INFO",
    "message": "Test message from Python",
    "service": "my_app",
    "extra_fields": {
        "user_id": 123,
        "action": "login"
    }
}

try:
    # Utilisez le paramètre json au lieu de data pour que requests gère automatiquement la sérialisation
    response = requests.post(url, headers=headers, json=log_data, timeout=5)
    response.raise_for_status()
    print(f"Success! Status Code: {response.status_code}, Response: {response.text}")
except requests.exceptions.RequestException as e:
    print(f"Error sending logs: {str(e)}")
    if hasattr(e, 'response') and e.response is not None:
        print(f"Response content: {e.response.text}")
