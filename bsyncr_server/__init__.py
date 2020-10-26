import subprocess

from flask import Flask, jsonify, send_file


app = Flask(__name__)


@app.route("/")
def hello_world():
    subprocess.call("/usr/local/bin/bsyncRunner.r")
    return send_file('/usr/src/app/output/test1.xml')
