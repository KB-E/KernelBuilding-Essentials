#!/bin/bash
# Save Last User "core.sh" config

writecoredevice () {
# Write settings to kernel config file
echo "# Config File for '$KERNELNAME'" > $DFILE
echo "export KERNELNAME=$KERNELNAME" >> $DFILE; log -t "WriteCoreDevice: Exported KERNELNAME=$KERNELNAME" $KBELOG
echo "export TARGETANDROID=$TARGETANDROID" >> $DFILE; log -t "WriteCoreDevice: Exported TARGETANDROID=$TARGETANDROID" $KBELOG
echo "export VERSION=$VERSION" >> $DFILE; log -t "WriteCoreDevice: Exported VERSION=$VERSION" $KBELOG
if [ "$ARMT" = "1" ]; then
  echo "export ARCH=arm" >> $DFILE; log -t "WriteCoreDevice: Exported ARCH=arm" $KBELOG
  echo "export CROSSCOMPILE=$CDF/resources/crosscompiler/arm/bin/arm-eabi-" >> $DFILE; log -t "WriteCoreDevice: Exported CROSSCOMPILE=$CDF/resources/crosscompiler/arm/bin/arm-eabi-" $KBELOG
elif [ "$ARMT" = "2" ]; then
  echo "export ARCH=arm64" >> $DFILE; log -t "WriteCoreDevice: Exported ARCH=arm64" $KBELOG
  echo "export CROSSCOMPILE=$CDF/resources/crosscompiler/arm64/bin/aarch64-linux-android-" >> $DFILE; log -t "WriteCoreDevice: Exported CROSSCOMPILE=$CDF/resources/crosscompiler/arm64/bin/aarch64-linux-android-" $KBELOG
fi
echo "export P=$P" >> $DFILE; log -t "WriteCoreDevice: Exported P=$P" $KBELOG
if [ $KDEBUG = 1 ]; then
  echo "export KDEBUG=1" >> $DFILE; log -t "WriteCoreDevice: Exported KDEBUG=1" $KBELOG
fi
echo "export VARIANT1=$VARIANT1" >> $DFILE; log -t "WriteCoreDevice: Exported VARIANT=$VARIANT1" $KBELOG
echo "export DEFCONFIG1=$DEFCONFIG1" >> $DFILE; log -t "WriteCoreDevice: Exported DEFCONFIG=$DEFCONFIG1" $KBELOG
if [ "$MKDTB" = "y" ] || [ "$MKDTB" = "Y" ]; then
  echo "export MAKEDTB=1" >> $DFILE; log -t "WriteCoreDevice: Exported MAKEDTB=1" $KBELOG
fi
if [ "$CLRS" = "y" ] || [ "$CLRS" = "Y" ]; then
  echo "export CLR=1" >> $DFILE; log -t "WriteCoreDevice: Exported CLR=1" $KBELOG
fi
}
export -f writecoredevice; log -f writecoredevice $KBELOG

