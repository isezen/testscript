#!/bin/bash
#
# Common functions to use in other installation scripts.
#
#

# COLOR CODES
# -------------------------------------------------------------
NONE="\033[0m"    # unsets color to term's fg color

# regular colors
K="\033[0;30m"    # black
R="\033[0;31m"    # red
G="\033[0;32m"    # green
Y="\033[0;33m"    # yellow
B="\033[0;34m"    # blue
M="\033[0;35m"    # magenta
C="\033[0;49;96m" # cyan
W="\033[0;37m"    # white

# emphasized (bolded) colors
EK="\033[1;30m"
ER="\033[1;31m"
EG="\033[1;32m"
EY="\033[1;33m"
EB="\033[1;34m"
EM="\033[1;35m"
EC="\033[1;49;96m"
EW="\033[1;37m"

# background colors
BGK="\033[40m"
BGR="\033[41m"
BGG="\033[42m"
BGY="\033[43m"
BGB="\033[44m"
BGM="\033[45m"
BGC="\033[46m"
BGW="\033[47m"

# UNICODE CODES
# -------------------------------------------------------------
CHK='\xE2\x9C\x94'

# -------------------------------------------------------------
# FUNCTIONS:
col () { echo -ne $1; echo $2; echo -ne ${NONE}; }
red () { col $R $1; }
grn () { col $G $1; }
ylw () { col $EMY $1; }
blu () { col $B $1; }
mgt () { col $M $1; }
cyn () { col $C $1; }
org () { col $Y $1; }
wht () { col $W $1; }

rep ()   { eval "printf -- '${1:-'-'}%.0s' {1.."${2:-80}"}"; }
line ()  { col ${2:-$M} $(rep ${1:-'-'}); }
line1 () { line; }
line2 () { line = ${1:-$M}; }

# get_last_sha () {
#     ret=$(curl -s https://api.github.com/repos/isezen/testscript/commits | jq)
# }

# Return file path if exist
get_file_if_exist () { [ -f "$1" ] && echo "$1"; }

# Return public IP address
get_ip () { echo $(curl -s -4 ifconfig.co); }

# If set up, return IP6 address from inet6
get_ip6 () { ip addr | grep inet6 | grep "scope global" | awk '{$1=$1};1' | \
             awk '{print $2}' | awk -F'/' '{print $1}'; }

# Return OS name
get_os () {
    un=$(uname | awk '{print tolower($0)}')
    [ "$un" = "darwin" ] && echo 'macos' || echo $un
}

# Return architecture name
get_arch () {
    arc=$(arch)
    [ "$arc" = "aarch64" ] && echo 'arm64' || \
    ([ "$arc" = "x86_64" ] && echo 'amd64' || echo $arc)
}

# Return joined OS and architecture names
get_os_arch () {
    un=$(get_os)
    arc=$(get_arch)
    [[ $un == 'linux' && $arc == 'amd64' ]] && echo $un || echo $un'_'$arc
}

# A modified lsb_release wrapper.
lsb_releasef () {
    echo $(lsb_release $1 | \
           awk 'BEGIN{FS=":"} {print $2}' | \
           awk '{$1=$1};1')
}

# Return name of linux distribution
get_linux_dist () {
    [ "$(get_os)" = "linux" ] && echo $(lsb_releasef -i) || echo $(get_os)
}

# Return version if dist is Ubuntu
get_ubuntu_ver () {
    [ "$(get_linux_dist)" = "Ubuntu" ] && echo $(lsb_releasef -r)
}

# Add a text to bash profile file if it does not exist
# Default text is $HOME/.local/bin
add2profile () {
    local exp=${1:-'export PATH="$PATH:$HOME/.local/bin"'}
    exist=$(grep "$exp" $PROFILE)
    if [ -z "$exist" ]; then
        echo -e "$exp" >> $PROFILE
    fi
    source $PROFILE
}
