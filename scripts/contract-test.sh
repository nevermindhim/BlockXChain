#!/bin/bash

KEY="mykey"
TESTKEY="test"
CHAINID="ethermint-100"
MONIKER="localtestnet"

# stop and remove existing daemon and client data and process(es)
rm -rf $PWD/.ethermint*
pkill -f "ethermint*"

make build-ethermint

$PWD/build/blockxcli config keyring-backend test

# Set up config for CLI
$PWD/build/blockxcli config chain-id $CHAINID
$PWD/build/blockxcli config output json
$PWD/build/blockxcli config indent true
$PWD/build/blockxcli config trust-node true

# if $KEY exists it should be deleted
$PWD/build/blockxcli keys add $KEY

# Set moniker and chain-id for BlockX (Moniker can be anything, chain-id must be an integer)
$PWD/build/blockxd init $MONIKER --chain-id $CHAINID

# Change parameter token denominations to abcx
cat $HOME/.blockxd/config/genesis.json | jq '.app_state["staking"]["params"]["bond_denom"]="abcx"' > $HOME/.blockxd/config/tmp_genesis.json && mv $HOME/.blockxd/config/tmp_genesis.json $HOME/.blockxd/config/genesis.json
cat $HOME/.blockxd/config/genesis.json | jq '.app_state["crisis"]["constant_fee"]["denom"]="abcx"' > $HOME/.blockxd/config/tmp_genesis.json && mv $HOME/.blockxd/config/tmp_genesis.json $HOME/.blockxd/config/genesis.json
cat $HOME/.blockxd/config/genesis.json | jq '.app_state["gov"]["deposit_params"]["min_deposit"][0]["denom"]="abcx"' > $HOME/.blockxd/config/tmp_genesis.json && mv $HOME/.blockxd/config/tmp_genesis.json $HOME/.blockxd/config/genesis.json
cat $HOME/.blockxd/config/genesis.json | jq '.app_state["mint"]["params"]["mint_denom"]="abcx"' > $HOME/.blockxd/config/tmp_genesis.json && mv $HOME/.blockxd/config/tmp_genesis.json $HOME/.blockxd/config/genesis.json

# Allocate genesis accounts (cosmos formatted addresses)
$PWD/build/blockxd add-genesis-account "$("$PWD"/build/blockxcli keys show "$KEY$i" -a)" 100000000000000000000abcx

# Sign genesis transaction
$PWD/build/blockxd gentx --name $KEY --amount=1000000000000000000abcx --keyring-backend test

# Collect genesis tx
$PWD/build/blockxd collect-gentxs

# Run this to ensure everything worked and that the genesis file is setup correctly
$PWD/build/blockxd validate-genesis

# Start the node (remove the --pruning=nothing flag if historical queries are not needed) in background and log to file
$PWD/build/blockxd start --pruning=nothing --rpc.unsafe --log_level "main:info,state:info,mempool:info" --trace > blockxd.log &

sleep 1

# Start the rest server with unlocked key in background and log to file
$PWD/build/blockxcli rest-server --laddr "tcp://localhost:8545" --unlock-key $KEY --chain-id $CHAINID --trace --rpc-api="web3,eth,net,personal" > blockxcli.log &

solcjs --abi $PWD/tests-solidity/suites/basic/contracts/Counter.sol --bin -o $PWD/tests-solidity/suites/basic/counter
mv $PWD/tests-solidity/suites/basic/counter/*.abi $PWD/tests-solidity/suites/basic/counter/counter_sol.abi 2> /dev/null
mv $PWD/tests-solidity/suites/basic/counter/*.bin $PWD/tests-solidity/suites/basic/counter/counter_sol.bin 2> /dev/null

ACCT=$(curl --fail --silent -X POST --data '{"jsonrpc":"2.0","method":"eth_accounts","params":[],"id":1}' -H "Content-Type: application/json" http://localhost:8545 | grep -o '\0x[^"]*' | head -1 2>&1)

echo $ACCT

curl -X POST --data '{"jsonrpc":"2.0","method":"personal_unlockAccount","params":["'$ACCT'", ""],"id":1}' -H "Content-Type: application/json" http://localhost:8545

PRIVKEY="$("$PWD"/build/blockxcli keys unsafe-export-eth-key $KEY)"

echo $PRIVKEY

## need to get the private key from the account in order to check this functionality.
cd tests-solidity/suites/basic/ && go get && sleep 5 && go run main.go $ACCT
