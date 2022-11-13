#!/bin/bash
#
# This script contains `sudo` command to download/update required packages and register system service for Massa.
#
# - download, make executable and run script:
#
#   1- bash <(curl -sL https://raw.githubusercontent.com/isezen/testscript/main/massa2.sh) && . ~/.profile
#   2- wget -qO massa.sh https://t.ly/1qqz && chmod +x massa.sh && ./massa.sh
#   3- wget -qO massa.sh https://raw.githubusercontent.com/isezen/testscript/main/massa2.sh && chmod +x massa.sh && ./massa.sh
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
REMOTE=https://api.github.com/repos/massalabs/massa/releases/latest
URL=https://raw.githubusercontent.com/isezen/testscript/main
source <(curl -s $URL/common.sh)

header=$(cat <<EOF

    )       )             )  
   (     ( /(  (   (   ( /(  
   )\  ' )(_)) )\  )\  )(_)) 
 _((_)) ((_)_ ((_)((_)((_)_  
| '  \()/ _\` |(_-<(_-</ _\` | 
|_|_|_| \__,_|/__//__/\__,_| 
                   \xF0\x9F\x94\xA5 Fire-\xCE\xB2
EOF
)
# -------------------------------------------------------------
# DEFINE SCRIPTS TO SAVE HERE

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

# Get info about project from remote github API
remote () {
    ret=$(curl -s $REMOTE)
    if [ -n "$(echo $ret | grep 'API rate limit exceeded')" ]; then
        msg_err "API rate limit exceeded."
        red "   Try again after a while ..."
        exit 1
    fi
    echo $ret
}

# Get latest relase url
get_latest_release_url () {
    echo $(remote | jq -r ".assets[].browser_download_url" | 
        grep $(get_os_arch)"\.")
}

# Get version of Massa
version () {
    if [  "${1:-local}" = "local" ]; then
        [ -z "$massa_version" ] && echo "NOT SET" || echo $massa_version
    else
        remote | jq -r ".tag_name"
    fi
}

# Add Massa version to PROFILE
a2p_version () { a2p 'export massa_version='$(version remote); }

# Add Massa password to PROFILE
a2p_pass () { a2p 'export massa_password='$1; }

# Add bootstrap list to config.toml
add_bootstrap_list () {
    if [ "$ADD_BOOTSTRAP_LIST" = true ] ; then
        if is_yes "Do you want to add bootstrap list?"; then
            echo "$bootstrap_list" >> $CONFIG_TOML
        fi
    fi
}

# Get/search binary path
get_bin_loc () {
    loc=
    binary="${1:-massa-client}"
    loc=$(which $binary)
    if [[ -z "$loc" ]]; then
        loc=$(get_file_if_exist "$HOME/massa/$binary/$binary")
    fi
    echo $loc
}

# Get IP type from $USER
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

# Create $CONFIG_TOML
create_config () {
    ip_type=4
    ip=$(get_ip)
    echo "Your external IPv4 address is "$(ylw $ip)
    ip6=$(get_ip6)
    if [ -n "$ip6" ]; then
        echo "Your external IPv6 address is "$(ylw $ip6)
        get_ip_type
    fi
    [ "$ip_type" -eq "6" ] && ip=$ip6
    echo "[network]" > $CONFIG_TOML
    echo "routable_ip = \"$ip\"" >> $CONFIG_TOML
    [ "$ip_type" -eq "4" ] && echo "bind = \"$NETWORK_IP\"" >> $CONFIG_TOML
    echo -e "\n[bootstrap]" >> $CONFIG_TOML
    [ "$ip_type" -eq "4" ] && echo "bind = \"$BOOTSTRAP_IP\"" >> $CONFIG_TOML
    add_bootstrap_list
}

is_installed () {
    [[ -n "$(get_bin_loc massa-client)" && \
       -n "$(get_bin_loc massa-node)" ]]
}

get_wallet () {
    local what=$(tolower ${1:-"address secret public"})
    local addr=
    local massa_client=$(get_bin_loc massa-client)
    if [[ -n "$massa_client" ]]; then
        for w in $what
        do
            local ret=$($massa_client wallet_info -p $massa_password  \
                        2> /dev/null | grep -i $w)
            local col=$([[ $w == "address" ]] && echo '$2' || echo '$3')
            local val=$(echo $ret | awk "{print $col}")
            [ -z "$val" ] && val='NOT SET'
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
        massa_password=$(get_pass 'Enter a password for Massa: ')
        a2p_pass $massa_password
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
    a2p_version
    echo -e "${GRN}${CHK} Binaries are downloaded${NC}"
}

services () {
    service_massad=$(echo "$service_massad" | 
        sed 's/$massa_password/'$massa_password'/g')
    save_embedded_content service
    sudo systemctl daemon-reload
    sudo systemctl enable massad > /dev/null 2>&1
    sudo systemctl restart massad
    sleep 1
    msg_info "Massa service is "$(systemctl is-active massad)
}

keys () {
    echo -e ''
    secret_key=
    if is_yes "Do you have a secret key?"; then
        footer="Added"
        cmd=wallet_add_secret_keys
        read -p 'Enter Secret Key: ' secret_key
    else
        footer="Generated"
        cmd=wallet_generate_secret_key
    fi
    massa_client=$(get_bin_loc massa-client)
    $massa_client $cmd "$secret_key" -p $massa_password > /dev/null 2>&1
    msg_info "Key "$footer
    echo -e ''
}

info () {
    source $PROFILE
    echo -e ${G}"INFO:"${NONE}
    wallet_str
    cmds="$(get_file_names | sed 's/^/'$(tput setaf 2)'/')"
    cmds=$(echo "$cmds" | sed -e 's/$/'$(tput sgr0)'/')
    cmds=$(echo "$cmds" | sed 's/^/ | /')
    echo -e "Available commands:"
    echo "$cmds"
    line2
    echo -e "${Y}NOTE:${NONE} Run ${B}'. ~/.profile'${NONE} or ${C}log out & in${NONE} to be able to run the commands."
    line2
}

clean () {
    if is_installed; then
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
        sudo systemctl disable --now massad 2> /dev/null
        sudo rm $(get_emb_cont_file_paths service) 2> /dev/null
        sudo systemctl daemon-reload 2> /dev/null
        echo -e ""${YLW}"Massa $vc"${NC}" removed from the system :("
    fi
}
# -------------------------------------------------------------
# MAIN
cd $HOME
# install required packages for the script
install_pre_deps "screen jq curl wget git"
clear

txt=$(red "$header\n" | sed 's/^/                                /')
if [ -z "$(get_ip6)" ]; then
    txt+='\n'$(msg_note $(ylw "NOTE: "))
    txt+="To enable IPv6 on DigitalOcean, refer the link below:"
    txt+='\n'$(blu "   https://docs.digitalocean.com/products/networking/ipv6/how-to/enable/#on-existing-droplets")
    txt+='\n'$(line2)
fi

opts=("Install")
if is_installed; then
    vc=$(version)
    opts+=("Uninstall")
    txt+='\n'"$(echo -e "It seems like "$(blu "Massa $vc")" is installed on your system.")"
    txt+='\n'"$(wallet_str)"
    txt+='\n'$(msg_warn "If you select [1], current Massa installation will be completely removed.")
    #
    vr=$(version remote)
    if [ "$vc" != "$vr" ]; then
        opts+=("Update")
        txt+='\n'$(line2)
        txt+='\n'$(red "$PACK A new version ($vr) is available.")
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
        a2p
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
    "Update")
        sudo systemctl disable --now massad 2> /dev/null
        download_bins
        sudo systemctl restart massad
      break
      ;;
    "Exit")
        red "-ByE\U02763\U1F60B\n"
      break
      ;;
    *)
        echo "Invalid $REPLY"
      ;;
  esac
done
