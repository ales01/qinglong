FROM alpine:3.16
COPY xr /xr

ARG QL_MAINTAINER="whyour"
LABEL maintainer="${QL_MAINTAINER}"
ARG QL_URL=https://github.com/${QL_MAINTAINER}/qinglong.git
ARG QL_BRANCH=develop

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    LANG=zh_CN.UTF-8 \
    SHELL=/bin/bash \
    PS1="\u@\h:\w \$ " \
    QL_DIR=/ql \
    QL_BRANCH=${QL_BRANCH}

WORKDIR ${QL_DIR}

RUN set -x \
    && apk update -f \
    && apk upgrade \
    && apk --no-cache add -f bash \
                             coreutils \
                             tzdata \
                             openssl \
                             nginx \
                             jq \
                             openssh \
                             wget unzip make python3 py3-pip build-base util-linux git curl perl bash sudo nodejs npm rclone transmission-cli syncthing\
    && rm -rf /var/cache/apk/* \
    && apk update \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && git config --global user.email "qinglong@@users.noreply.github.com" \
    && git config --global user.name "qinglong" \
    && git config --global http.postBuffer 524288000 \
    && npm add -g pm2 ts-node typescript tslib \
    && git clone -b ${QL_BRANCH} ${QL_URL} ${QL_DIR} \
    && cd ${QL_DIR} \
    && cp -f .env.example .env \
    && chmod 777 ${QL_DIR}/shell/*.sh \
    && chmod 777 ${QL_DIR}/docker/*.sh \
    && echo "node version" && node -v \
    && npm install --omit=dev --legacy-peer-deps && npm audit fix --force \
    && rm -rf /root/.cache \
    && rm -rf /root/.npm \
    && git clone -b ${QL_BRANCH} https://github.com/${QL_MAINTAINER}/qinglong-static.git /static \
    && mkdir -p ${QL_DIR}/static \
    && cp -rf /static/* ${QL_DIR}/static \
    && rm -rf /static \
    && ln -sf python3 /usr/bin/python \
    && cd / && git clone https://github.com/botgram/shell-bot.git \
    && cd shell-bot \
    && npm install pm2 -g \
    && npm install yarn -g \
    && npm install nodemon -g \
    && npm i \
    && cd .. \
    && mkdir -p /root/.config/rclone/ \
    && chmod +x /xr

EXPOSE 5700
ENTRYPOINT ["./docker/docker-entrypoint.sh"]
