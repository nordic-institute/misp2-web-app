FROM ubuntu:18.04
RUN export DEBIAN_FRONTEND=noninteractive \
  && apt-get -qq update \
  && apt-get -qq upgrade \
  && apt-get -qq install openjdk-8-jdk-headless sbt locales \
  && locale-gen en_US.UTF-8 \
  && update-locale "LANG=en_US.UTF-8" \
  && apt-get -qq autoremove \
  && apt-get -qq clean

ARG uid
ARG gid

RUN groupadd -g $gid builder && useradd -m -u $uid -g $gid builder
RUN mkdir -p /mnt/gradle-cache && chown -R builder:builder /mnt/gradle-cache

USER builder

ENV GRADLE_USER_HOME /mnt/gradle-cache
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV PATH /usr/local/nodejs/bin:$JAVA_HOME/bin:$PATH

WORKDIR /mnt
