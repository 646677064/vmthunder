#!/bin/bash

. /root/sftsan/cfg.data

i=1
table=()
table[$i]=$imagenode
let i=$i+1
let mm=$i+$degree
ll=1

echo "----- Config snapdev ------"
for node in $nodes
do
	if [ $snaptype = $dmsnap ]
	then
		ssh $node "sh $workdir/cfg.dmsnap $imagename $numsnap $vgname $workdir" &
	elif [ $snaptype = $qcsnap ]
	then
		ssh $node "sh $workdir/cfg.qcsnap $imagename $numsnap $workdir" &
	fi
done
wait
echo "----- All snapdev constructed ------"
