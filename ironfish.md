# INSTALL IRONFISH

**NOTE:** Tested on Ubuntu Server 22.04 LTS
**NOTE:** Minimum requirements are 4CPU+8GB RAM. However, it might run with 2CPU. Just try.

## Create User for Ironfish (OPTIONAL)

If you don't want a seperate user for ironfish, you can skip this step.

```sh
sudo adduser iron
sudo usermod -aG sudo iron
su - iron
```

## Install required packages

### Update packages (OPTIONAL)
```sh
sudo apt update && sudo apt upgrade -y
```

### Install NPM
This is required to install ironfish easily.

```sh
wget https://nodejs.org/download/release/v16.19.0/node-v16.19.0-linux-x64.tar.gz
tar -xzvf node-v16.19.0-linux-x64.tar.gz
```

#### Add NPM to the system PATH

Open `.profile` file by `nano .profile` command and add the following line.
```sh
export PATH="$HOME/node-v16.19.0/bin:$PATH"
```
and source the `.profile` by `source ~/.profile` command.

After this step `which npm` command should show a similar result as follows:
```
/home/iron2/node-v16.19.0-linux-x64/bin/npm
```

### Install/update Ironfish

Run the command below to install ironfish
```sh
npm install -g ironfish
```
If you installed ironfish succesfully, `which ironfish` command should give the following result:
```
/home/iron2/node-v16.19.0-linux-x64/bin/ironfish
```

If you need to update ironfish in the future, use the command below:
```sh
npm update -g ironfish
```

### Download chain data
To make it easier to catch up the current height, we can download the chain data from a snapshot by the command below. This is a long-running process. **You may want to run this command in a screen session.**
```sh
ironfish chain:download
```

## Set Graffiti and Telemetry
You can simply run `ironfish testnet` command to set your graffiti and telemetry or run the commands below. You have to register yourself to set a graffiti/username. Register here https://testnet.ironfish.network/signup

```sh
ironfish config:set blockGraffiti YOUR_GRAFFITI_NAME
ironfish config:set enableTelemetry true
```

Also you can set some other settings:
```sh
ironfish config:set logPrefix "[%time%] [%level%] [%tag%]"
ironfish config:set enableLogFile true
ironfish config:set loglevel "*:debug"
```

## How to start ironfish
```sh
nohup ironfish start --workers=-1 </dev/null >/dev/null 2>&1 & && disown
```


## USEFUL COMMANDS:

* View the logs: `tail -f .ironfish/ironfish.log`
* Follow ironfish status ` ironfish status -f`
* See public key of default account: `ironfish accounts:publickey`
* stop ironfish `ironfish stop`

## REFERENCES:
* [About Testnet](https://testnet.ironfish.network/about)
* [Ironfish Installation](https://ironfish.network/docs/onboarding/installation-iron-fish)
* [Testnet Leaderboard](https://testnet.ironfish.network/leaderboard)
* [Testnet FAQ](https://testnet.ironfish.network/faq)

