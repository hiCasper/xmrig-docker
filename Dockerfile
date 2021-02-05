FROM alpine:latest AS build
RUN adduser -S -D -H -h /xmrig xmrig
RUN apk --no-cache add \
        git \
        cmake \
        libuv-dev \
        libuv-static \
        openssl-dev \
        build-base && \
    apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing \
        hwloc-dev && \
    git clone https://github.com/xmrig/xmrig && \
    cd xmrig && \
    LATEST=$(git describe --tags) && \
    git checkout ${LATEST} && \
    mkdir build && cd build && \
    sed -i -e "s/kMinimumDonateLevel = 1/kMinimumDonateLevel = 0/g" ../src/donate.h && \
    sed -i -e "s/kDefaultDonateLevel = 1/kDefaultDonateLevel = 0/g" ../src/donate.h && \
    cmake .. -DCMAKE_BUILD_TYPE=Release -DUV_LIBRARY=/usr/lib/libuv.a -DBUILD_STATIC=ON && \
    make

FROM alpine:latest
RUN adduser -S -D -H -h /xmrig xmrig && \
    apk add --no-cache -X http://dl-cdn.alpinelinux.org/alpine/edge/testing hwloc-dev && \
    rm -rf /var/lib/apt/lists/*
USER xmrig
WORKDIR /xmrig/
COPY --from=build /xmrig/build/xmrig /xmrig/xmrig
ENTRYPOINT ["./xmrig"]