#!/bin/sh

TKD_BOOTSTRAP_PATH=$TKD_TMP_PATH/Bootstrap
TKD_CUBALOG_PATH=$TKD_TMP_PATH/Cubalog

if [ -d $TKD_BOOTSTRAP_PATH ]
then
  cd $TKD_BOOTSTRAP_PATH
  git pull
  cd $root
else
  git clone https://github.com/tokaido/tokaido-bootstrap.git $TKD_TMP_PATH/Bootstrap
fi

cd $TKD_BOOTSTRAP_PATH

bundle --standalone --without development

cd $root

if [ -d $TKD_CUBALOG_PATH ]
then
  cd $TKD_CUBALOG_PATH
  git pull
  cd $root
else
  git clone https://github.com/tokaido/tokaido-cubalog.git $TKD_TMP_PATH/Cubalog
fi

cd $TKD_TMP_PATH

zip -r tokaido-bootstrap.zip Bootstrap Cubalog
