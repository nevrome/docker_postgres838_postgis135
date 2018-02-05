FROM ubuntu:12.04.5

MAINTAINER Clemens Schmid <clemens@nevrome.de>

# explicitly set user/group IDs
RUN groupadd -r postgres --gid=999 && useradd -r -m -d /home/postgres/ -s /bin/bash -g postgres --uid=999 postgres

# make the "en_US.UTF-8" locale so postgres will be utf-8 enabled by default
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# install software from package repos
RUN apt-get update && \
		apt-get install -y build-essential libreadline-dev zlib1g-dev flex bison libxml2-dev libxslt-dev libssl-dev clang libgeos-dev wget

# install postgres
RUN	wget --no-check-certificate https://ftp.postgresql.org/pub/source/v8.3.8/postgresql-8.3.8.tar.gz && \
		tar zxf postgresql-8.3.8.tar.gz && \
		cd postgresql-8.3.8 && \
		./configure LDFLAGS=-lstdc++ CFLAGS="-O1" CC=clang && \
		make && \
		make install && \
		cd .. && \
		rm postgresql-8.3.8.tar.gz && \
		rm -r postgresql-8.3.8

# setup directories and variables for postgres
RUN	mkdir /usr/local/pgsql/data && \
		chown postgres /usr/local/pgsql/data
RUN LD_LIBRARY_PATH=/usr/local/pgsql/lib:$LD_LIBRARY_PATH && \
		export LD_LIBRARY_PATH && \
		export PATH=/usr/local/pgsql/bin:$PATH

# install proj4
RUN	wget http://download.osgeo.org/proj/proj-4.6.0.tar.gz && \
		tar xzf proj-4.6.0.tar.gz && \
		cd proj-4.6.0 && \
		./configure && make clean && make && \
		make install && \
		ldconfig && \
		cd .. && \
		rm proj-4.6.0.tar.gz && \
		rm -r proj-4.6.0

# install postgis
RUN	LD_LIBRARY_PATH=/usr/local/pgsql/lib:$LD_LIBRARY_PATH && \
		export LD_LIBRARY_PATH && \
		export PATH=/usr/local/pgsql/bin:$PATH && \
		wget http://postgis.refractions.net/download/postgis-1.3.5.tar.gz && \
		tar zxf postgis-1.3.5.tar.gz && \
		cd postgis-1.3.5 && \
		./configure && \
		make && \
		make install && \
		cd .. && \
		rm postgis-1.3.5.tar.gz && \
		rm -r postgis-1.3.5

ENV PGDATA /usr/local/pgsql/data

# port
EXPOSE 5432

# further postgres settings and system test
USER postgres
ENV PATH="/usr/local/pgsql/bin:${PATH}"
RUN initdb -D $PGDATA && \
		echo "host all  all    0.0.0.0/0  md5" >> $PGDATA/pg_hba.conf && \
		echo "listen_addresses='*'" >> $PGDATA/postgresql.conf && \
		pg_ctl -D $PGDATA -l $PGDATA/logfile start && \
		top -b -n 1 

# configure entrypoint
USER root
COPY docker_entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker_entrypoint.sh
RUN ln -s usr/local/bin/docker_entrypoint.sh /
ENTRYPOINT ["docker_entrypoint.sh"]
