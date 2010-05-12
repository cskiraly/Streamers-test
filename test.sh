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
STREAMER=../Streamers/offerstreamer-ml-monl
VIDEO=~/video/foreman_cif.mp4
OUTPUT="ffplay -"

#process options
while getopts "s:S:p:P:N:f:F:e:v:V:X:i:I:o:O:" opt; do
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
    f)	# filter output of X peers grepping for the argument
      FILTER=$OPTARG
      ;;
    F)	# filter output of source grepping for the argument
      FILTER=$OPTARG
      ;;
    e)
      STREAMER=$OPTARG
      ;;
    v)
      VIDEO=$OPTARG
      ;;
    V)	#valgrind peers
      NUM_PEERS_V=$OPTARG
      ;;
    O)	#output peers
      NUM_PEERS_O=$OPTARG
      ;;
    o)	#output command
      OUTPUT=$OPTARG
      ;;
    X)
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
