#!/bin/bash
#
# This script contains `sudo` command to download/update required packages and register system service for Massa.
#
# - download, make executable and run script:
#
#   1- bash <(curl -sL https://t.ly/1qqz) && . ~/.profile
#   2- wget -qO massa.sh https://t.ly/1qqz && chmod +x massa.sh && ./massa.sh
#   3- wget -qO massa.sh https://raw.githubusercontent.com/isezen/testscript/main/massa.sh && chmod +x massa.sh && ./massa.sh
#
# - Just type `node-status` to run.
# - to see the logs, type `see-logs.
#
# curl -s https://api.testnet.run/logo.sh | bash

MASSA_PATH=$HOME
PROFILE=$HOME/.profile
CONFIG_TOML=$MASSA_PATH/massa/massa-node/config/config.toml
ADD_BOOTSTRAP_LIST=false
NETWORK_IP="0.0.0.0:31244"
BOOTSTRAP_IP="0.0.0.0:31245"
# -------------------------------------------------------------
NC="\e[0m"; GRN="\e[32m"
RED='\033[1;31m'; YLW='\033[1;33m'
ORG='\033[0;33m'; BLU='\033[0;34m'
PRP='\033[0;35m'; CYN='\033[0;36m'
CHK='\xE2\x9C\x94'
REMOTE=https://api.github.com/repos/massalabs/massa/releases/latest

