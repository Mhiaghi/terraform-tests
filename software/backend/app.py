from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/login', methods = ["POST"])
def login():
    data = request.get_json()
    name = data.get("username")
    password = data.get("password")
    return jsonify({"message": f"Hola {name}, el login esta funcionando con la pass {password}"})

@app.route('/signin', methods = ["POST"])
def signin():
    data = request.get_json()
    name = data.get("username")
    password = data.get("password")
    return jsonify({"message": f"Hola {name}, el signin esta funcionando con la pass {password}"})