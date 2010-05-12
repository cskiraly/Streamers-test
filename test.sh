#!/bin/bash
#launch it e.g. like this:
#./test.sh -e "offerstreamer-ml" -n 5 -s "-m 1" -p "-b 40 -o 5 -c 25" -f "chbuf"
#./test.sh -e "offerstreamer-ml" -f chbuf

# Kill everything we've stared on exit (with trap).
trap "ps -o pid= --ppid $$ | xargs kill -9 2>/dev/null" 0

#defaults
IFACE=lo
SOURCE_PORT=6666
SOURCE_IP=127.0.0.1
PEER_PORT_BASE=5555
NUM_PEERS=1
FILTER=""
STREAMER=offerstreamer-ml-monl
VIDEO=foreman_cif.mpg
OUTPUT="fifo | ffplay -"

#process options
while getopts "s:S:p:P:N:f:F:e:v:V:X:i:I:o:O:Z" opt; do
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
      FILTER=$OPTARG
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
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done


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
    $STREAMER $PEER_OPTIONS -I $IFACE -P $PORT -i $SOURCE_IP -p $SOURCE_PORT 2>stderr.$PORT >/dev/null &
done


FIFO=fifo.$SOURCE_PORT
rm -f $FIFO
mkfifo $FIFO
#valgrind --track-origins=yes  --leak-check=full TODO!
$STREAMER $SOURCE_OPTIONS -l -f $VIDEO -I $IFACE -P $SOURCE_PORT 2>$FIFO >/dev/null | grep "$FILTER" $FIFO
