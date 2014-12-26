if [ `whoami` != "root" ]
then
  echo "You need to run the uninstallation script with sudo"
  exit 1
fi

rm -rf ~/.tokaido
rm -rf ~/Library/Application\ Support/Tokaido
rm -rf /etc/resolvers/tokaido
rm -rf ~/.magick
rm /usr/include/iconv.h
rm /usr/include/libcharset.h
rm /usr/include/localcharset.h
rm -rf /Library/LaunchDaemons/com.tokaido.firewall.plist
launchctl remove com.tokaido.firewall
