#!/bin/bash

$STEAMCMDDIR/steamcmd.sh +login anonymous +force_install_dir $STEAMAPPDIR +app_update $STEAMAPPID +quit

$STEAMAPPDIR/srcds_run \
	-game $STEAMAPPNAME -console -autoupdate -steam_dir $STEAMCMDDIR -steamcmd_script $STEAMCMDDIR/update.txt \
	-usercon +fps_max $SRCDS_FPSMAX -pidfile srcds.pid -debug -nowatchdog \
	-tickrate $SRCDS_TICKRATE -port $SRCDS_PORT -maxplayers $SRCDS_MAXPLAYERS \
	+map $SRCDS_STARTMAP +sv_password $SRCDS_PW \
	$SRCDS_ARGS