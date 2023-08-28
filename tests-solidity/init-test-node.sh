#!/bin/bash

CHAINID="ethermint-1337"
MONIKER="localtestnet"

VAL_KEY="localkey"
VAL_MNEMONIC="gesture inject test cycle original hollow east ridge hen combine junk child bacon zero hope comfort vacuum milk pitch cage oppose unhappy lunar seat"

USER1_KEY="user1"
USER1_MNEMONIC="copper push brief egg scan entry inform record adjust fossil boss egg comic alien upon aspect dry avoid interest fury window hint race symptom"

USER2_KEY="user2"
USER2_MNEMONIC="maximum display century economy unlock van census kite error heart snow filter midnight usage egg venture cash kick motor survey drastic edge muffin visual"

# remove existing daemon and client
rm -rf ~/.ethermint*

blockxcli config keyring-backend test

# Set up config for CLI
blockxcli config chain-id $CHAINID
blockxcli config output json
blockxcli config indent true
blockxcli config trust-node true

# Import keys from mnemonics
echo $VAL_MNEMONIC | blockxcli keys add $VAL_KEY --recover
echo $USER1_MNEMONIC | blockxcli keys add $USER1_KEY --recover
echo $USER2_MNEMONIC | blockxcli keys add $USER2_KEY --recover

# Set moniker and chain-id for BlockX (Moniker can be anything, chain-id must be an integer)
blockxd init $MONIKER --chain-id $CHAINID

# Allocate genesis accounts (cosmos formatted addresses)
blockxd add-genesis-account $(blockxcli keys show $VAL_KEY -a) 1000000000000000000000abcx,10000000000000000stake
blockxd add-genesis-account $(blockxcli keys show $USER1_KEY -a) 1000000000000000000000abcx,10000000000000000stake
blockxd add-genesis-account $(blockxcli keys show $USER2_KEY -a) 1000000000000000000000abcx,10000000000000000stake

# Sign genesis transaction
blockxd gentx --name $VAL_KEY --keyring-backend test

# Collect genesis tx
blockxd collect-gentxs

# Run this to ensure everything worked and that the genesis file is setup correctly
blockxd validate-genesis

# Command to run the rest server in a different terminal/window
echo -e '\nrun the following command in a different terminal/window to run the REST server and JSON-RPC:'
echo -e "blockxcli rest-server --laddr \"tcp://localhost:8545\" --wsport 8546 --unlock-key $VAL_KEY,$USER1_KEY,$USER2_KEY --chain-id $CHAINID --trace\n"

# Start the node (remove the --pruning=nothing flag if historical queries are not needed)
blockxd start --pruning=nothing --rpc.unsafe --log_level "main:info,state:info,mempool:info" --trace
