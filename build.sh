echo "Dependencies, among others: autoconf, flex, libtool, autopoint"
which flex || { echo "please install flex!"; exit 1; }
which libtoolize || { echo "please install libtool!"; exit 1; }
which autoconf || { echo "please install autoconf!"; exit 1; }
which autopoint || { echo "please install gettext (or autopoint) !"; exit 1; }

MAKE="make -j 4"

cd libevent-2.0.3-alpha || exit
./configure --prefix `pwd`/../Event || exit
$MAKE || exit; $MAKE install || exit
cd ..

cd confuse-2.7  || exit
./configure --prefix=`pwd`/../Conf || exit
$MAKE || exit; $MAKE install || exit
cd ..

cd ffmpeg || exit
./configure || exit
$MAKE || exit
cd ..

cd GRAPES || exit
$MAKE || exit
cd ..

cd NAPA || exit
cd ml || exit
./autogen.sh || exit
./configure --with-libevent2=`pwd`/../../Event || exit
$MAKE || exit
cd ..
mkdir -p m4 config || exit
autoreconf --force -I config -I m4 --install || exit
./configure --with-libevent2=`pwd`/../Event  --with-libconfuse=`pwd`/../Conf || exit
$MAKE -C common || exit
$MAKE -C dclog || exit
$MAKE -C rep || exit
$MAKE -C monl || exit
cd ..

cd OfferStreamer || exit
$MAKE clean
LIBEVENT=`pwd`/../Event ML=1  $MAKE || exit
LIBEVENT=`pwd`/../Event ML=1 STATIC=1 $MAKE || exit
$MAKE clean
LIBEVENT=`pwd`/../Event ML=1 MONL=1 $MAKE || exit
LIBEVENT=`pwd`/../Event ML=1 MONL=1 STATIC=1 $MAKE || exit
cd ..
