# NOTE:
I no longer use `vagrant` and am not updating this repository.

# centos-gm2-dev

This repository has a Vagrantfile and auxillary files for building a Centos 6.10 (equivalent to SLF6) Virtual Machine suitable for development of Muon g-2 offline code. 

The idea is to have a virtual machine with a run-time environment similar to that of grid jobs along with a development environment. See below for some workflow ideas. 

## 1 Terminology

The "host" is your metal machine (e.g. your laptop) running your host OS (e.g. MacOS). The `guest` is the virtual machine (VM) running SLF6. 
`VirtualBox` is a free product from Oracle that allows you to run Virtual Machines. `Vagrant` is a configuration manager that makes setting up and configuring VMs in VirtualBox easier. 

## 2 Features

Installed with this VM are:

* CVMFS
* emacs editor
* GNU screen
* X-windows (you can pop a window to your ssh host)
* VNC server
* Mesa OpenGL
* gdb
* git
* meld (graphical diff)
* valgrind
* kerberos
* netdata (for monitoring resource usage of the VM)

The VM configuration assumes you have a Mac as the host as it shares your `/Users` directory with the VM. It ought to work fine on Windows too, but you will need to alter the `Vagrantfile` and change the folder sharing (should be obvious). 

## 3 Main Installation

Note that the installation requires a large amount of downloads. Be sure to have a fast internet connection. 

If you have problems, see section 7 below. 

- Download and install VirtualBox from http://www.virtualbox.org/
- Download and install Vagrant (flavor appropriate for your **host**) from https://www.vagrantup.com/downloads.html

Install the `vagrant-guest` plugin (keeps the VirtualBox Guest Additions up to date on the VM -- you need this to access your host disk). From your terminal...
```bash
vagrant plugin install vagrant-vbguest
```

Clone or download this repository
```
git clone https://github.com/lyon-fnal/centos-gm2-dev.git
cd centos-gm2-dev
```

Check the `Vagrantfile` by editing it in your favorite editor. In particular, look for the lines,

```
  config.vm.provider "virtualbox" do |vb|
    # Customize the amount of memory on the VM:
    vb.cpus = 6   # I have a 6 core laptop
    vb.memory = 1024 * 16  # 16 GB (half of my memory)
```
and set the number of CPUs and memory size (in units of megabytes) according to your host machine. I generally give the VM access to all of my machine's CPUs and half the memory. 

### 3.1 Provision the VM

Provisioning means to install and configure stuff in the VM to make it usable for what you want to do. 

Be sure you are in the directory with the `VagrantFile`. 

Bring up the VM with full provisioning (it may take many minutes to run)
```
vagrant up
```

Note that you may need to give your host machine's administrative password because NFS needs to be set up for file sharing. 

The process may stop on an error. I've found that issuing `vagrant up` again makes things work.

If things are working, it may take a long time to populate the VM with all of the software. 

When it finishes, the virtual machine is now ready. Do `vagrant ssh` to log in.

## 4 Interacting with the VM

To interact with your VM, you need to be in the directory that has the `VagrantFile` file mentioned above. The `vagrant` commands know what VM you mean by the directory you are in. 

### 4.1 Starting and entering the VM

If you encounter problems, see section 7 below.

If you have recently rebootted your machine, it is likely that your VM is not running. You can always check with 

```bash
vagrant status
```

If it doesn't say `running`, then issue 

```bash
vagrant up
```

Note that you may need to give your host machine's administrative password because NFS needs to be set up for file sharing. 

You can then `ssh` into the VM with,

```bash
vagrant ssh  # See below for X-windows
```

If for some reason you want to reboot the VM, you can do that with

```bash
vagrant reload
```

You can stop the virtual machine with 

```bash
vagrant halt
```


### 4.2 Things you can do in the VM

There are many things you can do in the SLF6 Virtual Machine

#### 4.2.1 CVMFS

CVMFS is automounted. That means that when you first log into a fresh VM, doing `ls /cvmfs` will look empty. That's ok. You need to access a sub-directory first. Simply accessing `/cvmfs/gm2.opensciencegrid.org` (or any other Oasis or CERN CVMFS repository directory) in any way (`ls` or `source` a script inside) will mount the volume. You can mount any other CVMFS volume like `/cvmfs/fermilab.opensciencegrid.org` as well. 

An easy way to start is 

```
source /cvmfs/gm2.opensciencegrid.org/prod/g-2/setup 
```

Unfortunately, tab completion for the directory name only works when it is mounted. So you will not have tab completion for the first access.

Note that accessing files for the first time in `/cvmfs/...` may be slow because the files need to be downloaded. 

#### 4.2.2 X-windows

You can pop X-windows programs, like Root, in the VM and have them show up on your host, so long as you have an X-windows client like XQuartz for the Mac. For that to work, you will need to ssh into the VM with X-windows forwarding turned on. 

```
vagrant ssh -- -Y
```

You should be able to pop X-window programs on your host. Note that, however, X-windows tends to be quite slow. 

#### 4.2.3 VNC

A VNC server is a much faster way to interact with the VM as compared to X-windows. A VNC server is included in the VM. Here's how to run it. 

