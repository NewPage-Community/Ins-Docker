FROM debian:stretch-slim

ENV STEAMCMDDIR="/home/steam/steamcmd" \
	STEAMAPPNAME="insurgency" \
	STEAMAPPID=237410 \
	STEAMAPPDIR="/home/steam/ins-dedicated" \
	SRCDS_FPSMAX=300 \
	SRCDS_TICKRATE=64 \
	SRCDS_PORT=27015 \
	SRCDS_MAXPLAYERS=49 \
	SRCDS_PW="" \
	SRCDS_STARTMAP="buhriz_coop checkpoint" \
	SRCDS_ARGS=""

# 更新依赖和添加设置
RUN set -x \
	&& sed -i 's@/deb.debian.org/@/mirrors.aliyun.com/@g;s@/security.debian.org/@/mirrors.aliyun.com/@g' /etc/apt/sources.list \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends --no-install-suggests \
		lib32stdc++6 \
		gcc-multilib \
		g++-multilib \
		wget \
		ca-certificates \
		lib32z1 \
	&& useradd -m steam \
	&& su steam -c \
		"mkdir -p ${STEAMCMDDIR} \
		&& cd ${STEAMCMDDIR} \
		&& wget -qO- 'https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz' | tar zxf - \
		&& ${STEAMCMDDIR}/steamcmd.sh +login anonymous +quit " \
	&& apt-get remove --purge -y \
		wget \
	&& apt-get clean autoclean \
	&& apt-get autoremove -y \
	&& rm -rf /var/lib/apt/lists/* 

WORKDIR $STEAMAPPDIR

VOLUME $STEAMAPPDIR

# 设置权限、自动更新并启动服务器
ENTRYPOINT chown -R steam:steam ${STEAMAPPDIR} \
	&& su steam -c \
		"${STEAMCMDDIR}/steamcmd.sh \
		+login anonymous +force_install_dir ${STEAMAPPDIR} +app_update ${STEAMAPPID} +quit \
		&& { \
			echo '@ShutdownOnFailedCommand 1'; \
			echo '@NoPromptForPassword 1'; \
			echo 'login anonymous'; \
			echo 'force_install_dir ${STEAMAPPDIR}'; \
			echo 'app_update ${STEAMAPPID}'; \
			echo 'quit'; \
		} > ${STEAMAPPDIR}/update.txt \
		&& mkdir -p ~/.steam/sdk32 \
		&& ln -s ${STEAMCMDDIR}/linux32/steamclient.so ~/.steam/sdk32/steamclient.so \
		&& sed -i 's@/steam.sh/@/steamcmd.sh/@g' ${STEAMAPPDIR}/srcds_run \
		&& ${STEAMAPPDIR}/srcds_run \
			-game ${STEAMAPPNAME} -console -autoupdate -steam_dir ${STEAMCMDDIR} -steamcmd_script ${STEAMAPPDIR}/update.txt -usercon +fps_max 	$SRCDS_FPSMAX -pidfile srcds.pid -debug \
			-tickrate $SRCDS_TICKRATE -port $SRCDS_PORT -maxplayers $SRCDS_MAXPLAYERS \
			+map $SRCDS_STARTMAP +sv_password $SRCDS_PW \
			$SRCDS_ARGS"

# 暴露端口
EXPOSE 27015 27020 27005 51840