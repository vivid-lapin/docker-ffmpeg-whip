# from https://github.com/jrottenberg/ffmpeg/blob/d5ad2cdec5773820a7a01fbdc45d4a4229f97990/docker-images/5.1/ubuntu2004/Dockerfile

FROM ubuntu:20.04 AS base

FROM base as build

ENV FFMPEG_VERSION=5.1.3 \
    AOM_VERSION=v1.0.0 \
    CHROMAPRINT_VERSION=1.5.0 \
    FDKAAC_VERSION=0.1.5 \
    FONTCONFIG_VERSION=2.12.4 \
    FREETYPE_VERSION=2.10.4 \
    FRIBIDI_VERSION=0.19.7 \
    KVAZAAR_VERSION=2.0.0 \
    LAME_VERSION=3.100 \
    LIBASS_VERSION=0.13.7 \
    LIBPTHREAD_STUBS_VERSION=0.4 \
    LIBVIDSTAB_VERSION=1.1.0 \
    LIBXCB_VERSION=1.13.1 \
    XCBPROTO_VERSION=1.13 \
    OGG_VERSION=1.3.2 \
    OPENCOREAMR_VERSION=0.1.5 \
    OPUS_VERSION=1.2 \
    OPENJPEG_VERSION=2.1.2 \
    THEORA_VERSION=1.1.1 \
    VORBIS_VERSION=1.3.5 \
    VPX_VERSION=1.8.0 \
    WEBP_VERSION=1.0.2 \
    X264_VERSION=20170226-2245-stable \
    X265_VERSION=3.4 \
    XAU_VERSION=1.0.9 \
    XORG_MACROS_VERSION=1.19.2 \
    XPROTO_VERSION=7.0.31 \
    XVID_VERSION=1.3.4 \
    LIBXML2_VERSION=2.9.12 \
    LIBBLURAY_VERSION=1.1.2 \
    LIBZMQ_VERSION=4.3.2 \
    LIBSRT_VERSION=1.4.1 \
    LIBARIBB24_VERSION=1.0.3 \
    LIBPNG_VERSION=1.6.9 \
    LIBVMAF_VERSION=2.1.1 \
    SRC=/usr/local

ARG DEBIAN_FRONTEND=noninteractive

COPY ./configure.patch /tmp

ADD https://api.github.com/repos/winlinvip/ffmpeg-webrtc/git/refs/heads/feature/rtc-muxer /tmp/git.json
RUN apt update \
    && apt install -y --no-install-recommends git vim ca-certificates expat libgomp1 \
    && git clone --recursive --depth 1 -b feature/rtc-muxer https://github.com/winlinvip/ffmpeg-webrtc /build \
    && cd /build \
    && git apply --numstat --summary --check --apply --ignore-whitespace -v /tmp/configure.patch

RUN buildDeps="autoconf \
    automake \
    cmake \
    curl \
    bzip2 \
    libexpat1-dev \
    g++ \
    gcc \
    git \
    gperf \
    libtool \
    make \
    meson \
    nasm \
    perl \
    pkg-config \
    python \
    libssl-dev \
    yasm \
    zlib1g-dev" && \
    apt-get -yqq update && \
    apt-get install -yq --no-install-recommends ${buildDeps}

WORKDIR /build

ARG         FREETYPE_SHA256SUM="5eab795ebb23ac77001cfb68b7d4d50b5d6c7469247b0b01b2c953269f658dac freetype-2.10.4.tar.gz"
ARG         FRIBIDI_SHA256SUM="3fc96fa9473bd31dcb5500bdf1aa78b337ba13eb8c301e7c28923fea982453a8 0.19.7.tar.gz"
ARG         LIBASS_SHA256SUM="8fadf294bf701300d4605e6f1d92929304187fca4b8d8a47889315526adbafd7 0.13.7.tar.gz"
ARG         LIBVIDSTAB_SHA256SUM="14d2a053e56edad4f397be0cb3ef8eb1ec3150404ce99a426c4eb641861dc0bb v1.1.0.tar.gz"
ARG         OGG_SHA256SUM="e19ee34711d7af328cb26287f4137e70630e7261b17cbe3cd41011d73a654692 libogg-1.3.2.tar.gz"
ARG         OPUS_SHA256SUM="77db45a87b51578fbc49555ef1b10926179861d854eb2613207dc79d9ec0a9a9 opus-1.2.tar.gz"
ARG         THEORA_SHA256SUM="40952956c47811928d1e7922cda3bc1f427eb75680c3c37249c91e949054916b libtheora-1.1.1.tar.gz"
ARG         VORBIS_SHA256SUM="6efbcecdd3e5dfbf090341b485da9d176eb250d893e3eb378c428a2db38301ce libvorbis-1.3.5.tar.gz"
ARG         XVID_SHA256SUM="4e9fd62728885855bc5007fe1be58df42e5e274497591fec37249e1052ae316f xvidcore-1.3.4.tar.gz"
ARG         LIBBLURAY_SHA256SUM="a3dd452239b100dc9da0d01b30e1692693e2a332a7d29917bf84bb10ea7c0b42 libbluray-1.1.2.tar.bz2"
ARG         LIBZMQ_SHA256SUM="02ecc88466ae38cf2c8d79f09cfd2675ba299a439680b64ade733e26a349edeb v4.3.2.tar.gz"
ARG         LIBARIBB24_SHA256SUM="f61560738926e57f9173510389634d8c06cabedfa857db4b28fb7704707ff128 v1.0.3.tar.gz"