The first thing you should do is to create a password for your VNC server (it can be simple, VNC will be restricted to your laptop). Do that with 

```
vncpasswd
```

You can start your vnc server with (you can add -autokill will exit VNC server when you log out of the VNC session),

```
vncserver -geometry 1400x900 # You may need to play with the geometry - see below
```

You should see output referencing to `localhost.localdomain:1`. If you see `:2` instead, that means that you now have two vnc servers running. You should remove them with 
```
vncserver -kill :1 ; vncserver -kill :2
```
and start the server again. 

Note that the VNC server will out live your ssh terminal session. You should get in the habit of killing the server when you are done with it. You can do that with `vncserver -kill :1`

You can even start the VNC server from your host directly with 

```
vagrant ssh -- vncserver -geometry 2880x1800 -autokill &
```

Note that the geometry above is appropriate for a Mac laptop retina display. You may need to play with it to get the VNC screen the right size for you. Setting the gometry option above seems to set the maximum geometry in the VM (use the System -> Preferences -> Display option within the VM desktop to adjust further). Another good geometry may be`-geometry 2560x1440` (for a Thunderbolt display). Turning on Scaling in the VNC viewer will help as well. You can adjust things like font size from within the VM desktiop with System -> Preferences -> Appearance menu. 

Note that if you run `vncserver` on a Fermilab machine, you should **always** use the `-localhost` flag to restrict access to the VNC server. You do not need that here as VirtualBox will prevent outside access to your VNC server on the VM. 

You can access the VNC server on your host with a VNC client. A Mac comes with one already installed called "Screen Sharing.app". The connection URL is `localhost:5901`. Use the password you entered above. If you are using the "Screen Sharing.app" be sure to turn "Scaling" on (from the "View" menu). That will improve the sharpness of the GUI. 

If the VNC screen blanks out and then asks you for a password, that password will be `vagrant` .

A terminal program is available in the desktop from the menu "Applications -> System Tools -> Terminal". You can configure this desktop as you wish and your changes will be persistent between sessions. 

If you still have your ssh terminal, you can pop windows into the VNC server by first doing,

```
export DISPLAY=:1

# Then you can do,
gnome-terminal &  # Pop a terminal in the VNC
root # Run root
```

To stop the VNC session, click on "vagrant" at the top of the desktop and chose "Quit". If you used the `-autokill` option when you started the `vncserver`, then the server will automatically quit. If you didn't do that, then you can kill the VNC server when you are done your session with `vncserver -kill :1` .

If you do not have a Mac, then do a Google search for VNC clients. Most should work with the server installed on the VM. 

#### 4.2.4 Accessing the host file systm

Your username on the VM is `vagrant`. The `/home/vagrant` directory is on the VM filesystem. The `/vagrant` directory in the VM is the same directory on your host that has the `VagrantFile`. 

If you are on a Mac, you should also be able to access your Mac's files with `/Users/<macUserName>`. Access to those files should be quite fast as they are served with NFS. 

For Windows, you can likely set up a similar mount. 

#### 4.2.5 Obtaining a kerberos ticket

