#!/bin/sh

export root=$PWD

export RUBY_BINARY_PATH="$root/dist"
export COMPRESSED_SOURCE_PATH="$root/../compressed"
export BUILD_TOOLS_PATH="/Users/andraswhite/Code/static/builds"

export TKD_ARCH="x86_64"
export TKD_DARWIN="darwin12.0"
export TKD_ARCH_DARWIN="$TKD_ARCH-$TKD_DARWIN"

export TKD_RUBY_VERSION="2.2.2"
export TKD_RUBY_PATCH_VERSION="p95"
export TKD_RUBY="$TKD_RUBY_VERSION-$TKD_RUBY_PATCH_VERSION"
export TKD_RUBY_NAMESPACE_TINY="2.2"
export TKD_RUBY_NAMESPACE="2.2.0"

export TKD_RAILS_VERSION="4.2.1"

export TKD_TMP_PATH="$root/tmp"
export TKD_SUPPLEMENTS_PATH="$root/supplements"
export TKD_EXTENSIONS_PATH=$TKD_SUPPLEMENTS_PATH

if [ -d "b" ]
then
  b/build_binary.sh
else
  if [ ! -d $RUBY_BINARY_PATH/$TKD_RUBY ]
  then
    echo "No Ruby build script found. Compile a Ruby (Ex: $TKD_RUBY) and place it in $RUBY_BINARY_PATH"
    echo "Falling back to Tokaido bundled Ruby $TKD_RUBY..."
    mkdir -p $RUBY_BINARY_PATH
    cp $root/Tokaido/Rubies/$TKD_RUBY.zip $RUBY_BINARY_PATH/$TKD_RUBY.zip
    cd $RUBY_BINARY_PATH
    unzip $TKD_RUBY.zip
    rm $TKD_RUBY.zip
    cd $root
  fi
fi

export PATH="$RUBY_BINARY_PATH/$TKD_RUBY/bin:$PATH";

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

echo "Updating RubyGems..."
gem update --no-ri --no-rdoc --system
gem uninstall rubygems-update -x
echo "Done."

Scripts/gems.sh
Scripts/tokaido_modules.sh
Scripts/binaries.sh

if [ -d "b" ]
then
  cp $TKD_SUPPLEMENTS_PATH/$TKD_RUBY_VERSION/rb_config_release.rb $RUBY_BINARY_PATH/$TKD_RUBY/lib/ruby/$TKD_RUBY_NAMESPACE/$TKD_ARCH_DARWIN/rbconfig.rb
  cp $TKD_SUPPLEMENTS_PATH/$TKD_RUBY_VERSION/ruby-$TKD_RUBY_NAMESPACE_TINY.pc $RUBY_BINARY_PATH/$TKD_RUBY/lib/pkgconfig/ruby-$TKD_RUBY_NAMESPACE_TINY.pc
  cd $RUBY_BINARY_PATH
  zip -r $TKD_RUBY.zip $TKD_RUBY
  cp $RUBY_BINARY_PATH/$TKD_RUBY.zip $root/Tokaido/Rubies/$TKD_RUBY.zip
  cd $root
  rm -Rf src
fi

rm -Rf $RUBY_BINARY_PATH
Scripts/copy_tokaido_dependencies.sh
