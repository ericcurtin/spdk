#!/bin/bash

#set -e
#trap 'ec=$?; if [ $ec -ne 0 ]; then echo "exit $? due to '\$previous_command'"; fi; sudo pkill -f nvmf_tgt' SIGINT SIGTERM EXIT
#trap 'previous_command=$this_command; this_command=$BASH_COMMAND' DEBUG

sudo pkill -f nvmf_tgt
sudo pkill -f perf
sudo pkill -f nvmf_tgt
sudo pkill -f perf

./target.sh "$1" > log.log 2>&1 &

while ! pgrep -f nvmf_tgt > /dev/null 2>&1; do
  sleep 1
done

while ! grep -q "Accel engine initialized" log.log; do
  sleep 1
done

./host.sh >> log.log 2>&1 &

sleep 16

sudo pkill -f nvmf_tgt
sudo pkill -f perf

target_pid="$(grep PID log.log | grep -m1 "Total cores available" | cut -d"[" -f3 | cut -d"]" -f1)"
host_pid="$(grep PID log.log | grep -m1 ":nvme_tcp_ctrlr_construct:" | cut -d"[" -f3 | cut -d"]" -f1)"

sed -i "s/$target_pid/targ/g" log.log
sed -i "s/$host_pid/host/g" log.log

