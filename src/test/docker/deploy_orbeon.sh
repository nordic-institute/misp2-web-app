#!/bin/bash
set -e
#
#set -x

TOMCAT_WEB="/usr/local/tomcat/webapps"
CONTAINER=$(docker ps --filter "name=tomcat-dev-service" --filter "status=running" --format "{{.Names}}")
if [[ ! -e orbeon.war ]] ; then
  cp --verbose ../../../../misp2-install-source/xtee-misp2-orbeon/war/orbeon.war . || (echo "can't find orbeon war" ; exit 1)
fi
echo "copy orbeon war to ${TOMCAT_WEB}/"
# shellcheck disable=SC2086
docker cp  orbeon.war ${CONTAINER}:${TOMCAT_WEB}/
# shellcheck disable=SC2086
while ! (docker exec ${CONTAINER} bash -c "ls ${TOMCAT_WEB}/orbeon/" > /dev/null) ; do
    sleep 1
done
ORBEON_CONFIG=${TOMCAT_WEB}/orbeon/WEB-INF/resources/config/
echo "copying  $(ls -m orbeon/) to ${ORBEON_CONFIG}"
# shellcheck disable=SC2086
docker cp  orbeon/ ${CONTAINER}:${ORBEON_CONFIG}

#echo -e "contents of ${ORBEON_CONFIG}"
#docker exec ${CONTAINER} bash -c "ls -m ${ORBEON_CONFIG}"
