#!/bin/sh

source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/environment.sh"

echo "Setting up development environment."
mkdir -p $TKD_RUBY_DEPENDENCIES_HOME/$TKD_VERSION
cd $TKD_RUBY_DEPENDENCIES_HOME
ln -sf $TKD_VERSION current
cd $TKD_HOME_DEV
echo "done."

if [ ! -d $RUBY_BINARY_PATH/$TKD_RUBY ]
then
  Scripts/prelude.sh
  Scripts/ruby/build.sh
  Scripts/ideal_libraries.sh
else
  echo "Found $TKD_RUBY in $RUBY_BINARY_PATH"
  echo "Using existing $TKD_RUBY..."
fi

cd $TKD_HOME_DEV

export PATH="$RUBY_BINARY_PATH/$TKD_RUBY/bin:$PATH";


gem_home="$TKD_TMP_PATH/bootstrap-gems"

export GEM_HOME=$gem_home
export GEM_PATH=$gem_home

if [ -d $gem_home ]
then
  echo "Bootstrap gems already installed"
else
  mkdir -p $gem_home

  if [ $TKD_RUBY_MINOR -lt 6 ]; then
    gem install bundler -E $NO_DOC_OPTION
  fi
fi

export PATH=$TKD_TMP_PATH/bootstrap-gems/bin:$PATH

echo "Updating RubyGems..."
gem update $NO_DOC_OPTION --system
gem uninstall rubygems-update -x
echo "Done."

echo "Updating Bundler..."
gem update bundler $NO_DOC_OPTION
echo "Done."

Scripts/gems.sh
Scripts/tokaido_modules.sh
Scripts/binaries.sh

if [ -d "b" ]; then

  rm -Rf $root/Tokaido/Versions
  mv $TKD_RUBY_DEPENDENCIES_HOME $root/Tokaido/Versions

  ruby Supplements/common/setup_certificates.rb
  mv cert.pem $root/Tokaido/Versions/$TKD_VERSION/openssl/etc/openssl/cert.pem

  cp $TKD_SUPPLEMENTS_PATH/$TKD_RUBY_VERSION/rbconfig.rb $RUBY_BINARY_PATH/$TKD_RUBY/lib/ruby/$TKD_RUBY_NAMESPACE/$TKD_RUBY_ARCH_VERSION/rbconfig.rb
  cp $TKD_SUPPLEMENTS_PATH/$TKD_RUBY_VERSION/ruby-$TKD_RUBY_NAMESPACE_TINY.pc $RUBY_BINARY_PATH/$TKD_RUBY/lib/pkgconfig/ruby-$TKD_RUBY_NAMESPACE_TINY.pc

  cp $TKD_SUPPLEMENTS_PATH/$TKD_RUBY_VERSION/gem $RUBY_BINARY_PATH/$TKD_RUBY/bin/gem
  cp $TKD_SUPPLEMENTS_PATH/$TKD_RUBY_VERSION/bundle $RUBY_BINARY_PATH/$TKD_RUBY/bin/bundle

  cd $RUBY_BINARY_PATH
  zip -r $TKD_RUBY.zip $TKD_RUBY
  cp $RUBY_BINARY_PATH/$TKD_RUBY.zip $root/Tokaido/Rubies/$TKD_RUBY.zip
  cd $root
  rm -Rf src
fi

#rm -Rf $RUBY_BINARY_PATH
Scripts/copy_tokaido_dependencies.sh
