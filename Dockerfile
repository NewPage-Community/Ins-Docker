FROM harbor.new-page.xyz/newpage/steamcmd:latest

ENV STEAMAPPNAME="insurgency" \
	STEAMAPPID=237410

ENV	SRCDS_FPSMAX=300 \
	SRCDS_TICKRATE=64 \
	SRCDS_PORT=27015 \
	SRCDS_MAXPLAYERS=49 \
	SRCDS_PW="" \
	SRCDS_STARTMAP="buhriz_coop checkpoint" \
	SRCDS_ARGS=""

COPY *.sh /usr/local/bin/

RUN set -x \
	&& chmod 755 /usr/local/bin/*.sh

WORKDIR $STEAMAPPDIR

VOLUME $STEAMAPPDIR

ENTRYPOINT initserver.sh

EXPOSE 27015/tcp 27015/udp 27020/udp
