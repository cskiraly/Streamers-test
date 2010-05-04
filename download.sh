git clone http://www.disi.unitn.it/~kiraly/SharedGits/Streamers.git
git clone http://www.disi.unitn.it/~kiraly/PublicGits/GRAPES.git
wget http://www.monkey.org/~provos/libevent-2.0.3-alpha.tar.gz
tar xvzf libevent-2.0.3-alpha.tar.gz
wget http://savannah.nongnu.org/download/confuse/confuse-2.7.tar.gz
tar xvzf confuse-2.7.tar.gz

cd Streamers
git checkout -b for-demo origin/for-demo
cp -r ../GRAPES NAPA
cd NAPA; git checkout -b for-demo-NAPA origin/for-demo-NAPA; cd ..
cp -r ../GRAPES .
cd GRAPES; git checkout -b for-demo-GRAPES origin/for-demo-GRAPES; cd ..
make ffmpeg
