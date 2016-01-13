#!/usr/bin/env bash

## Bootstrap script to provision a CENTOS 6 VM

echo '======='
echo 'PROVISIONING...'

echo '..Udpate yum database..'
yum -y update

echo '..Install epel and redhat-lsb-core repositories..'
yum -y install epel-release
yum -y install redhat-lsb-core

echo '..Install some developer tools..'
yum -y install emacs screen git expat-devel perl gcc glibc-devel gdb freetype-devel mesa-libGL-devel mesa-libGLU-devel meld valgrind

yum -y install kernel-devel

echo '..Install X11 and openGL..'
yum -y groupinstall "X Window System" 
ln -sf /usr/lib64/libGLU.so.1.3.1 /usr/lib64/libGLU.so  # for cadmesh
ln -sf /usr/lib64/libGL.so.1.2.0 /usr/lib64/libGL.so
ln -sf /usr/lib64/libSM.so.6.0.1 /usr/lib64/libSM.so
ln -sf /usr/lib64/libICE.so.6.3.0 /usr/lib64/libICE.so
ln -sf /usr/lib64/libX11.so.6.3.0 /usr/lib64/libX11.so
ln -sf /usr/lib64/libXext.so.6.4.0 /usr/lib64/libXext.so
ln -sf /usr/lib64/libXmu.so.6.2.0 /usr/lib64/libXmu.so

echo '..Install CVMFS..'
yum -y install yum-plugin-priorities
rpm -Uvh https://repo.grid.iu.edu/osg/3.3/osg-3.3-el6-release-latest.rpm
yum -y install osg-oasis

echo "user_allow_other" > /etc/fuse.conf
grep -q -F '/cvmfs' /etc/auto.master || echo "/cvmfs /etc/auto.cvmfs" >> /etc/auto.master

sudo service autofs restart

cat > /etc/cvmfs/default.local <<EOF
# Pull repositories that are in /cvmfs/*.*
CVMFS_REPOSITORIES="`echo $(ls /cvmfs | grep  '\.')|tr ' ' ,`"

# Talk directly to the stratum 1 server unless overriden in domain.d files
CVMFS_HTTP_PROXY=DIRECT
#CVMFS_HTTP_PROXY="http://squid.fnal.gov:3128"

# Expand quota (units in MB)
CVMFS_QUOTA_LIMIT=20000
CVMFS_CACHE_BASE=/var/cache/cvmfs
EOF

# Add zerofree (needed to compact VDI disk)
wget ftp://fr2.rpmfind.net/linux/epel/5/x86_64/zerofree-1.0.1-5.el5.x86_64.rpm
sudo rpm -ivh zerofree-1.0.1-5.el5.x86_64.rpm
rm -f zerofree-1.0.1-5.el5.x86_64.rpm



echo '...PROVISIONING COMPLETE - Run more setups in $HOME/moreInstalls'
