#!/bin/bash
# This script synchronizes backups of configuration files in this directory
# with their originals
#
# bashrc --> $HOME/.bashrc
# kitty.conf --> $XDG_CONFIG_HOME/kitty/kitty.conf
# alacritty.toml --> $XDG_CONFIG_HOME/alacritty/alacritty.toml

cp -u -v ${HOME}/.bashrc bashrc
cp -u -v ${XDG_CONFIG_HOME:-${HOME}}/kitty/kitty.conf kitty.conf
cp -u -v ${XDG_CONFIG_HOME:-${HOME}}/alacritty/alacritty.toml alacritty.toml
