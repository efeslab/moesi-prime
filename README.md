# MOESI-prime: Preventing Coherence-Induced Hammering in Commodity Workloads

This is the source code for our ISCA 2022 paper "MOESI-prime: Preventing Coherence-Induced Hammering in Commodity Workloads".
MOESI-prime is implemented in the [gem5 simulator](https://github.com/gem5/gem5) (version 21.1.0.2).
When using code from this repository, please be sure to cite [the paper](https://www.kevinloughlin.org/moesi-prime.pdf).

## Implementation Overview

`git grep -il kevlough` will reveal most/all modified/added files.

Almost all of our additions/changes are in `src/mem/ruby/protocol/`. See file names beginning with
"MOESI-prime" in this directory, compared to their "MOESI_CMP_directory" counterparts from which
we started. We additionally added a few message types in `RubySlicc_MemControl.sm` for stat keeping.

Our full system (FS) config file is based on `configs/example/fs.py` and is located adjacently, named `moesi-prime_fs.py`. This script
uses `configs/ruby/MOESI-prime.py`, which itself uses `configs/common/FSConfig.py` and `configs/ruby/Ruby.py` (modified to support MOESI-prime). The configurarion assumes > 3 GB of memory will be simulated (an assumption that matters for code we modified to avoid an x86 gem5 quirk that otherwise doubles the number of memory controllers).

Note that we additionally changed select simulation parameters to better model the production hardware studied in the paper. 

## Building Gem5

NOTE: see `README` (in contrast to this file) for the original gem5 version.

We recommend compiling and running this code on Ubuntu 20.04 with KVM support, as that's where we've tested our setup. See [this document](https://www.gem5.org/documentation/general_docs/building) for building gem5 on Ubuntu 20.04.

Once dependencies are installed, you can compile MOESI-prime with `scons -j$(nproc) build/X86_MOESI-prime/gem5.fast` from the repo's top level directory. `gem5.opt` and `gem5.debug` can be used in lieu of `gem5.fast` as desired.

## Kernel, Benchmark, and Checkpoint Setup

Because we simulate MOESI-prime in gem5's full system (FS) mode, the simulation requires a kernel and disk image file. The source code for our kernel is available in the `ubuntu-20.04-gem5` submodule (available [here](https://github.com/efeslab/ubuntu-20.04-gem5), using [this build configuration](https://github.com/efeslab/ubuntu-20.04-gem5/blob/main/linux-config-5.4.0-88-generic-gem5)). For the disk image, we recommend using a raw `.img` file with gem5.

We evaluate regions-of-interest in benchmarks by (1) simulating the system at near-native speed until the region's start, using gem5's `X86KvmCPU` (2) checkpointing the simulation at this moment, and (3) resuming the checkpoint in a separate simulation on the `TimingSimpleCPU`. To support checkpointing, we build [m5ops](https://www.gem5.org/documentation/general_docs/m5ops/) and place the generated `m5` binary in `/sbin` on the disk image.

The gem5 webpage on [checkpoints](https://www.gem5.org/documentation/general_docs/checkpoints/) contains more information on instrumenting benchmarks to generate checkpoints at regions-of-interest. More information can also be found [here](https://gem5art.readthedocs.io/en/latest/). At a high level, each benchmark essentially executes special operations that signal the beginning and end of the region of interest to the simulator. From the X86KvmCPU, these operations can be communicated via special memory-mapped addresses per [this email](https://www.mail-archive.com/gem5-users@gem5.org/msg18356.html). From the TimingSimpleCPU, gem5's reserved instructions (e.g., `m5_exit`) should be executed instead.

## Running Simulations

An example script to run the X86KvmCPU (e.g., to generate a checkpoint) is at `scripts/run_kvm_cpu.sh`. You may need to update the kernel command line in the script based on your setup. You can attach to simulation's console with [m5term](https://www.gem5.org/documentation/general_docs/fullsystem/m5term).

An example script to run the TimingSimpleCPU (e.g., to resume from a checkpoint) is at `scripts/run_timing_cpu.sh`. This script demonstrates how to set various key simulation parameters (e.g., selecting among MOESI-prime, MOESI, and MESI protocols).
