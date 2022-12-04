# 关于

本文描述了本人在龙湖社区，推动的邻居组网计划，涵盖二三层网络设计，硬件选型及配
置相关信息，供后续维护查阅。

# 硬件选型

省略

# 软件信息

pve虚拟
1. ikuai
2. openwrt
3. zerotier

# 网络划分

## 三层网络划分

### 核心网外网规划

考虑到部分企业经常会占用10.0.0.0/8及172.16.0.0/12两个网段，为了后续扩展VPN时可
以支持策略路由而不与核心网不冲突，核心网部分地址规划只采用192.168.0.0/16地址。

用户的光猫LAN口接入到核心网路由器时，必须保证其LAN口网段互不相同，由此来确保核
心路由器在多WAN口下能正确路由。初步规划用户的光猫网段为192.168.xxx.0/24，其中
xxx为户号前两位和最后一位的组合，计算公式如下。
```
（（户号/100）*10）+（户号%10）
```
各户IP段划分如下表所示。

用户接入时，以路由器WAN口进行接入，各户为独立子网，不与核心网下其他接入用户进行
互联。网段任意，不参与三层网络地址划分计划中。

### 核心网内网规划

接入用户集中在18-22楼，后续二期工程扩展14-17楼，而23-27楼不在考虑范围内，因此可
以粗略认为14-22均为占用状态，其他部分为空闲状态。目前计划240-250为公共内网网
段，而10-99为预留内网网段。

目前规划241为默认LAN1网段，后续公共网段依此类推。

为了提高硬件资源利用率，降低维护难度，1801将不使用独立的虚拟机作为路由系统，而
直接使用核心网路由器，新增LAN2网段单独给1801户使用，规划IP段暂定88。

|网络类型|        IP段      |      说明      |
|:------:|:----------------:|:--------------:|
| LAN1   | 192.168.241.0/24 | 关DHCP         |
| PPPoE  | 192.168.242.0/24 |                |
| L2TP   | 192.168.243.0/24 |                |
|        |                  |                |
| LAN2   | 192.168.88.0/24  | 1801户，开DHCP |

## 二层网络划分

| 户号 |       接口编号       | VLAN ID  |       IP段       |
|:----:|:--------------------:|:--------:|:----------------:|
| 1801 | GigabitEthernet 1/1  | 241,1801 | 192.168.181.0/24 |
| 1802 | GigabitEthernet 1/2  | 241,1802 | 192.168.182.0/24 |
| 1803 | GigabitEthernet 1/3  | 241,1803 | 192.168.183.0/24 |
| 1804 | GigabitEthernet 1/4  | 241,1804 | 192.168.184.0/24 |
| 1901 | GigabitEthernet 1/5  | 241,1901 | 192.168.191.0/24 |
| 1902 | GigabitEthernet 1/6  | 241,1902 | 192.168.192.0/24 |
| 2001 | GigabitEthernet 1/7  | 241,2001 | 192.168.201.0/24 |
| 2003 | GigabitEthernet 1/8  | 241,2003 | 192.168.203.0/24 |
| 2101 | GigabitEthernet 1/9  | 241,2101 | 192.168.211.0/24 |
| 预留 | GigabitEthernet 1/10 |          |                  |
| 2201 | GigabitEthernet 1/11 | 241,2201 | 192.168.221.0/24 |
| 2202 | GigabitEthernet 1/12 | 241,2202 | 192.168.222.0/24 |
| 2203 | GigabitEthernet 1/13 | 241,2203 | 192.168.223.0/24 |

# 软件配置信息

## PVE

路由器板载Intel 82599万兆芯片，和一张螃蟹千兆卡。首次安装完成后，两张网卡在系统
上看到的情况为：

万兆卡：eth0
螃蟹卡：eno1

### 物理机配置VF直通

虚拟机中的网卡计划使用VF直通，考虑到后续使用i915显卡直通gvt-g功能，需要修改grub
文件。编辑**/etc/default/grub**，找到**GRUB_CMDLINE_LINUX_DEFAULT="quiet"**，在
**quit**后面添加：
```
intel_iommu=on i915.enable_gvt=1 pci=assign-busses pcie_acs_override=downstream iommu=pt
```
其中，**i915.enable_gvt=1**用于启用gvt-g功能，**intel_iommu=on**启用PCI
passthough功能，其他为万兆卡VF相关配置。

修改完成后，执行以下命令，然后重启。
```
# 这些ko不知道为什么要添加，别人写的gvt-g教程里面有提到，暂时保留
echo vfio >> /etc/modules
echo vfio_iommu_type1 >> /etc/modules
echo vfio_pci >> /etc/modules
echo vfio_virqfd >> /etc/modules
echo kvmgt >> /etc/modules

update-grub
update-initramfs -u -k all
```

### 启用SR-IOV

