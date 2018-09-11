#! /bin/bash

### Node
function node_neighbor_ip() {
    cat $@ | jq '.result[].IpAddr[12:][]'|sed 'N;N;N;s/\n/./g'
}

### Chord
function chord_success_ip() {
    cat $@ | jq '.result.Vnodes[].Successors[](.Host,.Id)' | sed 'N;s/\n/\t/g'
}

function chord_finger_ip() {
    cat $@ | jq '.result.Vnodes[].Finger[](.Host,.Id)'| sed 'N;s/\n/\t/g' | grep -v null
}

function _httpjson_API() {
    echo ${1//:/ } | read ip port
    [ -z "$port" ] && port=30003
    curl -s -H "Content-Type:application/json" -X POST "http://${ip}:${port}" -d '
        {
        "jsonrpc": "3.0",
        "id": "1",
        "method": "'$2'",
        "params": {}
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
