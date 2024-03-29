FROM ubuntu:16.04
# FROM arm=armhf/ubuntu:16.04
ENV ARCH=amd64
ARG DAPPER_HOST_ARCH
ENV HOST_ARCH=${DAPPER_HOST_ARCH} ARCH=${DAPPER_HOST_ARCH}

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y gcc ca-certificates git wget curl vim less file python-pip xz-utils && \
    rm -f /bin/sh && ln -s /bin/bash /bin/sh
RUN pip install tox

ENV GOLANG_ARCH_amd64=amd64 GOLANG_ARCH_arm=armv6l GOLANG_ARCH=GOLANG_ARCH_${ARCH} \
    GOPATH=/go PATH=/go/bin:/usr/local/go/bin:${PATH} SHELL=/bin/bash

RUN wget -O - https://storage.googleapis.com/golang/go1.7.4.linux-amd64.tar.gz | tar -xzf - -C /usr/local && \
    go get github.com/rancher/trash && go get github.com/golang/lint/golint

ENV DOCKER_URL_amd64=https://get.docker.com/builds/Linux/x86_64/docker-1.10.3 \
    DOCKER_URL_arm=https://github.com/rancher/docker/releases/download/v1.10.3-ros1/docker-1.10.3_arm \
    DOCKER_URL=DOCKER_URL_${ARCH}

RUN wget -O - https://get.docker.com/builds/Linux/x86_64/docker-1.10.3 > /usr/bin/docker && chmod +x /usr/bin/docker

ENV DAPPER_SOURCE /go/src/github.com/rancher/catalog-service/
ENV DAPPER_OUTPUT ./bin ./dist
ENV DAPPER_DOCKER_SOCKET true
ENV TRASH_CACHE ${DAPPER_SOURCE}/.trash-cache
ENV HOME ${DAPPER_SOURCE}
WORKDIR ${DAPPER_SOURCE}

ENTRYPOINT ["./scripts/entry"]
CMD ["ci"]
