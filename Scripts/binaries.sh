REDIS_VERSION="2.8.18"
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

if [ -d "$root/../../libs/imagemagik/bin" ]
then
  echo "Copying \'convert\' ImageMagick binary"
  cp $root/../../libs/imagemagik/bin/convert $TKD_TMP_PATH/bin
fi

echo "Zipping the binaries"

zip -r tokaido-bin.zip bin
