FROM cm2network/steamcmd:root

ENV STEAMAPPNAME insurgency
ENV STEAMAPPID 237410
ENV STEAMAPPDIR /home/steam/ins-dedicated

# 更新依赖和添加设置
# 修复scrds的自动更新问题 steamcmd.sh -> steam.sh
RUN set -x \
	&& sed -i 's@/deb.debian.org/@/mirrors.aliyun.com/@g;s@/security.debian.org/@/mirrors.aliyun.com/@g' /etc/apt/sources.list \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends --no-install-suggests \
		wget=1.18-5+deb9u3 \
		ca-certificates=20161130+nmu1+deb9u1 \
		lib32z1 \
	&& apt-get remove --purge -y \
		wget \
	&& apt-get clean autoclean \
	&& apt-get autoremove -y \
	&& rm -rf /var/lib/apt/lists/* \
	&& su steam -c "cp ${STEAMCMDDIR}/steamcmd.sh ${STEAMCMDDIR}/steam.sh"

ENV SRCDS_FPSMAX=300 \
	SRCDS_TICKRATE=64 \
	SRCDS_PORT=27015 \
	SRCDS_MAXPLAYERS=49 \
	SRCDS_PW="" \
	SRCDS_STARTMAP="buhriz_coop checkpoint" \
	SRCDS_REGION=4 \
	SRCDS_ARGS=""

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
		&& ${STEAMAPPDIR}/srcds_run \
			-game ${STEAMAPPNAME} -console -autoupdate -steam_dir ${STEAMCMDDIR} -steamcmd_script ${STEAMAPPDIR}/update.txt -usercon +fps_max 	$SRCDS_FPSMAX \
			-tickrate $SRCDS_TICKRATE -port $SRCDS_PORT -maxplayers_override $SRCDS_MAXPLAYERS \
			+map $SRCDS_STARTMAP +sv_password $SRCDS_PW +sv_region $SRCDS_REGION \
			$SRCDS_ARGS"

# 暴露端口
EXPOSE 27015 27020 27005 51840