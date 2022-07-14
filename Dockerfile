FROM docker.digicow.net/node:16.0-vuebuild as vuebuild
FROM docker.digicow.net/perl:5.36
LABEL maintainer="Mark Tyrrell <mtyrrell@digicowsoftware.com>"

COPY --from=vuebuild /app/dist  public
