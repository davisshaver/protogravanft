#!/usr/bin/env bash

set -eo pipefail

# bring up the network
. $(dirname $0)/run-temp-testnet.sh

# run the deploy script
. $(dirname $0)/deploy.sh

# get the address
addr=$(jq -r '.ProtoGravaNFT' out/addresses.json)

# the initial description should be what we expect
description=$(seth call $addr 'getDescription()(string)')
[[ $description = "Globally Recognized Avatars on the Ethereum Blockchain" ]] || error

# the initial default image should be what we expect
defaultimage=$(seth call $addr 'getDefaultImageFormat()(string)')
[[ $defaultimage = "robohash" ]] || error

# set it to a value
seth send $addr \
    'ownerSetDescription(string memory)' '"This Is Only A Test"' \
    --keystore $TMPDIR/8545/keystore \
    --password /dev/null

seth send $addr \
    'ownerSetDefaultFormat(string memory)' '"robohash"' \
    --keystore $TMPDIR/8545/keystore \
    --password /dev/null
sleep 1

# should be set afterwards
newdescription=$(seth call $addr 'getDescription()(string)')
[[ $newdescription = "This Is Only A Test" ]] || error

newimageformat=$(seth call $addr 'getDefaultImageFormat()(string)')
[[ $newimageformat = "robohash" ]] || error

echo "Success."
