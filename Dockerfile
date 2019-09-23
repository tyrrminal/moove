FROM node:10 as vuebuild
# By convention, our <app>-ui folder contains the Vuejs app
COPY *-ui /app
WORKDIR /app
RUN npm install && npm run build

#------------------------------------------------------------------------------------------

FROM perl:5.30
LABEL maintainer="Mark Tyrrell <mtyrrell@digicowsoftware.com>"

ENV PERL_CARTON_PATH="/carton/local" \
  PATH="/carton/local/bin:${PATH}" \
  PERL5LIB="/usr/share/perl5:/carton/local/lib/perl5:/carton/local/lib/perl5/x86_64-linux-gnu:${PERL5LIB}"
WORKDIR /app

RUN apt-get update && apt-get install -qy \
  --allow-downgrades --allow-remove-essential --allow-change-held-packages \
  build-essential \
  libwww-perl \
  libssl-dev \
  libnet-ssleay-perl \
  libexpat1-dev \
  libxml2 \
  libxml2-dev \
  default-libmysqlclient-dev \
  && rm -rf /var/lib/apt/lists/*

RUN cpanm Carton
COPY cpanfile* ./
RUN carton install --deployment

COPY docker-entrypoint.sh /bin/
COPY *.conf *.conf.def ./
ADD api api/
ADD lib lib/
ADD script script/
ADD t t/

COPY --from=vuebuild      /app/dist  public

EXPOSE 8080

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["prodserver"]
