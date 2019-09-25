# Hammerspoon configuration

## Installing Hammerspoon

To install Hammerspoon, you can run the following command:

    $ brew cask install hammerspoon

Or you can also download it in [this link](https://github.com/Hammerspoon/hammerspoon/releases/latest)

## Installing configuration

In order to work properly, the repository files should be directly inside the Hammerspoon folder (default: `~/.hammerspoon`):

    $ rm -rf ~/.hammerspoon
    $ git clone https://github.com/chrisvltn/hammerspoon-scripts.git ~/.hammerspoon

> Note that it will replace all your scripts. In case you want to keep them, clone the repository somewhere else and copy the scripts to your Hammerspoon folder.

## Adding more scripts

To add a new script, create a new `.lua` file in the `tasks` folder. It will be automatically imported to `init.lua`, and will be ready to use as soon as you save it 🙂.

## Auto update

The `auto-update` script runs the `git pull` command, making all the scripts synchronized between your devices.

## Credits

* [chrisvltn](https://github.com/chrisvltn/)
