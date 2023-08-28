#!/bin/bash

KEY="blockxtestkey-1"
CHAINID="blockx-11"
MONIKER="localtestnet-1"
MNEMONIC=""

# remove existing daemon and client
rm -rf ~/.blockx*

make build

./build/blockxcli config keyring-backend test

# Set up config for CLI
./build/blockxcli config chain-id $CHAINID
./build/blockxcli config output json
./build/blockxcli config indent true
./build/blockxcli config trust-node true

# Set moniker and chain-id for BlockX (Moniker can be anything, chain-id must be an integer)
./build/blockxd init $MONIKER --chain-id $CHAINID

# if $KEY exists it should be deleted
echo $MNEMONIC | ./build/blockxcli keys add $KEY --recover
