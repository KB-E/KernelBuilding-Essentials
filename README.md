 ## Guide for KB-E (Kernel Building - Essentials) ##
     ### By Artx/Stayn <artx4dev@gmail.com> ###

This Guide is going to tell you all the basics and functionality of this
program made for building Kernels (arm/arm64). This program can handle the 
Kernel Building automatically using some data defined by the user and other
operations made by the module scripts (such as MakeAnykernel or Megatools).

You don't need a lot of knowledge to run this program and build your own 
kernel, this software is going to download, install and export all the 
necessary tools, variables and functions, but, this doesn't mean that this
will fix your compilation errors, contact the maintainer of that kernel or 
fix it by yourself.

In case of any error or help needed, contact me via Email or PM via XDA 
@Stayn with the log files inside this program ./resources/logs folder, thanks ;).

--------------------------------------------------------------------------------

# Download and Setup: #

- To download and setup this program, follow these steps:

1) vm$ git clone https://github.com/KB-E/KernelBuilding-Essentials 
2) vm$ cd KernelBuilding-Essentials (Or the folder where you downloaded the repo)
3) vm$ source core.sh

- After running core.sh your environment will be set, then, you have to download
your kernel source inside ./source folder and run core.sh again (Keep in mind
that everytime you want to run this program it has to be inside the folder 
where you downloaded the repo)

--------------------------------------------------------------------------------

## Now, let's talk about the program: ##

In order to run this program, you have to run "core.sh", this is the main script,
to execute it, run "source core.sh" as a command and the program will initialize, after
this, you'll be prompted to accept an disclaimer, it's very important, because this 
software is going to require "sudo" access (To set the right permissions), then,
you'll be into the first run and once it's finished, you can execute this program 
again to start the config process where this program will prompt you for the session
needed information

# Main command: 'kbe' #

Here is where you start once you finish setting all the configs, 'kbe' is the 
main command of this program, but it only works with flags, otherwise it'll display
the flags information that I'm gonna explain right now:

## '--kernel' or '-k' Flag: ##

This flag added to the command 'kbe' ("kbe --kernel" or "kbe -k") is going to build
your kernel automatically using the data that you entered previously, you don't have
to worry about anything at this process if the kernel that you're building doesn't 
have any errors in the code.

If you allowed the kernel building debug during the program configuration then you'll 
see the compile process and if there's an error it will be more easy to you to fix it, 
however, if you're running it without kernel building debug then if there's an error 
everything will be logged into './resources/logs/' folder

The Kernel built is going to be stored into './out/Images/'. The kernel name is the
same has device variant name you set before (It can be anything, but you better put
your device codename there).

## '--dtb' or '-dt' Flag ##

This flag added to the command 'kbe' ("kbe --dtb" or "kbe -dt") is going to build the
variant dtb (Device tree) image for your specific device and variant. It's highly 
recommended to build it because it's the specific device tree image for the kernel that
you're going to build. The dtb image built is going to be stored into './out/dt/'.

# Modules: #

## AnyKernel Module ##
## '--anykernel' Flag ## 

This flag added to the command 'kbe' ("kbe --anynerel") is going to build the installer 
for your variant using AnyKernel by osm0sis, during the configuration this program gives
to you 3 options:

1) You can use the local AnyKernel template that is going to be extracted into 
'./out/aktemplate/', this process is done during the configuration phase, for this option
once the configuration is done you've to configure the template extracted

2) Download a template from your MEGA Account, you'll be prompted for entering the path of
this template, you've to enter the folder where it belongs and then the file name that 
*Must* be compressed into a .zip file, if the path is correctly given, your template is
going to be downloaded and extracted into './out/mega_aktemplate/'. Don't worry if you 
dont have MEGATools installed, this software is going download and install it

3) Manually set your own template into './out/aktemplate/' folder, that's it.

## '--upload' Flag ##

This flag added to the command 'essentials' (essentials --upload) is going to upload your
recently AnyKernel installer to your MEGA Account, if you don't have MEGA Installed this
software is going to download and install it

## '--all' Flag ##

This flag added to the command 'essentials' (essentials --all) will do everything the above
flags do, in order. Very useful if you want to do automatically all the processes from 
building the kernel to uploading it ready to install.

*NOTE* that all the above flags except '--all' can be combined, no matter in which order,
all the functions are going to be done in order to prevent an error (For example: 
'essentials --anykernel --kernel' will build the kernel and then build the installer)

--------------------------------------------------------------------------------

# Command: 'auto (device)' #

This command allows you to make pre-configured files for a specified device, it requires that you have executed the program core.sh for the first time because it stores some config in your
~/.bashrc file, then, you can turn on or restart your machine and this command will still be 
available for it's use

When you run 'auto' and next to it you specify the device (for example: auto oneplus), if the 
device (oneplus) doesn't exist in the device database (./resources/devices/) then, it'll 
promt to you all the data required for kernel, dtb (if applies), anykernel and upload process

