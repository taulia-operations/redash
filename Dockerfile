FROM ubuntu:trusty
MAINTAINER Di Wu <diwu@yelp.com>

COPY . /opt/redash/current/

WORKDIR /opt/redash/current

ENV FILES_BASE_URL /opt/redash/current/setup/files/

# Ubuntu packages
RUN apt-get update && \
  apt-get install -y python-pip python-dev curl build-essential pwgen libffi-dev sudo git-core && \
  # Postgres client
  apt-get -y install libpq-dev postgresql-client && \
  # Additional packages required for data sources:
  apt-get install -y libssl-dev libmysqlclient-dev

# Users creation
RUN useradd --system --comment " " --create-home redash
RUN useradd --system --comment " " --create-home postgres

# Folders creation
RUN mkdir /opt/redash/logs && \
  mkdir -p /opt/redash/supervisord

# Pip requirements for all data source types
RUN pip install -U setuptools && \
  pip install -r requirements_all_ds.txt && \
  pip install -r requirements.txt && \
  pip install supervisor==3.1.2

# Get supervisord startup script
RUN cp $FILES_BASE_URL"supervisord_docker.conf" /opt/redash/supervisord/supervisord.conf

RUN cp $FILES_BASE_URL"redash_supervisord_init" /etc/init.d/redash_supervisord

# Fix permissions
RUN chown -R redash /opt/redash

# Expose ports
EXPOSE 5000
EXPOSE 9001

# Startup script
CMD bash /etc/init.d/redash_supervisord start
