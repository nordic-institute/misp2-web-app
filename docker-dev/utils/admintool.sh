#!/bin/bash

java -Djava.security.egd=file:///dev/urandom -jar /utils/AdminTool.jar -config /usr/local/tomcat/webapps/misp2/WEB-INF/classes/config.cfg "$1" "$2"