header=$(cat <<EOF

    )       )             )  
   (     ( /(  (   (   ( /(  
   )\  ' )(_)) )\  )\  )(_)) 
 _((_)) ((_)_ ((_)((_)((_)_  
| '  \()/ _\` |(_-<(_-</ _\` | 
|_|_|_| \__,_|/__//__/\__,_| 
                   \xF0\x9F\x94\xA5 Fire-\xF0\x9D\x9B\xBC
EOF
)
# -------------------------------------------------------------
# DEFINE SCRIPTS TO SAVE HERE

script_massa_node=$(cat <<EOF
#!/bin/bash
# Path: $HOME/.local/bin/massa-node
cd $HOME/massa/massa-node
./massa-node \$@
EOF
)
script_massa_client=$(cat <<EOF
#!/bin/bash
# Path: $HOME/.local/bin/massa-client
cd $HOME/massa/massa-client
./massa-client \$@
EOF
)
script_see_logs=$(cat <<EOF
#!/bin/bash
# Path: $HOME/.local/bin/see-logs
journalctl -u massad.service -fo cat
EOF
)
script_node_status=$(cat <<EOF
#!/bin/bash
# Path: $HOME/.local/bin/node-status
echo -e "\e[32m\u2714 Massa Service is "\$(systemctl is-active massad)"\e[0m"
echo -e "\$(massa-client wallet_info -p \$massa_password | grep Balance)"
echo -e "\$(massa-client wallet_info -p \$massa_password | grep Rolls)"
ns=\$(massa-client get_status -p \$massa_password)
if  [ -z "\$(echo "\$ns" | grep "os error 111")" ]; then
    echo -e "\033[0;31m\u2714 \$(echo "\$ns" | grep Version)\e[0m"
    echo -e "\033[1;33m\u2714 \$(echo "\$ns" | grep "Node's IP")\e[0m"

    echo -e "\nConfig:"
    echo -e "\033[0;34m\$(echo "\$ns" | grep "Genesis timestamp")\e[0m"
    echo -e "\033[0;34m\$(echo "\$ns" | grep "End timestamp")\e[0m\n"
    echo -e "Episode ends in:\033[0;35m"
    massa-client when_episode_ends -p \$massa_password | sed 's/seconds.*/seconds/' | tr ',' '\n' | awk '{\$1=\$1};1' | sed 's/^/    /'

    echo -e "\n\e[0mNetwork stats:"
    echo -e "\033[0;33m\$(echo "\$ns" | grep "Active nodes")\e[0m"
    echo -e "\033[0;31m\$(echo "\$ns" | grep "In connections")\e[0m"
    echo -e "\e[32m\$(echo "\$ns" | grep "Out connections")\e[0m"
else
    echo -e "\033[0;31m\xE2\x8C\x9A Massa is currently bootstrapping\xE2\x80\xA6 \xE2\x98\x95\e[0m"
fi
echo -e ''
EOF
)
service_massad=$(cat <<EOF
# Path: /etc/systemd/system/massad.service
[Unit]
Description=Massa Daemon
After=network-online.target

[Service]
Environment="RUST_BACKTRACE=full"
WorkingDirectory=$HOME/massa/massa-node
User=$USER
ExecStart=$HOME/.local/bin/massa-node -p \$massa_password
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
)

bootstrap_list=$(cat <<EOF
bootstrap_list = [
  ["173.212.205.27:31245", "P125GPzhXrDcxLrHhLTKjAmzCuLNF2xRERmfceKpFhQESVeXzfdn"],
  ["185.202.238.118:31245", "P126nQ18Jst5TLN5ZZmfBhZsm4UVp7eEgNa6fx7TdxJyuFza1tgb"],
  ["65.21.235.110:31245", "P12Ce5ZLkzZhyg2JxWFhfNWoXsPzEDZWTwcYyXQQXajHicVcHsU1"],
  ["136.243.55.113:31245", "P12DpXhcenDUdUUJkz6FRS6ezz2vhTcu5eLHfbsvvceKiW6K86Za"],
  ["159.69.93.155:31245", "P12EAbuZDjvVRRNZXqAXn7Kzfa9sKiJgidBW2csMs2TcnLfdKxPG"],
  ["45.144.65.121:31245", "P12Lwwdu3EodLygJt7TBAC6soFLd4L61PN8vC8v5g6ooS3GLVusP"],
  ["161.97.136.50:31245", "P12U2J7Ug33xySkEzqzETGNq7TaM9g3DQu2i2oU6vP9JVGLPMo9p"],
  ["185.217.127.90:31245", "P12YGmZMMLLRsPdAsmXQJ544nPQnjmN63wPQcGhniQCKLhz1pLa9"],
  ["65.21.239.126:31245", "P12bro9api3NgranBoYUJheybNRC4XTM8qYYvu7ifw6R1Wvpd6wW"],
  ["167.235.252.230:31245", "P12buvn8VrsUHeRPmZgiS9rhM4aWAWbV3dtNHKX7KVHpY6GxgZi4"],
  ["161.97.123.0:31245", "P12crUjx2uaSEWgUgHa5JwRjY863A86jyJhVoUiKMwHscApnwZH8"],
  ["161.97.102.34:31245", "P12eUxyT3oLmfKokrsS6dD1WGqNb2QvZYEry6eRPsQyS33DpkM8a"],
  ["172.105.237.249:31245", "P12kEEWcniFjKrzfeGrKGMisN4FfakR6bomK2Md5pZ8uaPXbKZaV"],
  ["154.12.232.135:31245", "P12pohyqFLfGVPLZYG2LGY2PGXx87rf7Wt4p5Gz6SfctMvUx19Ze"],
  ["65.108.2.46:31245", "P12vmTMvgDJe3FCTLQhuJSihCyFRawTvdVu8b3nz8yn2ADwyWdzp"],
  ["116.203.32.102:31245", "P1886jMymAjJzfVLKUjXi8U6NnpowLLb6KbVS3mFMF6UmuHFkzB"],
  ["51.89.40.122:31245", "P1CaaiioFcPrpjYJUHdctiviC4nACSUaj85MHGgBATxfRTzrBYZ"],
  ["149.154.64.160:31245", "P1GEZ3ZPdoZckxtabyxyC5ooQuSHVgvADm32r4fz8UN6jz6TLXi"],
  ["65.21.111.0:31245", "P1JmvBqJZz9xM2mHweUBZRsPirjkdkVraAtD6Ms5MGdKuZ7mY4W"],
  ["217.79.178.197:31245", "P1NK6fVEkNGPfwHCa9wQ7aDsxp7BsDFqAqyZuEzP6c1evvyrFiz"],
  ["20.119.92.251:31245", "P1TKrYGGCj6WrdQN8Y8R5GRoPJtDAZxKgEPxYbcuDh7HvPM3K68"],
  ["38.242.137.82:31245", "P1c21LLWhjQj58yAdaK2xxmxLj1rmSuYGUzptW52fHyY63qqc26"],
  ["65.108.77.6:31245", "P1fNGrd5XvJiwQmKcE4CYpKNzTVJs1nc2E5sXxtuWCezBG8ijr7"],
  ["5.189.172.86:31245", "P1ntzkUVhEQjTyu8btsrP6p9MUtd5eNNjixCtQanuWhbjH6zmHK"],
  ["82.122.223.126:31245", "P1s49EHtKJRZEstUaumLL8pTa7DCydBRigu3AumwcAgTPyc4Zca"]
]
EOF
)
# -------------------------------------------------------------
# FUNCTIONS:

line2 () { echo -e ${PRP}"==============================================================="${NC}; }
line1 () { echo -e ${PRP}"---------------------------------------------------------------"${NC}; }
# get_last_sha () {
#     ret=$(curl -s https://api.github.com/repos/isezen/testscript/commits | jq)
# }
get_ubuntu_ver () { echo $(lsb_release -r | awk 'BEGIN{FS=":"} {print $2}' | 
    awk '{$1=$1};1'); }
get_ip () { echo $(curl -s -4 ifconfig.co); }
get_ip6 () { ip addr | grep inet6 | grep "scope global" | awk '{$1=$1};1' | \
             awk '{print $2}' | awk -F'/' '{print $1}'; }
get_ip_type () {
    while true; do
        read -p "Which IP do you want to use? (ipv-[4]/6): " ip_type
        ip_type=${ip_type:-4}
        case $ip_type in 
            [4] ) break;;
            [6] ) break;;
            * ) echo -e "${RED}\u274c Enter 4 or 6. Default is [4].${NC}";;
        esac
    done
}

add2profile () {
    local exp=${1:-'export PATH="$PATH:$HOME/.local/bin"'}
    exist=$(grep "$exp" $PROFILE)
    if [ -z "$exist" ]; then
        echo -e "$exp" >> $PROFILE
    fi
    source $PROFILE
}
add_profile_local_bin () {
    add2profile 'export PATH="$PATH:$HOME/.local/bin"'
}
add_profile_version () {
    local vr=$(version remote)
    add2profile 'export massa_version='$vr
}
add_profile_pass () {
    add2profile 'export massa_password='$1
}

add_bootstrap_list () {
    if [ "$ADD_BOOTSTRAP_LIST" = true ] ; then
        while true; do
            read -p "Do you want to add bootstrap list? (y/[n]) " yn
            yn=${yn:-n}
            case $yn in 
                [yY] ) break;;
                [nN] ) break;;
                * ) echo [y]es or [n]o?;
            esac
        done
        if [ "$yn" = "y" ]; then
            echo "$bootstrap_list" >> $CONFIG_TOML
        fi
    fi
}

create_config () {
    ip_type=4
    ip=$(get_ip)
    echo -e "Your external IPv4 address is ${YLW}$ip${NC}"
    ip6=$(get_ip6)
    if [ -n "$ip6" ]; then
        echo -e "Your external IPv6 address is ${YLW}$ip6${NC}"
        get_ip_type
    fi
    if [ "$ip_type" -eq "6" ]; then
        ip=$ip6
    fi
    echo "[network]" > $CONFIG_TOML
    echo "routable_ip = \"$ip\"" >> $CONFIG_TOML
    if [ "$ip_type" -eq "4" ]; then
        echo "bind = \"$NETWORK_IP\"" >> $CONFIG_TOML
    fi
    echo -e "\n[bootstrap]" >> $CONFIG_TOML
    if [ "$ip_type" -eq "4" ]; then
        echo "bind = \"$BOOTSTRAP_IP\"" >> $CONFIG_TOML
    fi
    add_bootstrap_list
}

file_exist () {
    loc=
    file="${1:-/etc/systemd/system/massad.service}"
    if test -f "$file"; then loc=$file; fi
    echo $loc
}

get_var_names () {
    pattern=${1:-script}
    vars="$(set | grep "^"$pattern"\_" | grep -v '_file' | 
        awk -F= '{print $1}' | uniq)"
    echo "$vars"
}

get_file_paths () {
    pattern=${1:-script}
    vars="$(get_var_names "$pattern")"
    pat="^# Path:"
    paths=
    for v in $vars
    do
        content=$(eval echo \"\${$v}\")
        paths+=$(echo "$content" | grep "$pat" | awk '{print $3}')" "
    done
    echo $paths
}

get_file_names () {
    pattern=${1:-script}
    fn=
    for f in $(get_file_paths $pattern)
    do
        fn+=$(basename $f)" "
    done
    echo $fn | tr " " "\n"
}

save () {
    pattern=${1:-script}
    echo -e ${YLW}'Generating '$pattern's...'${NC}
    vars="$(set | grep "^"$pattern"\_" | grep -v '_file' | 
        awk -F= '{print $1}' | uniq)"
    # vars="${vars%??}" # remove last two chars
    pat="^# Path:"
    for v in $vars
    do
        content=$(eval echo \"\${$v}\")
        file_path=$(echo "$content" | grep "$pat" | awk '{print $3}')
        dir_path="$(dirname "${file_path}")"
        mkdir -p "$dir_path"
        content=$(echo "$content" | grep -v "$pat")
        sd=
        if [[ $file_path != $HOME* ]]; then
            sd="sudo"
        fi
        if test -n "$file_path"; then
            eval 'echo "$content" | '$sd' tee $file_path > /dev/null'
            if [[ "$content" == "#!"* ]]; then
                eval $sd' chmod +x "$file_path"'
            fi
            echo -e ${YLW}' '${CHK}' '$file_path${NC}
        fi
    done
}

get_bin_loc () {
    loc=
    binary="${1:-massa-client}"
    loc=$(which $binary)
    if [[ -z "$loc" ]]; then
        loc=$(file_exist "$HOME/massa/$binary/$binary")
    fi
    echo $loc
}

is_installed () {
    massa_client=$(get_bin_loc massa-client)
    massa_node=$(get_bin_loc massa-node)
    if [[ -n "$massa_client" && -n "$massa_node" ]]; then
        echo "installed"
    fi
}

get_wallet () {
    local what=$(echo "${1:-address secret public}" | awk '{print tolower($0)}')
    local addr=
    local massa_client=$(get_bin_loc massa-client)
    if [[ -n "$massa_client" ]]; then
        for w in $what
        do
            local ret=$($massa_client wallet_info -p $massa_password  \
                        2> /dev/null | grep -i $w)
            local col=$([[ $w == "address" ]] && echo '$2' || echo '$3')
            val=$(echo $ret | awk "{print $col}")
            if [ -z "$val" ]; then
                val='NOT SET'
            fi
            addr+=$(echo "$val\n")
        done
        addr="${addr%??}"
    fi
    echo -e "$addr"
}

wallet_str () {
    secret=$(get_wallet secret)
    public=$(get_wallet public)
    address=$(get_wallet address)
    line1
    echo -e "Secret Key : ${RED}$secret${NC}"
    echo -e "Public Key : ${GRN}$public${NC}"
    echo -e "Address    : ${BLU}$address${NC}"
    line1
}

get_arch () {
    arc=$(arch)
    if [ "$arc" = "aarch64" ]; then
        arc='arm64'
    elif [ "$arc" = "x86_64" ]; then
        arc='amd64'
    fi
    echo $arc
}

get_os_arch () {
    os_arc=
    un=$(uname | awk '{print tolower($0)}')
    if [ "$un" = "darwin" ]; then
        un='macos'
    fi
    arc=$(get_arch)
    os_arc="$un"_"$arc"
    if [[ $un == 'linux' && $arc == 'amd64' ]]; then
        os_arc=$un
    fi
    echo $os_arc
}

remote () {
    ret=$(curl -s $REMOTE)
    if [ -n "$(echo $ret | grep 'API rate limit exceeded')" ]; then
        echo -e "${RED}\u274c API rate limit exceeded.${NC}"
        echo -e "${RED}   Try again after a while ...${NC}"
        exit 1
    fi
    echo $ret
}

version () {
    type=${1:-local}
    if [  "$type" = "local" ]; then
        echo $([ -z "$massa_version" ] && echo "NOT SET" || 
           echo $massa_version)
    else
        echo "$(remote | jq -r ".tag_name")"
    fi
}

get_latest_release_url () {
    echo $(remote | jq -r ".assets[].browser_download_url" | 
        grep $(get_os_arch)"\.")
}

to_install () {
    to_install=
    for p in $1
    do
        if [ -z "$(dpkg -l | grep $p)" ]; then
            to_install+=" $p"
        fi
    done
    echo $to_install
}

install () {
    local installed=false
    local to_install=$(to_install "$1")
    local header="${2:-Installing dependencies}"
    local footer="${3:-Dependencies installed}"
    if test -n "$to_install"; then
        echo -e ${YLW}"$header\e[0m"${NC}
        echo -e ''
        sudo apt update > /dev/null 2>&1
        sudo apt install $to_install -y > /dev/null 2>&1
        installed=true
    fi
    if [ "$installed" = true ] ; then
        echo -e ${YLW}"$footer\e[0m"${NC}
    fi
}

install_pre_deps () {
    local pkgs="screen jq curl wget git"
    local header="Installing pre-dependencies to run the script..."
    local footer="Pre-dependencies installed"
    install "$pkgs" "$header" "$footer"
}

install_deb_libssl1 () {
    local arch="_"$(get_arch)
    local local=/tmp/libssl1.1.deb
    if test -n "$local"; then
        url="http://security.debian.org/debian-security/pool/updates/main"
        url="$url/o/openssl/libssl1.1_1.1.0l-1~deb9u6$arch.deb"
        wget -qO "$local" "$url"
    fi
    sudo dpkg -i "$local" > /dev/null 2>&1
}

install_deps () {
    # local pkgs="build-essential clang librocksdb-dev pkg-config libssl-dev \
    #             libclang-dev"
    # local header="Installing dependencies"
    # local footer="Dependencies installed"
    # install "$pkgs" "$header" "$footer"
    #
    # if Ubuntu 22.04, install libssl1.1 from debian repo.
    # if [ $(get_ubuntu_ver) = '22.04' ]; then
    if [ $(awk 'BEGIN { print ('$(get_ubuntu_ver)' >= 22.04) ? "YES" : "NO" }') = 'YES' ]; then
        echo "Ubuntu version is $(get_ubuntu_ver)"
        if [ -z "$(dpkg -l | grep libssl1.1)" ]; then
            echo -en '  Installing libssl1.1 '
            install_deb_libssl1
            echo -e ${YLW}${CHK}${NC}
        fi
    fi
}

set_password () {
    if [ -z "$(grep "^export massa_password*" $PROFILE)" ]; then
        unset massa_password
    fi
    if [ ! "$massa_password" ]; then
        stty -echo
        while [ -z "${massa_password}" ]; do
            echo -e ""
            read -p 'Enter a password for Massa: ' massa_password
        done
        stty echo
        add_profile_pass $massa_password
        echo -e ""
    fi
}

download_bins () {
    local remote=$(get_latest_release_url)
    local file="$(basename "${remote}")"
    local local=/tmp/$file
    if test -n "$local"; then
        wget -qO $local "$remote"
    fi
    tar -xzf $local -C $MASSA_PATH
    add_profile_version
    echo -e "${GRN}${CHK} Binaries are downloaded${NC}"
}

services () {
    service_massad=$(echo "$service_massad" | 
        sed 's/$massa_password/'$massa_password'/g')
    save service
    sudo systemctl daemon-reload
    sudo systemctl enable massad > /dev/null 2>&1
    sudo systemctl restart massad
    sleep 1
    echo -e ${GRN}" ${CHK} Massa Service is "$(systemctl is-active massad)${NC}
}

keys () {
    echo -e ''
    secret_key=
    while true; do
        read -p "Do you have a secret key? (y/[n]) " yn
        yn=${yn:-n}
        case $yn in 
            [yY] )
                footer="Added"
                cmd=wallet_add_secret_keys
                read -p 'Enter Secret Key: ' secret_key
                break;;
            [nN] )
                footer="Generated"
                cmd=wallet_generate_secret_key
                break;;
            * ) echo [y]es or [n]o?;
        esac
    done
    footer=${GRN}${CHK}" Key "$footer${NC}
    massa_client=$(get_bin_loc massa-client)
    $massa_client $cmd "$secret_key" -p $massa_password > /dev/null 2>&1
    echo -e "$footer"
    echo -e ''
}

