FROM python:3.12-slim-bullseye

# install R and other packages
RUN apt-get update \
    && apt-get -y install \
        build-essential \
        build-essential \
        r-base \
        r-base-dev \
        curl \
        git \
        libbz2-dev \
        libcurl4-openssl-dev \
        libfreetype6-dev \
        libjpeg-dev \
        libffi-dev \
        libfontconfig1-dev \
        libfribidi-dev \
        libgit2-dev \
        libharfbuzz-dev \
        liblzma-dev \
        libncurses5-dev \
        libpng-dev \
        libreadline-dev \
        libsqlite3-dev \
        libssl-dev \
        libtiff5-dev \
        libv8-dev \
        libxml2-dev \
        libxmlsec1-dev \
        libxslt1-dev \
        llvm \
        tk-dev \
        wget \
        xz-utils \
        zlib1g-dev \
        python3-dev && \
        rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-c"]


# Copy over the install packages script
COPY ./install_r_packages.R /tmp/install_r_packages.R

# Run the R package install script
RUN Rscript /tmp/install_r_packages.R \
    && rm -f /tmp/install_r_packages.R \
    && strip /usr/local/lib/R/site-library/*/libs/*.so

# set work directory
WORKDIR /usr/src/app

RUN mkdir /usr/src/schematron
RUN wget -O '/usr/src/schematron/bsyncr_schematron.sch' 'https://raw.githubusercontent.com/BuildingSync/bsyncr/develop/bsyncr_schematron.sch'

# set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV FLASK_APP=/usr/src/app/bsyncr_server/main.py

# install dependencies
RUN pip install --upgrade pip
COPY ./requirements.txt /usr/src/app/requirements.txt
RUN pip install -r requirements.txt

# copy project
COPY . /usr/src/app/

EXPOSE 5000

CMD ["python", "manage.py", "run", "-h", "0.0.0.0"]
