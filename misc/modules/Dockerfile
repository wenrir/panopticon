FROM alpine:3.18.4 AS base

ARG MODULE_NAME
WORKDIR /${MODULE_NAME}
ARG OPTIONAL_DEPS
ARG ROSIMPL=sbcl-bin/2.3.9

RUN --mount=type=bind,source=entrypoint.ros,target=/usr/local/bin/entrypoint.ros \
    apk update && apk add --no-cache\
    make=4.4.1-r1 rlwrap=0.46.1-r0 \
    --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing roswell \
    && rm -rf /var/cache/apk/* \
    && ros install ${ROSIMPL} \
    && ros use ${ROSIMPL} \
    && ros build /usr/local/bin/entrypoint.ros

ENTRYPOINT ["/usr/local/bin/entrypoint"]


FROM base AS release
COPY ./services/${MODULE_NAME} /${MODULE_NAME}
ENTRYPOINT ["/usr/local/bin/entrypoint"]
