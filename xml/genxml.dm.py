
f = open('/root/sftsan/xml/template.dm.xml').read()
for i in range(1,21):
    for j in range(1,9):
        w=f%(i,j,j,'%0.2x'%i,'%0.2x'%j)
    	open('/root/sftsan/xml/genxml/test%dx%dx'%(i,j),'w').write(w)


