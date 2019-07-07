FROM debian:buster
EXPOSE 64738/tcp 64738/udp

ENV HOME /home/user
RUN useradd --create-home --home-dir $HOME user \
	&& chown -R user:user $HOME

# Runtime dependencies for murmurd
RUN apt-get update && apt-get install -y \
	ca-certificates \
		libprotobuf17 \
		libqt5xml5 \
		libqt5sql5 \
		libqt5network5 \
		libcap2 \
		libgrpc6 \
		libgrpc++1 \
		libzeroc-ice3.7 \
	&& rm -rf /var/lib/apt/lists/*

# The build dependencies will be uninstalled after compilation,
# so the image doesn't get bloated.
RUN buildDeps=' \
		build-essential \
		pkg-config \
		qt5-default \
		qtbase5-dev \
		qttools5-dev \
		qttools5-dev-tools \
		libqt5svg5* \
		libspeex1 \
		libspeex-dev \
		libboost-dev \
		libasound2-dev \
		libssl-dev \
		g++ \
		libspeechd-dev \
		libzeroc-ice-dev \
		zeroc-ice-slice \
		libpulse-dev \
		libcap-dev \
		libspeexdsp-dev \
		libprotobuf-dev \
		libprotoc-dev \
		protobuf-compiler \
		protobuf-compiler-grpc \
		libgrpc-dev \
		libgrpc++-dev \
		libogg-dev \
		libavahi-compat-libdnssd-dev \
		libsndfile1-dev \
		libxi-dev \
		git \
	' \
	&& set -x \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends \
	&& rm -rf /var/lib/apt/lists/* \
	&& mkdir -p /usr/src/murmur \
	&& git clone https://github.com/mumble-voip/mumble.git /usr/src/murmur \
	&& cd /usr/src/murmur \
	&& git submodule init \
	&& git submodule update \
	&& qmake -recursive main.pro CONFIG+="no-client no-g15 no-bonjour grpc" \
	&& make \
	&& cp -r release/ /home/user/release \
	&& chmod a+r /home/user/release -R \
	&& rm -rf /usr/src/murmur \
	&& apt-get purge -y --auto-remove $buildDeps

WORKDIR $HOME
USER user

ENTRYPOINT [ "/home/user/release/murmurd" ]
CMD [ "-fg", "-v", "-ini", "/data/murmur.ini" ]
