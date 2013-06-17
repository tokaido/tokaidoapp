root=$PWD
tmp=$root/tmp

bootstrap=$tmp/zips/bootstrap

mkdir -p $tmp/zips

if [ -d $bootstrap ]
then
  cd $bootstrap
  git pull
  cd $root
else
  git clone https://github.com/tokaido/tokaido-bootstrap.git tmp/zips/Bootstrap
fi

cd $bootstrap

bundle --standalone --without development

cd $tmp/zips

zip -r tokaido-bootstrap.zip Bootstrap
