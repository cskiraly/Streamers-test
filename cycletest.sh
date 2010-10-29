#!/bin/bash

# Copyright (c) 2010 Luca Abeni
# Copyright (c) 2010 Csaba Kiraly
# This is free software; see gpl-3.0.txt

usage()
{
  echo "Usage: $0 <configfile>"
}

[ -e "$1" ] || { usage; exit 1; }
. $1

limitupdown_init()
{
  ${tc} qdisc del dev $IFDEV root 2>/dev/null
  ${tc} qdisc add dev $IFDEV root handle 1: htb default 1
  ${tc} class add dev $IFDEV parent 1: classid 1:1 htb rate 100mbit burst 15k
}

limitupdown()
{
  PORT=$1
  DOWN_SPEED=$2 #mbit/s
  DOWN_LOSS=$3 #%
  DOWN_DELAY=$4 #msec
  UP_SPEED=$5 #mbit/s
  UP_LOSS=$6 #%
  UP_DELAY=$7 #msec

   # limit downlink
  HANDLE=$PORT
  ${tc} class add dev $IFDEV parent 1:1 classid 1:$HANDLE htb rate ${DOWN_SPEED}mbit burst 15k || exit
  ${tc} qdisc add dev $IFDEV parent 1:$HANDLE handle $HANDLE: netem loss ${DOWN_LOSS}% delay ${DOWN_DELAY}msec || exit
  ${tc} filter add dev $IFDEV protocol ip parent 1:0 prio 1 u32 \
    match ip protocol $PROTOCOL 0xff \
    match ip dport $PORT 0xffff \
    flowid 1:$HANDLE || exit

   # limit uplink
  HANDLE=$(($PORT + 2000))
  ${tc} class add dev $IFDEV parent 1:1 classid 1:$HANDLE htb rate ${UP_SPEED}mbit burst 15k || exit
  ${tc} qdisc add dev $IFDEV parent 1:$HANDLE handle $HANDLE: netem loss ${UP_LOSS}% delay ${UP_DELAY}msec || exit
  ${tc} filter add dev $IFDEV protocol ip parent 1:0 prio 1 u32 \
    match ip protocol $PROTOCOL 0xff \
    match ip sport $PORT 0xffff \
    flowid 1:$HANDLE || exit
}

# Kill everything we've started on exit (with trap).
bashkilltrap()
{
  # ok that's the end
  # you can add here all possible postprocessing,
#  sudo tc qdisc del dev lo root 2>/dev/null

  ps -o pid= --ppid $$ | xargs kill 2>/dev/null
}
trap bashkilltrap 0


rm -f stderr.[0-9]*

for CYCLE in `eval echo $CYCLEs`; do
for CHBUF in `eval echo $CHBUFs`; do
for REORDBUF in `eval echo $REORDBUFs`; do
for PEERNUM  in `eval echo $PEERNUMs` ; do
for PEERNUM1 in `eval echo $PEERNUM1s`; do
for PEERNUM2 in `eval echo $PEERNUM2s`; do
for NEIGH in `eval echo $NEIGHs`; do
for UPRATE  in `eval echo $UPRATEs` ; do
for UPRATEPART1  in `eval echo $UPRATEPART1s` ; do
for UPRATE1 in `eval echo $UPRATE1s`; do
for UPRATE2 in `eval echo $UPRATE2s`; do
for DOWNRATE in `eval echo $DOWNRATEs`; do
for DELAY in `eval echo $DELAYs`; do
for CPS in `eval echo $CPSs`; do
for BIN in `eval echo $BINs`; do

  SCENARIO_HDR="protocol,peers,uprateavg,upratepart1"\
",peers1,neighsize1,downrate1,downdelay1,downloss1,uprate1,updelay1,uploss1"\
",peers2,neighsize2,downrate2,downdelay2,downloss2,uprate2,updelay2,uploss2"\
",offerthreads,chbuf,reordbuf,cycle"
  export SCENARIO="$BIN,$PEERNUM,$UPRATE,$UPRATEPART1"\
",$PEERNUM1,$NEIGH,$DOWNRATE,$DELAY,0,$UPRATE1,$DELAY,0"\
",$PEERNUM2,$NEIGH,$DOWNRATE,$DELAY,0,$UPRATE2,$DELAY,0"\
",$CPS,$CHBUF,$REORDBUF,$CYCLE"
  CSV=published.${SCENARIO/,/_}.csv

  echo "running $SCENARIO"

  if [ ! -e $CSV ] ; then

  limitupdown_init

  for PORT in `seq 6667 $((6667+$PEERNUM1-1))`; do
    limitupdown $PORT $DOWNRATE 0 $DELAY $UPRATE1 0 $DELAY
  done;
  $TESTSH -v $VIDEO -I lo -f abouttopub -p "--measure_start $MEASURE_START --measure_every $MEASURE_EVERY -c $CPS -b $CHBUF -o $REORDBUF -M $NEIGH -n stun_server=0" -s "-M 0 -n stun_server=0" -X 0 -e ${BINPREFIX}${BIN}${BINPOSTFIX} -N $PEERNUM1 >a &
  PIDS+=" $!"

  for PORT in `seq $((6667+$PEERNUM1)) $((6667+$PEERNUM1+$PEERNUM2-1))`; do
    limitupdown $PORT $DOWNRATE 0 $DELAY $UPRATE2 0 $DELAY
  done;
  $TESTSH -I lo -f abouttopub -p "--measure_start $MEASURE_START --measure_every $MEASURE_EVERY -c $CPS -b $CHBUF -o $REORDBUF -M $NEIGH -n stun_server=0" -s "-M 0 -n stun_server=0" -X 0 -e ${BINPREFIX}${BIN}${BINPOSTFIX} -N $PEERNUM2 -P $((6667+$PEERNUM1)) -Z >a &
  PIDS+=" $!"

  sleep $DURATION
  kill $PIDS
  sudo tc qdisc del dev lo root
  sleep 30

  echo -e "#dummy,src,from,to,measure,value,stringval,channel,time,peergrp,$SCENARIO_HDR\n" >$CSV
  for PORT in `seq 6667 $((6667+$PEERNUM1-1))`; do
    awk '/aboutto/ { print $0",1,"ENVIRON["SCENARIO"] }' stderr.$PORT >>$CSV
  done;
  for PORT in `seq $((6667+$PEERNUM1)) $((6667+$PEERNUM1+$PEERNUM2-1))`; do
    awk '/aboutto/ { print $0",2,"ENVIRON["SCENARIO"] }' stderr.$PORT >>$CSV
  done;

  rm -f stderr.[0-9]*

  fi

done
done
done
done
done
done
done
done
done
done
done
done
done
done
done
