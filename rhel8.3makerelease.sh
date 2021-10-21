set -e
yum install -y epel-release
yum install -y wget git
yum install -y asciidoc audit-libs-devel automake bc binutils-devel bison\
 elfutils-devel elfutils-libelf-devel expect flex gcc\
 gcc-c++ git glib2 glib2-devel hmaccalc keyutils-libs-devel krb5-devel ksh\
 libattr-devel libblkid-devel libselinux-devel libtool libuuid-devel\
 lsscsi make ncurses-devel net-snmp-devel net-tools newt-devel\
 numactl-devel parted patchutils pciutils-devel perl-ExtUtils-Embed pesign\
 redhat-rpm-config rpm-build systemd-devel tcl tcl-devel tk\
 tk-devel wget xmlto yum-utils zlib-devel libaio-devel\
 libffi-devel python2-devel

# depending on version of centos it may be "PowerTools"
dnf config-manager --set-enabled powertools
#  libgen3-devel
dnf install -y libyaml-devel kernel-rpm-macros\
 binutils-devel platform-python-devel libtirpc-devel\
 python3-cffi python3-devel kernel-abi-whitelists
# some versions may have this as ha
yum install -y --enable-repo=HighAvailability resourceagents

yum install -y kernel-devel

mkdir -p releases/zfs

echo Downloading and building ZFS
if [ ! -d zfs ]
then
    git clone https://github.com/zfsonlinux/zfs.git
fi
cd zfs
git checkout zfs-2.0.0
# for some reason this if statement is fickle in centos8. No idea why
if [ ! -e *.el8.x86_64.rpm ]
then
    echo Building ZFS
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
if [ "$1" != "nozfsrpm" ]
then
# releases/zfs/*.x86_64.rpm\
yum install -y releases/zfs/kmod-zfs-*-1.el8.x86_64.rpm\
 releases/zfs/kmod-zfs-devel-*.el8.x86_64.rpm\
 releases/zfs/zfs-*.el8.x86_64.rpm\
 releases/zfs/libzfs4-*.el8.x86_64.rpm\
 releases/zfs/libzfs4-devel-*.el8.x86_64.rpm\
 releases/zfs/libzpool4-*.el8.x86_64.rpm\
 releases/zfs/libuutil3-*.el8.x86_64.rpm\
 releases/zfs/libnvpair3-*.el8.x86_64.rpm
else
 echo no zfs rpm install
fi
echo Downloading and building Lustre
if [ ! -d lustre-release ]
then
    git clone git://git.whamcloud.com/fs/lustre-release.git
fi
cd lustre-release
git checkout b2_14
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
