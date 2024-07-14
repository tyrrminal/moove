FROM docker.digicow.net/node:18 AS vuebuild
FROM docker.digicow.net/perl:5.38
LABEL maintainer="Mark Tyrrell <mtyrrell@digicowsoftware.com>"

COPY --from=vuebuild /app/dist  public
