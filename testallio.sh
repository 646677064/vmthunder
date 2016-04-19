ip=192.168.122.167
ssh-copy-id $ip 1>/dev/null

echo "----read network----"
for i in `seq 5 `
do
sh testio.sh $ip /tmp/m$i /dev/null
done
echo

echo "----read cache----"
for i in `seq 5 `
do
sh testio.sh $ip /tmp/m$i /dev/null
done
echo

echo "----read file write cache exist----"
for i in `seq 10 `
do
sh testio.sh $ip /tmp/m1 /tmp/m2
done
echo

echo "----read file write new----"
for i in `seq 20 `
do
sh testio.sh $ip /tmp/m1 /tmp/x$i
done
echo

echo "----read file write exist----"
for i in `seq 5 `
do
sh testio.sh $ip /tmp/m1 /tmp/t$i
done
echo

echo "----read snapshot----"
for i in `seq 5 `
do
sh testio.sh $ip /tmp/x1 /dev/null
done
echo

echo "----write 0 new----"
for i in `seq 5 `
do
sh testio.sh $ip /dev/zero /tmp/z$i
done
echo

echo "----write 0 exist----"
for i in `seq 5 `
do
sh testio.sh $ip /dev/zero /tmp/t2
done
