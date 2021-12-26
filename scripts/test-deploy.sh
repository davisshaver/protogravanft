#!/usr/bin/env bash

set -eo pipefail

# bring up the network
. $(dirname $0)/run-temp-testnet.sh

# run the deploy script
. $(dirname $0)/deploy.sh

# get the address
addr=$(jq -r '.ProtoGravaNFT' out/addresses.json)

echo $addr;

# the initial description should be what we expect
description=$(seth call $addr 'getDescription()(string)')
[[ $description = "Globally Recognized Avatars on the Ethereum Blockchain" ]] || error

# # set it to a value
# seth send $addr \
#     'greet(string memory)' '"yo"' \
#     --keystore $TMPDIR/8545/keystore \
#     --password /dev/null

# sleep 1

# # should be set afterwards
# greeting=$(seth call $addr 'greeting()(string)')
# [[ $greeting = "yo" ]] || error

echo "Success."
