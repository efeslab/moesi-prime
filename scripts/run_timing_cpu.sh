#!/bin/bash

protocol=$1
label=$2
size=$3
bench=$4
nnodes=$5
wb_dc=$6
mode=-1

if [[ "$protocol" == "moesi-prime" ]];
then
    mode=0
elif [[ "$protocol" == "moesi" ]];
then
    mode=1
elif [[ "$protocol" == "mesi" ]];
then
	mode=2
else
	echo "Invalid protocol: ${protocol}, exiting"
	exit 1
fi

if [[ ${nnodes} != 2 && ${nnodes} != 4 && ${nnodes} != 8 ]];
then
	echo "Invalid nnodes: ${nnodes}, exiting"
	exit 1
fi

if [[ "$size" != "simsmall" && "$size" != "simmedium" && "$size" != "simlarge" ]];
then
	echo "Invalid input size: ${size}, exiting"
	exit 1
fi

if [[ ${wb_dc} != 0 && ${wb_dc} != 1 ]];
then
	echo "Invalid wb_dc: ${wb_dc}, exiting"
	exit 1
fi

l2size=$(( 19456/${nnodes} ))
# always have 2048 sets, adjust ways a la slice mapping func
l2assoc=$(( 32 ))

dcsize=$(( 16 * 1024 * 8/${nnodes} ))
dcassoc=$(( 32 ))

GEM5_DIR=/path/to/gem5
mkdir -p ${GEM5_DIR}/results/${label}/${protocol}-${nnodes}node-${size}-wb${wb_dc}/
${GEM5_DIR}/build/X86_MOESI-prime/gem5.fast \
    --outdir=${GEM5_DIR}/results/${label}/${protocol}-${nnodes}node-${size}-wb${wb_dc}/${bench}/ \
    ${GEM5_DIR}/configs/example/moesi-prime_fs.py \
	--checkpoint-dir=/path/to/checkpoint \
	-r 1 \
	-n 8 \
	--cpu-clock=2.6GHz \
	--ruby \
	--wb-dc=${wb_dc} \
	--page-policy=close_adaptive \
	--addr-mapping=RoCoRaBaCh \
	--mode=${mode} \
	--dir-cache-size=${dcsize} \
	--dir-cache-assoc=${dcassoc} \
	--num-dirs=${nnodes} \
	--l1i_size 32kB \
	--l1i_assoc 8 \
	--l1d_size 32kB \
	--l1d_assoc 8 \
	--l2_size ${l2size}kB \
	--l2_assoc ${l2assoc} \
	--num-l2caches=${nnodes} \
	--cpu-type=TimingSimpleCPU \
	--kernel=/path/to/kernel \
	--disk-image=/path/to/image \
	--mem-type=DDR4_2400_16x4_${nnodes}node_16 \
	--mem-size=16GB