# HOW TO USE:
# This script will compile and install zfs AND compile lustre
# rpms will be in releases/lustre*
# install lustre rpms like `yum install -y --skip-broken releases/lustre-server/*x86_64.rpm`
# for now all lustre rpms install except lustre-resource-agents-2.14.0-1.el8.x86_64.rpm, but it seems to work
set -e
yum install -y epel-release
yum install -y wget git
yum install -y asciidoc audit-libs-devel automake bc binutils-devel bison\
 device-mapper-devel elfutils-devel elfutils-libelf-devel expect flex gcc\
 gcc-c++ git glib2 glib2-devel hmaccalc keyutils-libs-devel krb5-devel ksh\
 libattr-devel libblkid-devel libselinux-devel libtool libuuid-devel\
 libyaml-devel lsscsi make ncurses-devel net-snmp-devel net-tools newt-devel\
 numactl-devel parted patchutils pciutils-devel perl-ExtUtils-Embed pesign\
 python-devel redhat-rpm-config rpm-build systemd-devel tcl tcl-devel tk\
 tk-devel wget xmlto yum-utils zlib-devel libaio-devel\
 libffi-devel python-setuptools python2-devel python-cffi

yum install -y kernel-devel
mkdir -p releases/zfs

echo Downloading and building ZFS
if [ ! -d zfs ]
then
    git clone https://github.com/zfsonlinux/zfs.git
fi
cd zfs
git checkout zfs-0.8.1
if [ -e releases/zfs/kmod-zfs-devel-*.el7.x86_64.rpm ]
then
    sh autogen.sh
    ./configure --with-spec=redhat
    make pkg-utils pkg-kmod rpm-dkms
    cd ..
    mv zfs/*.rpm releases/zfs
else
    echo Skipping ZFS make as rpms exist
    cd ..
fi

echo Installing ZFS packages
if [ $1 = nozfsrpm ]
then
yum install -y releases/zfs/kmod-zfs-*-1.el7.x86_64.rpm\
 releases/zfs/kmod-zfs-devel-*.el7.x86_64.rpm\
 releases/zfs/zfs-*.el7.x86_64.rpm releases/zfs/zfs-kmod-*.el7.src.rpm\
 releases/zfs/libzfs2-*.el7.x86_64.rpm\
 releases/zfs/libzfs2-devel-*.el7.x86_64.rpm\
 releases/zfs/libzpool2-*.el7.x86_64.rpm\
 releases/zfs/libuutil1-*.el7.x86_64.rpm\
 releases/zfs/libnvpair1-*.el7.x86_64.rpm
else
 echo no zfs rpm install
fi
echo Downloading and building Lustre
if [ ! -d lustre-release ]
then
    git clone git://git.whamcloud.com/fs/lustre-release.git
fi
cd lustre-release
git checkout v2_12_7-RC1
sh autogen.sh
./configure --enable-server --disable-ldiskfs
make rpms

cd ..
mkdir -p releases/lustre-server
mv lustre-release/*.rpm releases/lustre-server

cd lustre-release
./configure --disable-server --enable-client
make rpms

cd ..
mkdir -p releases/lustre-client
mv lustre-release/*.rpm releases/lustre-client
