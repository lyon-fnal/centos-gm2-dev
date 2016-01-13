# Install the igprof profiler

# Load newer gcc
sudo yum -y install cmake
sudo wget http://people.centos.org/tru/devtools-2/devtools-2.repo -O /etc/yum.repos.d/devtools-2.repo
sudo yum clean all
sudo yum -y install devtoolset-2-gcc devtoolset-2-binutils
sudo yum -y install devtoolset-2-gcc-c++ devtoolset-2-binutils

source /opt/rh/devtoolset-2/enable

mkdir igprof
cd igprof

INSTAREA=/usr/local
IGPROF_VERSION=5.9.16
LIBATOMIC_VERSION=7.2alpha4
LIBUNWIND_VERSION=1.1

wget http://www.hpl.hp.com/research/linux/atomic_ops/download/libatomic_ops-$LIBATOMIC_VERSION.tar.gz
wget http://download.savannah.gnu.org/releases/libunwind/libunwind-$LIBUNWIND_VERSION.tar.gz
wget -Oigprof-$IGPROF_VERSION.tar.gz https://github.com/igprof/igprof/archive/v$IGPROF_VERSION.tar.gz

tar xvzf libatomic_ops-7.2alpha4.tar.gz
cd libatomic_ops-7.2alpha4
./configure --prefix=$INSTAREA
sudo make -j 4 install
cd ..

tar xvzf libunwind-1.1.tar.gz
cd libunwind-1.1
./configure CPPFLAGS="-I$INSTAREA/include" CFLAGS="-g -O3" --prefix=$INSTAREA --disable-block-signals
sudo make -j 4 install
cd ..

tar xvzf igprof-5.9.16.tar.gz
cd igprof-5.9.16
cmake -DCMAKE_INSTALL_PREFIX=$INSTAREA -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="-g -O3" .
make -j 4
sudo make install
cd ..

cd ..
echo 'Install of igprof to /usr/local complete. See $HOME/bin/setup_igprof to run'

