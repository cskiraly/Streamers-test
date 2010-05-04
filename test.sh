#!/bin/bash
#launch it e.g. like this:
#./test.sh -e "offerstreamer-ml" -n 5 -s "-m 1" -p "-b 40 -o 5 -c 25" -f "chbuf"
#./test.sh -e "offerstreamer-ml" -f chbuf

# Kill everything we've stared on exit (with trap).
trap "ps -o pid= --ppid $$ | xargs kill -9 2>/dev/null" 0

#defaults
SOURCE_PORT=6666
PEER_PORT_BASE=5555
NUM_PEERS=1
FILTER=""
STREAMER=./offerstreamer-ml
VIDEO=~/video/foreman_cif.mp4

#process options
while getopts "s:S:p:P:n:f:e:v:VX" opt; do
  case $opt in
    s)
      SOURCE_OPTION=$OPTARG
      ;;
    S)
      SOURCE_PORT=$OPTARG
      ;;
    p)
      PEER_OPTION=$OPTARG
      ;;
    P)
      PEER_PORT_BASE=$OPTARG
      ;;
    n)
      NUM_PEERS=$OPTARG
      ;;
    f)	#TODO
      FILTER=$OPTARG
      ;;
    e)
      STREAMER=$OPTARG
      ;;
    v)
      VIDEO=$OPTARG
      ;;
    V)	#TODO
      VALGRIND=1
      ;;
    X)	#TODO
      XTERM=1
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


((PEER_PORT_MAX=PEER_PORT_BASE + NUM_PEERS - 1))
for PORT in `seq $PEER_PORT_BASE 1 $PEER_PORT_MAX`; do
  #FIFO=fifo.$PORT
  #rm $FIFO
  #mkfifo $FIFO
  #xterm -e "$STREAMER $PEER_OPTIONS -I lo -P $PORT -i 127.0.0.1 -p 6666 2>$FIFO >/dev/null | grep $FILTER $FIFO" &
#  valgrind --track-origins=yes  --leak-check=full \ TODO!!!
  $STREAMER $PEER_OPTIONS -I lo -P $PORT -i 127.0.0.1 -p $SOURCE_PORT 2>stderr.$PORT >/dev/null &
done


#valgrind --track-origins=yes  --leak-check=full TODO!
$STREAMER $SOURCE_OPTIONS -l -f $VIDEO -I lo >/dev/null
