#!/bin/bash
#======================================================================================================#
# Title: bash script maker bash script
# Program by: Wiley Barton - 2022.02.07
# Modified for conda/docker pipeline - 2024.02.22
# last update - 2024.10.14
# Modified code sources:
#   
# Notes: generate bash files according to user input for the completion of pipeline
#ToDo:implement getopt
# 'pack' vars can prob be cut entirely
# expects input/out full statements
#======================================================================================================#
# Declare variables
seqc_dir_job=$(pwd)'/scrp_job'
seqc_dir_run=$(pwd)'/scrp_run'
func_help () {
# Help content
    echo "This function was designed to be run without being explicitly called...so..."
    echo "This function uses the following syntax:"
    echo "func_stepgen <dir_in> <dir_out> <mamba_env> <mamba_pack> <mamba_comnd>"
}
func_sys_eval () {
#check params
    echo "one day this might do something"
}
func_var_eval () {
# check input and export variable
# pot. use to change declaration of vars
    v_dir_in="${1}"
    v_dir_out="${2}"
    v_umam_env="${3}"
    v_umam_pac="${4}"
    v_umam_com="${5}"
    v_scrp_job=$seqc_dir_job/'job_'${v_umam_env}'_'${v_umam_pac}'.sh'
    echo $v_scrp_job
}
func_skely () {
# Call variables
#'${1}'=${1},"${1}"=kitty
#v_dir_in=${1}='path/to/dir'
    v_dir_in="${1}"
    v_dir_out="${2}"
    v_umam_env="${3}"
    v_umam_pac="${4}"
    v_umam_com="${5}"
    v_scrp_job=$seqc_dir_job/'job_'${v_umam_env}'_'${v_umam_pac}'.sh'
    v_scrp_run=$seqc_dir_run/'run_'${v_umam_env}'_'${v_umam_pac}'.sh'
# use template to generate initial bash script
    echo '#!/bin/bash
#======================================================================================================#
# Title: Template script for - '${v_umam_env}'_'${v_umam_pac}'
# Generating program by: Wiley Barton - 2022.02.07
# Modified for conda/docker pipeline - 2024.02.22
# last update - 2024.10.14
# Modified code sources:
#   https://sylabs.io/guides/3.5/user-guide/mpi.html
# Notes:
#======================================================================================================#
# modification by '$( whoami )'
#======================================================================================================#
# general syntax:
#  singularity-batch
#   serial:   singularity run <image> <image_arg_1> <image_arg_2> ...
#   parallel: mpiexec.slurm -n <nodes> singularity exec <image> <image_exec>
# docker
#   internal: micromamba activate env_s1 ... exec <param>
#   external: micromamba run -n env_s1 kneaddata --version .. micromamba run -n $ENV <ENV comms>
#variables to be expanded upon envokation of awk prog
#var_com_input='--input1 /home/seqc_user/seqc_project/step0_data_in/v_SAMPLE_UNIQ/_R1.fastq.gz'
#bash /home/seqc_user/seqc_project/scrp_job/job_env_s1_kneaddata_kneaddata.sh './file_in'
#obj_input=files_in
vawk_in=./files_in
vawk_in="${1}"
vawk_run0=$2
# AWK programme - run script
#{ split(vawk2, vawkinput, "va_nID") }                                                                                                  
#{ va_input=vawkinput[1] va_nID vawkinput[2] }
awk '\''BEGIN {FS="\t";OFS=FS} {if(NR >= 0){print $1}}'\'' $vawk_in | awk \
-v vawk0="'$v_umam_env'" \
-v vawk1="'$v_umam_pac'" \
-v vawk2="'${v_dir_in/# /}'" \
-v vawk3="'${v_dir_out/# /}'" \
'\''BEGIN { FS=OFS="\t" }
{ if(NR==1) {va_out=vawk1"/subdir_out"} }
{ va_nID=gensub(/\/.*\//,"","g",$1) }
{ va_input=vawk2 }
{ va_output=vawk3 }
{ gsub(/v_SAMPLE_UNIQ/,va_nID,va_input) }
{ gsub(/v_SAMPLE_UNIQ/,va_nID,va_output) }
{ printf "micromamba run -n %s %s %s %s",vawk0,vawk1,va_input,va_output }
'"$v_umam_com"'
{ printf "\n" }
END { printf "#EoB" }'\''> '$v_scrp_run'
sh '$v_scrp_run'
#EoB
'
#{ printf "vawk_in %s vawk0 %s vawk1 %s va_out %s vawk4_comms %s",$1,vawk0,vawk1,va_out,vawk4 }
}
#options
OPTSTRING=":h"
while getopts ${OPTSTRING} opt; do
  case ${opt} in
    h)
      func_help
      exit 0
      ;;
    esac
done
shift $((OPTIND -1))
#EoF
#func <dir_in> <dir_out> <mam_env> <mam_pack> <"$mam_comnd">
#func_skely /home/test_dir_in /home/test_dir_out env_s1 kneaddata "--version"
# Retrieve name of job file
v_scrp_job=$(func_var_eval "$1" "$2" "$3" "$4" "$5")
echo "job script: "$v_scrp_job
# Push job file for step
func_skely "$1" "$2" "$3" "$4" "$5" > $v_scrp_job
# make executable
chmod +x $v_scrp_job
# run job - currently run from mama
#bash $v_scrp_job
#EoB