Kerberos is installed in the VM. Be sure to give your Fermilab user name when requesting a ticket (if you don't you will get an error as the unix username in the VM is `vagrant`). 

```bash
kinit fred@FNAL.GOV
```

You will also need your Fermilab user name when you log in to the Fermilab machine...

```bash
ssh fred@gm2gpvm04.fnal.gov
```


#### 4.2.6 Accessing g-2 data

Processing large amounts of data should be performed by grid jobs. However, for testing or small analyses, you may want to transfer some files to your local machine with your VM. There are two easy ways to transfer files to your local machine. 

* `scp` allows you to directly copy files from a Fermilab node to your machine. You will need a kerberos ticket (see above). Then use the `scp` command like `cp`, but with the user and machine name included as shown below. If you use wild cards, enclose the expression in single quotes (otherwise your local VM shell will try to interpret them). 

```
scp 'fred@gm2gpvm04.fnal.gov:/gm2/app/users/fred/myStuff/*' . 
scp fred@gm2gpvm04.fnal.gov:/pnfs/GM2/scratch/users/fred/myDir/myFavoriteDataFile.root .
```

* Another way to directly work with a remote file system is to use `sshfs`, which is installed in the VM. `sshfs` allows you to mount a remote directory as if it is a file system in your VM. You can do this for files in `/pnfs` but remember that quickly accessing those files may cause a high load for dCache. sshfs has a nice feature that it caches files locally. If you have a file in `/pnfs` that you are reading from repeatedly, `sshfs` will make repeat access very fast with the caching. 

   There is a `/pnfs` mount point in the VM. You must give it correct permissions by doing,
   
   ```bash
   # Only do this once in the life of the VM
   sudo chown vagrant /pnfs ; sudo chgrp vagrant /pnfs
   ```
   
   Then you can mount `/pnfs` with...
   
    ```
    sudo kinit fred@FNAL.GOV   # Note that you must run this with `sudo` to save your ticket in the right place
    sudo sshfs fred@gm2gpvm04.fnal.gov:/pnfs /pnfs -o allow_other  
   ```
  
  You can then access files directly from your VM's `/pnfs/GM2/...`. 
  
  You can unmount the remote volume with 
  
  ```
  sudo umount /pnfs
  ```
  
  You will need to issue the `sshfs` command everytime you restart the VM. 
  
#### 4.2.7 Monitoring VM performance with netdata

The `netdata` monitoring system is installed, but is not started by default. You can start it with `sudo netdata`. `netdata` is the same system we run in the control room to monitor the DAQ machines. On your host, open `localhost:19999` in your browser and you'll see the monitoring page. If you are running a `gm2` program, click on the "Applications" section and you'll see metrics for a group called `art`. With those metrics you can see memory, CPU, disk, and network usage for your art program execution. 
  
## 5 Workflows tips

Here are some tips for using the virtual machine.

### 5.1 Use the host file system

You should use the host file system as much as possible and avoid writing to `/home/vagrant`, which is in the VM's filesystem. 

The VM's file system lives in a file on your host machine. The more you write to the VM's file system, the larger that file becomes. It will never shrink. To avoid it becoming huge, use a directory on your host machine like `/Users/fred/Development/whatever`.  Because that is served with NFS, access should be very fast. You can put g-2 code and executables there too. 

### 5.2 You have the full g-2 development enviornment

`setup` works. `mrb` works. `gm2` works. It all works and the code you build here can used for grid jobs. 

### 5.3 Use VNC 

With VNC, you can make a nice GUI environment that is very responsive. Doing things out of your host's terminal program works too. X-windows popped on your host tend to be slow, so prefer VNC. See above for how to pop windows from there into the VNC screen. 

## 6.0 CLion

CLion is an extremly useful and comprehensive C++ IDE. It is available at https://www.jetbrains.com/clion . Unfortunately, it costs real money to use, but you can try it for 30 days and they have free academic licenses if you have an `.edu` e-mail address. There is an effort at Fermilab to make CLion generally available to Fermilab staff as well. 

The best way I've found to install CLion is to simply download their Linux tar file, unpack it in a directory on your host, and run it from there in the VM. If you install it under `/Users` (on your Mac), the VM will access it with NFS and it will be fast. You definitely should use VNC for the fastest GUI response. Using it by popping an X-Window on your host will likely be slow. 

You can download from https://www.jetbrains.com/clion/download/#section=linux .

### 6.1 CLion and art/studio

It is possible to develop within the art ecosystem with CLion and in fact the environment you get will be very nice. Here are the steps I do to get going...

Start the VM; start VNC; connect to VNC with a client; pop a terminal window on that desktop. Within that terminal, set up your art environment. I've been using the `studio` simpified build system, but many of the instructions here should work for developing in a full-blown `mrb` environment as well. 

If you are going to be debugging (see below) then you'll need python3.6 to use the nice *pretty-printers* (python3.6 is installed in the VM, but is not the default python). To access that, the first thing you do in your terminal window is to issue the command,

```bash
scl enable rh-python36 bash
```

then set up your environment normally and then remove the `/cvmfs` python. See more info below for running the debugger. 

Once your environment is set up, then start up CLion (e.g. `/path/to/CLion/bin/clion.sh &'). If you are starting it for the first time, it will ask you many configuration questions. 

### 6.2 Preparing a CLion project with studio

To use the `studio` build system...

```bash
cd somewhere   # a directory on your host is best
source /cvmfs/gm2.opensciencegrid.org/prod/g-2/setup
setup gm2 v9_15_00 -q prof  # or the latest or your choice
setup studio
studio project gm2 -n MyProject  # Replace MyProject accordingly
cd MyProject
source setup.sh
setup cmake v3_10_1  # or appropriate version

studio create-analyzer TestAnalyzer
```

Now start CLion with this command in the terminal window: `/path/to/CLion/bin/clion.sh &' .

## 7 Problems

This section has a list of problems that have been encountered with solutions. 

## 7.1 `vagrant up` stops with failure

We have seen an issue where the `vagrant up` command stops with a vague error message like,

```
The following SSH command responded with a non-zero exit status.
Vagrant assumes that this means the command failed!

/sbin/ifdown 'eth1'
mv -f '/tmp/vagrant-network-entry-eth1-1557285375-0' '/etc/sysconfig/network-scripts/ifcfg-eth1'
(test -f /etc/init.d/NetworkManager && /etc/init.d/NetworkManager restart) || ((systemctl | grep NetworkManager.service) && systemctl restart NetworkManager)
/sbin/ifup 'eth1'

Stdout from the command:

Determining IP information for eth1... failed.
```

The problem is that VirtualBox's internal DHCP network is disabled (this network is apparently required by the Vagrant VM). Re-enable it by starting the VirtualBox application and selecting the menu `File -> Host Network Manager ...` That will bring up a dialog box listing Host networks. There should be one called `vboxnet0` and the check box next to `Enable` under `DHCP Server` should be checked (it's likely not checked if you are seeing this problem). Click the check box to enable and click `close`. You should then reload the VM with `vagrant reload`. 
