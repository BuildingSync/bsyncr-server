from flask.cli import FlaskGroup

from bsyncr_server.main import app


cli = FlaskGroup(app)
if __name__ == "__main__":
    cli()
