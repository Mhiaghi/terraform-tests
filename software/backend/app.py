from flask import Flask, request, jsonify
from flask_cors import CORS
import db

app = Flask(__name__)
CORS(app)

@app.route('/login', methods = ["POST"])
def login():
    data = request.get_json()
    name = data.get("username")
    password = data.get("password")
    user = db.select_user(name)
    if user and user[1] == name and user[2] == password:
        return jsonify({"message": f"Bienvenido {name}, el login fue exitoso"})
    else:
        return jsonify({"message": "Credenciales inválidas"})

@app.route('/signin', methods = ["POST"])
def signin():
    data = request.get_json()
    name = data.get("username")
    password = data.get("password")
    mail = data.get("mail")
    user = db.select_user(name)
    if user:
        return jsonify({"message": f"El usuario {name} ya existe"})
    else:
        db.add_user(name, password, mail)
        return jsonify({"message": f"Usuario {name} creado exitosamente"})
