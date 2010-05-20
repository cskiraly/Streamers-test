echo "Dependencies, among others: autoconf, flex, libtool, autopoint"
which flex || { echo "please install flex!"; exit 1; }
which libtoolize || { echo "please install libtool!"; exit 1; }
which autoconf || { echo "please install autoconf!"; exit 1; }
which autopoint || { echo "please install gettext (or autopoint) !"; exit 1; }

MAKE="make -j 4"

cd libevent-2.0.3-alpha
./configure --prefix `pwd`/../Streamers/Event
#./configure --prefix `pwd`/../Streamers/Event --disable-shared
$MAKE; $MAKE install
cd ..

cd confuse
./autogen.sh --prefix=`pwd`/../Streamers/Conf
$MAKE; $MAKE install
cd ..

cd Streamers
cd NAPA
mkdir -p m4 config
autoreconf --force -I config -I m4 --install
./configure --with-libevent2=`pwd`/../Event  --with-libconfuse=`pwd`/../Conf
echo "//blah" > common/chunk.c
$MAKE -C common
$MAKE -C dclog
$MAKE -C rep
$MAKE -C monl
$MAKE -C ml 
cd ..
$MAKE -C GRAPES/som
$MAKE -C ffmpeg
$MAKE clean
LIBEVENT=`pwd`/Event ML=1  $MAKE
LIBEVENT=`pwd`/Event ML=1 STATIC=1 $MAKE
$MAKE clean
LIBEVENT=`pwd`/Event ML=1 MONL=1 $MAKE
LIBEVENT=`pwd`/Event ML=1 MONL=1 STATIC=1 $MAKE
