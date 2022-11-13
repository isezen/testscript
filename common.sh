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
CHECK='\U02714'; WARN='\U026A1'; CROSS='\U274c'
# -------------------------------------------------------------
# FUNCTIONS:
col () { echo -ne $1; echo -e "$2"; echo -ne ${NONE}; }
red () { col $R "$1"; }
grn () { col $G "$1"; }
ylw () { col $Y "$1"; }
blu () { col $B "$1"; }
mgt () { col $M "$1"; }
cyn () { col $C "$1"; }
wht () { col $W "$1"; }

msg_info () { grn "$CHECK $1"; }
msg_warn () { org "$WARN $1"; }
msg_err  () { red "$CROSS $1"; }

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
    local un=$(uname | awk '{print tolower($0)}')
    [ "$un" = "darwin" ] && echo 'macos' || echo $un
}

# Return architecture name
get_arch () {
    local arc=$(arch)
    [ "$arc" = "aarch64" ] && echo 'arm64' || \
    ([ "$arc" = "x86_64" ] && echo 'amd64' || echo $arc)
}

# Return joined OS and architecture names
get_os_arch () {
    local un=$(get_os)
    local arc=$(get_arch)
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
a2p () {
    local exp=${1:-'export PATH="$PATH:$HOME/.local/bin"'}
    exist=$(grep "$exp" $PROFILE)
    if [ -z "$exist" ]; then
        echo -e "$exp" >> $PROFILE
    fi
    source $PROFILE
}

# Check a package is already installed or not
# Args:
#   $1: Name of package
is_pkg_exist () {
    local dist=$(get_linux_dist)
    if [ $dist == "Ubuntu" ]; then
      ! [ -z "$(dpkg -l | grep $1)" ]
    elif [ $dist == "macos" ]; then
        if [ -f "$(which port)" ]; then
            ret=$(port installed $1)
            ! [ "$ret" != "None of the specified ports are installed." ]
        fi
    fi
}

# Check package(s) need to install
#   $1: Name of packages to install
to_install () {
    local to_install=
    for p in $1
    do
        if is_pkg_exist $p; then
            to_install+=" $p"
        fi

    done
    echo $to_install
}

# Multiple Install function
# Currently only supports Ubuntu/debian and Macports
#
# Args:
#    $1: Name of packages to install
install_pkg () {
    local dist=$(get_linux_dist)
    if [ $dist == "Ubuntu" ]; then
        sudo apt update > /dev/null 2>&1
        sudo apt install $1 -y > /dev/null 2>&1
    elif [ $dist == "macos" ]; then
        if [ -f "$(which port)" ]; then
            sudo port install $1 > /dev/null 2>&1
        fi
    else
        col $BGR "Installing dependencies on $dist is not supported."
        col $BGR "You need to make sure install dependencies manually."
    fi
}

# Install given packages if not installed
# Currently only supports Ubuntu and Macports
#
# Args:
#   $1: Name of packages to install
#   $2: Installing Message Text
#       Default: "Installing dependencies"
#   $3: End of Installing Message Text
#       Default: "Dependencies installed"
install () {
    local to_install=$(to_install "$1")
    local header="${2:-"Installing dependencies"}"
    local footer="${3:-"Dependencies installed"}"
    local installed=false
    if test -n "$to_install"; then
        installed=true
        ylw "$header"; echo -e ''
        install_pkg $to_install
    fi
    [ "$installed" = true ] && ylw "$footer"
}

# Install given packages if not installed.
# Currently only supports Ubuntu and Macports.
# Created for pre-dependencies.
#
# Args:
#   $1: Name of packages to install
install_pre_deps () {
    install "$1" \
            "Installing pre-dependencies to run the script..." \
            "Pre-dependencies installed"
}

