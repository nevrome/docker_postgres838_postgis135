# Docker image for PostgreSQL 8.3.8 with PostGIS 1.3.5

This image is very simple. It's not intended for new projects. Please use the [official postgres images](https://hub.docker.com/_/postgres/) or -- if you need postgis -- an up-to-date and well prepared implementation like the one from [mdillon](https://hub.docker.com/r/mdillon/postgis/). 

The abomination in this repository creates a badly crafted docker container with terribly outdated software (Ubuntu 12.04, PostgreSQL 8.3.8, PostGIS 1.3.5, etc.). I created it to deal with very old PostGIS enabled Postgres databases. In my usecase the work necessary to port the databases to new versions would be disproportionately high. I therefore decided to craft this container with the old environment. I share it here to provide people in the same situation with a fast solution.

## Pull image from dockerhub and run container

```
docker run \
-e POSTGRES_USER="docker" \
-e POSTGRES_PASSWORD="'docker'" \
-p 5432:5432 \
--name pgres8 \
-dit nevrome/docker_postgres838_postgis135 /bin/bash
```

## Build image and run container from scratch

```
docker build -t docker_postgres838_postgis135 .

docker run \
-e POSTGRES_USER="docker" \
-e POSTGRES_PASSWORD="'docker'" \
-p 5432:5432 \
--name pgres8 \
-dit docker_postgres838_postgis135 /bin/bash
```

## Enable postgis for individual databases
See [here](http://www.postgis.org/download/postgis-1.3.5.pdf) for reference.

```
docker exec -it pgres8 /bin/bash
```

```
createlang plpgsql [yourdatabase]
psql -d [yourdatabase] -U [youruser] -f /usr/local/pgsql/share/lwpostgis.sql
psql -d [yourdatabase] -U [youruser] -f /usr/local/pgsql/share/spatial_ref_sys.sql
```