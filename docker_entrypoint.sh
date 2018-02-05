#!/usr/bin/env bash
set -e

#POSTGRES_USER="docker"
#POSTGRES_PASSWORD="'docker'"

su - postgres -c "
export PATH=$PATH:/usr/local/pgsql/bin &&\
echo \"export PATH=$PATH:/usr/local/pgsql/bin\" >> /home/postgres/.bashrc &&\
pg_ctl -D /usr/local/pgsql/data -l /usr/local/pgsql/data/logfile start &&\
psql -h 127.0.0.1 --command \"CREATE USER $POSTGRES_USER WITH SUPERUSER PASSWORD $POSTGRES_PASSWORD;\"
"

exec "$@";
