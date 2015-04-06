clear

BIN="$HOME/.tokaido/bin"

export TOKAIDO_GEM_HOME=$HOME/.tokaido/Gems/2.1.0
export GEM_HOME=$TOKAIDO_GEM_HOME
export GEM_PATH=$TOKAIDO_GEM_HOME
export PATH=$BIN:$TOKAIDO_PATH:$GEM_HOME/bin:$PATH

if [ -d /Applications/Postgres.app ]; then
  pg_versions=(/Applications/Postgres.app/Contents/Versions/*)
  export PATH="${pg_versions[$((${#pg_versions[@]} - 1))]}/bin:$PATH"
  echo -e "\033[0;32mTokaido detected Postgres.app and added it to the PATH\033[00m"
fi

cd "$TOKAIDO_APP_DIR"

echo -e "\033[0;32mThis terminal is now ready use with Tokaido.\033[00m"
echo