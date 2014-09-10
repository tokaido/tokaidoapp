root=$PWD
tmp=$root/tmp

bootstrap=$tmp/zips/bootstrap
cubalog=$tmp/zips/cubalog

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

cd $root

if [ -d $cubalog ]
then
  cd $cubalog
  git pull
  cd $root
else
  git clone https://github.com/tokaido/tokaido-cubalog.git tmp/zips/Cubalog
fi

cd $tmp/zips

zip -r tokaido-bootstrap.zip Bootstrap Cubalog
