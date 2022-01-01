const { MerkleTree } = require('merkletreejs');
const fs = require('fs');
const keccak256 = require('keccak256');
const path = require('path');
const Web3 = require('web3');

const allowlist = require('../config/allowlist.json');

const environment = process.argv[2] === "prod" ? "prod" : "dev";

/**
 * Generate new hash for address and Gravatar hash pair.
 *
 * @param {string} gravatarHash Gravatar hash.
 * @param {string} account EVM address. 
 * @returns {Buffer} Hex buffer of sha3 hash.
 */
function generateHash(gravatarHash, account) {
    return Buffer.from(Web3.utils.soliditySha3(
        {
            type: 'string',
            value: gravatarHash
        },
        {
            type: 'address',
            value: account
        }
    ).slice(2), 'hex');
}

// Generate leaves for the Merkle tree.
const leaves = Object.entries(allowlist[environment]).map(allowed => generateHash(...allowed));

// Assemble and hash Merkle tree.
const merkletree = new MerkleTree(leaves, keccak256, { sortPairs: true });

// Generate Merkle tree proofs for every eligible user.
const proofs = Object.entries(allowlist[environment]).map(entry => ({
    proof: merkletree.getHexProof(generateHash(...entry)),
    gravatarHash: entry[0],
    address: entry[1]
}));

// Define output path for Merkle tree data based on environment.
const outputPath = `${__dirname}/../proofs/${environment}.json`;

// Output Merkle tree data.
fs.writeFileSync(
    outputPath,
    JSON.stringify({
        root: merkletree.getHexRoot(),
        proofs,
    }, null, 2)
);
