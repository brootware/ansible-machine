# Command aliases
alias ..='cd ..'
alias ...='cd ../../../'
alias ....='cd ../../../../'
alias back='cd $OLDPWD'
alias c='clear'
alias cd..='cd ..'
alias cp='cp -iv'
alias chmod="chmod -c"
alias chown="chown -c"
alias df='df -h -x squashfs -x tmpfs -x devtmpfs'
alias e="vim -O "
alias E="vim -o "
alias egrep='egrep --colour=auto'
alias extip='curl icanhazip.com'
alias grep='grep --color=auto'
alias l.='ls -lhFa --time-style=long-iso --color=auto'
alias ll='ls'
alias ln='ln -iv'
alias ls=' ls -lhF --color=auto --human-readable --time-style=long-iso --classify'
alias lsmount='mount |column -t'
alias mkdir='mkdir -pv'
alias mv='mv -iv'
alias ports='netstat -tulanp'
alias h='history -i 1'
alias history='history 1'
alias j='jobs -l'
alias rm='rm -iv'
alias rmdir='rmdir -v'
alias speedtest='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -'
alias ssha='eval $(ssh-agent) && ssh-add'
alias svim='sudo vim'
alias tn='tmux new -s'
alias watch='watch -d'
alias weather='curl wttr.in'
alias wget='wget -c'

if command -v colordiff > /dev/null 2>&1; then
    alias diff="colordiff -Nuar"
else
    alias diff="diff -Nuar"
fi

## get top process eating memory
alias mem5='ps auxf | sort -nr -k 4 | head -5'
alias mem10='ps auxf | sort -nr -k 4 | head -10'

## get top process eating cpu ##
alias cpu5='ps auxf | sort -nr -k 3 | head -5'
alias cpu10='ps auxf | sort -nr -k 3 | head -10'

## list largest directories (aka "ducks")
alias dir5='du -cksh * | sort -hr | head -n 5'
alias dir10='du -cksh * | sort -hr | head -n 10'

# Safetynets
# do not delete / or prompt if deleting more than 3 files at a time #
alias rm='rm -I --preserve-root'

# Parenting changing perms on / #
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'

# reload zsh config
alias zshup="source ~/.zshrc"

# ansible aliases
alias avt=ansible-vault
alias apb=ansible-playbook
alias agx=ansible-galaxy
alias ant=ansible-lint

# Download web page with all assets
alias getpage='wget --no-clobber --page-requisites --html-extension --convert-links --no-host-directories'

# Download file with original filename
alias get="curl -O -L"

# Get week number
alias week='date +%V'

# Stopwatch
alias timer='echo "Timer started. Stop with Ctrl-D." && date && time cat && date'

# IP addresses
alias localip="sudo ifconfig | grep -Eo 'inet (addr:)?([0-9]*\\.){3}[0-9]*' | grep -Eo '([0-9]*\\.){3}[0-9]*' | grep -v '127.0.0.1'"
alias ips="sudo ifconfig -a | grep -o 'inet6\\? \\(addr:\\)\\?\\s\\?\\(\\(\\([0-9]\\+\\.\\)\\{3\\}[0-9]\\+\\)\\|[a-fA-F0-9:]\\+\\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"
alias routerip="ip route | grep default | grep -E '\b((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b'"
alias pubip="wget -qO- https://ipinfo.io"

# copy working directory
alias cwd='pwd | tr -d "\r\n" | xclip -selection clipboard'

# vhosts
alias hosts='sudo vi /etc/hosts'

# untar
alias untar='tar xvf'

# Undo the last commit
alias uncommit="git reset HEAD~1"

# Open .zshrc in vim
alias zshconfig="vim ~/.zsh/.zshrc"
alias aliases="vim ~/.zsh/.aliases.zsh"

# alias python to python3
alias python=python3

# List connected usb device speed
alias usbspeed="lsusb -vvv | grep -i -B5 -A5 bcdUSB"

# Package management
if [ -f /usr/bin/apt ]; then
  alias update='sudo apt update'
  alias upgrade='sudo apt update && sudo apt dist-upgrade && sudo apt autoremove && sudo apt clean'
  alias install='sudo apt install'
fi
if [ -f /usr/bin/dnf ]; then
  alias update='sudo dnf -Syyy'
  alias upgrade='sudo dnf -Syu'
  alias install='sudo dnf -S'
fi
