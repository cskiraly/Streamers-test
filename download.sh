svn co https://repository.napa-wine.eu/svn/napawine-software/trunk/Applications/OfferStreamer
svn co https://repository.napa-wine.eu/svn/napawine-software/trunk/GRAPES

# get libevent 2.0.3 (warning: newer version were not tested)
wget http://www.monkey.org/~provos/libevent-2.0.3-alpha.tar.gz
tar xvzf libevent-2.0.3-alpha.tar.gz

#get libconfuse 2.7 (warning: newer version were not tested)
wget http://savannah.nongnu.org/download/confuse/confuse-2.7.tar.gz
tar xvzf confuse-2.7.tar.gz
#git clone git://git.sv.gnu.org/confuse.git
#cd confuse; git checkout V2_7; cd ..

cd OfferStreamer
mv ../GRAPES NAPA
ln -s NAPA/som GRAPES
make ffmpeg
