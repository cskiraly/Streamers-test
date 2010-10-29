This is Streamers-test, a collection of scripts to download, build and
test streamers.

QUICK HOWTO
-----------

mkdir Streamers-build
cd Streamers-build
../download.sh
../build.sh


FILES
-----

- download.sh [experimental]: download the Streamer and (hopefully) all
required libraries. Use the "experimental" option to download the
experimental version of the streamer. WARNINNG: this version might not
compile/work! Use at your own risk!

- build.sh: build the streamer (normal or experimental, depending on
what had been downloaded)

- update.sh: tries to update the streamer and libraries to the actual
release (or the the most recent   experimental version). WARNING: the
update could fail for too many reasons to deal with. If it fails, create
a new build folder and download again!

- test.sh: test varios aspects of the streamer, running e.g. one source
and several peers. For the actual list of command line options and some
command line examples see documentation inside the script

- cycletest.sh: run a series of tests varying a number of parameters and
measureing their effects on streaming performance and network load
