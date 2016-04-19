
f = open('/root/sftsan/xml/template.qc.xml').read()
for i in range(255):
    w = f % '%0.2x' % i
    open('/root/sftsan/xml/bash/test%d.xml' % i, 'w').write(w)


