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

    DEBUG OPTIONS
    V:	# number of peers running valgrind. Current: $NUM_PEERS_V
    g:	# gperf: seconds to wait before killing peers and generating gperf data. Streamer must be compiled with -pg! Current: $GPERF_WAIT

    t:	# churn: minimum lifetime in seconds of peers (only for N type). Current: $CHURN_MIN
    T:	# churn: maximum lifetime in seconds of peers (only for N type). Current: $CHURN_MAX
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
PEER_PORT_BASE=5555
NUM_PEERS=1
FILTER=""
SOURCE_FILTER=""
STREAMER=offerstreamer-ml-monl
VIDEO=foreman_cif.mpg
OUTPUT="fifo | ffplay -"
CHURN_MIN=100000000
CHURN_WAIT=10

#process options
while getopts "s:S:p:P:N:f:F:e:v:V:X:i:I:o:O:Zt:T:w:g:" opt; do
  case $opt in
    I)	# the interface to use for all peers and the source, e.g. -I eth1
      IFACE=$OPTARG
      ;;
    s)	# options to pass to the source, .e.g. -s "-m 3"
      SOURCE_OPTIONS=$OPTARG
      ;;
    i)	# IP address of the source. Might be needed if -I!=lo
      SOURCE_IP=$OPTARG
      ;;
    S)	# the udp port used by the source
      SOURCE_PORT=$OPTARG
      ;;
    p)	# extra options passed to each peer, e.g. -p "-c 50 -b 100"
      PEER_OPTIONS=$OPTARG
      ;;
    P)	# peers use ports starting from this one
      PEER_PORT_BASE=$OPTARG
      ;;
    N)	# number of peers running in background (only stderr is logged). Use -N 0 to disable.
      NUM_PEERS=$OPTARG
      ;;
    f)	# filter output of X peers grepping for the argument, e.g. -f "chbuf"
      FILTER=$OPTARG
      ;;
    F)	# filter output of source grepping for the argument e.g. -F "sending\|received"
      SOURCE_FILTER=$OPTARG
      ;;
    e) # overrride streamer executable, e.g. -e ./offerstreamer-ml-monl
      STREAMER=$OPTARG
      ;;
    v) # override video file, e.g. -v ~/video/big_buck_bunny_480p_600k.mpg
      VIDEO=$OPTARG
      ;;
    V)	# number of peers running valgrind
      NUM_PEERS_V=$OPTARG
      ;;
    O)	# number of peers showing their ouput (on stdout)
      NUM_PEERS_O=$OPTARG
      ;;
    o)	# override output program, e.g. -o "fifo | vlc /dev/stdin"
      OUTPUT=$OPTARG
      ;;
    X)	# number of peers showing stderr in an xterm. If -f is specified, it is applied.
      NUM_PEERS_X=$OPTARG
      ;;
    Z)	# don't start the source. Use this mode to attach these peers to an exisiting source
      NO_SOURCE=1
      ;;
    t)	# churn: minimum lifetime in seconds of peers (only for N type)
      CHURN_MIN=$OPTARG
      ;;
    T)	# churn: maximum lifetime in seconds of peers (only for N type)
      CHURN_MAX=$OPTARG
      ;;
    w)	# churn: seconds to wait before restarting peer
      CHURN_WAIT=$OPTARG
      ;;
    g)	# gperf: seconds to wait before killing peers and generating gperf data. Use only with version compiled with -pg !!!
      GPERF_WAIT=$OPTARG
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
    $STREAMER $PEER_OPTIONS -I $IFACE -P $PORT -i $SOURCE_IP -p $SOURCE_PORT 2>stderr.$PORT >/dev/null &
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
    FIFO=fifo.$PORT
    rm -f $FIFO
    mkfifo $FIFO
    xterm -e "LD_LIBRARY_PATH=$LD_LIBRARY_PATH $STREAMER $PEER_OPTIONS -I $IFACE -P $PORT -i $SOURCE_IP -p $SOURCE_PORT 2>$FIFO >/dev/null | grep '$FILTER' $FIFO" &
done

((PEER_PORT_BASE = PEER_PORT_MAX + 1))
((PEER_PORT_MAX=PEER_PORT_BASE + NUM_PEERS_V - 1))
for PORT in `seq $PEER_PORT_BASE 1 $PEER_PORT_MAX`; do
    valgrind --track-origins=yes  --leak-check=full \
    $STREAMER $PEER_OPTIONS -I $IFACE -P $PORT -i $SOURCE_IP -p $SOURCE_PORT 2>stderr.$PORT >/dev/null &
done

((PEER_PORT_BASE = PEER_PORT_MAX + 1))
((PEER_PORT_MAX=PEER_PORT_BASE + NUM_PEERS - 1))
for PORT in `seq $PEER_PORT_BASE 1 $PEER_PORT_MAX`; do
    churn $CHURN_MIN $CHURN_MAX $CHURN_WAIT &
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
