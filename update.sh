#!/bin/bash

# Copyright (c) 2010 Luca Abeni
# Copyright (c) 2010 Csaba Kiraly
# This is free software; see gpl-3.0.txt

MAKE="make -j 4"

if [ ! -f experimental ]; then
  UP="svn up"
else
  UP="git pull"
fi

cd GRAPES
$UP
make || make -C som || exit
cd ..

cd NAPA
$UP
make -C ml 
make -C common
make -C dclog
make -C rep
make -C monl
cd ..

cd OfferStreamer
$UP
$MAKE clean
LIBEVENT=`pwd`/../Event ML=1  $MAKE || exit
LIBEVENT=`pwd`/../Event ML=1 STATIC=1 $MAKE || exit
$MAKE clean
LIBEVENT=`pwd`/../Event ML=1 MONL=1 $MAKE || exit
LIBEVENT=`pwd`/../Event ML=1 MONL=1 STATIC=1 $MAKE || exit
cd ..
