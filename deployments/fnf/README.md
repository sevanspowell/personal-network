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

Create a directory to store our hot keys, repeat for each
block-producing node you want:

    mkdir example/node1

### KES keys

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
    
## Launch

    cardano-node run \
        --config example/configuration.yaml \
        --topology example/node1/topology.json \
        --database-path example/node1/db \
        --socket-path example/node1/node.sock \
        --shelley-kes-key example/node1/kes.skey \
        --shelley-vrf-key example/node1/vrf.skey \
        --shelley-operational-certificate example/node1/cert \
        --port 3001

## Query address

    CARDANO_NODE_SOCKET_PATH=/run/cardano-node/node.socket \
    cardano-cli shelley query filtered-utxo \
        --address 82013... \
        --testnet-magic 42

## Transactions

1. Query protocol parameters

        CARDANO_NODE_SOCKET_PATH=/run/cardano-node/node.socket \
        cardano-cli shelley query protocol-parameters \
            --testnet-magic 42 > protocol.json

2. Calculate min fee

        cardano-cli shelley transaction calculate-min-fee \
            --tx-in-count 1 \
            --tx-out-count 2 \
            --ttl 100000 \
            --testnet-magic 42 \
            --signing-key-file addr1.skey \
            --protocol-params-file protocol.json
            
        > runTxCalculateMinFee: 168141
    
3. Get transaction hash and index of utxo we want to spend:

        CARDANO_NODE_SOCKET_PATH=/run/cardano-node/node.socket \
        cardano-cli shelley query filtered-utxo \
            --address 82013... \
            --testnet-magic 42
        
        >                            TxHash                                 TxIx        Lovelace
        > ----------------------------------------------------------------------------------------
        > 4e3a6e7fdcb0d0efa17bf79c13aed2b4cb9baf37fb1aa2e39553d5bd720c5c99     4     1000000000000
    
4. Create the transaction

    Note, the "TTL" is the slot after which your transaction becomes
    invalid, so you'll want to determine the current slot number and
    add a bit.

        cardano-cli shelley transaction build-raw \
            --tx-in 15a715493514645cb609fb7b7ab420989506e0f4166f43b6a9c4faef10d0f21a#7 \
            --tx-out $(cat addr2)+100000000 \
            --tx-out $(cat addr1)+999899831859 \
            --ttl 100000 \
            --fee 168141 \
            --tx-body-file tx001.raw
        
5. Sign the transaction

        cardano-cli shelley transaction sign \
          --tx-body-file tx001.raw \
          --signing-key-file addr1.skey \
          --testnet-magic 42 \
          --tx-file tx001.signed
          
6. Submit the transaction

        CARDANO_NODE_SOCKET_PATH=/run/cardano-node/node.socket \
        cardano-cli shelley transaction submit \
            --tx-filepath tx001.signed \
            --testnet-magic 42
        
7. Wait, see the effect:

        cardano-cli shelley query filtered-utxo \
            --address $(cat addr1) \
            --testnet-magic 42

        >                            TxHash                                 TxIx        Lovelace
        > ----------------------------------------------------------------------------------------
        > b64ae44e1195b04663ab863b62337e626c65b0c9855a9fbb9ef4458f81a6f5ee     1      999899831859
         
        cardano-cli shelley query filtered-utxo \
            --address $(cat addr2) \
            --testnet-magic 42
         
        >                            TxHash                                 TxIx        Lovelace
        > ----------------------------------------------------------------------------------------
        > b64ae44e1195b04663ab863b62337e626c65b0c9855a9fbb9ef4458f81a6f5ee     0         100000000
    
