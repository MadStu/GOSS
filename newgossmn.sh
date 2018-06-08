#!/bin/bash
clear
sleep 1
if [ -e getgossinfo.json ]
then
	echo " "
	echo "Script running already?"
	echo " "

else
echo "blah" > getgossinfo.json

THISHOST=$(hostname -f)

sudo apt-get install jq pwgen bc -y

#killall gossipcoind
#rm -rf gossipcoin*
#rm -rf .gossipcoin*

wget https://github.com/g0ssipcoin/GossipCoinCore/releases/download/v1.0.0/gossip_ubuntu_16.04.zip
unzip gossip_ubuntu_16.04.zip
mv gossip_ubuntu_16.04 gossipcoin
chmod 777 gossipcoin/go*
rm gossip_ubuntu_16.04.zip

mkdir ~/.gossipcoin
RPCU=$(pwgen -1 4 -n)
PASS=$(pwgen -1 14 -n)
EXIP=$(curl ipinfo.io/ip)

printf "rpcuser=rpc$RPCU\nrpcpassword=$PASS\nrpcport=22122\nrpcthreads=8\nrpcallowip=127.0.0.1\nbind=$EXIP:22122\nmaxconnections=32\ngen=0\nexternalip=$EXIP\ndaemon=1\n\n" > ~/.gossipcoin/gossipcoin.conf

~/gossipcoin/gossipcoind -daemon
sleep 20
MKEY=$(~/gossipcoin/gossipcoin-cli masternode genkey)

~/gossipcoin/gossipcoin-cli stop
printf "masternode=1\nmasternodeprivkey=$MKEY\n\n" >> ~/.gossipcoin/gossipcoin.conf
sleep 60
~/gossipcoin/gossipcoind -daemon
sleep 10
~/gossipcoin/gossipcoin-cli stop
sleep 30

mkdir ~/backup
cp ~/.gossipcoin/gossipcoin.conf ~/backup/gossipcoin.conf
cp ~/.gossipcoin/wallet.dat ~/backup/wallet.dat

crontab -l > mycron
echo "@reboot ~/gossipcoin/gossipcoind -daemon >/dev/null 2>&1" >> mycron
crontab mycron
rm mycron

echo "Reindexing blockchain..."

sleep 5
rm ~/.gossipcoin/mncache.dat
rm ~/.gossipcoin/mnpayments.dat
sleep 35
~/gossipcoin/gossipcoind -daemon -reindex
sleep 2

################################################################################

sleep 10

BLKS=$(curl http://chain.gossipcoin.net/api/getblockcount)

while true; do
WALLETBLOCKS=$(~/gossipcoin/gossipcoin-cli getblockcount)
if (( $(echo "$WALLETBLOCKS < $BLKS" | bc -l) )); then
	clear
	echo " "
	echo " "
	echo "  Keep waiting..."
	echo " "
	echo "    Blocks so far: $WALLETBLOCKS"
	echo " "
	echo " "
	echo " "
	sleep 5
else
	echo " "
	echo " "
	echo "    Complete!"
	echo " "
	echo " "
	sleep 5
	break
fi
	echo " "
	echo " "
	echo " "
done


echo "Now wait for AssetID: 999..."
sleep 1

while true; do

MNSYNC=$(~/gossipcoin/gossipcoin-cli mnsync status)
echo "$MNSYNC" > mngosssync.json
ASSETID=$(jq '.RequestedMasternodeAssets' mngosssync.json)

if (( $(echo "$ASSETID < 900" | bc -l) )); then
	clear
	echo " "
	echo " "
	echo "  Keep waiting..."
	echo " "
	echo "  Looking for: 999"
	echo "      AssetID: $ASSETID"
	echo " "
	echo " "
	echo " "
	sleep 5
else
	echo " "
	echo " "
	echo "    Complete!"
	echo " "
	echo " "
	sleep 5
	break
fi
	echo " "
	echo " "
	echo " "
done

###########################

rm mngosssync.json

echo " "
echo " "
echo " "

sleep 2
echo "=================================="
echo " "
echo "Your masternode.conf should look like:"
echo " "
echo "MNxx $EXIP:22122 $MKEY TXID VOUT"
echo " "
echo "=================================="
echo " "
echo "RPC details for your windows wallet gossipcoin.conf:"
echo " "
echo "rpcuser=rpc$RPCU"
echo "rpcpassword=$PASS"
echo "rpcport=22122"
echo "port=22123"
echo "rpcallowip=127.0.0.1"
echo "daemon=1"
echo "listen=1"
echo "server=1"
echo "externalip=$EXIP:22123"
echo " "
sleep 3
echo " "
echo "  - You can now Start Alias in the windows wallet!"
echo " "
echo "       Thanks for using MadStu's Install Script"
echo " "

rm getgossinfo.json
cp ~/.gossipcoin/masternode.conf ~/backup/masternode.conf

fi
