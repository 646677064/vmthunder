for i in `head -n $1 nodes `
do
ssh $i ls /dev/mapper/
done
