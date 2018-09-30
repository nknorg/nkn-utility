#! /bin/bash

### args: node_lst, user, cmd
function remote_exec () {
    for ip in $(awk '{print $2}' ${1})
    do
	    ssh -o StrictHostKeyChecking=no ${2}@${ip} 'echo "$(printf "\n### %s ### %s ###\n%s" $(hostname) '$ip' "$('$3')")"' &
    done
    wait
}

### Example
#remote_exec ~/cluster2.lst admin "cd ~/nknorg/src/github.com/nknorg/nkn/ && git pull"
#remote_exec ~/cluster2.lst admin 'export PATH=/usr/lib/go-1.10/bin:$PATH && export GOPATH=$HOME/nknorg && make -C ~/nknorg/src/github.com/nknorg/nkn/ all'
#remote_exec ~/cluster2.lst admin "cd ~/nknorg/src/github.com/nknorg/nkn/ && ./test/create_testbed.sh 2"
#remote_exec ~/cluster2.lst admin "cd ~/nknorg/src/github.com/nknorg/nkn/ && ./test/launch_node.sh ./testbed/node_0001 join"
