TKD_BOOTSTRAP_PATH=$TKD_TMP_PATH/Bootstrap
TKD_CUBALOG_PATH=$TKD_TMP_PATH/Cubalog

gem_home="$TKD_TMP_PATH/bootstrap-gems"

export GEM_HOME=$gem_home
export GEM_PATH=$gem_home

if [ -d $gem_home ]
then
  echo "Bootstrap gems already installed"
else
  mkdir -p $gem_home

  echo "Installing Bundler"
  gem install bundler -E --no-ri --no-rdoc
fi

export PATH=$TKD_TMP_PATH/bootstrap-gems/bin:$PATH

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
