#!/bin/bash
#
# This script contains `sudo` command to download/update required packages and register system service for Massa.
#
# - download, make executable and run script:
#   curl -sL https://t.ly/1qqz | bash
#
#   bash <(curl -sL https://t.ly/1qqz) && . ~/.profile
#   wget -qO massa.sh https://t.ly/1qqz && chmod +x massa.sh && ./massa.sh
#   wget -qO massa.sh https://raw.githubusercontent.com/isezen/testscript/main/massa.sh && chmod +x massa.sh && ./massa.sh
# - Just type `massa-client` to run.
# - to see the logs, type `see-logs`.
#
# curl -s https://api.testnet.run/logo.sh | bash

MASSA_PATH=$HOME
CONFIG_TOML=$MASSA_PATH/massa/massa-node/config/config.toml
NETWORK_IP="0.0.0.0:31244"
BOOTSTRAP_IP="0.0.0.0:31245"
# -------------------------------------------------------------
NC="\e[0m"; GRN="\e[32m"
RED='\033[1;31m'; YLW='\033[1;33m'
ORG='\033[0;33m'; BLU='\033[0;34m'
PRP='\033[0;35m'; CYN='\033[0;36m'
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
echo -e "\e[32m \u2714 Massa Service is "\$(systemctl is-active massad)"\e[0m"
ns=\$(massa-client get_status -p \$massa_password)
if  [ -z "$(echo "$ns" | grep "os error 111")" ]; then
    echo -e "\033[0;31m$(echo "\$ns" | grep "Version")\e[0m"
    echo -e "\$(echo "\$ns" | grep "Node's IP")"

    echo -e "\nConfig:"
    echo -e "\033[0;34m\$(echo "\$ns" | grep "Genesis timestamp")\e[0m"
    echo -e "\033[0;34m\$(echo "\$ns" | grep "End timestamp")\e[0m"
    echo -e "Episode ends in:"
    massa-client when_episode_ends -p \$massa_password | sed 's/seconds.*/seconds/' | tr ',' '\n' | awk '{$1=$1};1' | sed 's/^/    /'

    echo -e "\nNetwork stats:"
    echo -e "\$(echo "\$ns" | grep "Active nodes")"
    echo -e "\033[0;31m\$(echo "\$ns" | grep "In connections")\e[0m"
    echo -e "\e[32m\$(echo "\$ns" | grep "Out connections")\e[0m"
else
    echo -e "\033[0;31m\xE2\x8C\x9A Massa is currently bootstrapping\xE2\x80\xA6 \xE2\x98\x95\e[0m"
fi
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

line () { echo -e ${PRP}"==============================================================="${NC}; }
get_ubuntu_ver () { echo $(lsb_release -r | awk 'BEGIN{FS=":"} {print $2}' | 
    awk '{$1=$1};1'); }
get_ip () { echo $(curl -s -4 ifconfig.co); }

get_ip_type () {
    while true; do
        read -p "What kind of IP do you have? (ipv-[4]/6): " ip_type
        ip_type=${ip_type:-4}
        case $ip_type in 
            [4] ) break;;
            [6] ) break;;
            * ) echo -e "${RED}\u274c Enter 4 or 6. Default is [4].${NC}";;
        esac
    done
}

add_bootstrap_list () {
    while true; do
        read -p "Do you want to add bootstrap list? (y/[n]) " yn
        yn=${yn:-n}
        case $yn in 
            [yY] ) break;;
            [nN] ) break;;
            * ) echo [y]es or [n]o?;
        esac
    done
}

create_config () {
    ip=$(get_ip)
    echo -e "\nYour external IP is ${YLW}$ip${NC}"
    get_ip_type
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
    if [ "$yn" = "y" ]; then
        echo "$bootstrap_list" >> $CONFIG_TOML
    fi
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
            echo -e ${YLW}' \u2714 '$file_path${NC}
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
    what=$(echo "${1:-address secret public}" | awk '{print tolower($0)}')
    addr=
    massa_client=$(get_bin_loc massa-client)
    if [[ -n "$massa_client" ]]; then
        for w in $what
        do
            ret=$($massa_client wallet_info -p $massa_password  2> /dev/null \
                  | grep -i $w)
            col=$([[ $w == "address" ]] && echo '$2' || echo '$3')
            addr+=$(echo $ret | awk "{print $col}")"\n"
        done
        addr="${addr%??}"
    fi
    echo -e "$addr"
}

