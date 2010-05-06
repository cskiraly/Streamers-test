cd Streamers
cd NAPA
git fetch
git reset --hard origin/for-demo-NAPA
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

cd GRAPES
git fetch
git reset --hard origin/for-demo-GRAPES
make -C som clean
make -C som
cd ..

git fetch
git reset --hard origin/for-demo
ML=1 make clean
ML=1 STATIC=1 make clean
LIBEVENT=`pwd`/Event ML=1 make
LIBEVENT=`pwd`/Event ML=1 STATIC=1 make
ML=1 MONL=1 make clean
ML=1 MONL=1 STATIC=1 make clean
LIBEVENT=`pwd`/Event ML=1 MONL=1 make
LIBEVENT=`pwd`/Event ML=1 MONL=1 STATIC=1 make
