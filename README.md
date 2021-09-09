# zfslustre
rpm packages for zfs with lustre

HOW TO USE:

This script will compile and install zfs AND compile lustre

rpms will be in releases/

lustre rpms like `yum install -y releases/lustre-server/*x86_64.rpm

Feel free to change ZFS and Lustre versions. Follow https://wiki.whamcloud.com/display/PUB/Lustre+Support+Matrix for higher chance of success.

notes:
You may get an error installing lustre-resource-agents, you need to install resource-agents with enablerepo=ha. This repo may also be called different things depending on your yum version, just find corresponding name for High Availability repo.