info () {
    source $PROFILE
    echo -e ${GRN}"INFO:"${NC}
    wallet_str
    cmds="$(get_file_names | sed 's/^/'$(tput setaf 2)'/')"
    cmds=$(echo "$cmds" | sed -e 's/$/'$(tput sgr0)'/')
    cmds=$(echo "$cmds" | sed 's/^/ | /')
    echo -e "Available commands:"
    echo "$cmds"
    line2
    echo -e "${YLW}NOTE:${NC} Run ${BLU}'. ~/.profile'${NC} or ${CYN}log out & in${NC} to be able to run the commands."
    line2
}

clean () {
    if [ -n "$(is_installed)" ]; then
        cd $HOME
        local vc=$(version)
        declare -a patterns=('^export massa_password*' '^export massa_version*'
                             'export PATH="$PATH:$HOME/.local/bin"')
        for pat in "${patterns[@]}"
        do
            [ -n "$(grep "$pat" $PROFILE)" ] && 
            grep -v "$pat" $PROFILE > $PROFILE.tmp && 
            mv $PROFILE.tmp $PROFILE
        done
        rm -r massa 2> /dev/null
        rm $(get_file_paths script) 2> /dev/null
        sudo systemctl disable --now massad 2> /dev/null
        sudo rm $(get_file_paths service) 2> /dev/null
        sudo systemctl daemon-reload 2> /dev/null
        echo -e ""${YLW}"Massa $vc"${NC}" removed from the system :("
    fi
}
# -------------------------------------------------------------
# MAIN
txt=$(echo -e "$header" | sed 's/^/                                /')
txt=$(echo -e "${RED}$txt${NC}")"\n"
ip6=$(get_ip6)
if [ -z "$ip6" ]; then
    txt+='\n'"${YLW}NOTE:${NC} To enable IPv6 on DigitalOcean, refer the link below:"
    txt+='\n'"${BLU}\xF0\x9F\x94\x97 https://docs.digitalocean.com/products/networking/ipv6/how-to/enable/#on-existing-droplets${NC}"
    txt+='\n'$(line2)
