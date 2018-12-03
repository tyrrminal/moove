FROM ubuntu:18.04
LABEL maintainer="Mark Tyrrell <mtyrrell@digicowsoftware.com>"

RUN apt-get update && apt-get install -qy \
  --allow-downgrades --allow-remove-essential --allow-change-held-packages \
  perl \
	curl \
  build-essential \
	libssl-dev \
	libnet-ssleay-perl \
  libexpat1-dev \
  libxml2 \
  libxml2-dev \
  carton \
  cpanminus \
  libmysqlclient-dev \
  mysql-client
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list && \
  apt-get update && apt-get install -qy yarn
WORKDIR /app

ENV PERL_CARTON_PATH=/carton/local
COPY cpanfile* ./
RUN carton install --deployment

COPY . .

ENTRYPOINT ["/app/docker-entrypoint.sh"]
CMD ["prodserver"]
