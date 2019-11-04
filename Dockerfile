FROM cm2network/steamcmd:root

ENV STEAMAPPNAME insurgency
ENV STEAMAPPID 237410
ENV STEAMAPPDIR /home/steam/ins-dedicated

# Run Steamcmd and install CSGO
# Create autoupdate config
# Download ESL config
# Remove packages and tidy up
RUN set -x \
    && sed -i 's@/deb.debian.org/@/mirrors.aliyun.com/@g;s@/security-cdn.debian.org/@/mirrors.aliyun.com/@g' /etc/apt/sources.list \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends --no-install-suggests \
		wget=1.18-5+deb9u3 \
		ca-certificates=20161130+nmu1+deb9u1 \
	&& su steam -c \
        mkdir ${STEAMAPPDIR} \
		&& "{ \
			echo '@ShutdownOnFailedCommand 1'; \
			echo '@NoPromptForPassword 1'; \
			echo 'login anonymous'; \
			echo 'force_install_dir ${STEAMAPPDIR}'; \
			echo 'app_update ${STEAMAPPID}'; \
			echo 'quit'; \
		} > ${STEAMAPPDIR}/update.txt" \
	&& apt-get remove --purge -y \
		wget \
	&& apt-get clean autoclean \
	&& apt-get autoremove -y \
	&& rm -rf /var/lib/apt/lists/*

ENV SRCDS_FPSMAX=300 \
	SRCDS_TICKRATE=64 \
	SRCDS_PORT=27015 \
	SRCDS_MAXPLAYERS=49 \
	SRCDS_PW="" \
	SRCDS_STARTMAP="buhriz_coop checkpoint" \
	SRCDS_REGION=3 \
    SRCDS_AGES=""

USER steam

WORKDIR $STEAMAPPDIR

VOLUME $STEAMAPPDIR

# Set Entrypoint:
# 1. Update server
# 2. Start server
ENTRYPOINT ${STEAMCMDDIR}/steamcmd.sh \
		+login anonymous +force_install_dir ${STEAMAPPDIR} +app_update ${STEAMAPPID} +quit \
		&& ${STEAMAPPDIR}/srcds_run \
			-game ${STEAMAPPNAME} -console -autoupdate -steam_dir ${STEAMCMDDIR} -steamcmd_script ${STEAMAPPDIR}/update.txt -usercon +fps_max $SRCDS_FPSMAX \
			-tickrate $SRCDS_TICKRATE -port $SRCDS_PORT -maxplayers_override $SRCDS_MAXPLAYERS \
			+map $SRCDS_STARTMAP +sv_password $SRCDS_PW +sv_region $SRCDS_REGION

# Expose ports
EXPOSE 27015 27020 27005 51840