fi


install_pre_deps # install required packages for the script

cd $HOME
opts=("Install")
vr=$(version remote)
installed=$(is_installed)
if [ -n "$installed" ]; then
    vc=$(version)
    opts+=("Uninstall")
    opts+=("Update Scripts")
    txt+='\n'"$(echo -e "It seems like "${YLW}"Massa $vc"${NC}" is installed on your system.")"
    txt+='\n'"$(wallet_str)"
    txt+='\n'"$(echo -e ${CYN}"\xE2\x9A\xA0 If you select [1], current Massa installation will be completely removed."${NC})"
    #
    update=$([ "$vc" != "$vr" ] && echo "Update" || echo "")
    opts+=($update)
    if [ -n "$update" ]; then
        txt+='\n'$(line2)
        txt+='\n'$(echo -e ${RED}"\xF0\x9F\x93\xA6 A new version ($vr) is available."${NC})
        txt+='\n'$(line2)
    fi
fi
echo -e "$txt"'\n'


opts+=("Exit")

PS3=$'\n'$'\033[0;33m'"⬣ What would you like to do?: "
select opt in "${opts[@]}";
do
  case $opt in
    "Install")
    clean
    install_deps
    download_bins
    create_config
    save script
    add_profile_local_bin
    set_password
    keys
    services
    info
      break
      ;;
    "Uninstall")
    clean
      break
      ;;
    "Update Scripts")
    save script
    add_profile_local_bin
      break
      ;;
    "Update")
    echo -e '\e[1;35m\xF0\x9F\x9A\x80 Coming Soon...\e[0m'
    done_process
      break
      ;;
    "Exit")
        echo -e "${RED}-ByE\xE2\x9D\xA3\xF0\x9F\x98\x8B${NC}\n"
      break
      ;;
    *)
      echo "Invalid $REPLY"
      ;;
  esac
done
