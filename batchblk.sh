scp 172.16.10.129:/root/sftsan/nodes .

#ra=(0 256 1024)
#for ri in `seq 0 2`
ra=(128 256 384 512 640 768)
for ri in `seq 0 $((${#ra[*]}-1)) `
do

for i in `cat nodes`
do
scp cfg.cache-${ra[ri]} $i:/root/sftsan/cfg.cache
done

fname=(job1mrandread job2mrandread job4mrandread)
fsize=(10% 15% 20% 25% 30% 35% 40% 45% 50% 55% 60% 65% 70% 75% 80% 85% 90% 95%)

for i in `seq 0 $((${#fname[*]}-1))`
do
for j in `seq 0 $((${#fsize[*]}-1))`
do
ssh 172.16.10.129 sh /root/sftsan/config
virsh create /root/centos/test.bd.xml
sleep 30s
ssh 192.168.122.167 mount /dev/vdb /mnt/
sh runblk.sh ${fname[i]} randread ${fsize[j]}
virsh destroy test
ssh 172.16.10.129 sh /root/sftsan/deconfig
done
done

done
