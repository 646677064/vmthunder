scp 172.16.10.129:/root/sftsan/nodes .

tm=`date +"%m-%d-%T"`
#fname=job64mrandread
#frw=randread
#fsize=40%
fname=$1
frw=$2
fsize=$3
for i in `seq 2 8 1024`
do
sh blk.start
ssh 192.168.122.167 fio --name=/mnt/fio/$fname$i --rw=$frw --ioengine=psync --direct=1 --randrepeat=0 --size=$fsize
sh blk.stop
done
# | tee fio.$tm.out
