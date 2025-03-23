# Copyright (C) 2020 Crossedfall
# This file is MODIFIED from the original, made available under the terms
# of the Apache License 2.0. A copy is available in ./legal/Apache-2.0.txt
# However, this modified version is licensed under the BSD 3-Clause License.
# For full terms, see ./LICENSE

ARG NODE_VERSION=18

FROM debian:bookworm-slim AS goon_base

ARG BYOND_MAJOR=515
ARG BYOND_MINOR=1637
ARG RUST_G_VERSION=v2.0.0-G

ENV BYOND_MAJOR=$BYOND_MAJOR \
    BYOND_MINOR=$BYOND_MINOR \
    RUST_G_VERSION=$RUST_G_VERSION \
    NODE_VERSION=$NODE_VERSION

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y \
    wget make unzip \
    libstdc++6:i386 libssl-dev:i386 zlib1g:i386
RUN wget -O byond.zip "http://www.byond.com/download/build/${BYOND_MAJOR}/${BYOND_MAJOR}.${BYOND_MINOR}_byond_linux.zip" \
    && unzip byond.zip \
    && cd byond \
    && sed -i 's|install:|&\n\tmkdir -p $(MAN_DIR)/man6|' Makefile \
    && make install \
    && chmod 644 /usr/local/byond/man/man6/* \
    && cd .. \
    && rm -rf byond byond.zip /var/lib/apt/lists/*
RUN mkdir /goon \
    && wget -O /goon/librust_g.so  "https://github.com/goonstation/rust-g/releases/download/$RUST_G_VERSION/librust_g.so" \
    && chmod +x /goon/librust_g.so \
    && ldd /goon/librust_g.so \
    && apt-get purge -y --auto-remove wget unzip make

FROM goon_base AS goon_builder
ARG GOON_MAP=COGMAP2
ARG RP_MODE="no"
ARG SAVE_STATION_Z="no"
COPY ./goonstation /goon
WORKDIR /goon
COPY ./amend_buildfile.sh /
RUN chmod +x /amend_buildfile.sh \
    && /amend_buildfile.sh "$RP_MODE" "$SAVE_STATION_Z"
RUN touch ./+secret/__secret.dme \
    && ./tools/ci/dm.sh goonstation.dme -DMAP_OVERRIDE_${GOON_MAP}

FROM goon_base AS goon_server
COPY ./goonstation/assets /goon/assets
COPY ./goonstation/sound /goon/sound
COPY ./goonstation/strings /goon/strings
COPY ./goonstation/herb_modular/assets /goon/herb_modular/assets
COPY ./goonstation/herb_modular/sound /goon/herb_modular/sound
COPY ./goonstation/herb_modular/strings /goon/herb_modular/strings
COPY --from=goon_builder /goon/goonstation.dmb /goon/goonstation.rsc /goon/
WORKDIR /goon
ENTRYPOINT ["DreamDaemon", "goonstation.dmb"]
CMD ["25566", "-invisible", "-trusted"]

FROM node:${NODE_VERSION}-bookworm-slim AS cdn_builder
COPY ./goonstation/tgui ./tgui
RUN mkdir -p ./browserassets/tgui \
    && ./tgui/bin/tgui
COPY ./goonstation/browserassets ./browserassets
ARG CDN_BASE_URL="http://localhost"
RUN cd ./browserassets\
    && npm install \
    && npx gulp build --cdn="${CDN_BASE_URL}"

FROM debian:bookworm-slim AS rsc_builder
RUN apt-get update \
    && apt-get install -y zip
COPY --from=goon_builder /goon/goonstation.rsc ./goonstation.rsc
RUN zip -jD9 ./rsc.zip goonstation.rsc

FROM nginx AS cdn_server
COPY --from=cdn_builder ./browserassets/build /usr/share/nginx/cdn/
COPY --from=rsc_builder ./rsc.zip /usr/share/nginx/cdn/rsc.zip
COPY ./cdn_config /etc/nginx/templates
COPY ./public /usr/share/nginx/html
