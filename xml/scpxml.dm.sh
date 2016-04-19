i=21
for n in `cat /root/sftsan/nodes `
do
i=$((i-1))
for j in `seq 8`
do
#echo 
scp /root/sftsan/xml/genxml/test${i}x${j}x $n:/root/sftsan/xml/test-${j}.xml
done
done
