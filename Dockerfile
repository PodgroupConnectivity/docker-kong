FROM ubuntu:16.04
MAINTAINER Jose Enrique Ruiz Navarro, quique.ruiz@podgroup.com

ENV KONG_VERSION 0.11.0

ENV KONG_CONFIG /etc/kong/kong.conf

ENV KONG_SHA256 34cfd44f61a4da5d39ad7b59bad7b4790451065ff8c8c3d000b6258ab6961949

RUN apt-get update && apt-get install curl perl -y && \
curl -Lso /tmp/kong.deb \
     "https://bintray.com/kong/kong-community-edition-deb/download_file?file_path=dists/kong-community-edition-0.11.0.xenial.all.deb"  && \
     dpkg -i /tmp/kong.deb

RUN mv /etc/kong/kong.conf.default ${KONG_CONFIG}

RUN apt-get install python-pip -y && pip install cqlsh==5.0.4
RUN apt-get remove --purge python-pip -y

ADD scripts/docker-entrypoint.sh /docker-entrypoint.sh
ENTRYPOINT ["./docker-entrypoint.sh"]

EXPOSE 8000 8443 8001 8444
