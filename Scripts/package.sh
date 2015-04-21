export root=$PWD

export RUBY_BINARY_PATH="$root/dist"
export COMPRESSED_SOURCE_PATH="$root/../compressed"
export BUILD_TOOLS_PATH="/Users/andraswhite/Code/static/builds"

export TKD_RUBY_VERSION="2.1.5"
export TKD_RUBY_PATCH_VERSION="p273"
export TKD_RUBY="$TKD_RUBY_VERSION-$TKD_RUBY_PATCH_VERSION"
export TKD_RUBY_NAMESPACE_TINY="2.1"
export TKD_RUBY_NAMESPACE="2.1.0"

export TKD_TMP_PATH="$root/tmp"
export TKD_SUPPLEMENTS_PATH="$root/supplements"
export TKD_EXTENSIONS_PATH=$TKD_SUPPLEMENTS_PATH

if [ -d "b" ]
then
  b/build_binary.sh
else
  echo "No Ruby build script found. Compile a Ruby (Ex: $TKD_RUBY) and place it in $RUBY_BINARY_PATH"
fi

echo "Ruby is at $RUBY_BINARY_PATH"

echo "Adding $TKD_RUBY to path..."
export PATH="$RUBY_BINARY_PATH/$TKD_RUBY/bin:$PATH";

echo "Updating RubyGems..."
gem update --no-ri --no-rdoc --system
gem uninstall rubygems-update -x
echo "Done."

Scripts/gems.sh
Scripts/tokaido_modules.sh
Scripts/binaries.sh

cp -R $RUBY_BINARY_PATH/$TKD_RUBY $TKD_TMP_PATH/$TKD_RUBY

cp $TKD_SUPPLEMENTS_PATH/$TKD_RUBY_VERSION/rb_config_release.rb $TKD_TMP_PATH/$TKD_RUBY/lib/ruby/$TKD_RUBY_NAMESPACE/x86_64-darwin12.0/rbconfig.rb
cp $TKD_SUPPLEMENTS_PATH/$TKD_RUBY_VERSION/ruby-$TKD_RUBY_NAMESPACE_TINY.pc $TKD_TMP_PATH/$TKD_RUBY/lib/pkgconfig/ruby-$TKD_RUBY_NAMESPACE_TINY.pc

cd $TKD_TMP_PATH
zip -r $TKD_RUBY.zip $TKD_RUBY
cd $root

#rm -Rf src
#rm -Rf dist

cp $TKD_TMP_PATH/$TKD_RUBY.zip Tokaido/Rubies/$TKD_RUBY.zip
cp $TKD_TMP_PATH/tokaido-gems.zip Tokaido/tokaido-gems.zip
cp $TKD_TMP_PATH/tokaido-bin.zip Tokaido/tokaido-bin.zip
cp $TKD_TMP_PATH/tokaido-bootstrap.zip Tokaido/tokaido-bootstrap.zip

#rm -Rf $TKD_TMP_PATH
