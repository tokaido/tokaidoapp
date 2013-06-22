require "bundler/setup"

namespace :bootstrap do
  task :zip do
    Bundler.with_clean_env do
      sh "bash bootstrap.sh"
    end
  end

  task :copy => :zip do
    cp "tmp/zips/tokaido-bootstrap.zip", "Tokaido/tokaido-bootstrap.zip"
  end
end

namespace :gems do
  task :zip do
    Bundler.with_clean_env do
      sh "bash gems.sh"
    end
  end

  task :copy => :zip do
    cp "tmp/zips/tokaido-gems.zip", "Tokaido/tokaido-gems.zip"
  end
end

namespace :bins do
  task :zip do
    Bundler.with_clean_env do
      sh "bash bin.sh"
    end
  end

  task :copy => :zip do
    cp "tmp/zips/tokaido-bin.zip", "Tokaido/tokaido-bin.zip"
  end
end

task :default => ["gems:copy", "bootstrap:copy", "bins:copy"]
