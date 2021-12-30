#!/usr/bin/env bash

set -eo pipefail

# import the deployment helpers
. $(dirname $0)/common.sh

# Deploy.
ProtoGravaNFTAddr=$(deploy ProtoGravaNFT '"ProtoGravaNFT"' '"PROTOGRAV"' '0x5ba39d6a23933f83b06f5f4439d7eb891dbbc59250ff8f3109fd821802847b23')
log "ProtoGravaNFT deployed at:" $ProtoGravaNFTAddr
