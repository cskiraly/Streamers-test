#!/bin/bash

# Copyright (c) 2010 Csaba Kiraly
# Copyright (c) 2010 Luca Abeni
# This is free software; see gpl-3.0.txt

#launch it e.g. like this:
#./test.sh -e "offerstreamer-ml" -n 5 -s "-m 1" -p "-b 40 -o 5 -c 25" -f "chbuf"
#./test.sh -e "offerstreamer-ml" -f chbuf

# Kill everything we've started on exit (with trap).
bashkilltrap()
{
  # ok that's the end
  # you can add here all possible postprocessing,

  if [[ $GPERF_WAIT ]]; then
    for i in `ls gmon.out.*`; do gprof $STREAMER $i > gprof.${i#gmon.out.}; done
    gprof $STREAMER gmon.out.* > gprof.all
  fi

  ps -o pid= --ppid $$ | xargs kill 2>/dev/null
}
trap bashkilltrap 0


print_usage()
{
echo "
This is a simple script that start a source and some peers on the local machine

It accept the following options:
    e:  # streamer executable, e.g. -e ./offerstreamer-ml-monl. Current: $STREAMER

    I:	# the interface to use for all peers and the source, e.g. -I eth1. Current: $IFACE

    OPTIONS FOR THE SOURCE PEER
    S:	# the udp port used by the source. Current: $SOURCE_PORT
    v:  # stream video file, e.g. -v ~/video/big_buck_bunny_480p_600k.mpg. Current: $VIDEO
    F:	# filter output of source grepping for the argument e.g. -F \"sending\|received\". Current: $SOURCE_FILTER
    Z:	# don't start the source. Use this mode to attach these peers to an exisiting source. Current: $NO_SOURCE
    s:	# extra options to pass to the source, .e.g. -s \"-m 3\". Current: $SOURCE_OPTIONS

    OPTIONS FOR THE PEERS
    i:	# IP address of the source to connect to. Might be needed if -I!=lo. Current: $SOURCE_IP
    P:	# peers use ports starting from this one. Current: $PEER_PORT_BASE
    p:	# extra options passed to each peer, e.g. -p \"-c 50 -b 100\". Current: $PEER_OPTIONS
    N:	# number of peers running in background (only stderr is logged). Use -N 0 to disable. Current: $NUM_PEERS
    O:	# number of peers showing their ouput (on stdout). Current: $NUM_PEERS_O
    o:	# override output program, e.g. -o \"fifo | vlc /dev/stdin\". Current: $OUTPUT
    f:	# filter output of X peers grepping for the argument, e.g. -f \"chbuf\". Current: $FILTER
    X:	# number of peers showing stderr in an xterm. If -f is specified, filter is applied. Current: $NUM_PEERS_X
    C:	# number of peers runnung in background and churning. Current: $NUM_PEERS_C

    DEBUG OPTIONS
    V:	# number of peers running valgrind. Current: $NUM_PEERS_V
    g:	# gperf: seconds to wait before killing peers and generating gperf data. Streamer must be compiled with -pg! Current: $GPERF_WAIT
    z:	# gzip: compress each log file with gzip on-the-fly

    t:	# churn: minimum lifetime in seconds of peers (only for C type). Current: $CHURN_MIN
    T:	# churn: maximum lifetime in seconds of peers (only for C type). Current: $CHURN_MAX
    w:	# churn: seconds to wait before restarting peer. Current: $CHURN_WAIT
    
Examples:

Start a swarm with all default params, and pring chbuf messages only.
$0 -e \"offerstreamer-ml\" -f chbuf

Starts the source with optional parameter -m 1,  5 peers with param \"-b 40 -o 5 -c 25\" and print only chbuf messages
$0 -e \"../../Applications/OfferStreamer/offerstreamer-ml-monl-static\" -s \"-m 1\" -N 5 -p \"-b 40 -o 5 -c 25\" -f \"chbuf\"
"
}

#defaults
IFACE=lo
SOURCE_PORT=6666
SOURCE_IP=127.0.0.1
PEER_PORT_BASE=6667
NUM_PEERS=1
FILTER=""
SOURCE_FILTER=""
STREAMER=offerstreamer-ml-monl
VIDEO=foreman_cif.mpg
OUTPUT="fifo | ffplay -"
CHURN_MIN=100000000
CHURN_WAIT=10
CAT="cat"
CATEXT=

#process options
while getopts "s:S:p:P:N:f:F:e:v:V:X:i:I:o:O:ZC:t:T:w:g:z" opt; do
  case $opt in
    I)
      IFACE=$OPTARG
      ;;
    s)
      SOURCE_OPTIONS=$OPTARG
      ;;
    i)
      SOURCE_IP=$OPTARG
      ;;
    S)
      SOURCE_PORT=$OPTARG
      ;;
    p)
      PEER_OPTIONS=$OPTARG
      ;;
    P)
      PEER_PORT_BASE=$OPTARG
      ;;
    N)
      NUM_PEERS=$OPTARG
      ;;
    f)
      FILTER=$OPTARG
      ;;
    F)
      SOURCE_FILTER=$OPTARG
      ;;
    e)
      STREAMER=$OPTARG
      ;;
    v)
      VIDEO=$OPTARG
      ;;
    V)
      NUM_PEERS_V=$OPTARG
      ;;
    O)
      NUM_PEERS_O=$OPTARG
      ;;
    o)
      OUTPUT=$OPTARG
      ;;
    X)
      NUM_PEERS_X=$OPTARG
      ;;
    Z)
      NO_SOURCE=1
      ;;
    C)
      NUM_PEERS_C=$OPTARG
      ;;
    t)
      CHURN_MIN=$OPTARG
      ;;
    T)
      CHURN_MAX=$OPTARG
      ;;
    w)
      CHURN_WAIT=$OPTARG
      ;;
    g)
      GPERF_WAIT=$OPTARG
      ;;
    z)
      CAT="gzip"
      CATEXT=".gz"
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      print_usage
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      print_usage
      exit 1
      ;;
  esac
