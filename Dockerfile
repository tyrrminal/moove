FROM node:14 as vuebuild
WORKDIR /app
COPY vue /app
RUN npm ci && npm run build

#------------------------------------------------------------------------------------------

FROM perl:5.32
LABEL maintainer="Mark Tyrrell <mtyrrell@digicowsoftware.com>"

EXPOSE 8080
WORKDIR /app

ENV PERL_CARTON_PATH="/carton/local" \
  PERL_CARTON_MIRROR="http://cpan.digicow.net:5888/orepan" \
  PATH="/carton/local/bin:${PATH}" \
  PERL5LIB="/usr/share/perl5:/carton/local/lib/perl5:/carton/local/lib/perl5/x86_64-linux-gnu:${PERL5LIB}"

RUN apt-get update && apt-get install -qy \
  --allow-downgrades --allow-remove-essential --allow-change-held-packages \
  build-essential \
  libwww-perl \
  libssl-dev \
  libexpat1-dev \
  libxml2 \
  libxml2-dev \
  default-mysql-client \
  && rm -rf /var/lib/apt/lists/*

RUN cpanm Carton
COPY mojo/cpanfile* ./
RUN carton install --deployment

COPY docker-entrypoint.sh /bin/
COPY schema /schema
COPY mojo .
COPY --from=vuebuild /app/dist  public

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["prodserver"]
