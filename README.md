# vmthunder
Experiment prototype for the TPDS Paper VMThunder (25.12, 2014: 3328-3338)

[VMThunder: fast provisioning of large-scale virtual machine clusters](http://ieeexplore.ieee.org/xpls/abs_all.jsp?arnumber=6719385)

And  Frontiers of Computer Science, 2016 Paper: [Large-scale virtual machines provisioning in clouds: challenges and approaches](http://link.springer.com/article/10.1007/s11704-015-4420-7)

##简述

Sftsan软件包（该repo代码系统）是VMThunder系统的代码实现，其功能是为大规模物理机集群上快速部署并启动大批量虚拟机提供高效的存储系统，即sftsan是VMThunder中为虚拟机提供虚拟磁盘的存储系统。

Sftsan是树形结构，其中包含一个原存储节点和N个计算节点，原存储节点可为任意节点，存放虚拟机镜像，用户可以直接在该节点上配置定制虚拟机的最初版本；集群中的其他可以部署虚拟机的节点都可以设置为计算节点，计算节点将成为运行虚拟机的宿主物理机。Sftsan有以下特点：

1)	每个节点即可以为本地虚拟机提供存储服务，又可以为树形结构的下游节点提供数据服务，因此每个计算节点上需要配置对应镜像的缓存设备，以存储已缓存的数据（Flashcache）。

2)	每台虚拟机需要拥有自身的数据读写空间，因此每个计算节点上需要配置与虚拟机相同数量的快照设备（Device mapper Snapshot dmsnap）。

3)	每个计算节点的缓存设备需要为下游节点提供存储服务，因此每个计算节点都需要配置相应的远程数据访问服务（iSCSI target）。
4)	每个计算节点需要建立从上游节点获取iSCSI数据服务的本地服务（iSCSI initiator）


##配置参数

