# pull official base image
FROM python:3.8.1-slim-buster

# install R
RUN apt-get update \
    && apt-get -y install \
        r-base r-base-dev libssl-dev libcurl4-openssl-dev libxml2-dev

SHELL ["/bin/bash", "-c"]

# setup R packages
RUN Rscript - <<< $'\n\
    install.packages("devtools"); \n\
    library("devtools"); \n\
    devtools::install_github("kW-Labs/nmecr", upgrade="never"); \n\
    devtools::install_github("BuildingSync/bsyncr", upgrade="never");'

# set work directory
WORKDIR /usr/src/app

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV FLASK_APP /usr/src/app/bsyncr_server/__init__.py

# install dependencies
RUN pip install --upgrade pip
COPY ./requirements.txt /usr/src/app/requirements.txt
RUN pip install -r requirements.txt

# copy project
COPY . /usr/src/app/
COPY bsyncr_server/lib/bsyncRunner.r /usr/local/bin/bsyncRunner.r
RUN chmod +x /usr/local/bin/bsyncRunner.r

EXPOSE 5000

CMD ["python", "manage.py", "run", "-h", "0.0.0.0"]
