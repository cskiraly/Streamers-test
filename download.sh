#!/bin/bash

if [[ $1 && $1 == "experimental" ]]; then
  touch experimental
fi

if [ ! -f experimental ]; then
  svn co https://repository.napa-wine.eu/svn/napawine-software/trunk/Applications/OfferStreamer || exit
  svn co https://repository.napa-wine.eu/svn/napawine-software/trunk/GRAPES || exit
else
  git clone http://www.disi.unitn.it/~kiraly/SharedGits/Streamers.git || exit; mv Streamers OfferStreamer || exit
  cd OfferStreamer; git checkout -b experimental origin/experimental || exit; cd ..
  git clone http://www.disi.unitn.it/~kiraly/PublicGits/GRAPES.git || exit
  cd GRAPES; git checkout -b experimental origin/experimental || exit; cd ..
fi

# get libevent 2.0.3 (warning: newer version were not tested)
wget http://www.monkey.org/~provos/libevent-2.0.3-alpha.tar.gz || exit
tar xvzf libevent-2.0.3-alpha.tar.gz || exit

#get libconfuse 2.7 (warning: newer version were not tested)
wget http://savannah.nongnu.org/download/confuse/confuse-2.7.tar.gz || exit
tar xvzf confuse-2.7.tar.gz || exit
#git clone git://git.sv.gnu.org/confuse.git
#cd confuse; git checkout V2_7; cd ..

#get ffmpeg
if [ ! -f experimental ]; then
  svn checkout svn://svn.ffmpeg.org/ffmpeg/trunk -r 23732 ffmpeg
else
  (wget http://ffmpeg.org/releases/ffmpeg-checkout-snapshot.tar.bz2; tar xjf ffmpeg-checkout-snapshot.tar.bz2; mv ffmpeg-checkout-20* ffmpeg) || svn checkout svn://svn.ffmpeg.org/ffmpeg/trunk ffmpeg
fi

#fix names
mv GRAPES NAPA || exit
ln -s NAPA/som GRAPES || exit

#create bindings
ln -s ../NAPA OfferStreamer/NAPA || exit
ln -s ../GRAPES OfferStreamer/GRAPES || exit
ln -s ../ffmpeg OfferStreamer/ffmpeg || exit
