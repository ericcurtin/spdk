#!/bin/bash

set -e
trap 'ec=$?; if [ $ec -ne 0 ]; then echo "exit $? due to '\$previous_command'"; fi; sudo pkill -f nvmf_tgt' SIGINT SIGTERM EXIT
trap 'previous_command=$this_command; this_command=$BASH_COMMAND' DEBUG

./target.sh &

while ! pgrep -f nvmf_tgt > /dev/null 2>&1; do
  sleep 1
done

sleep 2

./host.sh


sudo pkill -f nvmf_tgt

