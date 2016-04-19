#!/bin/bash

. /root/sftsan/cfg.data

i=1
table=()
table[$i]=$imagenode
let i=$i+1
let mm=$i+$degree
ll=1

echo "----- Config cachedev ------"
for node in $nodes
do
	ssh $node "sh $workdir/cfg.cachedev $cachesize" &
done
wait
echo "----- All cachedev constructed ------"

echo "----- Config Head Node  ------"
echo $imagename  $imagenode  $imagedev
sh $workdir/cfg.target 1 cache.$imagename.$imagenode $imagedev
echo "----- Head Node constructed ------"

for node in $nodes
do
        table[$i]="$node"
        parent=`expr \( $i - 2 \) / $degree + 1`
        parenthost=${table[$parent]}
        iscsitname="cache.$imagename.${table[$parent]}"

	atwhere="ssh $node"
        tgtname="cache.$imagename.$node"
echo $parenthost $iscsitname $node $tgtname
        if [ $node = $imagenode ]
        then
                echo "-----Here is the image store host: $imagehost -----"
        else
                echo "-----Here is: $node ----- Parent is: $parenthost -----"
                $atwhere "sh $workdir/cfg.iscsi $parenthost $iscsitname;
                sh $workdir/cfg.cache $cachesize $iscsitname $parenthost $cacheloopdev;" &
 # sh $workdir/cfg.target 1 $tgtname '/dev/mapper/cachedev';  
                let i=$i+1
		if [ $i = $mm ]
		then
			wait
			echo $i
			let ll=$ll+1
			let mm=$mm+$degree**$ll
		fi
		sleep 0.2s
        fi

done
wait
echo "----- All iscsi client and target, cache constructed ------"
