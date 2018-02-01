# Docker image for PostgreSQL 8.3.8 with PostGIS 1.3.5

This image is very simple. It's not intended for new projects. Please use the [official postgres images](https://hub.docker.com/_/postgres/) or -- if you need postgis -- an up-to-date and well prepared implementation like the one from [mdillon](https://hub.docker.com/r/mdillon/postgis/). 

The abomination in this repository creates a badly crafted docker container with terribly outdated software (Ubuntu 12.04, PostgreSQL 8.3.8, PostGIS 1.3.5, etc.). I created it to deal with very old PostGIS enabled Postgres databases. In my usecase the work necessary to port the databases to new versions would be disproportionately high. I therefore decided to craft this container with the old environment. I share it here to provide people in the same situation with a fast solution.

## Build and run container
```
docker build -t nevrome/postgres_old:1.0 .

docker run \
-e POSTGRES_USER="docker" \
-e POSTGRES_PASSWORD="'docker'" \
-p 5432:5432 \
--name pgres \
-dit nevrome/postgres_old:1.0 /bin/bash 

docker exec -it pgres /bin/bash
```

## Enable postgis
See [here](http://www.postgis.org/download/postgis-1.3.5.pdf) for reference.

```
createlang plpgsql [yourdatabase]
psql -d [yourdatabase] -U [youruser] -f /usr/local/pgsql/share/lwpostgis.sql
psql -d [yourdatabase] -U [youruser] -f /usr/local/pgsql/share/spatial_ref_sys.sql
```