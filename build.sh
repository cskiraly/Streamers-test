cd libevent-2.0.3-alpha
./configure --prefix `pwd`/../Streamers/Event
#./configure --prefix `pwd`/../Streamers/Event --disable-shared
make; make install
cd ..

cd Streamers
cd NAPA
mkdir -p m4 config
autoreconf --force -I config -I m4 --install
./configure --with-libevent2=`pwd`/../Event
make
cd ..
make -C GRAPES
make -C ffmpeg
LIBEVENT=`pwd`/Event ML=1 MONL=1 make

