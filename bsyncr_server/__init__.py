
import json
from os import path
import subprocess

from tools.validate_sch import validate_schematron

from flask import Flask, jsonify, send_file, request


app = Flask(__name__)
R_SCRIPT_PATH = '/usr/src/app/bsyncr_server/lib/bsyncRunner.r'
SCHEMATRON_FILE_PATH = '/usr/src/schematron/bsyncr_schematron.sch'
INPUT_FILE_PATH = '/tmp/input.xml'
ERROR_FILE_PATH = '/usr/src/app/output/error.json'
OUTPUT_FILE_PATH = '/usr/src/app/output/test1.xml'


def json_error(status_code, detail):
    return {
        'errors': [
            {
                'status': str(status_code),
                'detail': detail
            }
        ]
    }, status_code


@app.route("/", methods=['POST'])
def root():
    if 'file' not in request.files:
        return json_error(400, 'No file in request')
    uploaded_file = request.files['file']

    uploaded_file.save(INPUT_FILE_PATH)
    try:
        errors = validate_schematron(SCHEMATRON_FILE_PATH, INPUT_FILE_PATH)
    except Exception as e:
        print(e)
        return json_error(400, 'Failed to run schematron. Is your XML well-formed?')

    if errors:
        def format_failure(failure):
            return f'line {failure.line}: element {failure.element}: {failure.message}'
        json_errors = [
            {'detail': format_failure(error), 'status': '400'}
            for error in errors
        ]
        return {
            'errors': json_errors
        }, 400

    completed_process = subprocess.run(
        ["Rscript", R_SCRIPT_PATH, INPUT_FILE_PATH],
        capture_output=True,
    )
    if completed_process.returncode != 0:
        error_filepath = ERROR_FILE_PATH if path.exists(ERROR_FILE_PATH) else None
        if error_filepath is None:
            raise Exception(f'Expected to find error json at "{ERROR_FILE_PATH}"')
        with open(error_filepath, 'r') as f:
            r_error = json.load(f)
            return json_error(500, r_error['message'])

    output_filepath = OUTPUT_FILE_PATH if path.exists(OUTPUT_FILE_PATH) else None
    if output_filepath is None:
        raise Exception(f'Expected to find output xml at "{OUTPUT_FILE_PATH}"')

    return send_file(OUTPUT_FILE_PATH)
