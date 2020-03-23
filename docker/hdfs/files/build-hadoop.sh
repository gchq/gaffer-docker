#!/bin/bash -xe

test -z "${HADOOP_VERSION}" && HADOOP_VERSION=3.2.1
test -z "${HADOOP_DOWNLOAD_URL}" && HADOOP_DOWNLOAD_URL=https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz
test -z "${HADOOP_APPLY_PATCHES}" && HADOOP_APPLY_PATCHES=false
test -z "${PROTOBUF_VERSION}" && PROTOBUF_VERSION=2.5.0

# Allow users to provide their own Hadoop Distribution Tarball
if [ -f "./hadoop-${HADOOP_VERSION}.tar.gz" ]; then
	exit 0
fi

mkdir -p /usr/share/man/man1
apt -qq update
apt -qq install -y wget

# Download official Hadoop Distribution Tarball
if [ ! -d "/patches/${HADOOP_VERSION}/" ] || [ "${HADOOP_APPLY_PATCHES}" != "true" ]; then
	wget -q ${HADOOP_DOWNLOAD_URL}
	exit 0
fi

# Build our own HDFS Distribution Tarball with patches applied

apt -qq install -y \
	automake \
	build-essential \
	cmake \
	g++ \
	git \
	libbz2-dev \
	libsnappy-dev \
	libsasl2-dev \
	libssl-dev \
	libtool \
	libzstd-dev \
	maven \
	openjdk-8-jdk \
	pkg-config \
	yasm \
	zlib1g-dev

export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64/

wget -q https://github.com/google/protobuf/releases/download/v${PROTOBUF_VERSION}/protobuf-${PROTOBUF_VERSION}.tar.gz
tar -xf protobuf-${PROTOBUF_VERSION}.tar.gz
cd protobuf-${PROTOBUF_VERSION}
./configure --prefix=/opt/protobuf/
make
make install
cd ..
rm -rf protobuf-${PROTOBUF_VERSION}.tar.gz protobuf-${PROTOBUF_VERSION}/
export PROTOBUF_HOME=/opt/protobuf
export PATH=${PROTOBUF_HOME}/bin:${PATH}

git clone https://github.com/01org/isa-l.git
cd isa-l
./autogen.sh
./configure
make
make install
cd ..
rm -rf isa-l/

git clone https://github.com/apache/hadoop.git
cd hadoop
git checkout rel/release-${HADOOP_VERSION}

for patch in /patches/${HADOOP_VERSION}/*.patch; do
	git apply $patch
done

mvn install \
	-P dist,native \
	-Dtar \
	-Drequire.bzip2 \
	-Drequire.snappy \
	-Drequire.zstd \
	-Drequire.openssl \
	-Drequire.isal \
	-Disal.prefix=/usr \
	-Disal.lib=/usr/lib \
	-Dbundle.isal=true \
	-DskipTests

mv hadoop-dist/target/hadoop-${HADOOP_VERSION}.tar.gz ../
