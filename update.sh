MAKE="make -j 4"

if [ ! -f experimental ]; then
  UP="svn up"
else
  UP="git pull"
fi

cd NAPA
$UP
make -C ml 
make -C common
make -C dclog
make -C rep
make -C monl
cd ..

cd OfferStreamer
$UP
$MAKE clean
LIBEVENT=`pwd`/../Event ML=1  $MAKE || exit
LIBEVENT=`pwd`/../Event ML=1 STATIC=1 $MAKE || exit
$MAKE clean
LIBEVENT=`pwd`/../Event ML=1 MONL=1 $MAKE || exit
LIBEVENT=`pwd`/../Event ML=1 MONL=1 STATIC=1 $MAKE || exit
cd ..
