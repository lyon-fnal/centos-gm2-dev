# Install openspeedshop

sudo yum install -y cmake rpm-build openmpi patch autoconf automake elfutils-libelf elfutils-libelf-devel libxml2 libxml2-devel binutils binutils-devel python python-devel flex bison bison-devel bison-runtime libtool libtool-ltdl libtool-ltdl-devel git

sudo wget http://people.centos.org/tru/devtools-2/devtools-2.repo -O /etc/yum.repos.d/devtools-2.repo
sudo yum -y install devtoolset-2-gcc devtoolset-2-binutils
sudo yum -y install devtoolset-2-gcc-c++ devtoolset-2-binutilsls

source /opt/rh/devtoolset-2/enable

mkdir oss
cd oss

wget http://iweb.dl.sourceforge.net/project/openss/openss/openspeedshop-2.2/openspeedshop-release-2.2.tar.gz
tar xvzf openspeedshop-release-2.2.tar.gz
cd openspeedshop-release-2.2

sudo ./install-tool --build-krell-root --krell-root-prefix /opt/krellroot_v2.2  # Takes a long time
sudo ./install-tool --build-offline --openss-prefix /opt/ossoffline_v2.2 --krell-root-prefix /opt/krellroot_v2.2

cd ..
echo 'Install of openspeedshop to /opt complete. See $HOME/bin/setup_oss to run'