新建文件**/etc/systemd/system/sriov.service**，填入
```
[Unit]
Description=Script to enable SR-IOV on boot

[Service]
Type=simple
# Start SR-IOV
ExecStartPre=/usr/bin/bash -c '/usr/bin/echo 16 > /sys/class/net/eth0/device/sriov_numvfs'
ExecStart=/usr/bin/bash -c '/usr/bin/ip link set eth0 up'
ExecStartPost=/usr/bin/bash -c '/usr/bin/ip link set eth0 mtu 9000'
ExecStartPost=/usr/bin/bash -c '/usr/sbin/ethtool -G eth0 rx 4096'
ExecStartPost=/usr/bin/bash -c '/usr/sbin/ethtool -G eth0 tx 4096'
# For iKuai
ExecStartPost=/usr/bin/bash -c '/usr/bin/ip link set eth0 vf 0 mac 02:00:00:00:02:41 vlan 241'
ExecStartPost=/usr/bin/bash -c '/usr/bin/ip link set eth0 vf 1 mac 02:01:00:00:00:88 vlan 88'
ExecStartPost=/usr/bin/bash -c '/usr/bin/ip link set eth0 vf 2 mac 02:02:00:00:18:01 vlan 1801'
ExecStartPost=/usr/bin/bash -c '/usr/bin/ip link set eth0 vf 3 mac 02:03:00:00:18:02 vlan 1802'
ExecStartPost=/usr/bin/bash -c '/usr/bin/ip link set eth0 vf 4 mac 02:04:00:00:18:03 vlan 1803'
ExecStartPost=/usr/bin/bash -c '/usr/bin/ip link set eth0 vf 5 mac 02:05:00:00:18:04 vlan 1804'
ExecStartPost=/usr/bin/bash -c '/usr/bin/ip link set eth0 vf 6 mac 02:06:00:00:19:01 vlan 1901'
ExecStartPost=/usr/bin/bash -c '/usr/bin/ip link set eth0 vf 7 mac 02:07:00:00:19:02 vlan 1902'
ExecStartPost=/usr/bin/bash -c '/usr/bin/ip link set eth0 vf 8 mac 02:08:00:00:20:01 vlan 2001'
ExecStartPost=/usr/bin/bash -c '/usr/bin/ip link set eth0 vf 9 mac 02:09:00:00:20:03 vlan 2003'
ExecStartPost=/usr/bin/bash -c '/usr/bin/ip link set eth0 vf 10 mac 02:10:00:00:21:01 vlan 2101'
ExecStartPost=/usr/bin/bash -c '/usr/bin/ip link set eth0 vf 11 mac 02:11:00:00:22:01 vlan 2201'
ExecStartPost=/usr/bin/bash -c '/usr/bin/ip link set eth0 vf 12 mac 02:12:00:00:22:02 vlan 2202'
ExecStartPost=/usr/bin/bash -c '/usr/bin/ip link set eth0 vf 13 mac 02:13:00:00:22:03 vlan 2203'
# For OpenWRT
ExecStartPost=/usr/bin/bash -c '/usr/bin/ip link set eth0 vf 14 mac 02:14:88:00:00:02 vlan 88'
# For Zerotier
ExecStartPost=/usr/bin/bash -c '/usr/bin/ip link set eth0 vf 15 mac 02:15:88:00:00:03 vlan 88'
ExecStartPost=/usr/bin/bash -c '/usr/bin/ip link set eno1v0 up'
ExecStartPost=/usr/bin/bash -c '/usr/bin/ip link set eno1v1 up'
ExecStartPost=/usr/bin/bash -c '/usr/bin/ip link set eno1v2 up'
ExecStartPost=/usr/bin/bash -c '/usr/bin/ip link set eno1v3 up'
ExecStartPost=/usr/bin/bash -c '/usr/bin/ip link set eno1v4 up'
ExecStartPost=/usr/bin/bash -c '/usr/bin/ip link set eno1v5 up'
ExecStartPost=/usr/bin/bash -c '/usr/bin/ip link set eno1v6 up'
ExecStartPost=/usr/bin/bash -c '/usr/bin/ip link set eno1v7 up'
ExecStartPost=/usr/bin/bash -c '/usr/bin/ip link set eno1v8 up'
ExecStartPost=/usr/bin/bash -c '/usr/bin/ip link set eno1v9 up'
ExecStartPost=/usr/bin/bash -c '/usr/bin/ip link set eno1v10 up'
ExecStartPost=/usr/bin/bash -c '/usr/bin/ip link set eno1v11 up'
ExecStartPost=/usr/bin/bash -c '/usr/bin/ip link set eno1v12 up'
ExecStartPost=/usr/bin/bash -c '/usr/bin/ip link set eno1v13 up'
ExecStartPost=/usr/bin/bash -c '/usr/bin/ip link set eno1v14 up'
ExecStartPost=/usr/bin/bash -c '/usr/bin/ip link set eno1v15 up'
Restart=on-failure

[Install]
WantedBy=multi-user.target
```
然后执行命令刷新，并启动sr-iov脚本：
```
systemctl daemon-reload
systemctl enable sriov.service
```
注意，在启动中，有使用到ethtool，需要提前安装**apt install ethtool**。

#### SR-IOV二层mac地址划分

IEEE规范规定，mac最高字节的bit[1]，为1时表示mac地址为本地管理，为0时表示mac地址
全球管理。此处将改bit默认为1，保持与IEEE规范兼容，表示本mac地址不经过全球组织管
理。为了方便标识VF编号，第二个字节表示VF编号，其他为0。

为了区分输入户号，**02:00:00:00:xx:yy**地址表示各户的网卡，其中xx表示楼层号，yy
表示户号，例如**02:00:00:00:18:01**表示1801户接入网卡。其中有例外情况：当xx:yy
小于10:00时，表示LAN口地址，xx:yy则对应为LAN口的VLAN号。目前将241及88划分为两个
VLAN，对应的地址为02:00:00:00:02:41及02:00:00:00:00:88。

