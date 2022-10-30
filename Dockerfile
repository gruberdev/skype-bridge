FROM golang:1-alpine3.14 AS builder

RUN apk add --no-cache git ca-certificates build-base su-exec olm-dev

COPY . /build
WORKDIR /build
RUN go build -o /usr/bin/matrix-skype

FROM alpine:3.14

ENV UID=1337 \
    GID=1337

RUN apk add --no-cache ffmpeg su-exec ca-certificates olm bash jq yq curl
RUN curl -L https://github.com/a8m/envsubst/releases/download/v1.2.0/envsubst-`uname -s`-`uname -m` -o envsubst \
    && chmod +x envsubst \
    && mv envsubst /usr/local/bin

COPY --from=builder /usr/bin/matrix-skype /usr/bin/matrix-skype
COPY --from=builder /build/example-config.yaml /opt/matrix-skype/example-config.yaml
COPY --from=builder /build/docker-run.sh /docker-run.sh
VOLUME /data

CMD ["/docker-run.sh"]
