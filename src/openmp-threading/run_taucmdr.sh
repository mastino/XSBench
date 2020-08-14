#!/bin/bash
#
#SBATCH --job-name=xsbench_tau
#SBATCH --output=test_tau.txt
#
#SBATCH --ntasks=40
#SBATCH --time=8:00:00

source /projects/artab/soft/taucmdr-arm.env
module load openmpi/3.1.3-gcc_8.2.0
module load cmake

# parameters for TAU
#EXP=history_unroll_8p56t  # experiment name - must be created before running this script
#EXP=history_overview_8p56t
EXP=event_k1_overview_8p56t
tau experiment select $EXP # switch tau to this experiment

export OMPI_MCA_pml=ob1
export OMPI_MCA_btl=^openlib

export OMP_PLACES=sockets
export OMP_PROC_BIND=close

# command to execute the mkFit program
#    note the '\' before each space
#    also this must be redefined inside the loop to overwrite the variable as they vary
CMD="mpirun -n 4 ./XSBench -m event -t 56"
#CMD="mpirun -n 4 ./XSBench -t 56"

# measurement list; these are tau commander measurements that must be created first
measure_list=(spec_ins fp_ins simd_ins tot_cyc tot_ins ld_ins sr_ins br_ins dcm1 dca1 tcm2 tca2 mem_rd mem_wr stl_front stl_back)
#measure_list=(dca1 tcm2 tca2 mem_rd mem_wr stl_front stl_back)
function run_trials {

	for i in ${measure_list[@]}; do
		tau experiment edit ${EXP} --measurement $i
		tau trial create ${CMD}
	done
	rm core*
}

# run multiple trials that get averaged
#for n in {0..3}; do
run_trials
#done




