guestip=$1
if=$2
of=$3

#echo 3 > /proc/sys/vm/drop_caches; echo 0 > /proc/sys/vm/drop_caches;
ssh $guestip "echo 3 > /proc/sys/vm/drop_caches"
ssh $guestip "echo 0 > /proc/sys/vm/drop_caches"
r0=`ifconfig eth0 | grep bytes | awk '{print $2}' | awk -F: '{print $2}'`
t0=`ifconfig eth0 | grep bytes | awk '{print $6}' | awk -F: '{print $2}'`
ssh $guestip "dd if=$if of=$of bs=4k count=65536" 2> out1
r1=`ifconfig eth0 | grep bytes | awk '{print $2}' | awk -F: '{print $2}'`
t1=`ifconfig eth0 | grep bytes | awk '{print $6}' | awk -F: '{print $2}'`
r=$(((r1-r0)/1024))
t=$(((t1-t0)/1024))

cat out1 | grep bytes | awk '{print $8 " " $9}'
echo $r $t

