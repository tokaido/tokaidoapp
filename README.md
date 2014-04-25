# Tokaido.app

## Background
This project was launched via KickStarter (https://www.kickstarter.com/projects/1397300529/railsapp) in May 2012.
The goal of the project is to make an all-in-one Rails on OS X Application.

## Getting Started
1. Visit https://github.com/tokaido/tokaidoapp/releases/tag/v1.0
2. Click on the Tokaido.zip button to download the app
3. When the Application downloads, drag it to your Applications folder
4. Double Click Tokaido.app

## Warnings

If you get a warning about the app not being loaded because it is from an unknown developer:

![Unknown Developer Error](https://cloud.githubusercontent.com/assets/22501/2796617/7526189c-cc12-11e3-963e-78a89d0cd66b.png)

You can fix this by going into System Preferences -> Security & Privacy -> General.  Under Allow apps downloaded from,
select "Anywhere".

![Allow unsigned software](https://cloud.githubusercontent.com/assets/32929/2796536/eda019d2-cc10-11e3-83bd-e8af4510419d.png)

This may be fixed in the future.

## Developer Setup

When first cloning this repo, be sure to run the following:

    gem install cocoapods
    pod install
    bundle install
    rake
    open Tokaido.xcworkspace

You should then be able to build and run Tokaido in Xcode.

## Static Ruby

Compiling static ruby:

https://github.com/tokaido/tokaido-build#static-ruby

