MAKE="make -j 4"

cd OfferStreamer
cd NAPA
svn up
make -C common
make -C dclog
make -C rep
make -C monl
make -C ml 
cd ..

svn up
$MAKE clean
LIBEVENT=`pwd`/../Event ML=1  $MAKE || exit
LIBEVENT=`pwd`/../Event ML=1 STATIC=1 $MAKE || exit
$MAKE clean
LIBEVENT=`pwd`/../Event ML=1 MONL=1 $MAKE || exit
LIBEVENT=`pwd`/../Event ML=1 MONL=1 STATIC=1 $MAKE || exit
