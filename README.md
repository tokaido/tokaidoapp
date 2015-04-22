# Tokaido.app

## Background
[Tokaido](http://yehudakatz.com/2012/04/13/tokaido-my-hopes-and-dreams)
installs Rails as a Mac OS X application.
Working copies of Ruby, Rubygems, Rails and all necessary gems
are installed into the user's system, available from the Terminal.

## Getting Started
1. Visit https://github.com/tokaido/tokaidoapp/releases/
2. Click on the Tokaido.zip button to download the app
3. When the Application downloads, drag it to your Applications folder
4. Double Click Tokaido.app

## Warnings

If you get a warning about the app not being loaded because it is from an unknown developer:

![Unknown Developer Error](https://cloud.githubusercontent.com/assets/22501/2796617/7526189c-cc12-11e3-963e-78a89d0cd66b.png)

You can fix this by following the directions under "How to open an app from a unidentified developer and exempt it from Gatekeeper" [here](http://support.apple.com/kb/ht5290).

## Developer Setup

When first cloning this repo, be sure to run the following:

    gem install cocoapods
    pod install
    Scripts/package.sh
    open Tokaido.xcworkspace

You should then be able to build and run Tokaido in Xcode.
