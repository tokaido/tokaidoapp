clear

BIN="$HOME/.tokaido/bin"

export TOKAIDO_GEM_HOME=$HOME/.tokaido/Gems/$TOKAIDO_GEM_NAMESPACE
export GEM_HOME=$TOKAIDO_GEM_HOME
export GEM_PATH=$TOKAIDO_GEM_HOME
export PATH=$TOKAIDO_BIN_BUNDLED:$BIN:$TOKAIDO_PATH:$GEM_HOME/bin:$PATH
export PKG_CONFIG_PATH=$TOKAIDO_PKG_CONFIG_PATH:$PKG_CONFIG_PATH

if [ -d /Applications/Postgres.app ]; then
  export PATH="/Applications/Postgres.app/Contents/Versions/latest/bin:$PATH"
  echo -e "\033[0;32mTokaido detected Postgres.app and added it to the PATH\033[00m"
fi

cd "$TOKAIDO_APP_DIR"

echo -e "\033[0;32mThis terminal is now ready to use with Tokaido.\033[00m"
echo
