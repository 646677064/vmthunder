n=8
wget 172.16.10.129/py/index.py -o /tmp/hello.html
for i in `cat nodes `
do
for j in `seq $n `
do
ssh $i virsh create /root/sftsan/xml/test-$j.xml & 
done
done
wait