wallet_str () {
    secret=$(get_wallet secret)
    public=$(get_wallet public)
    address=$(get_wallet address)
    secret=$([ -z "$secret" ] && echo "NOT SET" || echo "$secret")
    public=$([ -z "$public" ] && echo "NOT SET" || echo "$public")
    address=$([ -z "$address" ] && echo "NOT SET" || echo "$address")
    line
    echo -e "Secret Key : ${RED}$secret${NC}"
    echo -e "Public Key : ${GRN}$public${NC}"
    echo -e "Address    : ${BLU}$address${NC}"
    line
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
    v=$massa_version
    echo $([ -z "$1" ] && [ -z "$v" ] && echo "NOT SET" || 
           remote | jq -r ".tag_name")
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
    installed=false
    to_install=$(to_install "$1")
    header="${2:-Installing dependencies}"
    footer="${3:-Dependencies installed}"
    if test -n "$to_install"; then
        echo -e ${YLW}"$header\e[0m"${NC}
        echo -e ''
        sudo apt update
        sudo apt install $to_install
        installed=true
    fi
    if [ "$installed" = true ] ; then
        echo -e ${YLW}"$footer\e[0m"${NC}
    fi
}

install_pre_deps () {
    pkgs="screen jq curl wget git"
    header="Installing pre-dependencies to run the script"
    footer="Pre-dependencies installed"
    install "$pkgs" "$header" "$footer"
}

install_deb_libssl1 () {
    arch="_"$(get_arch)
    wget -qO libssl1.1.deb http://security.debian.org/debian-security/pool/updates/main/o/openssl/libssl1.1_1.1.0l-1~deb9u6$arch.deb
    sudo dpkg -i libssl1.1.deb
}

install_deps () {
    pkgs="build-essential clang librocksdb-dev pkg-config libssl-dev libclang-dev"
    header="Installing dependencies"
    footer="Dependencies installed"
    install "$pkgs" "$header" "$footer"
    #
    # if Ubuntu 22.04, install libssl1.1 from debian repo.
    if [ $(get_ubuntu_ver) = '22.04' ]; then
        if [ -z "$(dpkg -l | grep libssl1.1)" ]; then
            echo -e ${YLW}'Installing libssl1.1\e[0m'${NC}
            install_deb_libssl1
            echo -e ${YLW}'libssl1.1 installed\e[0m'${NC}
        fi
    fi
}

set_password () {
    psw_exist=$(grep "^export massa_password*" $HOME/.profile)
    if [ -z "$psw_exist" ]; then
        unset massa_password
    fi
    if [ ! "$massa_password" ]; then
        stty -echo
        while [ -z "${massa_password}" ]; do
            echo -e ""
            read -p 'Enter a password for Massa: ' massa_password
        done
        # read -p 'Enter a password for Massa: ' massa_password
        stty echo
        echo 'export massa_password='$massa_password >> $HOME/.profile
        echo -e ""
        echo "################################################################"
    fi
    source $HOME/.profile
}

download_bins () {
    vr=$(version remote)
    remote=$(get_latest_release_url)
    file="$(basename "${remote}")"
    local=/tmp/$file
    if test -n "$local"; then
        wget -qO $local "$remote"
    fi
    tar -xzf $local -C $MASSA_PATH
    echo 'export massa_version='$vr >> $HOME/.profile
    echo -e ${GRN}'\u2714 Binaries are downloaded'${NC}
}

services () {
    service_massad=$(echo "$service_massad" | 
        sed 's/$massa_password/'$massa_password'/g')
    save service
    sudo systemctl daemon-reload
    sudo systemctl enable massad  > /dev/null 2>&1
    sudo systemctl restart massad
    sleep 1
    echo -e ${GRN}" \u2714 Massa Service is "$(systemctl is-active massad)${NC}
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
    footer=${GRN}"\u2714 Key "$footer${NC}
    echo -e "$footer"
    echo -e ''
    massa_client=$(get_bin_loc massa-client)
    $massa_client $cmd "$secret_key" -p $massa_password > /dev/null 2>&1
}

