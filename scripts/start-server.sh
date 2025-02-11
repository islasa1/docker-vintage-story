#!/bin/bash
curl -s http://api.vintagestory.at/${VS_CHANNEL}.json > ${VS_CHANNEL}.json
DL_URL="$( cat ${VS_CHANNEL}.json | jq -r '.["'$VS_VERSION'"].linuxserver.urls.local' )"
DL_FILE=$( basename $DL )
LAT_V="$( cat ${VS_CHANNEL}.json | jq -r 'keys[]' | sort -V | tail -n 1 )"
CUR_V="$(find ${DATA_DIR} -name installed-* | cut -d '-' -f2-)"
NEED_UPDATE="false"

if [ -z $LAT_V ]; then
  if [ -z $CUR_V ]; then
    echo "---Something went wrong, can't get latest version and found no local version, putting server into sleep mode!---"
    exit 1    
  fi
  echo "---Can't get latest version but found local version, continuing with local version..."
  LAT_V=$CUR_V
fi
echo "---Version Check---"
if [ "${DISABLE_UPDATES}" == "true" ]; then
  echo "---Automatic Updates Disabled!---"
elif [ -z "$CUR_V" ]; then
  echo "---Vintage Story not found, downloading...---"
  NEED_UPDATE="true"
elif [ "${LAT_V}" != "$CUR_V" ]; then
  echo "---Newer version found, installing!---"
  rm ${DATA_DIR}/installed-$CUR_V
  find ${DATA_DIR} -maxdepth 1 -not -name 'data' -print0 | xargs -0 -I {} rm -R {} 2&>/dev/null
  NEED_UPDATE="true"
elif [ "${LAT_V}" == "$CUR_V" ]; then
  echo "---Vintage Story version up-to-date---"
else
  echo "---Something went wrong, exit!---"
  exit 1
fi

if [ "$NEED_UPDATE" == "true" ]; then
  rm -f ${DATA_DIR}/vs_server_linux*
  if wget -q -nc --show-progress --progress=bar:force:noscroll -P ${DATA_DIR}/ "$DL_URL" ; then
    echo "---Successfully downloaded Vintage Story $DL_FILE---"
  else
    echo "---Can't download Vintage Story $DL_FILE, exit!---"
    exit 1
  fi
  tar -xvf ${DATA_DIR}/$DL_FILE -C ${DATA_DIR}
  rm ${DATA_DIR}/$DL_FILE
  touch ${DATA_DIR}/installed-${LAT_V}
fi

echo "---Preparing Server---"
chmod -R ${DATA_PERM} ${DATA_DIR}
echo "---Checking for old logs---"
find ${DATA_DIR} -name "masterLog.*" -exec rm -f {} \;
screen -wipe 2&>/dev/null

echo "---Starting Server---"
if [ -f "${DATA_DIR}/VintagestoryServer.exe" ]; then
  screen -S VintageStory -L -Logfile ${DATA_DIR}/masterLog.0 -d -m mono VintagestoryServer.exe --dataPath ${DATA_DIR}/data ${GAME_PARAMS}
  sleep 2
  screen -S watchdog -d -m /opt/scripts/start-watchdog.sh
  tail -f ${DATA_DIR}/masterLog.0
elif [ -f "${DATA_DIR}/VintagestoryServer" ]; then
  screen -S VintageStory -L -Logfile ${DATA_DIR}/masterLog.0 -d -m ${DATA_DIR}/VintagestoryServer --dataPath ${DATA_DIR}/data ${GAME_PARAMS}
  sleep 2
  screen -S watchdog -d -m /opt/scripts/start-watchdog.sh
  tail -f ${DATA_DIR}/masterLog.0
else
  echo "Can't find game executable, exit!"
  exit 1
fi
