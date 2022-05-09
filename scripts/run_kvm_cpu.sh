#!/bin/bash
GEM5_DIR=/path/to/gem5
${GEM5_DIR}/build/X86_MOESI-prime/gem5.fast ${GEM5_DIR}/configs/example/moesi-prime_fs.py \
--kernel=/path/to/kernel\
--disk-image=/path/to/image \
--cpu-type=X86KvmCPU \
--cpu-clock=2.6GHz \
-n 8 \
--command-line="earlyprintk=ttyS0 console=ttyS0 lpj=10400000 root=/dev/hda2 numa=fake=2 nr_cpus=8" \
--mem-size=16GB
