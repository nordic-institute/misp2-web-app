#!/bin/bash
set -e
#
#set -x
CONTAINER_NAME=${1:-tomcat-dev-service}
TOMCAT_WEB="/usr/local/tomcat/webapps"
CONTAINER=$(docker ps --filter "name=${CONTAINER_NAME}" --filter "status=running" --format "{{.Names}}")
[[ -z $CONTAINER ]] && echo "No container with name ${CONTAINER_NAME} found" && exit 1
if [[ ! -e orbeon.war ]] ; then
  cp --verbose ../../../../misp2-install-source/xtee-misp2-orbeon/war/orbeon.war . || (echo "can't find orbeon war" ; exit 1)
fi
echo "copy orbeon war to ${TOMCAT_WEB}/"
docker cp  orbeon.war "${CONTAINER}":${TOMCAT_WEB}/
echo "waiting for orbeon war to be deployed"
while ! (docker exec "${CONTAINER}" bash -c "ls ${TOMCAT_WEB}/orbeon/" > /dev/null 2>&1) ; do
    sleep 1
    echo -n  "."
done
echo ""
ORBEON_CONFIG=${TOMCAT_WEB}/orbeon/WEB-INF/resources/config/
echo "copying  $(ls -m orbeon/) to ${ORBEON_CONFIG}"
# shellcheck disable=SC2086
docker cp  orbeon/ ${CONTAINER}:${ORBEON_CONFIG}

