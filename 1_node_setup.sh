#!/bin/bash

KEY="blockxtestkey-1"
CHAINID="blockx-11"
MONIKER="validator-1"
MNEMONIC=""
GENESIS_ACCOUNT_AMOUNT=100000000000000000000000000abcx
STAKE_AMOUNT=10000000000000000000000abcx

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

# Change parameter token denominations to abcx
cat $HOME/.blockxd/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="abcx"' > $HOME/.blockxd/config/tmp_genesis.json && mv $HOME/.blockxd/config/tmp_genesis.json $HOME/.blockxd/config/genesis.json
cat $HOME/.blockxd/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="abcx"' > $HOME/.blockxd/config/tmp_genesis.json && mv $HOME/.blockxd/config/tmp_genesis.json $HOME/.blockxd/config/genesis.json
cat $HOME/.blockxd/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="abcx"' > $HOME/.blockxd/config/tmp_genesis.json && mv $HOME/.blockxd/config/tmp_genesis.json $HOME/.blockxd/config/genesis.json
cat $HOME/.blockxd/config/genesis.json | jq '.app_state["mint"]["params"]["mint_denom"]="abcx"' > $HOME/.blockxd/config/tmp_genesis.json && mv $HOME/.blockxd/config/tmp_genesis.json $HOME/.blockxd/config/genesis.json

if [[ $1 == "pending" ]]; then
    echo "pending mode on; block times will be set to 30s."
    sed -i 's/timeout_propose = "3s"/timeout_propose = "30s"/g' $HOME/.blockxd/config/config.toml
    sed -i 's/timeout_propose_delta = "500ms"/timeout_propose_delta = "5s"/g' $HOME/.blockxd/config/config.toml
    sed -i 's/timeout_prevote = "1s"/timeout_prevote = "10s"/g' $HOME/.blockxd/config/config.toml
    sed -i 's/timeout_prevote_delta = "500ms"/timeout_prevote_delta = "5s"/g' $HOME/.blockxd/config/config.toml
    sed -i 's/timeout_precommit = "1s"/timeout_precommit = "10s"/g' $HOME/.blockxd/config/config.toml
    sed -i 's/timeout_precommit_delta = "500ms"/timeout_precommit_delta = "5s"/g' $HOME/.blockxd/config/config.toml
    sed -i 's/timeout_commit = "5s"/timeout_commit = "150s"/g' $HOME/.blockxd/config/config.toml
fi

# Allocate genesis accounts (cosmos formatted addresses)
./build/blockxd add-genesis-account $(./build/blockxcli keys show $KEY -a) $GENESIS_ACCOUNT_AMOUNT

# Sign genesis transaction
./build/blockxd gentx --name $KEY --amount=$STAKE_AMOUNT --keyring-backend test

# Collect genesis tx
./build/blockxd collect-gentxs

# Run this to ensure everything worked and that the genesis file is setup correctly
./build/blockxd validate-genesis

# Command to run the rest server in a different terminal/window
echo -e '\nrun the following command in a different terminal/window to run the REST server and JSON-RPC:'
echo -e "./build/blockxcli rest-server --laddr \"tcp://0.0.0.0:8545\" --chain-id $CHAINID --trace --rpc-api eth,net,web3 --unsafe-cors\n"

# Start the node (remove the --pruning=nothing flag if historical queries are not needed)
./build/blockxd start --pruning=nothing --rpc.unsafe --log_level "main:info,state:info,mempool:info" --trace
