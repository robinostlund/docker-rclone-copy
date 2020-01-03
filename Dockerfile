FROM alpine:3.11

MAINTAINER Robin Ostlund <me@robinostlund.name>

ENV INST_RCLONE_VERSION=current
ENV ARCH=amd64
ENV COPY_SRC=
ENV COPY_DEST=
ENV COPY_OPTS=-v
ENV RCLONE_OPTS="--config /config/rclone.conf"
ENV CRON=
ENV CRON_ABORT=
ENV FORCE_COPY=
ENV CHECK_URL=
ENV TZ=

RUN apk -U add ca-certificates fuse wget dcron tzdata \
    && rm -rf /var/cache/apk/* \
    && cd /tmp \
    && wget -q http://downloads.rclone.org/rclone-${INST_RCLONE_VERSION}-linux-${ARCH}.zip \
    && unzip /tmp/rclone-${INST_RCLONE_VERSION}-linux-${ARCH}.zip \
    && mv /tmp/rclone-*-linux-${ARCH}/rclone /usr/bin \
    && rm -r /tmp/rclone*

COPY entrypoint.sh /
COPY copy.sh /
COPY copy-abort.sh /

VOLUME ["/config"]

ENTRYPOINT ["/entrypoint.sh"]

CMD [""]
