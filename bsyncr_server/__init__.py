
from io import BytesIO
import json
from os import path
import subprocess
import tempfile
import zipfile

from tools.validate_sch import validate_schematron

from flask import Flask, jsonify, send_file, request


app = Flask(__name__)
R_SCRIPT_PATH = '/usr/src/app/bsyncr_server/lib/bsyncRunner.r'
SCHEMATRON_FILE_PATH = '/usr/src/schematron/bsyncr_schematron.sch'
INPUT_FILE_PATH = '/tmp/input.xml'
OUTPUT_FILENAMES = ['result.xml', 'plot.png']
ERROR_FILENAME = 'error.json'
MODEL_CHOICES = ['SLR', '3PC', '3PH', '4P']


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

    model_type = request.args.get('model_type')
    if model_type is None:
        return json_error(400, f'Invalid value for `model_type` query parameter. '
                               f'Must provide one of the following: {", ".join(MODEL_CHOICES)}')

    with tempfile.TemporaryDirectory() as tmpdirname:
        completed_process = subprocess.run(
            ["Rscript", R_SCRIPT_PATH, INPUT_FILE_PATH, model_type, tmpdirname],
        )

        if completed_process.returncode != 0:
            error_filepath = f'{tmpdirname}/{ERROR_FILENAME}'
            if not path.exists(error_filepath):
                raise Exception(f'Expected to find error json at "{error_filepath}"')
            with open(error_filepath, 'r') as f:
                r_error = json.load(f)
                return json_error(500, f'Unexpected error from bsyncr script: {r_error["message"]}')

        zip_file = BytesIO()
        with zipfile.ZipFile(zip_file, 'w') as zf:   
            for filename in OUTPUT_FILENAMES:
                zf.write(f'{tmpdirname}/{filename}', arcname=filename)

        zip_file.seek(0)
        return send_file(zip_file, attachment_filename='bsyncr.zip')
