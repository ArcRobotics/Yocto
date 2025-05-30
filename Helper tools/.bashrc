# ~/.bashrc: executed by bash(1) for non-login shells.

# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Function to use fzf for reverse search in bash
fzf-history-search() {
    local selected=$(history | fzf --tac +s --tiebreak=index --exact | sed 's/ *[0-9]* *//')
    if [[ -n "$selected" ]]; then
        # Insert the selected command into the current prompt
        READLINE_LINE="$selected"
        READLINE_POINT=${#READLINE_LINE}
    fi
}

# Bind Ctrl+R to fzf-history-search
bind -x '"\C-r": fzf-history-search'


stop() {
    if [ -z "$1" ]; then
        echo "Usage: kill_process_by_name <process_name>"
        return 1
    fi

    local process_name="$1"

    # Find and kill the process
    ps aux | grep "$process_name" | grep -v grep | awk '{print $2}' | xargs -r kill -9

    if [ $? -eq 0 ]; then
        echo "Successfully killed processes matching '$process_name'."
    else
        echo "Failed to kill processes matching '$process_name' or no processes found."
    fi
}

#Task managers in linux
alias nerd='btop'
alias nerd++='htop'

#open helper manual for any command
alias help='man'

#Display size  occupied by each file / delete file / spwan at the current directory
alias space='ncdu --color dark'

#Display size occupied by each mounted disk and other info
alias disk='duf'

alias exe='chmod +x'

#To combine nano with fzf add the following to bashrc

#Enable nano fzf for quick access to file search
nanox() {
	local file
	file=$(fzf --preview='cat {}')   # Start fzf and store selected file
	[[ -n "$file" ]] && nano "$file"  # Open selected file in nano if one is selected
	}

export PATH=$HOME/.local/bin:$PATH
eval "$(oh-my-posh init bash)"


eval "$(oh-my-posh --init --shell bash --config ~/.poshthemes/my-quick-term.omp.json.json)" || \
 echo "Please download https://github.com/ArcRobotics/Yocto/tree/master/Helper%20tools/My%20posh%20themes "

#Function to display the root file system and explain their purpose
rootfs()
{
# First level (root directories)
echo "                                RootFS"
echo "                                  |"
echo " ┌────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┬────┐"
echo " |    |    |    |    |    |    |    |    |    |    |    |    |    |    |"
echo "bin  etc  usr  var  home root boot tmp  sbin opt  sys  proc  dev  run srv"
echo "           │    │                                  │"
echo "        ┌──┴──┐ └─────┬────┬───────┐               │"
echo "        |     |       |    |       |               │"
echo "       usr    var     log  spool  cache          class"
echo "                                                   │"
echo "                                 ┌─────────────────┴────────────────┐"
echo "                                 |        |       |       |         |"
echo "                                gpio     i2c     net     usb    power_supply"
echo "Descriptions:"
echo "bin   - Essential command binaries(e.g., ls, cp, mv)"
echo "etc   - System configuration files"
echo "usr   - User programs and libraries"
echo "  ├── bin   - Non-essential user binaries"
echo "  ├── lib   - Libraries for /usr binaries"
echo "  └── share - Architecture-independent data"
echo "var   - Variable files like logs and spool"
echo "  ├── log   - Log files"
echo "  ├── spool - Print and mail spool directories"
echo "  └── cache - Cached data"
echo "home  - User home directories"
echo "root  - Root user home directory"
echo "boot  - Bootloader files(e.g., kernel, initrd)"
echo "tmp   - Temporary files, including some runtime files like sockets or PID files"
echo "sbin  - System binaries(e.g., fsck, reboot)."
echo "opt   - Optional add-on software"
echo "sys   - Kernel and system device info (virtual filesystem,Class -> gpio , pcie , i2c...etc)"
echo "proc  - Process and kernel info (virtual filesystem)"
echo "dev   - Device files(e.g., /dev/sda, /dev/null)"
echo "run   - Runtime variable data (volatile)"
echo "srv   - Data for services provided by the system (e.g., web, ftp)"
}