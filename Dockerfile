FROM ubuntu:18.04
LABEL maintainer="Mark Tyrrell <mtyrrell@digicowsoftware.com>"

RUN apt-get update && apt-get install -qy \
  --allow-downgrades --allow-remove-essential --allow-change-held-packages \
  perl \
	curl \
  build-essential \
	libssl-dev \
	libnet-ssleay-perl \
  carton \
  cpanminus \
  libmysqlclient-dev \
  mysql-client

WORKDIR /app

ENV PERL_CARTON_PATH=/carton/local
COPY cpanfile* ./
RUN carton install --deployment

COPY . .

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["prodserver"]
