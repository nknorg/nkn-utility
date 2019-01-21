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
#remote_exec ~/cluster2.lst admin "cd ${NKN_HOME} && git pull"
#remote_exec ~/cluster2.lst admin 'export PATH=/usr/lib/go-1.10/bin:$PATH && export GOPATH=$HOME/nknorg && make -C ${NKN_HOME} all'
#remote_exec ~/cluster2.lst admin "cd ${NKN_HOME} && ./test/create_testbed.sh 2"
#remote_exec ~/cluster2.lst admin "cd ${NKN_HOME} && ./test/launch_node.sh ./testbed/node_0001 join"