rolls () {
    cd $HOME
    wget -q https://api.testnet.run/massa_rolls.sh -O rolls.sh && chmod +x rolls.sh
    screen -dmS autorolls ./rolls.sh
}

info () {
    echo -e ${GRN}"INFO:"${NC}
    wallet_str
    cmds="$(get_file_names | sed 's/^/'$(tput setaf 2)'/')"
    cmds=$(echo "$cmds" | sed -e 's/$/'$(tput sgr0)'/')
    cmds=$(echo "$cmds" | sed 's/^/ | /')
    echo -e "Available commands:"
    echo "$cmds"
    echo -e "${YLW}NOTE:${NC} Run ${BLU}'. ~/.profile'${NC} or ${CYN}log out & in${NC} to be able to run the commands."
    line
    # ROLLS="screen -r"
    # echo -e "The buy_rolls process happens automatically, to check status: ${BLU}'$ROLLS'${NC}"
    # echo -e ${RED}"! Please don't close the screen."${NC}
    # echo -e ${RED}"! Just use the CTRL+A+D key combination to leave the screen."${NC}
    # line
}

clean () {
    if [ -n "$(is_installed)" ]; then
        cd $HOME
        vc=$(version)
        pat="^export massa_password*"
        [ -n "$(grep "$pat" $HOME/.profile)" ] && 
        grep -v "$pat" .profile > .profile.tmp && 
        mv .profile.tmp .profile
        pat="^export massa_version*"
        [ -n "$(grep "$pat" $HOME/.profile)" ] && 
        grep -v "$pat" .profile > .profile.tmp && 
        mv .profile.tmp .profile
        rm -r massa 2> /dev/null
        rm $(get_file_paths script) 2> /dev/null
        sudo systemctl disable --now massad 2> /dev/null
        sudo rm $(get_file_paths service) 2> /dev/null
        sudo systemctl daemon-reload 2> /dev/null
        echo -e ""${YLW}"Massa $vc"${NC}" removed from the system."
    fi
}
# -------------------------------------------------------------
# MAIN

install_pre_deps # install required packages for the script

cd $HOME
opts="Install"
vr=$(version remote)
installed=$(is_installed)
txt=$(echo -e "${RED}$header${NC}")"\n"
if [ -n "$installed" ]; then
    opts+=" Uninstall"
    txt+='\n'"$(echo -e "It seems like "${YLW}"Massa $vc"${NC}" is installed on your system.")"
    txt+='\n'"$(wallet_str)"
    txt+='\n'"$(echo -e ${CYN}"\xE2\x9A\xA0 If you select [1], current Massa installation will be completely removed."${NC})"
    #
    vc=$(version)
    update=$([ "$vc" != "$vr" ] && echo "Update" || echo "")
    opts+=" "$update
    if [ -n "$update" ]; then
        txt+='\n'$(line)
        txt+='\n'$(echo -e ${RED}"\xF0\x9F\x93\xA6 A new version ($vr) is available."${NC})
        txt+='\n'$(line)
    fi
fi
echo -e "$txt"


opts+=" Exit"

PS3=$'\n'$'\033[0;33m'"⬣ What would you like to do?: "
select opt in $opts;
do
  case $opt in
    Install)
    clean
    install_deps
    download_bins
    create_config
    set_password
    save script
    keys
    services
    # rolls
    info
    source $HOME/.profile
      break
      ;;
    Uninstall)
    clean
      break
      ;;
    Update)
    echo -e '\e[1;35m\xF0\x9F\x9A\x80 Coming Soon...\e[0m'
    done_process
      break
      ;;
    Exit)
        echo -e "${RED}-ByE\xE2\x9D\xA3\xF0\x9F\x98\x8B${NC}\n"
      break
      ;;
    *)
      echo "Invalid $REPLY"
      ;;
  esac
done
