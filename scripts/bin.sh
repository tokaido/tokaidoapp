root=$PWD
tmp=$root/tmp
zips=$tmp/zips

version="2.6.14"
redisdir="$zips/redis-$version"

cd $zips

if [ -d $redisdir ]
then
  echo "Redis is already downloaded"
else
  mkdir -p $zips
  curl -O "http://redis.googlecode.com/files/redis-$version.tar.gz"
  tar -xf $redisdir.tar.gz

  echo "Building Redis"
  cd $redisdir

  make

  mkdir -p $zips/bin
  cp src/redis-{server,cli} $zips/bin
fi

echo "Zipping the binaries"

cd $zips

zip -r tokaido-bin.zip bin
