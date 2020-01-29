#!/bin/bash
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"

NEXUS_HOME=/opt/sonatype/nexus
KEYCLOAK_CONFIG="${DIR}/keycloak.json"

DCR_NAME=nexus
DCR_IMAGE=billklinefelter/dsop-nexus
DCR_IMAGE_VERSION=latest

if [ ! -e "${KEYCLOAK_CONFIG}" ]; then
    echo "Please provide your keycloak.json and put it to ${DIR}"
    exit 1
fi

docker run -d --name ${DCR_NAME} \
                --restart always \
                --ulimit nofile=655360 \
                -e NEXUS_CONTEXT="/" \
                -e JAVA_MAX_MEM=4096M \
                -v "${KEYCLOAK_CONFIG}":${NEXUS_HOME}/etc/keycloak.json:ro \
                -v /data/nexus:/nexus-data \
                -p 8081:8081 \
                ${DCR_IMAGE}:${DCR_IMAGE_VERSION}
