# GravaNFT (Prototype!)

## Testing Deployment

### Forge Create

```
forge create --constructor-args "ProtoGravaNFT" "PROTOGRAV" "0x5ba39d6a23933f83b06f5f4439d7eb891dbbc59250ff8f3109fd821802847b23" --rpc-url https://optimism-kovan.infura.io/v3/<YOUR_API_KEY> --private-key <YOUR_PRIVATE_KEY> src/ProtoGravaNFT.sol:ProtoGravaNFT
```

### Forge Verify

```
ETH_RPC_URL=https://optimism-kovan.infura.io/v3/<YOUR_API_KEY> ETHERSCAN_API_KEY=<YOUR_API_KEY> forge verify-contract --constructor-args $(cast abi-encode "constructor(string,string,bytes32)" "ProtoGravaNFT" "PROTOGRAV" "0x5ba39d6a23933f83b06f5f4439d7eb891dbbc59250ff8f3109fd821802847b23") --compiler-version v0.8.10+commit.fc410830 --chain-id 69 --optimize --optimize-runs 1000000 <ADDRESS_FROM_LAST_STEP> './src/ProtoGravaNFT.sol:ProtoGravaNFT' 
```

### Forge Verify Check

```
ETHERSCAN_API_KEY=<YOUR_API_KEY> forge verify-check <GUID_FROM_LAST_STEP> --chain-id 69
```