done

[[ $GPERF_WAIT ]] && export GMON_OUT_PREFIX="gmon.out"

[[ $CHURN_MAX ]] || CHURN_MAX=$CHURN_MIN

function churn {
  # Kill everything we've started on exit (with trap).
  trap "ps -o pid= --ppid $BASHPID | xargs kill 2>/dev/null" 0

  MIN=$1
  MAX=$2
  PAUSE=$3

  if [ $MIN -lt $MAX ]; then
    let "RUN=$MIN+($RANDOM%($MAX-$MIN))"
  else
    RUN=$MIN
  fi

  while [ 1 ] ; do
    $STREAMER $PEER_OPTIONS -I $IFACE -P $PORT -i $SOURCE_IP -p $SOURCE_PORT 2> >(grep "$FILTER" | $CAT >stderr.$PORT$CATEXT) >/dev/null &
    PID=$!
    sleep $RUN
    kill $PID
    sleep $PAUSE
  done

}


((PEER_PORT_MAX=PEER_PORT_BASE + NUM_PEERS_O - 1))
for PORT in `seq $PEER_PORT_BASE 1 $PEER_PORT_MAX`; do
    $STREAMER $PEER_OPTIONS -I $IFACE -P $PORT -i $SOURCE_IP -p $SOURCE_PORT 2>stderr.$PORT | `eval "$OUTPUT"` &
done

((PEER_PORT_BASE = PEER_PORT_MAX + 1))
((PEER_PORT_MAX=PEER_PORT_BASE + NUM_PEERS_X - 1))
for PORT in `seq $PEER_PORT_BASE 1 $PEER_PORT_MAX`; do
#  valgrind --track-origins=yes  --leak-check=full \ TODO!!!
    xterm -e "LD_LIBRARY_PATH=$LD_LIBRARY_PATH $STREAMER $PEER_OPTIONS -I $IFACE -P $PORT -i $SOURCE_IP -p $SOURCE_PORT 2> >(grep '$FILTER') >/dev/null" &
done

((PEER_PORT_BASE = PEER_PORT_MAX + 1))
((PEER_PORT_MAX=PEER_PORT_BASE + NUM_PEERS_V - 1))
for PORT in `seq $PEER_PORT_BASE 1 $PEER_PORT_MAX`; do
    valgrind --track-origins=yes  --leak-check=full \
    $STREAMER $PEER_OPTIONS -I $IFACE -P $PORT -i $SOURCE_IP -p $SOURCE_PORT 2> >(grep '$FILTER' | $CAT >stderr.$PORT$CATEXT) >/dev/null &
done

((PEER_PORT_BASE = PEER_PORT_MAX + 1))
((PEER_PORT_MAX=PEER_PORT_BASE + NUM_PEERS_C - 1))
for PORT in `seq $PEER_PORT_BASE 1 $PEER_PORT_MAX`; do
    churn $CHURN_MIN $CHURN_MAX $CHURN_WAIT &
done

((PEER_PORT_BASE = PEER_PORT_MAX + 1))
((PEER_PORT_MAX=PEER_PORT_BASE + NUM_PEERS - 1))
for PORT in `seq $PEER_PORT_BASE 1 $PEER_PORT_MAX`; do
    $STREAMER $PEER_OPTIONS -I $IFACE -P $PORT -i $SOURCE_IP -p $SOURCE_PORT 2> >(grep "$FILTER" | $CAT >stderr.$PORT$CATEXT) >/dev/null &
done

if [[ $GPERF_WAIT ]]; then
   (sleep $GPERF_WAIT; killall $STREAMER) &
fi

FIFO=fifo.$SOURCE_PORT
rm -f $FIFO
mkfifo $FIFO
#valgrind --track-origins=yes  --leak-check=full TODO!
if [[ $NO_SOURCE ]]; then
   sleep 366d
else 
   $STREAMER $SOURCE_OPTIONS -l -f $VIDEO -I $IFACE -P $SOURCE_PORT 2>$FIFO >/dev/null | grep "$SOURCE_FILTER" $FIFO
fi
