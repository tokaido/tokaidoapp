directory "tmp/zips"
directory "tmp/zips/gem_home"

namespace :bootstrap do
  task :update => "tmp/zips" do
    if File.exist?("tmp/zips/Bootstrap")
      cd "tmp/zips/Bootstrap" do
        sh "git pull"
      end
    else
      sh "git clone https://github.com/tokaido/tokaido-bootstrap.git tmp/zips/Bootstrap"
    end

    Bundler.with_clean_env do
      cd "tmp/zips/Bootstrap" do
        sh "bundle --standalone --without development"
      end
    end
  end

  task :zip => :update do
    require "zip/zip"

    rm_f "tmp/zips/tokaido-bootstrap.zip"

    directory = "tmp/zips/Bootstrap/"
    zipfile_name = "tmp/zips/tokaido-bootstrap.zip"

    Zip::ZipFile.open(zipfile_name, Zip::ZipFile::CREATE) do |zipfile|
      Dir[File.join(directory, '**', '**')].each do |file|
        zipfile.add("Bootstrap/" + file.sub(directory, ''), file)
      end
    end
  end

  task :copy => :zip do
    cp "tmp/zips/tokaido-bootstrap.zip", "Tokaido/tokaido-bootstrap.zip"
  end
end

def install_gem(gem, options="")
  sh "gem install #{gem} --no-ri --no-rdoc -E -i tmp/zips/gem_home #{options}"
end

namespace :gems do
  task :deps do
    cd "tmp/zips" do
      sh "curl -O http://www.sqlite.org/sqlite-autoconf-3070500.tar.gz"
      sh "tar -xf sqlite-autoconf-3070500.tar.gz"
    end

    cd "tmp/zips/sqlite-autoconf-3070500" do
      sh "./configure --disable-shared --enable-static"
      sh "make"
    end
  end

  task :build => ["tmp/zips/gem_home", :deps] do
    rm_rf "tmp/zips/gem_home/*"

    cp "Tokaido/Gemfile", "tmp/zips"

    Bundler.with_clean_env do
      sh "bundle --path tmp/zips/gem_home"
    end

    sh "gem install bundler -i tmp/zips/gem_home/ruby/2.0.0"
  end

  task :zip => :build do
    require "zip/zip"

    rm_f "tmp/zips/tokaido-gems.zip"

    directory = "tmp/zips/gem_home/ruby/2.0.0"
    zipfile_name = "tmp/zips/tokaido-gems.zip"

    Zip::ZipFile.open(zipfile_name, Zip::ZipFile::CREATE) do |zipfile|
      Dir[File.join(directory, '**', '**')].each do |file|
        zipfile.add("Gems/" + file.sub(directory, ''), file)
      end
    end
  end

  task :copy => :zip do
    cp "tmp/zips/tokaido-gems.zip", "Tokaido/tokaido-gems.zip"
  end
end

task :default => ["gems:copy", "bootstrap:copy"]
