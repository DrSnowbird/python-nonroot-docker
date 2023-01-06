#!/bin/bash -x

BRIDGE_NAME=${1:-dev-network}

find_brdige=`sudo docker network ls|awk '{print $2}' | grep $BRIDGE_NAME`
if [ "${find_brdige}" = "${BRIDGE_NAME}"  ]; then
    echo "Docker network creation for: ${BRIDGE_NAME}: EXISTS! Skip!"
    exit 0
fi

sudo docker network create --driver bridge ${BRIDGE_NAME}
sudo docker network ls
