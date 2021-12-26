#!/usr/bin/env bash

set -eo pipefail

# import the deployment helpers
. $(dirname $0)/common.sh

# Deploy.
ProtoGravaNFTAddr=$(deploy ProtoGravaNFT '"ProtoGravaNFT"' '"PROTOGRAV"' '0x31ec1fc12927b46ccb39c33438bcb5206998698ffe2c5356f6b3c16be0b989fd')
log "ProtoGravaNFT deployed at:" $ProtoGravaNFTAddr
