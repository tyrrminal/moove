FROM node:10 as vuebuild
COPY *-ui /app
WORKDIR /app
RUN npm install && npm run build

#------------------------------------------------------------------------------------------

FROM perl:5.26 as cartoninstall
RUN apt-get update && apt-get install -qy \
  --allow-downgrades --allow-remove-essential --allow-change-held-packages \
  build-essential \
  libwww-perl libssl-dev libnet-ssleay-perl \
  libexpat1-dev \
  default-libmysqlclient-dev mysql-client \
  && rm -rf /var/lib/apt/lists/*
ENV PERL5LIB=/usr/share/perl5

WORKDIR /app
COPY cpanfile* ./
RUN cpanm -l /app/local --force --installdeps .

#------------------------------------------------------------------------------------------

FROM perl:5.26
LABEL maintainer="Mark Tyrrell <mtyrrell@digicowsoftware.com>"

RUN apt-get update && apt-get install -qy \
  --allow-downgrades --allow-remove-essential --allow-change-held-packages \
	libssl-dev \
	libnet-ssleay-perl \
  libexpat1-dev \
  libxml2 \
  libxml2-dev \
  default-libmysqlclient-dev \
  mysql-client \
  && rm -rf /var/lib/apt/lists/*
WORKDIR /app

COPY docker-entrypoint.sh /bin/
COPY *.conf *.conf.def ./
ADD api api/
ADD lib lib/
ADD script script/
ADD t t/

COPY --from=cartoninstall /app/local local
COPY --from=vuebuild      /app/dist  public

ENV PATH="/app/local/bin:${PATH}"
ENV PERL5LIB="/app/local/lib/perl5:/app/local/lib/perl5/x86_64-linux-gnu:${PERL5LIB}"

EXPOSE 8080

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["prodserver"]
