cd libevent-2.0.3-alpha
./configure --prefix `pwd`/../Streamers/Event
#./configure --prefix `pwd`/../Streamers/Event --disable-shared
make; make install
cd ..

cd confuse
./autogen.sh --prefix=`pwd`/../Streamers/Conf
make; make install
cd ..

cd Streamers
cd NAPA
mkdir -p m4 config
autoreconf --force -I config -I m4 --install
./configure --with-libevent2=`pwd`/../Event  --with-libconfuse=`pwd`/../Conf
echo "//blah" > common/chunk.c
make -C common
make -C dclog
make -C rep
make -C monl
make -C ml 
cd ..
make -C GRAPES/som
make -C ffmpeg
LIBEVENT=`pwd`/Event ML=1 MONL=1 make
LIBEVENT=`pwd`/Event ML=1 MONL=1 STATIC=1 make
