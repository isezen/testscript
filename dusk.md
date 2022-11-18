# INSTALL DUSK

**NOTE:** Tested on Ubuntu Server 22.04 LTS
**NOTE:** User must have `sudo` priviliges.

## Install Wallet and Register

### Install by pre-compiled binaries

Download and extract pre-compiled binary (This is for linux).
```sh
wget https://github.com/dusk-network/wallet-cli/releases/download/v0.12.0/ruskwallet0.12.0-linux-x64.tar.gz
tar -xzvf ruskwallet0.12.0-linux-x64.tar.gz
cd rusk-wallet0.12.0-linux-x64/
```

### Install from source

### Install pre-requisities
Install required packages and Rust.
```sh
sudo apt install build-essential pkg-config libssl-dev
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### Build from source
Binary file will be in `wallet-cli/target/release`.
```sh
git clone https://github.com/dusk-network/wallet-cli.git
cd wallet-cli
make install
cd target/release
```

## Registration

* Run rusk-wallet `./rusk-wallet`
* Select new wallet
* create a new password (enter 2 times)
* **Save/backup 12 secret phrases**
* select `y`
* Accept the suggested address
* **Backup suggested DUSK address**
* Select `export previsioner key-pair`
* Select/change the saving directory i.e. `/root/.dusk/rusk-wallet`
* Enter the password created in step 2.
* Backup the files ending with `.key` and `.cpk`.
* Fill the registration [form](https://docs.google.com/forms/d/e/1FAIpQLScxABRnszbBEaTZAIg2TwfJVIq0kRggy8QK2MRBTO7vuyP_Ug/viewform)


## Install DUSK Node

```sh
curl --proto '=https' --tlsv1.2 -sSf https://dusk-infra.ams3.digitaloceanspaces.com/rusk/itn-installer.sh | sudo sh
```

Open ports:
```sh
sudo ufw allow 9000:9005/udp
```

To launch the node:
```sh
service rusk start
service dusk start
tail -F /var/log/{d,r}usk.{log,err}
```

## Update Consensus Key

Copy the `.key` file created in previous steps as `consensus.keys` to `/opt/dusk/conf` directory.
```sh
sudo cp .dusk/rusk-wallet/XXXXXXX.key /opt/dusk/conf/consensus.keys
```
Update the password used to access your consensus key
```sh
echo 'DUSK_CONSENSUS_KEYS_PASS=<your_password>' | sudo tee /opt/dusk/services/dusk.conf
```

## Start the node
```sh
sudo service rusk start
sudo service dusk start
```

# RESOURCES:
1) [Dusk Network to launch rolling Incentivized Testnet activities](https://dusk.network/news/dusk-network-to-launch-rolling-incentivized-testnet-activities)
1) [Incentivized Testnet - Step-by-step Guide](https://dusk.network/pages/incentivized-testnet)
1) [Install from source](https://github.com/dusk-network/wallet-cli/blob/main/src/bin/README.md)