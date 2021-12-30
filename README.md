# GravaNFT (Prototype!)

## TODOs

- Test on Kovan network with verified source
- Improve test coverage for Merkle tree implementation
- Automate generation of Merkle trees for different networks
- Automate deployment for different networks
- Add event emissions for differnt actions
- Close-read code comments and enhance/expand
- Add .sethrc to repo docs/ignore from git
- Document differences between Foundry and DappTools
- estimate gas while passing constructor arguments too

## Stack

This project is based on [Georgios Konstantopoulos' DappTools template](https://github.com/gakonst/dapptools-template), and therefore will also be cross-compatible with Konstantopoulos' reimplementation of DappTools in Rust ([Foundry](https://github.com/gakonst/foundry)).

Currently we use [OpenZeppelin modules](https://openzeppelin.com/) to provide ERC-721 and Merkle tree implementations; however, we hope to switch to [Solmate](https://github.com/Rari-Capital/solmate/) in the future, likely to be a more gas-efficient implementation of ERC-721 and related patterns such as counters. ([See pending Solmate v6 pull request here.](https://github.com/Rari-Capital/solmate/pull/77))

## Local

If you do not have DappTools already installed, please first [follow the toolkit installation instructions](https://github.com/gakonst/dapptools-template#installing-the-toolkit). **DappTools has compatibility issues with M1 Macs due to GHC compiliation issues on ARM architecture. [See here for workaround details.](https://roycewells.io/writing/dapptools-m1/)**

```
git clone TK
cd gravanft
make
make test
```

At this time you should see passing tests.

You may also want to experiment with [Foundry](https://github.com/gakonst/foundry). Running `forge test` should give you similiar output to `make test`, but at present there is a failing test for the Merkle tree verification due to tests being hard-coded to use the DappTools address (0xEFc56627233b02eA95bAE7e19F648d7DcD5Bb132).

## Merkle Tree Generation


https://en.wikipedia.org/wiki/Merkle_tree
https://medium.com/@ItsCuzzo/using-merkle-trees-for-nft-whitelists-523b58ada3f9
https://github.com/OpenZeppelin/workshops/blob/master/06-nft-merkle-drop/slides/20210506%20-%20Lazy%20minting%20workshop.pdf

## Deploying
For network deployments, you will need to setup your keystore as well as configure an RPC URL or a Alchemy API key. [Please see the DappTools template for additional setup details on deploying.](https://github.com/gakonst/dapptools-template#deploying) 

dapp create ProtoGravaNFT '"ProtoGravaNFT"' '"PROTOGRAV"' 0x5ba39d6a23933f83b06f5f4439d7eb891dbbc59250ff8f3109fd821802847b23 -- --gas "5000000" --rpc-url "https://optimism-kovan.infura.io/v3/e94089d24a0247b690a22f0c842b371c" --from 0x0F545f9be53fA596aF36baf231663D16E8C66911 --keystore ~/.ethereum/keystore --password $PWD/pass

https://community.optimism.io/docs/infra/networks.html#optimism-kovan-testnet

https://kovan-optimistic.etherscan.io/address/0xca3cb82a586eed2e0b394cc6c4fdf1c908aea94a#code

UPDATE DAPP TOOLS

https://github.com/dapphub/dapptools

https://dashboard.alchemyapi.io/apps/wgibtdyviy0yibu7
