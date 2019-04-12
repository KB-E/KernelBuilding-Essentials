#!/bin/bash
# Save Last User "core.sh" config

writecoredevice () {
# Write settings to kernel config file
echo "# Config File for '$KERNELNAME'" > $DFILE
echo "export KERNELNAME=$KERNELNAME" >> $DFILE
echo "export TARGETANDROID=$TARGETANDROID" >> $DFILE
echo "export VERSION=$VERSION" >> $DFILE
if [ "$ARMT" = "1" ]; then
  echo "export ARCH=arm" >> $DFILE
  echo "export CROSSCOMPILE=$CDF/resources/crosscompiler/arm/bin/arm-eabi-" >> $DFILE
elif [ "$ARMT" = "2" ]; then
  echo "export ARCH=arm64" >> $DFILE
  echo "export CROSSCOMPILE=$CDF/resources/crosscompiler/arm64/bin/aarch64-linux-android-" >> $DFILE
fi
echo "export P=$P" >> $DFILE
if [ $KDEBUG = 1 ]; then
  echo "export KDEBUG=1" >> $DFILE
fi
echo "export VARIANT1=$VARIANT1" >> $DFILE
echo "export DEFCONFIG1=$DEFCONFIG1" >> $DFILE
if [ "$MKDTB" = "y" ] || [ "$MKDTB" = "Y" ]; then
  echo "export MAKEDTB=1" >> $DFILE
fi
if [ "$CLRS" = "y" ] || [ "$CLRS" = "Y" ]; then
  echo "export CLR=1" >> $DFILE
fi
}


