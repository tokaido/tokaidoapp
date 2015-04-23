#!/bin/sh

cp Tokaido/Gemfile $TKD_TMP_PATH/Gemfile
cd $TKD_TMP_PATH

echo "Removing existing GEM_HOME to rebuild it"
rm -rf gem_home

echo "Building new GEM_HOME"
mkdir -p $TKD_TMP_PATH/gem_home/ruby/$TKD_RUBY_NAMESPACE


command -v pkg-config >/dev/null 2>&1 && bundle config --local build.nokogiri --with-opt-dir=$(pkg-config iconv --variable=prefix)
command -v pkg-config >/dev/null 2>&1 && bundle config --local build.sqlite3 --with-opt-dir=$(pkg-config sqlite3 --variable=prefix)

bundle --path gem_home --gemfile Gemfile

gem install bundler -E --no-ri --no-rdoc -i gem_home/ruby/$TKD_RUBY_NAMESPACE

rm -f tokaido-gems.zip
rm -Rf Gems

mkdir Gems
cd Gems
cp -R ../gem_home/ruby/$TKD_RUBY_NAMESPACE .
cd ..
mkdir -p Gems/supps
#FIXME
cp $TKD_EXTENSIONS_PATH/railties-4.2.1_app_base.rb Gems/$TKD_RUBY_NAMESPACE/gems/railties-4.2.1/lib/rails/generators/app_base.rb

cp -R $TKD_SUPPLEMENTS_PATH/iconv Gems/supps/iconv
cp -R $TKD_SUPPLEMENTS_PATH/bin_files Gems/bin_files

zip -r tokaido-gems.zip Gems
