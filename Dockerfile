FROM docker.digicow.net/node:24 AS vuebuild
FROM docker.digicow.net/perl:5.40
LABEL maintainer="Mark Tyrrell <mtyrrell@digicowsoftware.com>"

COPY --from=vuebuild /app/dist  public
