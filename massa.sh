#!/bin/bash
#
# This script contains `sudo` command to download/update required packages and register system service for Massa.
#
# - download, make executable and run script:
#   wget -qO massa.sh https://gist.githubusercontent.com/isezen/3e4646cdacc4ea985c3f2bd6f42dbd39/raw/massa.sh && chmod +x massa.sh && ./massa.sh
# - Just type `massa-client` to run.
# - to see the logs, type `see-logs`.
#
echo -e ''
curl -s https://api.testnet.run/logo.sh | bash && sleep 3
echo -e ''
GREEN="\e[32m"
NC="\e[0m"
RED='\033[0;31m'
YELLOW='\033[1;33m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
VER="TEST.16.0"
ARC="_"$(dpkg --print-architecture)

dependencies () {
    pkgs="build-essential clang librocksdb-dev screen jq pkg-config curl 
    git libssl-dev libclang-dev"
    installed=false
    to_install=
    for p in $pkgs
    do
        if [ -z "$(dpkg -l | grep $p)" ]; then
            to_install+=" $p"
        fi
    done
    if test -n "$to_install"; then
        echo -e ${YELLOW}'Installing dependencies\e[0m'${NC}
        echo -e ''
        sudo apt update
        sudo apt install $to_install
        installed=true
    fi
    # if you are on Ubuntu Server 22.04, install libssl1.1
    UBUNTU_VER=$(lsb_release -r | awk 'BEGIN{FS=":"} {print $2}' | awk '{$1=$1};1')
    if [ $UBUNTU_VER = '22.04' ]; then
        if [ -z "$(dpkg -l | grep libssl1.1)" ]; then
            echo "Installing libssl1.1"
            wget -qO libssl1.1.deb http://security.debian.org/debian-security/pool/updates/main/o/openssl/libssl1.1_1.1.0l-1~deb9u6$ARC.deb
            sudo dpkg -i libssl1.1.deb
            installed=true
        fi
    fi
    if [ "$installed" = true ] ; then
        echo -e ${YELLOW}'Dependencies installed\e[0m'${NC}
    fi
}

file_exist () {
    loc=
    file="${1:-/etc/systemd/system/massad.service}"
    if test -f "$file"; then loc=$FILE; fi
    echo $loc
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
        echo 0
    else
        echo 1
    fi
}

get_wallet () {
    what=$(echo "${1:-address}" | awk '{print tolower($0)}')
    addr=
    massa_client=$(get_bin_loc massa-client)
    if [[ -n "$massa_client" ]]; then
        addr=$($massa_client wallet_info -p $password | grep -i $what)
        if [[ $what == "address" ]]; then
            awk_str='$2'
        else
            awk_str='$3'
        fi
        addr=$(echo $addr | awk "{print $awk_str}")
    fi
    echo $addr
}

get_ver () {
    ver=
    massa_client=$(get_bin_loc massa-client)
    if [[ -n "$massa_client" ]]; then
        ns=$($massa_client get_status -p $password)
        ver=$(echo "$ns" | grep 'Version' | awk '{print $2}')        
    fi
    echo $ver
}

binaries () {
    cd $HOME
if [ ! "$password" ]; then
    echo "################################################################"
    echo -e ""
    read -p ' Enter your node password!: ' password
    echo 'export password='$password >> $HOME/.profile
    echo -e ""
    echo "################################################################"
fi
    EXTERNAL=$(curl -4 ifconfig.co)
    source $HOME/.profile
    echo -e ''
    echo -e ${YELLOW}'Download Binaries'${NC} && sleep 1
    echo -e ''
    if [ $ARC = '_amd64' ]; then
        ARC=""
    fi
    wget https://github.com/massalabs/massa/releases/download/"$VER"/massa_"$VER"_release_linux$ARC.tar.gz -O massa.tar.gz
    tar -xvf massa.tar.gz
    mkdir -p $HOME/.local/bin
    cp $HOME/massa/massa-node/massa-node $HOME/.local/bin
    wget https://raw.githubusercontent.com/Errorist79/massa/main/config.toml -O $HOME/massa/massa-node/config/config.toml
    sed -i -e "s/^routable_ip *=.*/routable_ip = \"$EXTERNAL\"/" $HOME/massa/massa-node/config/config.toml
#
tee $HOME/.local/bin/massa-client > /dev/null <<EOF
#!/bin/bash
cd $HOME/massa/massa-client
./massa-client $@
EOF
chmod +x $HOME/.local/bin/massa-client
#
tee $HOME/.local/bin/see-logs > /dev/null <<EOF
#!/bin/bash
journalctl -u massad.service -fo cat
EOF
chmod +x $HOME/.local/bin/see-logs
#
tee $HOME/.local/bin/node-status > /dev/null <<EOF
#!/bin/bash
massa-client get_status -p $password
EOF
chmod +x $HOME/.local/bin/node-status
}

