i=21
for n in `cat /root/sftsan/nodes `
do
i=$((i-1))
for j in `seq 8`
do
ssh $n virsh destroy centos62-$i-$j &
done
done
wait
