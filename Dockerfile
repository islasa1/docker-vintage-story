FROM ich777/mono-baseimage

LABEL org.opencontainers.image.authors="admin@minenet.at"
LABEL org.opencontainers.image.source="https://github.com/ich777/docker-vintage-story"

RUN wget -q -O /tmp/packages-microsoft-prod.deb https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb && \
	dpkg -i /tmp/packages-microsoft-prod.deb && \
	apt-get update && \
	apt-get -y install --no-install-recommends curl screen jq dotnet-runtime-7.0 && \
	rm -rf /var/lib/apt/lists/* /tmp/packages-microsoft-prod.deb

ENV DATA_DIR="/vintagestory"
ENV CONFIG="/opt/config/serverconfig.jsonc"
ENV MOD_DIR="/opt/mods"
ENV VS_CHANNEL="stable"
ENV VS_VERSION="1.20.3"
ENV DISABLE_UPDATES="false"
ENV GAME_PARAMS=""
ENV UMASK=000
ENV UID=99
ENV GID=100
ENV DATA_PERM=770
ENV USER="vintagestory"

RUN mkdir -p $DATA_DIR
RUN useradd -d $DATA_DIR -s /bin/bash $USER
RUN chown -R $USER $DATA_DIR
RUN ulimit -n 2048

ADD /scripts/ /opt/scripts/
ADD /config/ /opt/config/
RUN chmod -R 770 /opt/scripts/

#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]