#!/bin/bash -le
module load libs-extra
module load mkl/2018-initial
module load gcc/5.3.0
module load cmake/3.7.2
module load hwloc/1.11.6-gcc-5.3.0
#module load mpi-openmpi/2.1.0-gcc-5.3.0
#module load starpu/1.2.1-gcc-5.3.0-openmpi
module load starpu/1.2.1-gcc-5.3.0

module list
git config --global credential.helper 'cache --timeout=36000'

# BASH verbose mode
set -x 


reponame=hicma
# Check if we are already in hicma repo dir or not.
if git -C $PWD remote -v | grep -q "https://github.com/ecrc/$reponame"
then
	# we are, lets go to the top dir (where .git is)
	until test -d $PWD/.git ;
	do
		cd ..
	done;
else
	#we are not, we need to clone the repo
	git clone https://github.com/ecrc/$reponame.git
	cd $reponame
fi

# Update submodules
HICMADEVDIR=$PWD 
git submodule update --init --recursive

# STARS-H
cd stars-h
rm -rf build
mkdir -p build/installdir
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$PWD/installdir -DMPI=OFF -DOPENMP=OFF
make clean
make -j
make install
export PKG_CONFIG_PATH=$PWD/installdir/lib/pkgconfig:$PKG_CONFIG_PATH

# CHAMELEON
cd $HICMADEVDIR
cd chameleon
rm -rf build
mkdir -p build/installdir
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCHAMELEON_USE_MPI=OFF  -DCMAKE_INSTALL_PREFIX=$PWD/installdir
make clean
make -j
make install
export PKG_CONFIG_PATH=$PWD/installdir/lib/pkgconfig:$PKG_CONFIG_PATH

# HICMA
cd $HICMADEVDIR
rm -rf build
mkdir -p build/installdir
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$PWD/installdir -DHICMA_USE_MPI=OFF
make clean
make -j
make install
export PKG_CONFIG_PATH=$PWD/installdir/lib/pkgconfig:$PKG_CONFIG_PATH

