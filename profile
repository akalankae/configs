#!/bin/sh
# ~/.profile

# Append "$1" to $PATH when not already in.
# This function API is accessible to scripts in /etc/profile.d
append_path () {
    case ":$PATH:" in
        *:"$1":*)
            ;;
        *)
            PATH="${PATH:+$PATH:}$1"
    esac
}

# add paths below containing my custom binaries to PATH
# ~/pkg/bin, ~/.local/bin, ~/.local/share/gem/ruby/3.0.0/bin
for path in $HOME/{pkg,.local{,/share/gem/ruby/3.0.0}}/bin
do
        if [[ -d $path ]]
        then
        	append_path $path
        fi
done
# unset -v user_bin_paths path 
unset -f append_path

declare -r vim_bin=$(which vim   2> /dev/null)
declare -r nvim_bin=$(which nvim  2> /dev/null)

[ "$nvim_bin" ] && VISUAL=${nvim_bin} || VISUAL=${vim_bin}

export EDITOR=$(which vi)
[ "$VISUAL" ] && export VISUAL

export GOPATH="$HOME/go"
# sanitize_path()
# examine $PATH and remove paths that are,
# 1. symlinks to paths that are already in $PATH
# 2. empty dirs
#
# initialize empty _PATH
# loop through each of paths in $PATH
# test $path against paths in $_PATH with sanitize_path()
# if successful, add $path to $_PATH
# at end of loop set PATH to _PATH and export