sftsan的配置信息放置在cfg.data里面：

    imagenode=192.168.0.152   #原存储节点ip
    imagename=ubuntu12      #镜像名称
    numsnap=2               #在计算节点建立snapshot的数目
    vgname=vgdata            #原存储节点VG的名称
    imagedev=/dev/mapper/vgdata-lvimage1     #原存储节点的镜像路径
    degree=1					#sftsan树形模型的度，2为二叉树，10为十叉树，1为链状结构
    workdir=/root/sftsan/       #sftsan工作路径
    nodes=\`cat $workdir/nodes\`  #计算节点列表，每个计算节点一行
    cachesize=4096            #cache的大小，设置太大占用过多内存，导致性能下降，甚至崩溃，设置太小会导致数据置换，性能下降
    cacheloopdev=/dev/loop6   #用来进行缓存的块设备
    dmsnap=dmsnap           #配置snapshot的参数
    qcsnap=qcsnap            #另一种实现方式qcow2，现在没有使用
    snaptype=$dmsnap
    \#snaptype=$qcsnap

Sftsan的节点信息放置在nodes里面，里面存放的是计算节点的ip地址。在参数设置完毕后，在原存储节点sftsan工作目录下执行./cpcfgfiles，完成对计算节点运行文件的传输。
	
##计算节点环境配置

计算节点除了需要有配置文件以外，还必须进行一些软件的安装与配置，sftsan需要使用这些软件。在每个计算节点下配置以下软件：

a、Flashcache配置
  
    i.	下载flashcache源码，并解压
    ii.	进入目录安装：make & make install
    iii.	加载flashcache模块：modprobe flashcache
    iv.	确定加载完成：lsmod | grep flashcache
  
如果安装失败看提示，一般是内核源码没安装的原因。

b、target 和 iscsi配置和启动服务
	
	Target：apt-get install tgt
			service tgtd start
	Iscsi：apt-get install open-iscsi
			service iscsi start

c、配置计算节点lvm。
	
在启动sftsan之前，还需要初始化每个计算节点的VG，在每个计算节点上执行./cfg.lvmfile，生成名为vgdata的VG。在原存储节点/root/sftsan下执行./cfg.lvminit，激活每个节点上的vgdata。
  
如确定计算节点的lvm已经配置过，但由于系统重启等原因lv处于不活跃状态，则无需执行cfg.lvmfile，只需要执行cfg.lvminit。如果确定lv处于活跃状态，则无需执行这两个文件。

##启动与关闭sftsan

a、启动sftsan
在原存储节点/root/sftsan下执行./config可启动sftsan，注意启动sftsan前要检查计算节点的剩余内存是否足够。config文件完成的主要工作如下：
  
    i、	在计算节点生成4G大小的cache块设备
    ii、	原存储节点建立target
    iii、	计算节点iscsi远程挂载target
    iv、	计算节点生成flashcache
    v、	计算节点建立target
    vi、	计算节点建立snapshot
  
如果执行成功，可以在计算节点的/dev/mapper/目录中找到snp-ubuntu12_x的snapshot设备，编辑虚拟机xml配置文档，将虚拟机硬盘挂载指向该snapshot设备。

例如，编辑计算节点/root/sftsan/xml目录下test. xml文件：

    <disk type='file' device='disk'>
         <driver name='qemu' type='raw'/>
         <source file='/dev/mapper/snp-ubuntu12_x'/>
         <target dev='vda' bus='virtio'/>
    </disk>

在计算节点使用virsh create test.snap.xml可以快速启动虚拟机test。

b、批量启动虚拟机
  
执行完config后，会在每个计算节点生成snapshot设备，数目为numsnap指定的值，为了快速批量启动虚拟机，需要进行以下操作：

1)  在原存储节点/root/sftsan/xml目录下执行python genxml.dm.py，程序会对模板xml文件template.dm.xml进行修改，在/root/sftsan/xml/genxml中生成对应每个计算节点、每个snapshot设备的文档。修改的参数主要是虚拟机名称，指定挂载的snapshot设备，mac地址。例如：有两个计算节点，numsnap=2，则会生成test1x1x,test1x2x,test2x1x,test2x2x四个文档。

2)  在原存储节点/root/sftsan/xml目录下执行./scpxml.dm.sh，程序会将genxml中的xml文件分发给各个计算节点。例如：同上情况，原存储节点会将test1x1x,test1x2x发给计算节点1并分别改名为test-1.xml,test-2.xml, 将test2x1x,test2x2x发给计算节点2并分别改名为test-1.xml,test-2.xml。

3)	在原存储节点/root/sftsan目录下执行./vmstart.sh，在各计算节点上运行virsh create命令，生成虚拟机。

4)	确保网络中DHCP服务器的正常运行状态，否则虚拟机将无法获得ip地址。

执行完上诉步骤后，可以使用virsh list来查看虚拟机的运行状态以及vnc的连接，已经ssh的连接。

c、关闭sftsan
	
使用virsh destroy test关闭虚拟机test。
  
若要批量删除虚拟机，在原存储节点/root/sftsan下执行./vmdestroy.sh，在各计算节点上运行virsh destroy命令删除虚拟机。
确认删除所有虚拟机后，在原存储节点/root/sftsan下执行./deconfig关闭sftsan。Deconfig的主要工作如下：
  
    i、	断开计算节点iscsi连接
    ii、	删除计算节点target
    iv、	删除原存储节点target
    v、	删除snapshot
    vi、	删除cache块设备

##附录：

a)	安装虚拟机镜像

首先，我们需要在原存储节点上安装虚拟机镜像，该镜像为系统中所有快速启动虚拟机的母镜像，使用的镜像为ubuntu-12.04.3-server-amd64.iso。

1、使用LVM

虚拟机被安装在LVM块设备上，这样做的好处是便于管理，能够就具体情况增减块设备容量，且配置灵活。下面是LVM操作步骤：

创建PV，将一个块设备转化为物理卷，这个块设备可以是一块硬盘，也可以是文件转化成的块设备。

    命令格式：pvcreate 块设备名
    例如：pvcreate /dev/sde 

创建VG，在pv后的块设备上创建VG。

    命令格式：vgcreate VG名 块设备名
    例如：vgcreate vgdata /dev/sde

创建LV，在VG上创建LV。

    命令格式：lvcreate –L 容量 –n LV名 VG名
    例如：lvcreate –L 20G –n lvimage1 vgdata

创建好LV之后，会在/dev/mapper目录下生成名为“卷组-逻辑卷”的软连接，例如vgdata-lvimage1。

2、编辑虚拟机xml文件

启动虚拟机之前需要先编辑虚拟机xml配置文件，xml中主要需要修改两个参数，即虚拟机所在的磁盘和虚拟机所用的安装镜像。我们将虚拟机所在磁盘指定为上文生成的块设备软连接，将所用安装镜像指定为ubuntu-12.04.3-server-amd64.iso。

例如，编辑/root/sftsan/xml目录下的test.cdboot.xml：

    <disk type='file' device='disk'>
         <driver name='qemu' type='raw'/>
         <source file='/dev/mapper/vgdata-lvimage1'/>
         <target dev='vda' bus='virtio'/>
    </disk>
    <disk type='file' device='cdrom'>
             <source file='/root/ubuntu-12.04.3-server-amd64.iso'/>
              <target dev='hdc'/>
              <readonly/>
    </disk>

b)	使用virsh操作虚拟机
virsh 是一个虚拟机的管理工具，提供管理虚拟机更高级的能力。可以利用 virsh 来启动、删除、控制、监控虚拟机。

    例如：运行virsh create test.cdboot.xml，将Ubuntu12.04安装在lvimage1中，生成名为test的虚拟机。

运行virsh destroy test，删除名为test的虚拟机。

下面列出关于virsh的一些常用用法：

    命令 说明
    create 启动一个新的虚拟机
    destroy 删除一个虚拟机
    start 开启（已定义的）非启动的虚拟机
    list 列出虚拟机
    reboot 重新启动虚拟机
    save 存储虚拟机的状态
    restore 回复虚拟机的状态
    suspend 暂停虚拟机的执行
    resume 继续执行该虚拟机
    shutdown 关闭虚拟机

