#!/bin/bash
# ~/.bashrc
# Read by BASH when run as an interactive NON-LOGIN shell

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ZSH-like autocompletion
# NB: Does not behave exactly like zsh.  Zsh autocompletes the string up until
# next ambiguous match, but bash prints the matches and cycles through all
# matches.
bind -s 'set completion-ignore-case on' # Ignore case on tab completion
bind -s 'set show-all-if-ambiguous on'
bind -s 'TAB:menu-complete'

# Unless given path ($1) is already in PATH add it to PATH
function append_path(){
    [ ! -d "$1" ] && return
    case ":${PATH}:" in
        (*":$1:"*)
                ;; # do nothing
            (*)
                PATH="${PATH:+$PATH:}$1" # if set and not NIL expand PATH
    esac
}

# Add following dirs to path
append_path "$HOME/.local/bin"

# Make `cd` look inside directories in addition to $PWD
export CDPATH=".:$HOME:$HOME/.config:$HOME/code"

# If found source ~/.bash_aliases
[ -f "$HOME/.bash_aliases" ] && source "$HOME/.bash_aliases"

# -----------------------------------------------------------------------------
#                       Custom shell functions
# -----------------------------------------------------------------------------
# pacman -Ql --quiet <package> command gives a list of files and directories. 
# I want to examine ONLY the files of the given package.
package_files() {
	pkg_name="$1"
	if [[ "$1" == "-x" ]]; then
		pkg_name="$2"
		pacman -Ql --quiet "${pkg_name}" | xargs -I{} sh -c "test -f {} && test -x {} && echo {}" || true
	else
		pacman -Ql --quiet "${pkg_name}"
	fi
}

# Using tput to change bash prompt color
# tput colors: setaf (foreground), setab (background)
declare -r time_color="\[$(tput setaf 220)\]"
declare -r cwd_color="\[$(tput setaf 40)\]"
declare -r git_color="\[$(tput setaf 161)\]"
declare -r err_bg_color="\[$(tput setab 240)\]"

declare -r reset="\[$(tput sgr0)\]"
declare -r rev="\[$(tput rev)\]"
declare -r bold="\[$(tput bold)\]"

PS1="${bold}${time_color}\@ "
PS1+="${cwd_color}\w"
PS1+="${git_color}\$(parse_git_branch)"
PS1+="${reset}${bold} 󰄾 "
export PS1

# Aliases
# -------
alias ls="ls --color=auto"
alias la="ls --color=auto --almost-all"
alias ll="ls --color=auto -l"
alias lt="ls --color=auto -t"
alias grep="grep --color=auto"
alias ipython="ipython --no-banner"
alias tree="tree -C"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

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

# NOTE: Because of how variable expansion differs between double and single 
# quotes, assigning `_err_bg_color` and `reset` to `_bg_color` does not work.
# This function does not directly modify `PS1`, therefore bin/activate
# script in python virtual envs can still update the prompt `PS1`
function update_bg(){
    if [ "$?" != 0 ]; then
        _bg_color="$(tput setab 240)"
    else
        _bg_color="$(tput sgr0)"
    fi
}

# Get name of current git branch
# list branches and select branch with "*" infront
function parse_git_branch() {
    _git_branch=$(git branch 2>/dev/null | sed -e "/^[^*]/d; s/* \(.*\)/(\1)/")
}

function update_prompt(){
    update_bg
    parse_git_branch
}

# Using tput to change bash prompt color (need ligaturized font for the prompt)
# PROMPT_COMMAND is evaluated each time before `PS1` is printed
export PROMPT_COMMAND=update_prompt

# Needs dynamic expansion at each time PS1 is evaluated. Thus SINGLE quotes.
PS1='${_bg_color}'
PS1+="${bold}${time_color}\@ ${cwd_color}\w${git_color} "
PS1+='${_git_branch}'
PS1+="${reset}$ 󰄾 "
export PS1


# -----------------------------------------------------------------------------
#                               Python
# -----------------------------------------------------------------------------
#
# Virtual Environments

# Look for given path in current directory and all directories above (i.e.
# parent directories). Utility function to search for some indicator (e.g. .git)
# that shows what is the root directory of a software project.
# "$1" = path to search for (i.e. bin/activate)
# Accepts absolute or relative path as target, if no argument given implies
# current working directory is the target
function get_parent_dirs(){
    if [ -n "$1" ]
    then
        path=$(realpath "$1")
    else
        path=$(pwd)
    fi
    # If not a valid path stop and return to caller
    [[ -e "${path}" ]] || return

    while [[ "${path}" != "/" ]]
    do
        [[ -d "${path}" ]] && printf "%s\n" "${path}"
        path=$(dirname "${path}")
    done
}

# Activate the python virtual environment directly without having to source
# relavent bin/activate script.
# NOTE: Assume above script is found locally in the virtual env directory or any
# of the parent directories above.
activate() {
    parent_dirs="$(get_parent_dirs)"
    for dir in ${parent_dirs[@]}; do
        script="${dir}/bin/activate"
        if [[ -f ${script} ]]; then
            source ${script}
            echo "Python virtual environment activated"
            return
        fi
    done
    echo "No python virtual environment activate script was found" >&2
}

# Setup python development environment
# -----------------------------------------
# Python interpreter writes *.pyc files to a __pycache__ directory
# on module import, for better performance. But I don't want my
# directories messed up with these.
export PYTHONDONTWRITEBYTECODE=x

# If I have a "lib" directory in my home, add it to python
# module import path, so that I can import custom modules.
if [[ -n ${PYTHONPATH}  &&  -d "${HOME}/lib" ]]; then
	export PYTHONPATH="${PYTHONPATH}:${HOME}/lib"
fi

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


# For neovim
export XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
export XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}
export MYVIMRC="${XDG_CONFIG_HOME}/nvim/init.lua"