ARG         LD_LIBRARY_PATH=/opt/ffmpeg/lib
ARG         MAKEFLAGS="-j2"
ARG         PKG_CONFIG_PATH="/opt/ffmpeg/share/pkgconfig:/opt/ffmpeg/lib/pkgconfig:/opt/ffmpeg/lib64/pkgconfig"
ARG         PREFIX=/opt/ffmpeg
ARG         LD_LIBRARY_PATH="/opt/ffmpeg/lib:/opt/ffmpeg/lib64"

### libopus https://www.opus-codec.org/
RUN \
    DIR=/tmp/opus && \
    mkdir -p ${DIR} && \
    cd ${DIR} && \
    curl -sLO https://archive.mozilla.org/pub/opus/opus-${OPUS_VERSION}.tar.gz && \
    echo ${OPUS_SHA256SUM} | sha256sum --check && \
    tar -zx --strip-components=1 -f opus-${OPUS_VERSION}.tar.gz && \
    autoreconf -fiv && \
    ./configure --prefix="${PREFIX}" --enable-shared && \
    make && \
    make install && \
    rm -rf ${DIR}

## x264 http://www.videolan.org/developers/x264.html
RUN \
    DIR=/tmp/x264 && \
    mkdir -p ${DIR} && \
    cd ${DIR} && \
    curl -sL https://download.videolan.org/pub/videolan/x264/snapshots/x264-snapshot-${X264_VERSION}.tar.bz2 | \
    tar -jx --strip-components=1 && \
    ./configure --prefix="${PREFIX}" --enable-shared --enable-pic --disable-cli && \
    make && \
    make install && \
    rm -rf ${DIR}

RUN DIR=/tmp/ffmpeg ./configure --enable-muxer=whip --enable-openssl --enable-version3 \
    --enable-libx264 --enable-gpl --enable-libopus --enable-nonfree \
    --extra-cflags="-I${PREFIX}/include" --extra-ldflags="-L${PREFIX}/lib" --extra-libs=-ldl --prefix="${PREFIX}"  \
    && make -j10 \
    && make install

## cleanup
RUN \
    ldd ${PREFIX}/bin/ffmpeg | grep opt/ffmpeg | cut -d ' ' -f 3 | xargs -i cp {} /usr/local/lib/ && \
    for lib in /usr/local/lib/*.so.*; do ln -s "${lib##*/}" "${lib%%.so.*}".so; done && \
    cp ${PREFIX}/bin/* /usr/local/bin/ && \
    cp -r ${PREFIX}/share/ffmpeg /usr/local/share/ && \
    LD_LIBRARY_PATH=/usr/local/lib ffmpeg -buildconf && \
    cp -r ${PREFIX}/include/libav* ${PREFIX}/include/libpostproc ${PREFIX}/include/libsw* /usr/local/include && \
    mkdir -p /usr/local/lib/pkgconfig && \
    for pc in ${PREFIX}/lib/pkgconfig/libav*.pc ${PREFIX}/lib/pkgconfig/libpostproc.pc ${PREFIX}/lib/pkgconfig/libsw*.pc; do \
    sed "s:${PREFIX}:/usr/local:g" <"$pc" >/usr/local/lib/pkgconfig/"${pc##*/}"; \
    done

FROM        base AS release
LABEL       org.opencontainers.image.authors="7887955+ci7lus@users.noreply.github.com" \
    org.opencontainers.image.source=https://github.com/vivid-lapin/docker-ffmpeg-whip

ENV         LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64

CMD         ["--help"]
ENTRYPOINT  ["ffmpeg"]

COPY --from=build /usr/local /usr/local/
