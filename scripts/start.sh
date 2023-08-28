#!/bin/sh
blockxd --home /ethermint/node$ID/blockxd/ start > blockxd.log &
sleep 5
blockxcli rest-server --laddr "tcp://localhost:8545" --chain-id "ethermint-7305661614933169792" --trace --rpc-api="web3,eth,net,personal" > blockxcli.log &
tail -f /dev/null
