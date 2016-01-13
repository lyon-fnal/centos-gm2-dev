# centos-gm2-dev

This repository has a Vagrantfile and auxillary files for building a Centos 6.7 (equivalent to SLF6) Virtual Machine suitable for development of Muon g-2 offline code. 

## Features

Installed with this VM are:

* CVMFS with `/cvmfs/gm2.opensciencegrid.org` configured
* emacs editor
* GNU screen
* Minimal X-windows
* Mesa OpenGL
* gdb
* git
* meld (graphical diff)
* valgrind

Also included are installers for two profilers: `igprof` and `OpenSpeedShop`

This VM is meant to go on a Mac. It shares the host machines `/Users` directory. 

## Main Installation

Download and install VirtualBox from http://www.virtualbox.org/
Download and install Vagrant from https://www.vagrantup.com/downloads.html

Clone this repository to a directory and cd to it. 

Install the `vagrant-guest` plugin (keeps the VirtualBox Guest Additions up to date on the VM)
```
vagrant plugin install vagrant-vbguest
```

Clone or download this repository, initialize and provision the VM
```
git clone https://github.com/lyon-fnal/centos-gm2-dev.git
cd centos-gm2-dev
vagrant up  # Could take a long time
```

### Converting to VDI

It may be desirable to shrink the main VM disk, expecially after installing OpenSpeedShop. To shrink the disk, one must first convert the VMDK file for the VM into a VDI file.



