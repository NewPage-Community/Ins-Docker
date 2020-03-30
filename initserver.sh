#!/bin/bash

#修复权限
chown -R steam:steam $STEAMAPPDIR
chmod -R 755 $STEAMAPPDIR
su steam -c "startserver.sh"

#叛乱修复
sed -i 's@/steam.sh/@/steamcmd.sh/@g' $STEAMAPPDIR/srcds_run
rm -f $STEAMAPPDIR/bin/libstdc++.so.6