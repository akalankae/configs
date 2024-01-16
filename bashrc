#!/bin/bash
# shellcheck disable=2068
# file: ~/.bashrc
# Read by BASH when run as an interactive NON-LOGIN shell

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Source ~/.profile
[[ -f $HOME/.profile ]] && . $HOME/.profile

# get name of current git branch
parse_git_branch() {
	git branch 2>/dev/null | sed -e "/^[^*]/d; s/* \(.*\)/ (\1)/"
	return ${pipestatus[0]}
}

time_color="\[$(tput setaf 220)\]"
cwd_color="\[$(tput setaf 40)\]"
git_color="\[$(tput setaf 161)\]"

reset="\[$(tput sgr0)\]"
rev="\[$(tput rev)\]"
bold="\[$(tput bold)\]"

# tput colors: setaf (foreground), setab (background)
# black: 0, red: 1, green: 2, yellow: 3, blue: 4, magenta: 5, cyan: 6, white: 7

# Using tput to change bash prompt color
PS1="${bold}${time_color}\@ "
PS1+="${cwd_color}\w"
PS1+="${git_color}$(parse_git_branch)"
PS1+="${reset}${bold} 󰄾 "
export PS1

# Aliases
# -------
alias ls="ls --color=auto"
alias grep="grep --color=auto"
alias ipython="ipython --no-banner"
alias tree="tree -C"

# Custom shell functions
# ----------------------
# pacman -Ql --quiet <package> command gives you a list of files
# and directories. I want to examine ONLY the files of the given
# package.
package_files() {
	for path in $(pacman -Ql --quiet "$1"); do
		if [ -f "$path" ]; then
			echo "$path"
		fi
	done
}

# Disable beeper in X for all apps.
xset b off

# Setting up python development environment
# -----------------------------------------
# Python interpreter writes *.pyc files to a __pycache__ directory
# on module import, for better performance. But I don't want my
# directories messed up with these.
export PYTHONDONTWRITEBYTECODE=x

# If I have a "lib" directory in my home, add it to python
# module import path, so that I can import custom modules.
if [ -n "$PYTHONPATH" ] && [ -d "${HOME}/lib" ]; then
	export PYTHONPATH="${PYTHONPATH}:${HOME}/lib"
fi

# Project Gutenberg ftp archive
export GUTENBERG_FTP="sailor.gutenberg.lib.md.us"

# Expose WLAN router and Google DNS server IP address as variables
# for convenient pinging.
export ROUTER=192.168.1.1
export GOOGLE_DNS=8.8.8.8

# export workon_home=~/.virtualenvs
# source /usr/bin/virtualenvwrapper.sh

export CDPATH=".:$HOME:$HOME/.config:$HOME/code"

# export PROMPT_COMMAND='echo ""'

# ZSH-like autocompletion
# NB: Does not behave exactly like zsh.  Zsh autocompletes the string up until
# next ambiguous match, but bash prints the matches and cycles through all
# matches.
bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'

#ignore upper and lowercase when TAB completion
bind "set completion-ignore-case on"

# Neovim config switcher
alias astronvim="NVIM_APPNAME=AstroNvim nvim"
alias lazyvim="NVIM_APPNAME=LazyVim nvim"
alias kickstart="NVIM_APPNAME=kickstart.nvim nvim"
alias n="NVIM_APPNAME=nvim-test nvim"

# Augmented nvim to pick any of given configs
# Defaults to regular nvim
function v() {
	items=("default" "nvim-test" "LazyVim" "AstroNvim" "kickstart.nvim")
	config=$(printf "%s\n" "${items[@]}" | fzf --prompt=" Neovim Config 󰶻 " --height=~50% --layout=reverse --border --exit-0)
	if [[ -z "$config" ]]; then
		echo "Nothing selected"
		return 0
	elif [[ "$config" == "default" ]]; then
		config=""
	fi
	NVIM_APPNAME="$config" nvim "$@"
}

# Augmented alacritty-themes command
# If --clean option is given, delete all backup files in alacritty config dir
function theme() {
	if [[ "$1" == "--clean" ]]; then
		~/pkg/bin/alacritty-themes-backup-cleanup.sh
	else
		alacritty-themes "$@"
	fi
}
export theme

# Python Virtual Environments
# Trick to activate python virtual environments with venv without explicitly
# look for venv/bin/activate or .venv/bin/activate in that order, and source
# the first of them found
activate() {
	activate_scripts=({,.}venv/bin/activate)
	for script in ${activate_scripts[@]}; do
		if [[ -f $script ]]; then
			. "$script"
			echo "Python virtual environment activated"
			return 0
		fi
	done
	echo "Neither of ${activate_scripts[*]} found" >&2
	return 1
}

# Launch alacritty with dark/light background depending on time of the day
if [[ "$TERM" == "alacritty" ]]; then
    hour_of_day=$(date +%_H)
    if (( "$hour_of_day" < 6 || "$hour_of_day" > 19 )); then
        alacritty-themes Terminal-app 
    else
        alacritty-themes Terminal-app-Basic
    fi
fi
