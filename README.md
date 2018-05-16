 ## Guide for KB-E (Kernel-Building Essentials) ##
  ## By Artx/Stayn <jesusgabriel.91@gmail.com> ##

This Guide is going to tell you all the basics and functionality of this
program made for automatic building of all your Kernel related process as
your please (Only Kernel for now).

Basically, this program can handle the Kernel Building automatically with
predefined by user data, also, you can, Build the Device Tree Image easily,
Build the installers Zips with two options, AnyKernel or AROMA and Upload it
to MEGA (mega.co.nz).

--------------------------------------------------------------------------------

INDEX:

Line 20: Program and Commands explanation
Line 138: How to use this program, tricks and tips

--------------------------------------------------------------------------------

Let's talk about the program and commands:

In order to run this program, you have to run "core.sh", this is the main script
to run it, run ". core.sh" has a command and the program will initialize, after
this, all functions are going to load and if you're running it for the first
time it'll do some checking and echo some really important information.

The Functions are (Commands):

- checkfolders
- checkenvironment
- megacheck
- buildkernel
- buildkernel_debug
- build_dtb
- make_anykernel
- megaupload

I'll explain each one:

## checkfolders ##

This command will check in there's all folders needed to start working in your
environment, to be more specific, it creates an "out" folder and inside it other
sub-folders that I'll explain:

out: Main output folder
out/zImagesNew: Recently built zImages
out/zImages: Last Built zImages
out/temp: Temp folder (Used for unzipping AROMA files)
out/temp2: Temp folder 2 (Used for unzipping AnyKernel and other files)
out/newzips: New Zips built output folder (AROMA/AnyKernel/Others)
out/aroma: Base Zips for new kernel installer builds (AROMA)
out/anykernel: Base Zips for new kernel installer builds (AnyKernel)
out/files: Files to be updated in the new AROMA Installer Build
out/files2: Files to be updated in the new AnyKernel Installer Build
out/dt: New Device Tree Images for each variants (dtb)

## checkenvironment ##

This command will check for the path of your crosscompiler that should be
defined in ./resources/paths.sh in order to build your kernel, this is the only
file that you've to edit of this whole program (excluding ./defaultsettings.sh,
I'll explain it later). Also, it'll check the DTB tool that you shouldn't worry
about because it's included in ./resources/dtb/dtbToolLineage, it'll check also
for the Zip Tool to pack your new AROMA or AnyKernel installers and some android
Development tools needed in your Linux installation.

Note that, if this program doesn't detect the crosscompiler path, kernel
building process will be cancelled.

## megacheck ##

This command will check if MEGA is installed, if it is, it's going the check for
the ~/.megarc configuration file for automatic login and uploads (This file is
used only by megatools program).

You can also run this program with --reconfigure flag (megacheck --reconfigure)
to re-configure megarc file, I mean, to change the email, password or both in
case of an error or you just want to use another account

## buildkernel ##

This is the command to initialize Kernel Building, if your crosscompiler path is
set correctly, this will build the kernel or the source that you previously
selected after running the main script of this program (./core.sh). If there was
an compilation error it'll prompt to you to open the buildkernel_log.txt file
where you can see what went wrong in the process. After a successful build, the
old kernel built (it theres one) will be moved to "./out/zImages" and new Kernel
will be copied to "./out/zImagesNew".

## buildkernel_debug ##

This is the same script as above with two differences:

1- This will show all the compilation process in the screen
2- buildkernel_log.txt isn't gonna be used here because you'll see all the
   process

## build_dtb ##

This command will generate the dt.img (Device Tree Image) using the
dtbToolLineage inside ./resources/dtb, the file will be renamed to "dtb", moved
to "./out/dtb" and packed or updated in the AROMA or AnyKernel Installer. It's
recommended to do this.

## make_anykernel ##

For this command its essential a base Zip in this case for AROMA, you can
download a template of another AROMA zip that you want to modify and move it to
"./out/aroma", the zip that you're using as base for your new installer must be
named equal to the variant that you have defined, for example, if your variant
is "d851" then the base zip must be named "d851.zip". You can also, download the
base zip from MEGA setting a path to automatically download it if it's missing
in ./resources/megaconfig.sh.

If the above requirement is correctly set, then, the program will start
unpacking the AnyKernel contents inside "./out/temp", then, it'll copy these
files:

- update-binary
- anykernel.sh
- ak2-core.sh
- The post boot script name defined in ./scripts/makeanykernel.sh
- zImage (Kernel) from ./out/zImagesNew/
- dtb (dt.img) from ./out/dtb/

From ./out/files (if they exist), update them in "./out/temp/" folder, repack it
again with the name, version, targetandroid, buildtype, etc... that you defined
before and then move it to "./out/newzips/" folder, ready for installation!

## megaupload ##

No, I'm not talking about old megaupload.com, this command will prompt to you
where to upload your last built kernel installer, that's all

--------------------------------------------------------------------------------

Well, we're done here with all the commands explanation, now we can start with,
how to use it, tricks and other tips to make the experience easy and automatic
for you:

Like I said, you've to run core.sh (Main script) with ". core.sh" to load all
the functions and resources, then, you'll be able to do two things:

- Run the commands for the functions that you want to do

- run "essentials" commands with flags. I'll explain this one:

You can run the command "essentials" with flags like:

1) "--kernel"

This flag will tell to the program to build the kernel

2) "--dtb"

This flag will tell to the program to build the dtb (dt.img)

3) "--anykernel"

This flag will tell to the program to build the AnyKernel Installer

4) "--upload"

This flag will tell to the program to upload your last built installer to MEGA

##
Note that you can use various flags when running the "essentials" command, like:
"essentials --anykernel --kernel" (No matter in which order you set the flags,
this program will execute the functions in order, this means that even if the
flag "--anykernel" is set first than "--kernel", the AnyKernel installer will be
built after the Kernel)

5) "--all"

Instead of defining the above flags with the "essentials" command, you can use
this flag to automatically run all the process, this is what I mean in the
introduction with Automatic building of kernel, Installer and uploading process

To be more clear, "essentials --all" will build your kernel, build the dtb,
make your Kernel installer and upload it automatically.

As I said before, this program will prompt to you for data that'll be used
during all the processes, but, here comes the "./defaultsettings.sh".

defaultsettings.sh: This configuration file is designed to have all the data
used during the program execution, all the data that is prompted to the user
can be pre-defined here in this file, you just have to modify his settings and
enable it (There's a variable named "DSENABLED", change the value to 1), and
the program will no longer ask you for necessary data, this will make a more
faster and automatized session of this program.

This program, can run on every Linux machine and it's fully portable, you can
extract it anywhere you want but you must cd (enter this directory), to run
core.sh, once its done, you can use the commands wherever you are.

That's all, thanks for reading and happy building! If you need any support or
help send me a email to "jesusgabriel.91@gmail.com" or PM (private message) me
on Telegram @ArtxDev ! :)
