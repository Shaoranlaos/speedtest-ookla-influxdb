FROM alpine:3.11 as packager

LABEL maintainer="shaoranlaos@shaoranlaos.de"

# Speedtest CLI Version
ARG SPEEDTEST_VERSION=1.2.0


RUN apk add --no-cache iputils curl jq
RUN echo "nobody:x:65534:65534:Nobody:/:" > /passwd.minimal

RUN ARCHITECTURE=$(uname -m) && \
    export ARCHITECTURE && \
    if [ "$ARCHITECTURE" = 'armv7l' ];then ARCHITECTURE="armhf";fi && \
    wget -nv -O /tmp/speedtest.tgz "https://install.speedtest.net/app/cli/ookla-speedtest-${SPEEDTEST_VERSION}-linux-${ARCHITECTURE}.tgz" && \
    tar zxvf /tmp/speedtest.tgz -C /tmp




FROM scratch

ENV LD_LIBRARY_PATH /usr/lib:/lib
ENV IFDB_MEASUREMENT environment
ENV IFDB_SERVER kube-master.local:8086
ENV IFDB_DBNAME HomeIoT

USER nobody
WORKDIR /app

COPY --from=packager --chown=65534:65534 /tmp /tmp
COPY --from=packager /passwd.minimal /etc/passwd
COPY --from=packager /usr/lib/libjq.so.1 /usr/lib/libcurl.so.4 /usr/lib/
COPY --from=packager /tmp/speedtest /usr/local/bin/
COPY --from=packager /usr/bin/jq /usr/bin/curl /usr/bin/
COPY --from=packager /bin/ls /bin/sh /bin/
COPY src/startscript.sh /app/startscript.sh

CMD ["/app/startscript.sh"]

