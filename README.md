# Installing zfslustre
rpm packages for zfs with lustre for RHEL

## HOW TO USE:

This script will compile and install zfs AND compile lustre

rpms will be in releases/

zfs rpms will automatically be installed as they are needed to install lustre. Install lustre rpms however you'd like, ex: `yum install -y releases/lustre-server/*x86_64.rpm`

Feel free to change ZFS and Lustre versions. Follow the [support matrix](https://wiki.whamcloud.com/display/PUB/Lustre+Support+Matrix) for higher chance of success.

### Troubleshooting:

If the script seems to be failing, then feel free to get rid of the if statements, they seem to be a bit buggy at the time of writing for some reason.

## Compiling zfs/lustre
ZFS and lustre require a lot of packages. These packages are given in the beginning of the script. There are some yum repos you will need to enable to install certain package dependencies. These include "PowerTools" and "HighAvailability". The script gives a general step by step and was developed off [this guide](https://github.com/DDNStorage/lustre_manual_markdown/blob/master/02.01-Installation%20Overview.md#steps-to-installing-the-lustre-software). The referenced guide gives a very good insight into Lustre, and is a more reliable source of information than the lustre wiki.

# Configuring ZFS and Lustre

## Quick links
Here are some quick readings that I felt were helpful in configuring the ZFS and Lustre

**zfs**
http://nex7.blogspot.com/2013/03/readme1st.html
https://arstechnica.com/gadgets/2020/05/zfs-versus-raid-eight-ironwolf-disks-two-filesystems-one-winner/
https://jrs-s.net/2018/08/17/zfs-tuning-cheat-sheet/

**Lustre**
https://github.com/DDNStorage/lustre_manual_markdown/blob/master/02.07-Configuring%20a%20Lustre%20File%20System.md
https://wiki.lustre.org/images/0/0d/LUG2019-Sysadmin-tutorial.pdf

## ZFS
Creating ZFS pools is easy and quite well documented. To get started is easy, just follow the links above to read some explanations from people who can explain much better than I can

## Lustre
**Important**: make sure that you disable SElinux and disable firewall(or open lustre ports). If you don't do these steps, your system may fail to work and error messages will be unclear.
```
systemctl stop firewalld
systemctl disable firewalld 
systemctl start lustre
```
```
sed -i '/^SELINUX=/s/.*/SELINUX=disabled/' /etc/selinux/config
```
It is probably best to read the github ddn manual, but here is a simple example:
**MGS**
```
Zpool create mgspool raidz sdb sdc sdd sde
mkfs.lustre --mgs --backfstype=zfs mgspool/mgt

mkfs.lustre  --mdt --backfstype=zfs --fsname=lustre --mgsnode=$(hostname)@tcp --index=0 mgspool/mdt0
# change $(hostname) if needed

mkdir /mnt/mgt
mount -t lustre mgspool/mgt /mnt/mgt

Mkdir /mnt/mdt
mount -t lustre mgspool/mdt0 /mnt/mdt
```
**OSS**
```
Zpool create osspool raidz sdb sdc sdd sde
mkfs.lustre  --ost --backfstype=zfs --fsname=lustre --mgsnode=node1@tcp --index=0 osspool/ost0

mkdir /mnt/ost
mount -t lustre osspool/ost0 /mnt/ost![image](https://user-images.githubusercontent.com/35553770/138371430-1b106cf0-ea3a-4041-9e74-111017f903fa.png)
```

# Other notes

I also have some automated test code for creating and testing local zfslustre systems. Could be useful. See [here](https://github.com/botkevin/zfslustrefiotest)
