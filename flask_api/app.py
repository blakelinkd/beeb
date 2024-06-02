import time
from flask import Flask, request, jsonify
import random

app = Flask(__name__)

# List of 90s video games
games = [
    "Super Mario 64",
    "The Legend of Zelda: Ocarina of Time",
    "Final Fantasy VII",
    "Doom",
    "Sonic the Hedgehog",
    "Street Fighter II"
]

@app.route('/', methods=['POST'])
def respond():
    data = request.get_json()
    if 'message' in data:
        chosen_game = random.choice(games)
        response = f"I like {chosen_game}!"
        time.sleep(2.5)
        return jsonify({"text": response})
    else:
        return jsonify({"error": "No message provided"}), 400

if __name__ == '__main__':
    # Run the app on host '0.0.0.0' to accept connections from any IP
    app.run(debug=True, host='0.0.0.0')
