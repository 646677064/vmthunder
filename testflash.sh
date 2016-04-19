cachesize=4096
iscsitname=cache.ubuntu12.192.168.0.152
parentip=192.168.0.152

sleep 0.2s
#blockdev --setra 0 $cacheoridev
cachedev=`iscsiadm -m session -n $iscsitname.$parentip -P 3 | sed -n 's/^\s\+Attached scsi disk \(sd\w\+\)\s.*$/\1/p'`
cacheoridev="/dev/$cachedev"
#flashcache_create -p back -s ${cachesize}m -b 4k cachedev $cacheloopdev $cacheoridev
sleep 0.2s
#blockdev --setra 0 /dev/mapper/cachedev
#blockdev --setra 1024 /dev/mapper/cachedev

