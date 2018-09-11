#! /bin/bash

### node_lst user src dest
function copy_to_remote () {
    [ $# -ne 4 ] || [ -z "$3" ] && echo "Invalid args [$@]" && return $EINVAL

    for ip in $(cat ${1} |awk '{print $3}')
    do 
        scp -o StrictHostKeyChecking=no -r ${3} ${2}@${ip}:${4} &
    done
    wait
}

### node_lst user src dest
function copy_from_remote () {
    [ $# -ne 4 ] || [ -z "$3" ] && echo "Invalid args [$@]" && return $EINVAL
    [ -d ${4} ] || mkdir -p ${4} || return $?

    name=$(basename ${3})
    for ip in $(cat ${1} |awk '{print $2}')
    do 
        scp -o StrictHostKeyChecking=no -r ${2}@${ip}:${3} ${4}/${ip}_${name} &
    done
    wait
}
