for i in `cat /root/sftsan/nodes `; do j=`echo $i | awk -F. '{print $4}'`; scp bash/test$j.xml $i:/root/sftsan/xml/test.xml; done
