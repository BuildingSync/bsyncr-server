"""
BuildingSync®, Copyright (c) Alliance for Sustainable Energy, LLC, and other contributors.
See also https://github.com/BuildingSync/bsyncr-server/blob/main/LICENSE.txt
"""

from flask.cli import FlaskGroup

from bsyncr_server.main import app


cli = FlaskGroup(app)
if __name__ == "__main__":
    cli()
