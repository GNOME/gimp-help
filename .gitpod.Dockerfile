FROM debian:testing

ENV INSTALL_DIR="_install" INSTALL_PREFIX="${INSTALL_DIR}"

RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y --no-install-recommends \
        automake \
        build-essential \
        docbook-xml \
        docbook-xsl \
        pkg-config \
        pngcrush \
        pngnq \
        python3 \
        python3-libxml2 \
        xsltproc \
        gettext \
        sudo \
        git
