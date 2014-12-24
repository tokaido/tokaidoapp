root=$PWD
tmp=$root/tmp
zips=$tmp/zips

version="2.8.18"
redisdir="$zips/redis-$version"

cd $zips

if [ -d $redisdir ]
then
  echo "Redis is already downloaded"
else
  mkdir -p $zips
  curl -O "http://download.redis.io/releases/redis-$version.tar.gz"
  tar -xf $redisdir.tar.gz

  echo "Building Redis"
  cd $redisdir

  make

  mkdir -p $zips/bin
  cp src/redis-{server,cli} $zips/bin
fi

echo "Zipping the binaries"

cd $zips

if [ -d "$root/../../../../libs/imagemagik" ]
then
  echo "Imagemagick is already compiled."
  echo "Copying 'convert' binary..."

  cp "$root/../../../../libs/imagemagik/bin/convert" $zips/bin
fi

zip -r tokaido-bin.zip bin
