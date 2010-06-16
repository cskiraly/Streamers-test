git clone http://www.disi.unitn.it/~kiraly/SharedGits/Streamers.git
git clone http://www.disi.unitn.it/~kiraly/PublicGits/GRAPES.git

# get libevent 2.0.3 (warning: newer version were not tested)
wget http://www.monkey.org/~provos/libevent-2.0.3-alpha.tar.gz
tar xvzf libevent-2.0.3-alpha.tar.gz

#get libconfuse 2.7 (warning: newer version were not tested)
#wget http://savannah.nongnu.org/download/confuse/confuse-2.7.tar.gz
#tar xvzf confuse-2.7.tar.gz
git clone git://git.sv.gnu.org/confuse.git
cd confuse; git checkout V2_7; cd ..

cd Streamers
git checkout -b for-demo origin/for-demo
cp -r ../GRAPES NAPA
cd NAPA; git checkout -b for-demo-NAPA origin/for-demo-NAPA; cd ..
mv ../GRAPES .
cd GRAPES; git checkout -b for-demo-GRAPES origin/for-demo-GRAPES; cd ..
make ffmpeg
