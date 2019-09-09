 ## Guide for KB-E (Kernel Building - Essentials) ##
     ## By Artx/Stayn <artx4dev@gmail.com> ##

This Guide is going to tell you all the basics and functionality of this
program made for building Kernels (arm/arm64). This program can handle the 
Kernel Building, Device Tree Image and other jobs as modules that anyone
can make for custom functionality.

You don't need a lot of knowledge to run this program and build your own 
kernel, this software is going to download, install and export all the 
necessary tools, variables and functions, but, this doesn't mean that this
will fix your compilation errors, contact the maintainer of that kernel or 
fix it by yourself.

In case of any error or help needed, contact me via Email, PM via XDA 
@Stayn or Telegram: @ArtxDev with the log files inside this program 
./resources/logs folder, thanks ;).

--------------------------------------------------------------------------------

# Download and Setup: #

1) To download and setup this program, follow these steps:

- $ git clone https://github.com/KB-E/KernelBuilding-Essentials 
- $ cd KernelBuilding-Essentials (Or the folder where you downloaded the repo)
- $ source core.sh

2) After running core.sh KB-E will get "installed" into your environment, then, 
you have to download your kernel source inside ./source folder and you can
initialize KB-E using the command:

- $ kbe start

3) After installation, the command 'kbe' alone will display information about
its usage, you can run it anywhere because the paths are set in ~/.bashrc file

--------------------------------------------------------------------------------

# Now, let's talk about the program: #

In order to initialize KB-E, you have to run the command:

- $ kbe start

This is the main KB-E command, from here you can start configuring a device and
all the data will be stored in a folder named "devices", inside it will be a 
folder with your device codename (ex: bacon) and inside that device folder there
will be another folder with the name you gave to your kernel
(ex: devices/bacon/ArtxKernel/).

With this system, you can run "kbe start" and configure another kernel, if the
device codename is the same then your new configuration will be stored in that
same device folder, if the kernel name is the same the config will get overwritten
without confirmation..!

The modules that comes with KB-E are "makeanykernel" and "megatools", I will talk 
about those modules and how they work later, for now, let's see what the command
"kbe" can do:

# Main command: 'kbe' #

Here is where you start once KB-E is installed, running 'kbe' alone without an
argument will display it's usage that will vary depending on the status of KB-E
and the config supplied. First of all, to start configuring a device you need
a kernel source inside the "./source" folder, then, you can initialize KB-E
using:

- $ kbe start

After you set the config for your device, KB-E will store all that data inside
"./devices/<device>/<kernelname>/" folder, you can configure all the kernels you
want for that specific device (In case you want to build different kernels or
your device has multiple variants).

The command "kbe start" can load an existing device and kernel, the usage for this
is the following:

- $ kbe start <device> <kernelname>

If you don't specifiy a <device> KB-E will start a new config process
If you specify a <device> and not the <kernelname>, KB-E will check if that
device exist and if it does theres two cases:

1) If that device has only one kernel configured it will automatically load it and
KB-E will be ready for its use
2) If that device has more than one kernel configured it will show you a list and
you have to select which one to load

If you specify a <device> and a <kernelname>, KB-E will check if such device and
kernel exist and load it automatically without selecting from a list (in case there
is more than two kernels for the same device).

# '--kernel' or '-k' Flag: #

This flag added to the command 'kbe' ("kbe --kernel" or "kbe -k") is going to
build your kernel automatically using the data of the device you created/selected
you don't have to worry about anything at this process if the kernel that you're
building  doesn't have any errors in the code. This program WILL NOT fix those
compilation errors for you.

If you allowed the kernel building debug during the program configuration then
you'll  see the compile process and if there's an error it will be more easy to 
you to fix it, however, if you're running it without kernel building debug then
if there's an error everything will be logged into './resources/logs/' folder

The Kernel built is going to be stored into the
./devices/<device>/<kernelname>/out/kernel/ folder, you can easily copy that
kernel anywhere you want with the command:

- $ cpkernel <path>

## '--dtb' or '-dt' Flag ##

This flag added to the command 'kbe' ("kbe --dtb" or "kbe -dt") is going to build
the variant dtb (Device tree) image for your specific device and variant. It's 
highly  recommended to build it because it's the specific device tree image for
the kernel that you're going to build. The dtb image built is going to be stored
into the ./devices/<device>/<kernelname>/out/dt/ folder, you can easliy copy that
device tree image anywhere you want with the command:

- $ cpdtb <path>

# Modules: #

## AnyKernel Module ##
## '--anykernel' Flag ## 

This flag added to the command 'kbe' ("kbe --anykernel") is going to build the
installer  for your variant using AnyKernel by osm0sis, during the configuration
this program gives to you 2 options:

1) You can use the local AnyKernel template that is going to be extracted into 
'./devices/<device>/<kernelname>/anykernelfiles/', this process is done during the 
configuration phase, for this option once the configuration is done you've to
configure the template extracted

3) Manually set your own template into './devices/<device>/<kernelname>/anykernel/'
folder. That's it.

## '--upload' Flag ##

This flag added to the command 'kbe' (kbe --upload) is going to upload your
recently built AnyKernel installer to your MEGA Account, if you don't have MEGA
Installed this software is going to download and install it

--------------------------------------------------------------------------------

## For advanced users of developers, please run "kbe info" for more detailed information ##

