
f = open('/root/sftsan/xml/template.new.xml').read()
for ii in range(8):
    i = ii + 1
    w = f % (i, i, i, i)
    open('/root/sftsan/xml/bash/test.ubuntu%d.xml' % i, 'w').write(w)


