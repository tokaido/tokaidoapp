root=$PWD
tmp=$root/tmp

mkdir -p $tmp/zips

if [ -d $tmp/2.1.5-p273 ]
then
  echo "Tokaido Ruby is unzipped"
else
  echo "Unzipping Tokaido Ruby"
  cp "Tokaido/Rubies/2.1.5-p273.zip" $tmp/2.1.5-p273.zip
  unzip $tmp/2.1.5-p273.zip -d $tmp
fi

export PATH=$tmp/2.1.5-p273/bin:$PATH

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

mkdir -p $zips
cp Tokaido/Gemfile tmp/zips/Gemfile

cd $zips

if [ -d $libiconv ]
then
  echo "libiconv already built"
else
  echo "Downloading and extracting libiconv"
  curl -O http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.14.tar.gz
  tar -xf libiconv-1.14.tar.gz

  echo "Building static libiconv"
  cd $libiconv

  ./configure --enable-static --prefix=$zips/libiconv-1.14
  make
  make install

  cd ..
fi

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

bundle config --local build.sqlite3 --with-sqlite3-lib=$sqlite3/.libs --with-sqlite3-include=$sqlite3

echo "Removing existing GEM_HOME to rebuild it"
rm -rf gem_home

echo "Building new GEM_HOME"
bundle --path gem_home --gemfile Gemfile

gem install bundler -E --no-ri --no-rdoc -i $zips/gem_home/ruby/2.1.0

rm -f tokaido-gems.zip
rm -rf Gems
cp -R gem_home/ruby/2.1.0 Gems

mkdir -p Gems/supps
cp -R $zips/libiconv Gems/supps/libiconv

zip -r tokaido-gems.zip Gems
