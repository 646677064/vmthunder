
wget 172.16.10.131/hello.html -o /tmp/hello.html
for i in `cat nodes `
do
ssh $i virsh create /root/sftsan/xml/testdm.xml & 
done
wait
