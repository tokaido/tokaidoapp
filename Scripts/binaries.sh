#!/bin/sh

REDIS_VERSION="5.0.5"
REDIS_PATH="$TKD_TMP_PATH/redis-$REDIS_VERSION"

if [ -d $REDIS_PATH ]
then
  echo "Redis is already downloaded"
else
  cd $TKD_TMP_PATH
  curl -O "http://download.redis.io/releases/redis-$REDIS_VERSION.tar.gz"
  tar -xf redis-$REDIS_VERSION.tar.gz

  echo "Building Redis"
  cd "redis-$REDIS_VERSION"
  make
fi

cd $TKD_TMP_PATH

mkdir bin

cp $REDIS_PATH/src/redis-{server,cli} $TKD_TMP_PATH/bin
cp $TKD_DEPENDENCIES_HOME/magick/bin/convert $TKD_TMP_PATH/bin

echo "Zipping the binaries"

zip -r tokaido-bin.zip bin
