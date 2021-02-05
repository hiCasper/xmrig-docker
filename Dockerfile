FROM alpine:latest AS build
RUN adduser -S -D -H -h /xmrig xmrig
RUN apk --no-cache add make git make cmake libstdc++ gcc g++ automake libtool autoconf linux-headers wget && \
    git clone https://github.com/xmrig/xmrig && \
    cd xmrig && LATEST=$(git describe --tags) && git checkout ${LATEST} && \
    cd scripts && ./build_deps.sh && cd .. && \
    mkdir build && cd build && \
    sed -i -e "s/kMinimumDonateLevel = 1/kMinimumDonateLevel = 0/g" ../src/donate.h && \
    sed -i -e "s/kDefaultDonateLevel = 1/kDefaultDonateLevel = 0/g" ../src/donate.h && \
    cmake .. -DCMAKE_BUILD_TYPE=Release -DBUILD_STATIC=ON && \
    make -j$(nproc)

FROM alpine:latest
RUN adduser -S -D -H -h /xmrig xmrig
USER xmrig
WORKDIR /xmrig/
COPY --from=build /xmrig/build/xmrig /xmrig/xmrig
ENTRYPOINT ["./xmrig"]