# pull official base image
FROM python:3.8.1-slim-buster

# install R and other packages
RUN apt-get update \
    && apt-get -y install \
        r-base r-base-dev libssl-dev libcurl4-openssl-dev libxml2-dev wget git libgit2-dev

SHELL ["/bin/bash", "-c"]

# setup R packages
RUN Rscript - <<< $'install.packages("devtools");'
RUN Rscript - <<< $'\n\
    library("devtools"); \n\
    devtools::install_github("ropensci/rnoaa@v1.3.4", upgrade="never");'
# prefetch weather station data so first request isn't terribly slow
RUN Rscript - <<< $'\n\
    library("rnoaa"); \n\
    rnoaa::ghcnd_stations();'
RUN Rscript - <<< $'\n\
    library("devtools"); \n\
    devtools::install_github("kW-Labs/nmecr", ref="0bb2b7746d96eeb78b12bf4a13a42f49b3518d35", upgrade="never");'
RUN Rscript - <<< $'\n\
    library("devtools"); \n\
    devtools::install_github("BuildingSync/bsyncr", ref="63da9648fe5351004f0eed484d7cf65dfbb456c7", upgrade="never");'

# set work directory
WORKDIR /usr/src/app

RUN mkdir /usr/src/schematron
RUN wget -O '/usr/src/schematron/bsyncr_schematron.sch' 'https://raw.githubusercontent.com/BuildingSync/bsyncr/develop/bsyncr_schematron.sch'

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

EXPOSE 5000

CMD ["python", "manage.py", "run", "-h", "0.0.0.0"]
