# Ins Docker

[![pipeline status](https://git.new-page.xyz/newpage/insurgency/ins-docker/badges/master/pipeline.svg)](https://git.new-page.xyz/newpage/insurgency/ins-docker/-/commits/master)

## How to use

```shell
docker run --net=host newpagecommunity/ins-docker
```

> Need to mount volume! Or your game file will **lost** when container closed

### Volume

- `/home/steam/game-dedicated`

### Environment Variables

```shell
SRCDS_FPSMAX=300
SRCDS_TICKRATE=64
SRCDS_PORT=27015
SRCDS_MAXPLAYERS=49
SRCDS_PW=""
SRCDS_STARTMAP="buhriz_coop checkpoint"
SRCDS_ARGS=""
```
