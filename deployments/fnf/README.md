# README

    mkdir example

## Cold keys
Generate genesis delegate key pairs (these are the operator's offline
keys, a.k.a. the "cold" keys and should be generated and kept
offline):

    cardano-cli shelley genesis key-gen-delegate \
        --verification-key-file example/delegate-keys/delegate1.vkey \
        --signing-key-file example/delegate-keys/delegate1.skey \
        --operational-certificate-issue-counter example/delegate-keys/delegate-opcert1.counter
        
## Hot keys
### KES keys

Create a directory to store our KES keys, repeat for each
block-producing node you want:

    mkdir example/node1

    cardano-cli shelley node key-gen-KES \
        --verification-key-file example/node1/kes.vkey \
        --signing-key-file example/node1/kes.skey

### VRF keys

    cardano-cli shelley node key-gen-VRF \
        --verification-key-file example/node1/vrf.vkey \
        --signing-key-file example/node1/vrf.skey
        
### Operational certificate

    cardano-cli shelley node issue-op-cert \
    --hot-kes-verification-key-file example/node1/kes.vkey \
    --cold-signing-key-file example/delegate-keys/delegate1.skey \
    --operational-certificate-issue-counter example/delegate-keys/delegate-opcert1.counter \
    --kes-period 0 \
    --out-file example/node1/cert
    
## Launching

    cardano-node run \
        --config example/configuration.yaml \
        --topology example/node1/topology.json \
        --database-path example/node1/db \
        --socket-path example/node1/node.sock \
        --shelley-kes-key example/node1/kes.skey \
        --shelley-vrf-key example/node1/vrf.skey \
        --shelley-operational-certificate example/node1/cert \
        --port 3001
