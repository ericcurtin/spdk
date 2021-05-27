#!/bin/bash

set -e
trap 'ec=$?; if [ $ec -ne 0 ]; then echo "exit $ec due to '\$previous_command'"; fi; sudo pkill -f nvmf_tgt' SIGINT SIGTERM EXIT
trap 'previous_command=$this_command; this_command=$BASH_COMMAND' DEBUG

sudo pkill -f nvmf_tgt

if [ -n "$1" ]; then
  sed -i "s/^#define TLS//g" module/sock/posix/posix.c
fi

export CFLAGS="-ggdb -O0 -fsanitize=address"
export LDFLAGS="-rdynamic -fsanitize=address"

if ! [ -e "lib/nvme/nvme.o" ]; then
  git submodule update --init
  ./configure
  make DEBUG=1 V=1 -j$(getconf _NPROCESSORS_ONLN)
else
  make DEBUG=1 V=1 -j$(getconf _NPROCESSORS_ONLN)
fi

mkdir -p /dev/hugepages
mountpoint -q /dev/hugepages || mount -t hugetlbfs nodev /dev/hugepages
sudo /bin/bash -c "echo 1024 > /sys/devices/system/node/node0/hugepages/hugepages-2048kB/nr_hugepages"
#sudo /usr/bin/catchsegv build/bin/nvmf_tgt -m 0xf 2>&1 
sudo build/bin/nvmf_tgt -m 0xf 2>&1 

