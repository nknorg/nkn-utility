#! /bin/bash

### Node
function node_neighbor_ip() {
    cat $@ | jq '(.result[].addr[6:] / ":")[0]'
}

### Chord
function chord_success_ip() {
    cat $@ | jq '.result.Vnodes[].Successors[]|(.Host,.Id)' | sed 'N;s/\n/\t/g'
}

function chord_finger_ip() {
    cat $@ | jq '.result.Vnodes[].Finger[]|(.Host,.Id)'| sed 'N;s/\n/\t/g' | grep -v null
}

function _httpjson_API() {
    read ip port<<EOF
${1//:/ }
EOF
    [ -z "$port" ] && port=30003
    curl -s -H "Content-Type:application/json" -X POST "http://${ip}:${port}" -d '
        {
        "jsonrpc": "3.0",
        "id": "1",
        "method": "'$2'",
        "params": {'${3}'}
        }
    '
}

function getBlockHeight() {
    cat $@ | awk '{print $2}' | while read ip; do
        echo "$(printf "%-15s: " ${ip}; echo $(_httpjson_API $ip getlatestblockheight))" &
    done
}

function getVersion() {
    cat $@ | awk '{print $2}' | while read ip; do
        echo "$(printf "%-15s: " ${ip}; echo $(_httpjson_API $ip getversion|jq .result))" &
    done
}

function nbr_curr_hash() {
    for me in "$@"; do
        printf "%-16s: %s\n" ${me} "$(_httpjson_API ${me} getlatestblockhash | jq -c .result)"
        _httpjson_API ${me} getneighbor | node_neighbor_ip |sed 's/"//g' | while read ip; do
            printf "%-16s: %s\n" ${ip} "$(_httpjson_API ${ip} getlatestblockhash | jq -c .result)" &
        done
	wait
    done
}

function getBlockHash() {
    cat $1 | awk '{print $2}' | while read ip; do
        echo "$(printf "%-15s: " ${ip}; echo $(_httpjson_API $ip getblock \"height\":$2 | jq .result.hash))" &
    done
}
