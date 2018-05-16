# Configure Anykernel and Aroma templates script
# By Artx/Stayn <jesusgabriel.91@gmail.com>

# AnyKernel extract
templates_config () {
  echo -e "$GREEN - Setting AnyKernel files into '$FILES2' ..."
  echo " "
  if [ ! -f $FILES2/anykernel.sh ]; then
    cp $AKTF/anykernel.sh $FILES2/
    echo -e "$WHITE   anykernel.h - Done"
  fi
  if [ ! -f $FILES2/update-binary ]; then
    cp $AKTF/META-INF/com/google/android/update-binary $FILES2/
    echo -e "$WHITE   update-binary - Done"
  fi
  if [ ! -f $FILES2/ak2-core.sh ]; then
    cp $AKTF/tools/ak2-core.sh $FILES2/
    echo -e "$WHITE   ak2-core.sh - Done"
  fi
  echo -e " "
  echo -e "$GREEN - AnyKernel Extract Done"
  export AKED=1
}