services () {
    echo -e ''
    echo -e ${YELLOW}'Creating Daemon'${NC} && sleep 1
    echo -e ''
    sudo tee /etc/systemd/system/massad.service > /dev/null <<EOF
[Unit]
Description=Massa Daemon
After=network-online.target

[Service]
Environment="RUST_BACKTRACE=full"
WorkingDirectory=$HOME/massa/massa-node
User=$USER
ExecStart=$HOME/.local/bin/massa-node -p $password
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable massad
sudo systemctl restart massad
sudo systemctl status massad
}

keys () {
    echo -e ''
    echo -e "Generating keys..."
    echo -e ''
    sleep 3
    cd $HOME/massa/massa-client
    ./massa-client wallet_generate_secret_key  -p $password > /dev/null 2>&1
    sleep 5
}

rolls () {
    cd $HOME
    wget -q https://api.testnet.run/massa_rolls.sh -O rolls.sh && chmod +x rolls.sh
    screen -dmS autorolls ./rolls.sh
}

done_process () {
    LOG_SEE="see-logs"
    NODE_STATUS="node-status"
    ROLLS="screen -r"
    echo -e ${GREEN}"======================================================"${NC}
    ADDR=$(cd $HOME/massa/massa-client && ./massa-client wallet_info -p $password | grep Address)
    echo -e "Here is your ${BLUE}$ADDR${NC}"
    echo -e "Available commands:"
    echo -e " | massa-client"
    echo -e " | ${BLUE}$LOG_SEE${NC} "
    echo -e " | node-status"
    echo -e "The buy_rolls process happens automatically, to check status: ${BLUE}$ROLLS${NC}"
    echo -e ${RED}"please don't close the screen! Just use the CTRL+A+D key combination to leave the screen! "${NC}
    echo -e ${GREEN}"======================================================"${NC}
}


opts="Install quit"
if [ -n "$(is_installed)" ]; then
    ver=$(get_ver)
    echo ""
    echo -e "It seems like "${RED}"Massa $ver"${NC}" is already installed on your system."
    echo -e ${PURPLE}"==============================================================="${NC}
    echo -e "Secret Key: ${RED}$(get_wallet secret)${NC}"
    echo -e "Public Key: ${GREEN}$(get_wallet public)${NC}"
    echo -e "Address   : ${BLUE}$(get_wallet)${NC}"
    echo -e ${PURPLE}"==============================================================="${NC}
    opts="Install Update Additional quit"
fi

PS3="What would you like to do?: "
select opt in $opts;
do

  case $opt in
    Install)
    echo -e '\e[1;32mThe installation process begins...\e[0m'
    sleep 1
    dependences
    binaries
    services
    keys
    rolls
    done_process
      break
      ;;
    Update)
    echo -e '\e[1;32mThe updating process begins...\e[0m'
    echo -e ''
    echo -e '\e[1;32mSoon...'
    done_process
      break
      ;;
    Additional)
    echo -e '\e[1;32mAdditional commands...\e[0m'
    echo -e ''
    echo -e '\e[1;32mSoon...'
    done_process
      ;;
    quit)
    echo -e '\e[1;32mexit...\e[0m'
      break
      ;;
    *)
      echo "Invalid $REPLY"
      ;;
  esac
done