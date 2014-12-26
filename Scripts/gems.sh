root=$PWD
tmp=$root/tmp

mkdir -p $tmp/zips

if [ -d $tmp/2.2.0-p0 ]
then
  echo "Tokaido Ruby is unzipped"
else
  echo "Unzipping Tokaido Ruby"
  cp "Tokaido/Rubies/2.2.0-p0.zip" $tmp/2.2.0-p0.zip
  unzip $tmp/2.2.0-p0.zip -d $tmp
fi

export PATH=$tmp/2.2.0-p0/bin:$PATH
gem update --system --no-ri --no-rdoc
gem uninstall rubygems-update
gem_home="$tmp/bootstrap-gems"

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

export PATH=$tmp/bootstrap-gems/bin:$PATH

zips="$tmp/zips"
sqlite3="$zips/sqlite-autoconf-3080704"
libiconv="$zips/libiconv-1.14"
puma="$zips/puma"

mkdir -p $zips
cp Tokaido/Gemfile $zips/Gemfile

cd $zips

if [ -d $libiconv ]
then
  echo "libiconv already built"
else
  echo "Downloading and extracting libiconv (You are at: `pwd`)"
  curl -O http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz
  tar -xf libiconv-1.14.tar.gz

  echo "Building static libiconv"
  cd $libiconv

  ./configure --enable-static --prefix=$zips/libiconv --build=x86_64-darwin12.0
  make
  make install

  mkdir -p $zips/Gems/supps
  mkdir -p $zips/Supps

  cd $zips/libiconv
  rm lib/*.la
  rm lib/*.dylib
  rm -Rf share
  rm -Rf bin

  cd $zips
  cp -R libiconv $zips/Gems/supps/iconv
  cp -R libiconv $zips/Supps/iconv  
  cd $zips
fi

cd $zips

if [ -d $sqlite3 ]
then
  echo "SQLite3 already built"
else
  echo "Downloading and extracting SQLite3"
  curl -O http://www.sqlite.org/2014/sqlite-autoconf-3080704.tar.gz
  tar -xf sqlite-autoconf-3080704.tar.gz

  echo "Building static SQLite3"
  cd $sqlite3

  ./configure --disable-shared --enable-static
  make

  cd ..
fi

if [ -d $puma ]
then
  cd $puma
  gem build puma.gemspec
fi

cd $zips

bundle config --local build.sqlite3 --with-sqlite3-lib=$sqlite3/.libs --with-sqlite3-include=$sqlite3

echo "Removing existing GEM_HOME to rebuild it"
rm -rf gem_home

echo "Building new GEM_HOME"
bundle --path gem_home --gemfile Gemfile

gem install $puma/puma-2.10.2.gem -E --no-ri --no-rdoc -i $zips/gem_home/ruby/2.2.0
gem install bundler -E --no-ri --no-rdoc -i $zips/gem_home/ruby/2.2.0

rm -f tokaido-gems.zip
rm -rf Gems
cp -R gem_home/ruby/2.2.0 Gems


mkdir -p Gems/supps
zip -r tokaido-gems.zip Gems
