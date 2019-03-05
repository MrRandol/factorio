#!/bin/bash

set -e

GAMES_DATA_DIR="/FACTORIO/GAMES"

echo "====================================="
echo "      RANDOL'S FACTORIO MANAGER      "
echo "====================================="

echo "-----------------------------"
echo "- Please select game config -"
echo "-----------------------------"

select d in */; do test -n "$d" && break; echo ">>> Invalid Selection"; done

echo ""
GAME_NAME="$(basename $d)"
echo "Game selected : $GAME_NAME"

echo ""
echo "> Retreiving config from game folder."
. ./${GAME_NAME}/config
echo "  Done !"

echo ""
echo "> Checking config"
if [ -z ${VERSION} ]; 
then 
  echo "Variable <VERSION> is unset or empty. Please specify it in the ${GAME_NAME}/config file.";
  exit 1;
fi
if [ -z ${PORT} ]; 
then 
  echo "Variable <PORT> is unset or empty. Please specify it in the ${GAME_NAME}/config file.";
  exit 1;
fi
if [ -z ${CONTAINER_NAME} ]; 
then 
  echo "Variable <CONTAINER_NAME> is unset or empty. Please specify it in the ${GAME_NAME}/config file.";
  exit 1;
fi
echo "  Done !"

echo ""
echo "> Force pull of new image."
FACTORIO_IMAGE="goofball222/factorio:${VERSION}"
docker pull ${FACTORIO_IMAGE}

echo ""
CONTAINER_ID="$(docker ps -a --filter name=${CONTAINER_NAME} --format {{.ID}})"
if [ -z ${CONTAINER_ID} ];
then
  echo "> Found no current docker container running or stopped."
  echo "  Nothing to do ! \o/"
else
  echo "> Found one container (${CONTAINER_ID}) matching the CONTAINER_NAME, killing it."
  docker rm -f ${CONTAINER_NAME}
  echo "  Done !"
fi

echo ""
echo "> Creating new container for factorio v${VERSION}."

GAME_DATA_DIR="${GAMES_DATA_DIR}/${GAME_NAME}/"
docker run -ti -d --name ${CONTAINER_NAME} \
           -v ${GAME_DATA_DIR}/config:/opt/factorio/config \
           -v ${GAME_DATA_DIR}/saves:/opt/factorio/saves \
           -v ${GAME_DATA_DIR}/mods:/opt/factorio/mods \
           -p ${PORT}:34197 \
           ${FACTORIO_IMAGE}
echo "  Done !"

echo ""
echo "> Retreiving current IP."
IP="$(curl -s http://whatismyip.akamai.com/)"
echo "  Done !"

echo ""
echo "-----------------------------------------------------"
echo "- ALL DONE ! Enjoy game at ${IP}:${PORT}  -"
echo "-----------------------------------------------------"