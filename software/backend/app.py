from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

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
    mail = data.get("mail")
    return jsonify({"message": f"Hola {name}, el signin esta funcionando con la pass {password} y el correo {mail}"})