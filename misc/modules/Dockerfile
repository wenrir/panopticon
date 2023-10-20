FROM alpine:3.18.4 AS base

ARG MODULE_NAME
ARG ADDITIONAL_APK
ARG ROSIMPL=sbcl-bin/2.3.9
ENV MODULE_DIR=$MODULE_NAME
WORKDIR /${MODULE_DIR}

#FIXME Most be a nicer way to mount, build and execute entrypoint.
RUN --mount=type=bind,source=entrypoint.ros,target=entrypoint.ros \
    apk update && apk add --no-cache\
    make=4.4.1-r1 rlwrap=0.46.1-r0 ${ADDITIONAL_APK}\
    --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing roswell \
    && rm -rf /var/cache/apk/* \
    && ros install ${ROSIMPL} \
    && ros use ${ROSIMPL} \
    && ros build entrypoint.ros \
    && echo "cd /${MODULE_DIR} && ./entrypoint \$@" > /start_module.sh\
    && chmod u+x /start_module.sh

ENTRYPOINT ["/bin/sh", "/start_module.sh"]

#FROM base AS release
