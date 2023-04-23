FROM alpine:3.17

LABEL maintainer="shaoranlaos@shaoranlaos.de"

# Speedtest CLI Version
ARG SPEEDTEST_VERSION=1.2.0


RUN apk add --no-cache iputils curl jq
RUN adduser -D speedtest
WORKDIR /app

COPY src/startscript.sh /app/startscript.sh
COPY src/speedtest-cli.json /home/speedtest/.config/ookla/

RUN ARCHITECTURE=$(uname -m) && \
    export ARCHITECTURE && \
    if [ "$ARCHITECTURE" = 'armv7l' ];then ARCHITECTURE="armhf";fi && \
    wget -nv -O /tmp/speedtest.tgz "https://install.speedtest.net/app/cli/ookla-speedtest-${SPEEDTEST_VERSION}-linux-${ARCHITECTURE}.tgz" && \
    tar zxvf /tmp/speedtest.tgz -C /tmp && \
    cp /tmp/speedtest /usr/local/bin && \
    chown -R speedtest:speedtest /app && \
    rm -rf \
     /tmp/*



ENV LD_LIBRARY_PATH /usr/lib:/lib
ENV IFDB_MEASUREMENT environment
ENV IFDB_SERVER kube-master.local:8086
ENV IFDB_DBNAME HomeIoT

USER speedtest

ENTRYPOINT ["/app/startscript.sh"]