Once you have configured your device it'll be stored and when you run again the command 'auto'
followed by the device name you configured before, (for example: auto oneplus) it'll load that device config file and build everything automatically (Kernel, dtb if applies, anykernel and upload if its enabled)

You can also, edit a device file with 'auto (device) --edit' or remove it with '--remove'. As I 
said before, this command always works and can be executed anywhere.

--------------------------------------------------------------------------------

# Other program commands (Functions) #

You can manually execute the functions of this program, there's a lot of them used by this
software and I'll explain here some of them:

- checkfolders
- checkenvironment
- megacheck
- buildkernel
- buildkernel_debug
- build_dtb
- make_anykernel
- megaupload
- kbeclear

I'll explain each one:

## checkfolders ##

This command will check in there's all folders needed to start working in your
environment, to be more specific, it creates an "out" folder and inside it other
sub-folders that I'll explain:

- out: Main output folder
- out/zImagesNew: Recently built zImages
- out/zImages: Last Built zImages
- out/newzips: New Zips built output folder
- out/aktemplate: Base Zips for new kernel installer builds (AnyKernel)
- out/mega_aktemplate: Base Zips for new kernel installer builds from MEGA (AnyKernel)
- out/dt: New Device Tree Images for each variants (dtb)

## checkenvironment ##

This command will check for the path of your crosscompiler,  Also, it'll check 
the DTB tool that you shouldn't worry about because it's included in ./resources/dtb/dtbToolLineage, it'll check also check for the Zip Tool to re-pack
your new AnyKernel installer and some android Development tools needed in your Linux installation.

Note that, if this program doesn't detect the crosscompiler path, kernel
building process will be cancelled (In which case it would be extremely rare because
this software auto-downloads the correspondent crosscompiler).

## megacheck ##

This command will check if MEGA is installed, if it is, it's going the check for
the ~/.megarc configuration file for automatic login and uploads (This file is
used only by megatools program, there's nothing else in the whole code of this 
software that makes use of it).

You can also run this program with --reconfigure flag (megacheck --reconfigure)
to re-configure megarc file, I mean, to change the email, password or both in
case of an error or you just want to use another account

## buildkernel ##

This is the command to initialize Kernel Building, if your crosscompiler path is
set correctly, this will build the kernel on the source that you previously
selected after running the main script of this program (./core.sh). If there was
an compilation error it'll prompt to you to open the buildkernel_log.txt file
where you can see what went wrong in the process. After a successful build, the
old kernel built (it theres one) will be moved to "./out/zImages" and new Kernel
will be copied to "./out/zImagesNew".

## buildkernel_debug ##

This is the same script as above with two differences:

1) This will show all the compilation process in the screen

2) buildkernel_log.txt isn't gonna be used here because you'll see all the
process

## build_dtb ##

This command will generate the dt.img (Device Tree Image) using the
dtbToolLineage inside './resources/dtb/', the file will be renamed to the variant
name specified for your phone and moved to './out/dtb'.

## make_anykernel ##

This command will work depending on which option you selected during the
configuration phase of this software, if you selected to use the local template
or manually set the template this command will simply take the lastest kernel
and dtb for the specified variant and make a new installer with it made into 
'./out/aktemplate/' and moved to './out/newzips/'.

If you selected to download and extract the template from MEGA, then this 
command will do the same but using the './out/mega_aktemplate' folder instead 
to make a new installer.

## megaupload ##

No, I'm not talking about old megaupload.com, this command will upload your 
new kernel installer into the root of your MEGA Account, that's all :)

## kbeclear ##

This command will make a full cleaning of your KB-E folder, if you break 
something or this software isn't working as expected you can always try to
make a full cleaning of this program using that command. This will not delete
your source folder.

---

## IMPORTANT ##

Don't use these commands when you're building anything for multi-variants, 
rather use the essentials command, this will only work the first variant

--------------------------------------------------------------------------------

# Variables #

This program uses a lot of variables, but, some of them can be changed during 
a session, it could be very useful if you want to quickly change a config
some variables that you might need to know are these: 

- KERNELNAME - This variable contains the kernel name
- TARGETANDROID - Contains the target android OS
- VERSION - Contains the version of your kernel
- KDEBUG - If this variable contains the 'y' value then you'll see all the 
  kernel compilation process
- MAKEDTB - If this variable contains the value '1' it'll enable the device tree
  image generation for the current kernel build
- P - Path to the kernel source that will be used during the session of this software
- CLR - If this variable contains the value 'y' it'll enable the kernel source 
  cleaning on each kernel build

--------------------------------------------------------------------------------

# That's all #

This program, can run on every Linux machine and it's fully portable, you can
extract it anywhere you want but you must cd (enter this directory), to run
core.sh, once its done, you can use the commands wherever you are.

That's all, thanks for reading and happy building! If you need any support or
help send me a email to "jesusgabriel.91@gmail.com" or PM (private message) me
on Telegram @ArtxDev ! :)
