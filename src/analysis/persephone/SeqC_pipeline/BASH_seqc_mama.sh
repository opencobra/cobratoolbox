#!/bin/bash
#======================================================================================================#
# Title: mama script: take run commands, est db link, run stepgen
# Program by: Wiley Barton - 2022.02.27
# Modified for conda/docker pipeline - 2024.02.22
# Version for: PERSEPHONE
# last update - 2025.06.23
# Modified code sources:
#   https://stackoverflow.com/questions/2043453/executing-multi-line-statements-in-the-one-line-command-line
# Notes: generate bash files according to user input for the completion of pipeline
# Refer to README for setup and use information
# ToDo:ToSTART
#	CRIT: find WTF is causing hang on kraken classify with bad input - currently sidestep with kill of PID
#  Resolve spp id/taxid with APOLLO reconstruction ID for complete DB pulling/report - SUPER COMLICATED!
#  implement cross step paralelisation
#  -d DB dir in main func, use it!
#  auto compile file list from input dir in absence of provided list
# ToDo:ToFINISH:
#	Clean-up of unused data - determine essentials, set option for TIGHT disk usage and trim with each process
#	redirect/suppress mars stand out
#  restructure logging to parsable long format: {ID}/t{VARIABLE}/t{VALUE}
#	LOG_MAMA_DBUG_LN100/tFILE_COUNT/t50
#	LOG_REF/tSeqC/t'the complete reference'
#  devise and implement an estimate of run time based on resources, file size, steps/stage, etc
#  debug opt expansion
#  flesh out func_demo to build complete demo run within /DB/DEPO_demo
#  expand splash to include system params: cpu, mem, du of key directories
# implement pv for progress bar... tar -I pigz -xvf stuff.tar.gz | pv
# Refs
# prodigal:https://bmcbioinformatics.biomedcentral.com/articles/10.1186/1471-2105-11-119#citeas
# https://www.cyberciti.biz/tips/bash-shell-parameter-substitution-2.html
#======================================================================================================#
#----------------------------------------------------------------------------------------
# Variable build
#----------------------------------------------------------------------------------------
var_BLOCK='T'
seqc_dir_init=$(pwd)
seqc_dir_run=${seqc_dir_init}"/scrp_run"
seqc_dir_job=${seqc_dir_init}"/scrp_job"
seqc_dir_proc=${venv_dir_proc}
var_rep_ary[0]=''
var_rep_len=${#var_rep_ary[@]}
# transfer env as temp fix TODO replace v_dir_db with env
v_dir_db=${venv_dir_db}
v_logfile=${venv_log_init}
#size check -db
v_vol_real=$(du -bs $v_dir_db | cut -f1 )
v_vol_none=60000
#system max cpu
v_sys_mem=$(nproc)
v_scrp_check=0
# Step logic gate variables - NOT IN USE
var_log_S0_0=0
var_log_S1_0=0
var_log_S2_0=0
var_log_S2_1=0
var_log_S2_2=0
var_log_S2_3=0
var_log_S3_0=0
var_log_S3_1=0
# Optional flag logic gates
# gate to only run log for valid run flags - Passing valid run flags enables logging AND script progression with vopt_log=1
vopt_log=0
vopt_dbug=0
vopt_status=0
vopt_db_log=0
vopt_pac_log=0
vopt_com_log=0
vopt_head_log=0
vopt_tail_log=0
vopt_check_log=0
vopt_part=0
vopt_keep=0
VLOG_MATLAB_MARS=0
# Version and splash 
v_version='1.0.1'
declare VEN_SPLASH
# user input of script
v_com_log="$@"
#----------------------------------------------------------------------------------------
# Directory check/config - ROUGH
#----------------------------------------------------------------------------------------
mkdir -p /DB/{DEPO_demo,DEPO_proc/{logs,tmp},REPO_host/{btau,hsap,hsap_contam,mmus}/bowtie2,REPO_tool/{checkm2,humann,kraken,mmseqs2,ncbi_NR}}/
#----------------------------------------------------------------------------------------
# Logging check/config
#----------------------------------------------------------------------------------------
# after fresh build: v_logfile="log_"${v_proj}".txt" v_logdir=${v_dir_work}/logs
#	    venv_log_init="log_"${v_proj}".txt" = v_logfile="log_"${v_proj}".txt"
# TODO: improve to adjust .bashrc etc
# Copy initial log to log dir
if [[ ! -f /tmp/${venv_log_init} ]];then 
	printf '%s\nStart of pipeline log -- Docker Initialized@: %s\n%s\n' "${v_logblock0}" "$(date)" "${v_logblock0}" > /tmp/${venv_log_init}
else
	cp /tmp/${venv_log_init} ${venv_dir_log}/${venv_log_init}
fi
# Determine logdir pos
if [[ ${venv_dir_log} = ${v_dir_work}/logs ]];then
	if [[ -d ${venv_dir_log} ]];then
		if [[ -d ${venv_dir_proc}/logs ]];then
		#move files
			mv ${venv_dir_log}/* ${venv_dir_proc}/logs/ 2> /dev/null 
		else
		#move dir
			mv ${venv_dir_log} ${venv_dir_proc} 2> /dev/null 
		fi
	#else
	#no default dir, check proc
	fi
	# remove if empty default
	if [[ ! -f ${venv_dir_log}/${v_logfile} ]];then 
		rm -rf ${venv_dir_log}
	fi
	#set to proc
	venv_dir_log=${venv_dir_proc}/logs
fi
# Merge vars - needs checks
v_logfile=${venv_dir_log}/${v_logfile}
#----------------------------------------------------------------------------------------
# Core programme
#----------------------------------------------------------------------------------------
while [[ ${v_scrp_check} -lt 2 ]];do
# v_scrp_check @0: functions and splash, @1: parse flags and attempt run 
if [[ ${v_scrp_check} -eq 0 ]];then
# Functions
func_help () {
# Display usage/help content
	printf " Usage (CLI): $0 [-h] [-i </input/dir>] [-b] [-o </output/dir>] [-s <array>]\n\t[-e <regex>] [-t <regrex>] [-n <string>] [-k] [-r <string>]\n"
	printf " Usage (Internal): $0 [-h] [-v] [-i </input/dir>] [-b] [-o </output/dir>] [-c <step commands>]\n\t[-s <array>] [-e <regex>] [-t <regrex>] [-n <string>] [-u <string>] [-p <string>] [-r <string>]\n"
	printf " -h       : Show this help message\n"
	printf " -v       : Display software version\n"
	printf " -i INPUT : Directory containing input (/path/to/input)\n"
	printf " -b DEBUG : Enable debug output\n"
	printf " -a ALL   : Confirm with Y to install all databases to -d\n"
	printf " -d DB dir: Databases for step, set according to following options\n"
	printf "\t Host decontam: 'host_kd_hsapcontam' (DEFAULT) 'host_kd_btau' 'host_kd_mmus'\n"
	printf "\t Taxonomy:      'tool_k2_agora' (DEFAULT) 'tool_k2_apollo' 'tool_k2_std8'\n"
	printf " -o OUTPUT: Directory to contain final output (/path/to/output)\n"
	printf " -r BrANCH: Branch of pipeline to use, one of SR, MAG, ALL\n\t(default: SR)\n"
	printf " -c COMMS : Commands applied to step\n"
	printf " -s STEPS : Steps of pipeline to run with '0' complete run \n\t(steps=( $( eval echo {1..9} ) ))\n"
	printf " -e HeAD  : Head of files, from first char to start of variable region\n"
	printf "\tsample_01.fastq\n\t...\n\tsample_10.fastq\n\t^^^^^^^\n"
	printf " -t TAIL  : File tail, ~extension, constant across all input\n"
	printf "\tsample_01.fastq\n\t...\n\tsample_10.fastq\n\t         ^^^^^^\n"
	printf " -n NAME  : Unique names linking sample to input file(s)\n"
	printf "\tPlain text file with entries separated by new line\n"
	printf "\te.g., sample_01_R1.fastq sample_01_R2.fastq .. sample_10_R1.fastq sample_10_R2.fastq ->\n"
	printf "\tsample_01\n\t...\n\tsample_10\n"
	printf " -u uMAMBA: Explicit micromamba environment\n"
	printf " -p PACK  : Name of package used in step, currently redunt\n"
	printf " -k KEEP  : Retain all intermediary data\n"
	printf " -0 check : Perform checks\n"
	printf " -1 Demo  : Conduct a demo run of the pipeline using synthetic data\n"
}
func_log () {
	# Expand log files by standard entry lines
	# Set section with $1: 0=all 1=main 2=debug 3=status 4=console
	# Build base log file on vopt_log=1
	# POT. change sep from :FS: to : or better
	if [[ $1 -eq 1 ]] || [[ $1 -eq 0 ]];then
		# type/entry/value
    	((vopt_log)) && printf '%s:FS:%s:FS:%s\n' "$2" "$3" "$4" >> "$v_logfile"
		#func_log "1" "MESSAGE" "FUNC_MAMA" "Something nice to say"
	fi
	# Build debug log file on vopt_dbug=1
	if [[ $1 -eq 2 ]] || [[ $1 -eq 0 ]];then
	#
		local line_info call_line
        line_info=$(caller 0)
        call_line=${line_info%% *}
        #printf '%s:FS:%s_DEBUG(LINE%s):FS:%s\n' "$2" "$3" "$call_line" "$4" >> "$v_logfile_dbug"
	#
		# type/entry/value
    	((vopt_dbug)) && printf '%s:FS:%s_DEBUG(LINE%s):FS:%s\n' "$2" "$3" "$call_line" "$4" >> "$v_logfile_dbug"
		#func_log "2" "MESSAGE" "FUNC_MAMA" "Something wild to say"
	fi
	# Build status log file on vopt_status=1
	if [[ $1 -eq 3 ]] || [[ $1 -eq 0 ]];then
		# type/entry/value
    	((vopt_status)) && printf '%s:FS:%s:FS:%s\n' "$2" "$3" "$4" >> "$v_logfile_status"
		#func_log "3" "CONFIG" "run_ID" "${v_runID}"
	fi
	# Print to console
	if [[ $1 -eq 4 ]] || [[ $1 -eq 0 ]];then
		# type/entry/value
    	printf '%s\t%s\t%s\n' "$2" "$3" "$4" && return
		#func_log "4" "CRITICAL" "FUNC_MAMA" "something bad happened XO"
	fi
}
func_file_find () {
	# Simple find file<1> in given list of dirs<2> returns first hit
	#vq_name="$vopt_name"
	#vq_dir=("." "step0_data_in" "final_reports")
	local query_file="${1}"
	shift
	local query_dir=("$@")
	for dir in ${query_dir[@]};do
		[[ -f "$dir/$query_file" ]] && echo "$dir/$query_file" && return
	done
	echo "" # Return empty if not found
	#vopt_name=$(func_file_find "$vq_name" "${vq_dir[@]}")
}
func_status_step() {
	# check status of sample progress from status file
	# step corresponds to digit in index and stat is match arg and file is status file
	# returns list of match to stdout
	# use: func_status_step 1 0 ${vtfile} "STATE" <optional field2>
	local vstep=$1
	local vstat=$2
	local vfile=$3
	local vtype=$4
	local vname
	[[ -z $5 ]] && vname='PASS' || vname=$5
	awk -F ":FS:" -v pos="$vstep" -v want="$vstat" -v type="$vtype" -v name="$vname" '
	{
		if ($1 == type)
			if (name == "PASS" || $2 == name)
				if (substr($3, pos, 1) == want)
					print $2
	}' "${vfile}"
}
func_test() {
	local vmid0="${1}" # NULL=unchanged
	local vmid1="${2}" # NULL=unchanged
	local vmid2="${3}" # NULL=unchanged
	local vext0="${4}" # NULL=unchanged
	[[ ! "${vmid0}" = "NULL" ]] && func_status_adj "set" "${v_logfile_status}" "CONFIG" "file_str_mid0" "${vmid0}"
	[[ ! "${vmid1}" = "NULL" ]] && func_status_adj "set" "${v_logfile_status}" "CONFIG" "file_str_mid1" "${vmid1}"
	[[ ! "${vmid2}" = "NULL" ]] && func_status_adj "set" "${v_logfile_status}" "CONFIG" "file_str_mid2" "${vmid2}"
	[[ ! "${vext0}" = "NULL" ]] && func_status_adj "set" "${v_logfile_status}" "CONFIG" "file_str_ext" "${vext0}"
	# transfer to variables
	vopt_mid[0]=$(func_status_adj "get" "${v_logfile_status}" "CONFIG" "file_str_mid0")
	vopt_mid[1]=$(func_status_adj "get" "${v_logfile_status}" "CONFIG" "file_str_mid1")
	vopt_mid[2]=$(func_status_adj "get" "${v_logfile_status}" "CONFIG" "file_str_mid2")
	vopt_ext=$(func_status_adj "get" "${v_logfile_status}" "CONFIG" "file_str_ext")
	printf 'mid0 %s mid1 %s mid2 %s ext0 %s\n' "${vopt_mid[0]}" "${vopt_mid[1]}" "${vopt_mid[2]}" "${vopt_ext}"
}
func_status_exit() {
	# perform standard exit commands at end of step
	# TODO: check for preexisting vout_sN and append for substeps ie vout_s3A
	# use: func_status_exit ${istep} ${vin_O_dir} '*kneaddata*{.log,.fastq}' '*kneaddata*{unmatched,contam}*.fastq' '*kneaddata*paired*.fastq' NULL NULL NULL NULL
	# 	   func_status_exit <step> <step output dir> <catch regex to keep> <catch regex to dump NOW> <catch regex to dump END> <mid string 0> <mid string 1> <mid string 2> <extension string>
	local vstep="${1}" # step
	local vout="${2}" # vin_O_dir
	local vcatch="${3}" # v_exit_catch='*kneaddata*{.log,.fastq}'
	local vdump="${4}"	# v_drop_catch='*kneaddata*{unmatched,contam}*.fastq'
	local vdump_fin="${5}" # v_drop_catch='*kneaddata*paired*.fastq' NULL if no
	local vmid0="${6}" # NULL=unchanged
	local vmid1="${7}" # NULL=unchanged
	local vmid2="${8}" # NULL=unchanged
	local vext0="${9}" # NULL=unchanged
	local vstatus="${10}" # NULL=leave step open otherwise (=DONE) pass to step state
	# do it
	v_exit_TS=$(date +"%Y%m%d%H%M")
	v_exit_dir='done_'${v_exit_TS}
	vexit=${vin_O_dir}/${v_exit_dir}
	mkdir -p ${vexit}
	# move content
	eval "mv ${vout}/${vcatch} ${vexit}" 2> /dev/null
	# STATUS - update
	# Record path for step
	#vtar1="PATH:FS:step"${vstep}"_PATH";vtar2="NULL";vrep1=${vtar1};vrep2=${vexit}
	#sed -i "s|$vtar1:FS:$vtar2|$vrep1:FS:$vrep2|g" $v_logfile_status
	func_status_adj "set" "${v_logfile_status}" "PATH" "step"${vstep}"_PATH" "${vexit}"
	# Record completion for step - TODO more confirm
	#vtar1="STATE:FS:step"${vstep};vtar2="PENDING";vrep1=${vtar1};vrep2="DONE"
	#sed -i "s|$vtar1:FS:$vtar2|$vrep1:FS:$vrep2|g" $v_logfile_status
	[[ ! "${vstatus}" = "NULL" ]] && func_status_adj "set" "${v_logfile_status}" "STATE" "step"${vstep} "${vstatus}"
	[[ ! "${vmid0}" = "NULL" ]] && func_status_adj "set" "${v_logfile_status}" "CONFIG" "file_str_mid0" "${vmid0}"
	[[ ! "${vmid1}" = "NULL" ]] && func_status_adj "set" "${v_logfile_status}" "CONFIG" "file_str_mid1" "${vmid1}"
	[[ ! "${vmid2}" = "NULL" ]] && func_status_adj "set" "${v_logfile_status}" "CONFIG" "file_str_mid2" "${vmid2}"
	[[ ! "${vext0}" = "NULL" ]] && func_status_adj "set" "${v_logfile_status}" "CONFIG" "file_str_ext" "${vext0}"
	# transfer to variables
	vopt_mid[0]=$(func_status_adj "get" "${v_logfile_status}" "CONFIG" "file_str_mid0")
	vopt_mid[1]=$(func_status_adj "get" "${v_logfile_status}" "CONFIG" "file_str_mid1")
	vopt_mid[2]=$(func_status_adj "get" "${v_logfile_status}" "CONFIG" "file_str_mid2")
	vopt_ext=$(func_status_adj "get" "${v_logfile_status}" "CONFIG" "file_str_ext")
	# step keep-clean
	if (( ${vopt_keep} ));then
		printf 'KEEP active - Retaining all files\n' >> ${v_logfile}
	else
		[[ ! "${vdump}" = "NULL" ]] && eval "rm ${vexit}/${vdump}" 2> /dev/null
		#statment for final drop
		[[ ! "${vdump_fin}" = "NULL" ]] && v_drop_exit=${v_drop_exit}' '${vexit}/${vdump_fin}
	fi
	# TODO more elaborate permissions transfer approach
	# pot. grab user ID at start and set ownership directly
	chmod -R +777 ${vexit}/* 2> /dev/null
	v_print_size=$( du -sh ${vexit} | cut -f 1 )
	v_print_count=$( find ${vexit} | wc -l )
	# TODO - update to log function
	printf 'Step product location:\t%s\nStep run script location:\t%s\nStep output size(disk use):\t%s\nStep output count(files):\t%s\n%s\n' \
	"${vexit}" "${v_scrp_base}" "${v_print_size}" "${v_print_count}" "${v_logblock1}" >> ${v_logfile}
	# export
	export vout_s${vstep}=${vexit} 2> /dev/null
	export vout_sX=${vexit}
	export vopt_mid
	export vopt_ext
	# Remove tmp name file
	eval "rm ${vstat_name}" 2> /dev/null
}
func_status_adj() {
	# utility to modify or retrieve status_value field
	# CHANGE ADD TO SET UGH
	local vmode=$1
	local vfile=$2
	local vtype=$3
	local vvarb=$4
	local vvalu=$5
	local vout=$(
	awk -F ":FS:" -v mode="$vmode" -v type="$vtype" -v varb="$vvarb" -v valu="$vvalu" '
    {
		if ($1 == type && $2 == varb) {
				if (mode == "get") {print $3}
				if (mode == "set") {printf "|%s|%s%s|",$0,$1FS$2FS,valu}
			}
    }' "${vfile}"
	)
	[[ "$vmode" = "get" ]] && echo $vout && return
	[[ "$vmode" = "set" ]] && sed -i "s${vout}g" "${vfile}" && return
	#func_status_adj "get" "${v_logfile_status}" "ITEM" "run_log_file"
	#func_status_adj "set" "${v_logfile_status}" "PATH" "proc_PATH" "KITTY"
}
func_awk_esc() {
    local input="$1"
    # Adjust print statement for feeding into func_mama
	# Escape backslashes, double quotes, and dollars
    input="${input//\\/\\\\}"  # Escape backslashes
    input="${input//\"/\\\"}"  # Escape double quotes
    #input="${input//\$/\\\$}"  # Escape dollar signs
    input="${input//\`/\\\`}"  # Escape backticks (optional)
    input="${input//\!/\\\!}"  # Escape !
	input="${input//\{/\\\{}"  # Escape {}
	input="${input//\}/\\\}}"  # Escape {}
	input="${input//\(/\\\(}"  # Escape ()
	input="${input//\)/\\\)}"  # Escape ()
    echo "$input"
}

func_mama2 () {
    #======================================================================================================#
    # Title: FUNC_MAMA (Main processing function with script generation)
    # Merged and refactored with BASH_seqc_stepgen.sh by ChatGPT - 2025.06.13
	# Usage: func_mama -s <step> -e <mamba_env> -p <package> -j <script base name> -I <input_dir> -O <output_dir> -c <commands> -H <head> -T <tail> -N <name_file> -b <debug> -m <mkdir>
    #======================================================================================================#
    # Defaults
	local OPTIND
    local vloc_dbug=0
    local vloc_mkdr=1
	local vloc_head=''
	local vloc_tail=''
    # Parse args
	OPTSTRING=":s:e:p:j:I:O:c:H:T:N:b:m:"
	while getopts ${OPTSTRING} opt; do
        case ${opt} in
            s) local vloc_step="${OPTARG}" ;; # step
            e) local vloc_env="${OPTARG}" ;; # env
            p) local vloc_pac="${OPTARG}" ;; # package
            j) local vloc_scrp="${OPTARG}" ;; # base script name SCRIPT_NAME > vloc_scrp
            I) local vloc_I_dir="${OPTARG}" ;; # Input directory
            O) local vloc_O_dir="${OPTARG}" ;; # Output directory
            #c) IFS=$'\n' read -rd '' -a vloc_com <<< "${OPTARG}" ;;  # Command statements STATEMENTS > vloc_com
			c) local vloc_com+=("${OPTARG}") ;;
            H) local vloc_head="${OPTARG}" ;; # Head string
            T) local vloc_tail="${OPTARG}" ;; # Tail string
            N) local vloc_name="${OPTARG}" ;; # name file
            b) local vloc_dbug="${OPTARG}" ;; # Debug
            m) local vloc_mkdr="${OPTARG}" ;; # make out dir
            \?) echo "Invalid option: -$OPTARG" >&2; return 1 ;;
            :) echo "Option -$OPTARG requires an argument." >&2; return 1 ;;
        esac
    done
    # Required check
#    if [[ -z "${vloc_com[*]}" || -z "$vloc_env" || -z "$vloc_pac" || -z "$JOB_SCRIPT_NAME" || -z "$vloc_name" ]]; then
 #       echo "Usage: func_mama -s <statements> -e <mamba_env> -p <package> -j <job_script> -f <file_with_samples> \
#		-S <step> -I <input_dir> -C <input_command_dir> -O <output_dir> -D <output_command_dir> -c <commands> \
#		-H <head> -T <tail> -N <name_file> -u <script_path> -b <debug> -m <mkdir>"
 #       return 1
  #  fi
    local vloc_string="${vloc_head}${vloc_tail}"
	# Set up working directories and file paths
    DIR_JOB="$(pwd)/scrp_job"
    DIR_RUN="$(pwd)/scrp_run"
    mkdir -p "$DIR_JOB" "$DIR_RUN"
    local SCRP_JOB="${DIR_JOB}/job_${vloc_scrp}"
    local SCRP_RUN="${DIR_RUN}/run_${vloc_scrp}"

    # Join statements into a single string for awk
	local COMBINED_CMD="${vloc_com[*]}"
#	ESCAPED_CMD=$(echo "$COMBINED_CMD" | sed 's/"/\\"/g')
	local ESCAPED_CMD=$(func_awk_esc "${COMBINED_CMD}")
    #ESCAPED_CMD=$(printf "%s\n" "${vloc_com[@]}" | sed ':a;N;$!ba;s/\n/\\n/g')
	# Check for input
	if [[ ! -d $vloc_I_dir ]];then
		func_log "4" "CRITICAL_ERROR" "FUNC_MAMA" "Input directory for Step $vloc_step is missing"
		func_log "4" "CRITICAL_HELP" "FUNC_MAMA" "Check validity of: $vloc_I_dir"
		exit 1
	fi
	v_statment=$(printf 'DEBUG: step: %s dir_I: %s dir_O: %s CMDS: %s head: %s tail: %s name: %s env: %s pack: %s scrp: %s DEBUG: %s MKDIR: %s' "${vloc_step}" "${vloc_I_dir}" "${vloc_O_dir}" "${ESCAPED_CMD}" "${vloc_head}" "${vloc_tail}" "${vloc_name}" "${vloc_env}" "${vloc_pac}" "${vloc_scrp}" "${vloc_dbug}" "${vloc_mkdr}")
	func_log "2" "MESSAGE" "FUNC_MAMA" "${v_statment}"
	# Check for output dir
		if [[ ! -d $vloc_O_dir ]];then
			func_log "2" "ERROR" "FUNC_MAMA" "Output directory for Step $vloc_step is missing"
			func_log "2" "FIX" "FUNC_MAMA" "Creating output directory for Step: $vloc_step"
			(( $vloc_mkdr )) && mkdir -p "${vloc_O_dir}"
		else
			if [ $( ls -1 $vloc_O_dir/$vloc_string 2>/dev/null | wc -l ) -gt 0 ];then
				func_log "2" "MESSAGE" "FUNC_MAMA" "Stuff is already in output directory"
			fi
		fi
	if [[ ! -f $vloc_name ]];then
		func_log "4" "CRITICAL_ERROR" "FUNC_MAMA" "Name file for Step $vloc_step is missing"
		func_log "4" "CRITICAL_HELP" "FUNC_MAMA" "Attempting to create sample name file"
		func_log "4" "CRITICAL_ERROR" "FUNC_MAMA" "Functionality currently missing, manually create :3"
		func_log "4" "CRITICAL_HELP" "FUNC_MAMA" "ex: var_sample_uniq=(sample{1..9});printf '%s\n' ${var_sample_uniq[@]} > file_in_samples"
		exit 1
	else
		if [ $( ls -1 $vloc_O_dir/$vloc_string 2>/dev/null | wc -l ) -gt 0 ];then
			func_log "2" "MESSAGE" "FUNC_MAMA" "Input files located"
		fi
	fi
	# extract non-const strings for auto generation of sample name file
	# run if not absent from func mama command
	# currently unused - 2024.10.14
	if [[ ! -z $vloc_name ]];then
		local vloc_core[0]=''
		local vloc_core_len=${#vloc_core_len[@]}
		for vi in $(eval echo $vloc_name);do
			if [ $(eval ls -1 ${vloc_I_dir}/${vi}*${v_tail} 2>/dev/null | wc -l ) -gt 1 ];then
				echo "FUNC_MAMA: Sample <"$vi"> matches multiple files"
				vloc_core_len=${#vloc_core_len[@]}
				for vii in $(eval ls -1 ${vloc_I_dir}/${vi}*${v_tail});do
					echo "FUNC_MAMA: Extracting nonconstant strings between head and tail"
					v_mid="${vii#*$vi}";v_mid="${v_mid%$vloc_tail}"
					for viii in ${!vloc_core[@]};do
						while [[ ${viii} -le ${#vloc_core[@]} ]];do 
							if [[ ${vloc_core[viii]} == ${v_mid} ]];then
								echo "FUNC_MAMA: viii eq while:"$viii
								break
							fi
							if [[ ${vloc_core[viii]} != ${v_mid} ]];then
								echo "FUNC_MAMA: viii ne:"$viii
								if [[ ${viii} == ${#vloc_core[@]} ]];then
									echo "FUNC_MAMA: viii assign:"$viii" val:"${v_mid}
									vloc_core[viii]=${v_mid}
								break
								fi
								((viii++))
							fi
						done
						if [[ ${vloc_core[viii]} == ${v_mid} ]];then
							echo "FUNC_MAMA: viii eq for:"$viii
							break
						fi
					done
				done
			fi
		done
	fi # Eonameextract
    # Generate script
    cat <<EOF > "$SCRP_JOB"
#!/bin/bash
#======================================================================================================#
# Template Job Script: ${vloc_scrp}
# Generated: $(date)
# Micromamba Env: ${vloc_env}
# Mamba Pack:     ${vloc_pac}
# Input File:     ${vloc_name}
# Generating program by: Wiley Barton - 2022.02.07
# Modified code sources:
#   https://sylabs.io/guides/3.5/user-guide/mpi.html
#======================================================================================================#
# modification by '$( whoami )'
#======================================================================================================#
# Check for file and if missing take arg 1
[[ -z ${vloc_name} ]] && vloc_name="${1}"
vawk_in="${vloc_name}"

awk 'BEGIN { FS=OFS="\t" }
{
    va_nID = gensub(/.*\\/(.*)/, "\\\\1", "g", \$1)
    va_cmd = "${ESCAPED_CMD}"
    gsub(/v_SAMPLE_UNIQ/, va_nID, va_cmd)
	gsub(/v_LINO/, "\n", va_cmd)
    printf("micromamba run -n ${vloc_env} ${vloc_pac} %s\\n", va_cmd)
}
END { print "#EoB" }' "\$vawk_in" > "${SCRP_RUN}" 2> /dev/null

# Run the generated run script and redirect awk error
bash "${SCRP_RUN}"
EOF
    # Make executable and run
    chmod +x "$SCRP_JOB"
    bash "$SCRP_JOB" "${vloc_name}"
	# POSTCHECK
	# TODO
} # EoFunc - mama2
func_check () {
	#set internal flag to direct operations
	#0=all, 1=size est, 2=...
	local vloc_check="${1}"
	if [[ ${vloc_check} -eq 1 ]];then
	# apply estimate with IBD100 ratio: 3.196 (inGB:totGB)
	# adjust estimate according to 'keep' status
	# table of space/sample with aim of deriving average ratio of expansion for est of upper limit in req space
		varr_size+=("$(printf '%s\t%s\t%s\t%s\t%s\n' \
		"sample_id" \
		"size_input" \
		"size_KD" \
		"size_KB" \
		"size_total"
		)")
		for vi in $(cat step0_data_in/sample_id.txt);do
		v_tot=("$(du -csh {step0_data_in,/DB/DEPO_proc/step1_kneaddata/done_202412112001,/DB/DEPO_proc/step2_kraken/done_202412112004}/${vi}_* 2>/dev/null | tail -1 | cut --fields 1)")
		varr_size+=("$(printf '%s\t%s\t%s\t%s\t%s\n' \
		"${vi}" \
		"$( du -csh step0_data_in/${vi}_* 2>/dev/null | tail -1 | cut --fields 1 )" \
		"$( du -csh /DB/DEPO_proc/step1_kneaddata/done_202412112001/${vi}_* 2>/dev/null | tail -1 | cut --fields 1 )" \
		"$( du -csh /DB/DEPO_proc/step2_kraken/done_202412112004/${vi}_* 2>/dev/null | tail -1 | cut --fields 1 )" \
		"${v_tot}"
		)")
		done
	fi
	if [[ ${vloc_check} -eq 0 ]];then
	# check and make job/run dirs
		printf 'FUNC_CHECK: Running check of essential directories\n'
		if [ ! -d $seqc_dir_run ];then
			printf 'FUNC_CHECK: Run script dir. missing and being created\n'
			mkdir $seqc_dir_run
		fi
		if [ ! -d $seqc_dir_job ];then
			printf 'FUNC_CHECK: Job script dir. missing and being created\n'
			mkdir $seqc_dir_job
		fi
		# check for DBs/initalisation
		if [[ $v_vol_real -lt $v_vol_none ]];then
			echo "SEQC_MAMA: DB is likely uninitalised or misconfigured"
			echo "SEQC_MAMA: Confirm that \$v_dir_db is correct ("$v_dir_db")"
			read -p "SEQC_MAMA: Should the default databases be setup? (Y/n)" ans_db
			if [ $ans_db = 'Y' ];then
				echo "SEQC_MAMA: Running seqc_makedb (BASH_seqc_makedb.sh -a Y)"
				BASH_seqc_makedb.sh -a Y
			else
				echo "SEQC_MAMA: Cannot proceed with current configuration... :{"
				exit 1
			fi
		fi
		# check if pipeline arrays are absent, make if true
		# TODO: complete and implement
		if [[ ! -v VARR_DB_NAME ]];then
			IFS=':' read -ra VARR_DB_NAME <<< "$VEN_DB_NAME"; for i in "${VARR_DB_NAME[@]}"; do echo $i;done
		fi
		if [[ ! -v VARR_DB_GETS ]];then
			IFS=':' read -ra VARR_DB_GETS <<< "$VEN_DB_GETS"; for i in "${VARR_DB_GETS[@]}"; do echo $i;done
		fi
		if [[ ! -v VARR_DB_PATH ]];then
			IFS=':' read -ra VARR_DB_PATH <<< "$VEN_DB_PATH"; for i in "${VARR_DB_PATH[@]}"; do echo $i;done
		fi
		if [[ ! -v VARR_DB_PACK ]];then
			IFS=':' read -ra VARR_DB_PACK <<< "$VEN_DB_PACK"; for i in "${VARR_DB_PACK[@]}"; do echo $i;done
		fi
	fi
}
#EoFunc - check
func_ref () {
# Generate references for used software
# run as func_ref {tool,branch}
# TODO flexibility for non-loaded envs
	vlog_seqc=0
	vlog_kneaddata=0
	vlog_kraken=0
	vlog_camisim=0
	vlog_mars=0
	vlog_seqkit=0
	vlog_taxonkit=0
	if [[ "${1}" = "ALL" ]];then
		vlog_seqc=1
		vlog_kneaddata=1
		vlog_kraken=1
		vlog_mars=1
	fi
	if [[ "${1}" = "SR" ]];then
		vlog_seqc=1
		vlog_kneaddata=1
		vlog_kraken=1
		vlog_mars=1
	fi
	#seqc kneaddata spades vamb checkm2 minimap2 kraken mmseqs2 camisim mars seqkit taxonkit
	if [[ "${1}" = "seqc" ]];     then vlog_seqc=1;fi
	if [[ "${1}" = "kneaddata" ]];then vlog_kneaddata=1;fi
	if [[ "${1}" = "humann" ]];   then vlog_humann=1;fi
	if [[ "${1}" = "kraken" ]];   then vlog_kraken=1;fi
	if [[ "${1}" = "mmseqs2" ]];  then vlog_mmseqs2=1;fi
	if [[ "${1}" = "camisim" ]];  then vlog_camisim=1;fi
	if [[ "${1}" = "mars" ]];     then vlog_mars=1;fi
	if [[ "${1}" = "seqkit" ]];   then vlog_seqkit=1;fi
	if [[ "${1}" = "taxonkit" ]]; then vlog_taxonkit=1;fi
	# generate if vlog=1
	if [[ "${vlog_seqc}" -eq 1 ]];then
		v_nom='SeqC'
		v_ver=$(BASH_seqc_mama.sh -v)
		v_ref=$(printf 'Bram Nap, Tim Hensen, Anna Sheehy, Wiley Barton, Jonas Widder, Ines Thiele, 2025. Persephone: A personalisation and evaluation pipeline for human whole-body metabolic models')
		printf '%s\n%s\n\t%s\n' "${v_nom}" "${v_ver}" "${v_ref}"
	fi
	if [[ "${vlog_kneaddata}" -eq 1 ]];then
		v_nom='kneaddata'
		v_ver=$(micromamba run -n env_s1_kneaddata kneaddata --version)
		#sic:Boštjan
		v_ref=$(printf 'Murovec, Bostjan, et al. "MetaBakery: a Singularity implementation of bioBakery tools as a skeleton application for efficient HPC deconvolution of microbiome metagenomic sequencing data to machine learning ready information." Frontiers in microbiology 15 (2024): 1426465.')
		printf '%s\n%s\n\t%s\n' "${v_nom}" "${v_ver}" "${v_ref}"
	fi
	if [[ "${vlog_checkm2}" -eq 1 ]];then
		v_nom='CheckM2'
		v_ver=$(micromamba run -n env_s3_checkm2 checkm2 --version)
		v_ref=$(printf 'Chklovski, Alex, et al. "CheckM2: a rapid, scalable and accurate tool for assessing microbial genome quality using machine learning." Nature Methods 20.8 (2023): 1203-1212.')
		printf '%s\n%s\n\t%s\n' "${v_nom}" "${v_ver}" "${v_ref}"
	fi
	if [[ "${vlog_minimap2}" -eq 1 ]];then
		v_nom='Minimap2'
		v_ver=$(micromamba run -n env_s3_minimap2 minimap2 --version)
		v_ref=$(printf 'Li, Heng. "Minimap2: pairwise alignment for nucleotide sequences." Bioinformatics 34.18 (2018): 3094-3100.')
		printf '%s\n%s\n\t%s\n' "${v_nom}" "${v_ver}" "${v_ref}"
	fi
	if [[ "${vlog_humann}" -eq 1 ]];then
		v_nom='HuMANn'
		v_ver=$(micromamba run -n env_s4_humann humann --version)
		v_ref=$(printf 'Franzosa, Eric A., et al. "Species-level functional profiling of metagenomes and metatranscriptomes." Nature methods 15.11 (2018): 962-968.')
		printf '%s\n%s\n\t%s\n' "${v_nom}" "${v_ver}" "${v_ref}"
	fi
	if [[ "${vlog_kraken}" -eq 1 ]];then
		v_nom='Kraken2'
		v_ver=$(micromamba run -n env_s4_kraken kraken2 --version)
		v_ref=$(printf 'Wood, Derrick E., Jennifer Lu, and Ben Langmead. "Improved metagenomic analysis with Kraken 2." Genome biology 20 (2019): 1-13.')
		printf '%s\n%s\n\t%s\n' "${v_nom}" "${v_ver}" "${v_ref}"
		v_nom='Bracken'
		v_ver=$(micromamba run -n env_s4_kraken bracken -v)
		v_ref=$(printf 'Lu, Jennifer, et al. "Bracken: estimating species abundance in metagenomics data." PeerJ Computer Science 3 (2017): e104.')
		printf '%s\n%s\n\t%s\n' "${v_nom}" "${v_ver}" "${v_ref}"
	fi
	if [[ "${vlog_mmseqs2}" -eq 1 ]];then
		v_nom='MMseqs2'
		v_ver=$(micromamba run -n env_s4_mmseqs2 mmseqs version)
		#sic:Söding
		v_ref=$(printf 'Steinegger, Martin, and Johannes Soding. "MMseqs2 enables sensitive protein sequence searching for the analysis of massive data sets." Nature biotechnology 35.11 (2017): 1026-1028')
		printf '%s\n%s\n\t%s\n' "${v_nom}" "${v_ver}" "${v_ref}"
	fi
	if [[ "${vlog_camisim}" -eq 1 ]];then
		v_nom='CAMISIM'
		v_ver='version 1.3 (Could not retrieve from software)'
		v_ref=$(printf 'Fritz, Adrian, et al. "CAMISIM: simulating metagenomes and microbial communities." Microbiome 7 (2019): 1-12.')
		printf '%s\n%s\n\t%s\n' "${v_nom}" "${v_ver}" "${v_ref}"
	fi
	if [[ "${vlog_mars}" -eq 1 ]];then
		v_nom='MARS'
		v_ver='version 1.0 (Could not retrieve from software)'
		v_ref=$(printf 'Hulshof, Tim, et al. "Microbial abundances retrieved from sequencing data-automated NCBI taxonomy (MARS): a pipeline to create relative microbial abundance data for the microbiome modelling toolbox and utilising homosynonyms for efficient mapping to resources." Bioinformatics Advances (2024): vbae068.')
		printf '%s\n%s\n\t%s\n' "${v_nom}" "${v_ver}" "${v_ref}"
	fi
	if [[ "${vlog_seqkit}" -eq 1 ]];then
		v_nom='SeqKit'
		v_ver=$(micromamba run -n env_util_seqkit seqkit version)
		v_ref=$(printf 'Shen, Wei, et al. "SeqKit: a cross-platform and ultrafast toolkit for FASTA/Q file manipulation." PloS one 11.10 (2016): e0163962.')
		printf '%s\n%s\n\t%s\n' "${v_nom}" "${v_ver}" "${v_ref}"
	fi
	if [[ "${vlog_taxonkit}" -eq 1 ]];then
		v_nom='TaxonKit'
		v_ver=$(micromamba run -n env_util_taxonkit taxonkit version)
		v_ref=$(printf 'Shen, Wei, and Hong Ren. "TaxonKit: A practical and efficient NCBI taxonomy toolkit." Journal of genetics and genomics 48.9 (2021): 844-850.')
		printf '%s\n%s\n\t%s\n' "${v_nom}" "${v_ver}" "${v_ref}"
	fi
	#eggnog:Carlos P Cantalapiedra, Ana [sic]Hernandez-Plaza, Ivica Letunic, Peer Bork, Jaime Huerta-Cepas, eggNOG-mapper v2: Functional Annotation, Orthology Assignments, and Domain Prediction at the Metagenomic Scale, Molecular Biology and Evolution, Volume 38, Issue 12, December 2021, Pages 5825–5829, https://doi.org/10.1093/molbev/msab293
	#DEMETER:Heinken A, [sic]Magnusdottir S, Fleming RMT, Thiele I. DEMETER: efficient simultaneous curation of genome-scale reconstructions guided by experimental data and refined gene annotations. Bioinformatics. 2021 Nov 5;37(21):3974-3975. doi: 10.1093/bioinformatics/btab622. PMID: 34473240; PMCID: PMC8570805
}
#EoFunc - refs
func_taxa_map () {
#map read count via bam to final taxonomy assigned to meta-bin assembles
#https://www.biostars.org/p/14246/#14264
#TODO: apply debug var, multi taxa lvl, slower with func format
	v_dir_bam_head="${1}"
	v_dir_bam_tail="${2}"
	v_profile="${3}"
	#'/DB/DEPO_demo/demo/step4_mmseqs2/result_taxonomy_agora_smol.tsv'
	v_outfile="${4}"
	#'/DB/DEPO_demo/demo/step4_mmseqs2/result_taxonomy_join_agora_smol.tsv'
	vloc_dbug="${5}"
	v_dir_bam="${v_dir_bam_head}*${v_dir_bam_tail}"
	v_len=$( ls -1 ${v_dir_bam} | wc -l )
	echo $v_len; printf '%s\n' "${v_dir_bam[@]}"
	#v_dir_in='/DB/DEPO_demo/demo/step1_kneaddata'
	#v_len=$( ls -1 "${v_dir_in}"/camisim_agora_smol_s*_1_kneaddata.fastq | wc -l )
	#v_dir_bam='/DB/DEPO_demo/demo/step3_minimap/camisim_s*.bam'
	#taxonomy report from mmseqs2
	#v_profile='/DB/DEPO_demo/demo/step4_mmseqs2/result_taxonomy_agora_smol.tsv'
	#v_outfile='/DB/DEPO_demo/demo/step4_mmseqs2/result_taxonomy_join_agora_smol.tsv'
	#match string taxa level - expand to generate output/lvl
	v_keep=( 'strain' 'species' 'genus' )
	#convert v_i to length of taxa lvl for multi table generation
	for (( v_i=0; v_i<${v_len}; v_i++ ));do
		if [ $v_i -eq 0 ];then
			#compile header
			v_header=$(printf 'id_taxa\tid_contig')
			#debug
			v_header=$(printf '%s\t%s' "${v_header}" "id_contig_Q")
			#extract var cols from taxa profile
			mapfile -t varr_cont < <( cat "${v_profile}" | sort | cut --fields 1 )
			mapfile -t varr_tlvl < <( cat "${v_profile}" | sort | cut --fields 3 )
			mapfile -t varr_tnom < <( cat "${v_profile}" | sort | cut --fields 4 )
			mapfile -t varr_taxa < <( cat "${v_profile}" | sort | cut --fields 6 )
			varr_index=()
			v_body_prof=()
			#retain species in tlvl and associated contigs and taxa,2> /dev/null, pot confirm issue empty last element
			#better approach for complete list of array index!
			#https://stackoverflow.com/questions/42314168/bash-the-quickest-and-efficient-array-search
			for v_ii in "${!varr_tlvl[@]}";do
			# =~ is for string to regexp results in greedy match
				if [[ "${varr_tlvl[v_ii]}" =~ ${v_keep[0]} ]];then
					varr_index+=( "${v_ii}" )
					if (( ${vloc_dbug} ));then
					printf 'spp:%s @%s with inx:%s\n' "${varr_tlvl[v_ii]}" "${#varr_index[@]}" "${v_ii}"
					fi
				fi
			done
			if [[ "${#varr_index[@]}" -gt 0 ]];then
				printf 'setting taxa and cont from index\n'
				varr_cont_tmp=()
				varr_tnom_tmp=()
				varr_taxa_tmp=()
				#retaining via match
				for v_ii in "${!varr_index[@]}";do
					v_idx=( "${varr_index[v_ii]}" )
					printf 'i:%s | idx:%s\n' "${v_ii}" "${v_idx}"
					varr_cont_tmp+=( "${varr_cont[v_idx]}" )
					varr_tnom_tmp+=( "${varr_tnom[v_idx]}" )
					varr_taxa_tmp+=( "${varr_taxa[v_idx]}" )
				done
				#join for sorting
				#remove trailing duplicate flag on contig id and combine
				v_body_prof=$( paste <(printf '%s\n' "${varr_cont_tmp[@]/%_[1-9]?([0-9])/}") \
				<(printf '%s\n' "${varr_tnom_tmp[@]}") <(printf '%s\n' "${varr_taxa_tmp[@]}") )
				v_body_prof=$( printf '%s\n' "${v_body_prof}" | uniq | sort )
				varr_cont=( $( printf '%s\n' "${v_body_prof[@]}" | cut -f 1 ) )
				mapfile -t varr_tnom < <( printf '%s\n' "${v_body_prof[@]}" | cut --fields 2 )
				mapfile -t varr_taxa < <( printf '%s\n' "${v_body_prof[@]}" | cut --fields 3 )
				v_body_prof=()
			fi
			#pull cols for taxa and assoc contigs
			v_body_prof=$( paste <(printf '%s\n' "${varr_taxa[@]}") <(printf '%s\n' "${varr_cont[@]}") )
			#identify frequency of each contig ie dublicates to repeat with bam contigs
			mapfile -t varr_dupe_cont < <( printf '%s\n' "${varr_cont[@]}" | uniq -c | awk '{print $1}')
			#create index of taxa contigs in sample files used to retain elements of interest
			for vbam in $( ls -1 ${v_dir_bam} );do
				#index then create bam map files
				printf 'indexing bam files\n'
				#IF check for corresponding map files
				micromamba run -n env_s3_minimap2 samtools index ${vbam}
				micromamba run -n env_s3_minimap2 samtools idxstats ${vbam} > ${vbam/.bam/.map}
				#remove dumb trailing *
				mapfile -t varr_bmap_reads < <( cat "${vbam/.bam/.map}" | head -n -1 | cut --fields 3 )
				#pull first file for index
				if [[ "${vbam}" == "$( ls -1 ${v_dir_bam} | head -1 )" ]];then
					printf 'indexing with file:%s\n' "${vbam}"
					mapfile -t varr_bmap < <( cat "${vbam/.bam/.map}" | head -n -1 | cut --fields 1 )
					varr_bmap_cont=()
					#which bam elements to retain
					#ToDo find if no matches remain and break
					varr_index=()
					#adjust trailing duplicate flag on contig id
					mapfile -t varr_cont_tmp < <( printf '%s\n' "${varr_cont[@]}" )
					#varr_cont_tmp=( $( printf '%s\n' "${varr_cont_tmp[@]/%_[1-9]?([0-9])/}" | sort | uniq ) )
					for v_ii in "${!varr_bmap[@]}";do
						for v_jj in "${!varr_cont_tmp[@]}";do
							v_cont="${varr_cont_tmp[v_jj]}"
							if [[ "${varr_bmap[v_ii]}" == "${v_cont}" ]];then
								varr_index+=( "${v_ii}" )
								#remove element matching to reduce next v_ii, pot increase effect with unset
								#varr_cont_tmp=( "${varr_cont_tmp[@]/$vcont}" )
								unset -v 'varr_cont_tmp[$v_jj]'
								#varr_cont_tmp=( ${varr_cont_tmp[@]} )
								printf '@vi:%s\tmatch pool size:%s with drop:%s\n' "${v_ii}" "${#varr_cont_tmp[@]}" "${v_cont}"
								#break after match
								break
							fi
						done
					#Eovcont
					done
					#Eobmap
					for v_ii in "${!varr_index[@]}";do
						v_idx=( "${varr_index[v_ii]}" )
						#gen retained contig ids from bams
						varr_bmap_cont+=( "${varr_bmap[v_idx]}" )
						printf 'v_bmap_cont count:%s\n' "${#varr_bmap_cont[@]}"
					done
					#debug
					#v_body=$( paste <(printf '%s\n' "${v_body[@]}") <(printf '%s\n' "${varr_bmap_cont[@]}") )
					#build index of contig order prior to sort to match with dupes
					mapfile -t varr_order_pre < <( paste <(printf '%s\n' "${varr_bmap_cont[@]}") \
					<(printf '%s\n' "${!varr_bmap_cont[@]}" ) | sort | cut --fields 2)
					#order bam contigs to match final
					mapfile -t v_body_bam < <( printf '%s\n' "${varr_bmap_cont[@]}" | sort )
					##v_body_bam=( ${v_body_bam[@]} )
					#duplicate initial body_bam for rep
					varr_tmp=()
					for v_ii in "${!varr_dupe_cont[@]}";do
						v_rep=( "${varr_dupe_cont[v_ii]}" )
						printf 'vii:%s v_rep:%s ' "${v_ii}" "${v_rep}"
						for v_iii in $(seq 1 ${v_rep});do
							varr_tmp+=( "${v_body_bam[v_ii]}" )
							printf "cont: %s\n" "${v_body_bam[v_ii]}"
						done
					done
					mapfile -t v_body_bam < <(printf '%s\n' "${varr_tmp[@]}")
					#reorder dupe list 2@189 -> 195 2orig@186 -> 2sort@189
					#varr_tmp=()
					#for v_order in "${!varr_order_pre[@]}";do
					#printf '@vorder:%s\t%s->%s\n' "${v_order}" "${varr_dupe_cont[v_order]}" "${varr_order_pre[v_order]}"
					#  v_idx=( "${varr_order_pre[v_order]}" )
					#  varr_tmp+=( "${varr_dupe_cont[v_idx]}" )
					#done
					#varr_dupe_cont=( "${varr_tmp[@]}" )
				fi
				#Eobamindx
				#contig | contig length | mapped reads | unmapped
				varr_bam_tmp=()
				printf 'setting bam cont from index - file:%s\n' "${vbam/.bam/.map}"
				#compile retained counts for contigs
				for v_ii in "${!varr_index[@]}";do
					v_idx=( "${varr_index[v_ii]}" )
					varr_bam_tmp+=( "${varr_bmap_reads[v_idx]}" )
				done
				#join for sort on contig id
				v_body_tmp=$(paste <(printf '%s\n' "${varr_bmap_cont[@]}") \
				<(printf '%s\n' "${varr_bam_tmp[@]}") | sort )
				mapfile -t v_body_tmp < <( printf '%s\n' "${v_body_tmp[@]}" | cut --fields 2 )
				#duplicate according to profile cont frequency
				varr_tmp=()
				for v_ii in "${!varr_dupe_cont[@]}";do
					v_rep=( "${varr_dupe_cont[v_ii]}" )
					for v_iii in $(seq 1 ${v_rep});do
						varr_tmp+=( "${v_body_tmp[v_ii]}" )
					done
				done
				mapfile -t varr_bam_tmp < <( printf '%s\n' "${varr_tmp[@]}" )
				#add each bams read count to bam body
				v_bam_id="${vbam##*/}"
				##varr_bam_tmp=( ${varr_bam_tmp[@]} )
				#v_body=$( paste <(printf '%s\n' "${v_body[@]}") <(printf '%s\n' "${varr_bam_tmp[@]}") )
				printf 'vbodlen:%s varbamtmplen:%s\n' "${#v_body_bam[@]}" "${#varr_bam_tmp[@]}"
				mapfile -t v_body_bam < <(paste <(printf '%s\n' "${v_body_bam[@]}") <(printf '%s\n' "${varr_bam_tmp[@]}"))
				printf '%s\n' "${v_body_bam[@]}" | head
				v_header=$(printf '%s\tid_sample_%s' "${v_header}" "${v_bam_id/.bam}")
			done
			#Eobam
		fi
		#Eoeq0
		if [ $v_i -eq $((v_len-1)) ];then
			#compile output file
			printf 'compiling output\n'
			#sort for match with profile contigs
			##v_body_bam=$( printf '%s\n' "${v_body_bam}" | sort )
			#if not debug drop bam contig col
			#v_body_bam=$( printf '%s\n' "${v_body_bam}" | cut --fields 1 --complement )
			#modify header to reflect +/- contig id with debug
			mapfile -t v_header < <(printf '%s\n' "${v_header[@]}" | cut --fields 2-3 --complement)
			mapfile -t v_body_full < <( paste <(printf '%s\n' "${v_body_prof[@]}") \
			<(printf '%s\n' "${v_body_bam[@]}") | sort)
			#collapse counts according to unique taxa
			printf 'collapsing counts on taxa'
			mapfile -t varr_sum_taxa < <( printf '%s\n' "${v_body_full[@]}" | cut --fields 1 )
			mapfile -t varr_sum_cont < <( printf '%s\n' "${v_body_full[@]}" | cut --fields 2 )
			mapfile -t varr_sum_contQ < <( printf '%s\n' "${v_body_full[@]}" | cut --fields 3 )
			mapfile -t varr_sum_read < <( printf '%s\n' "${v_body_full[@]}" | cut --fields 1-3 --complement )
			#join taxa and reads
			mapfile -t varr_sum_pre < <(paste <(printf '%s\n' "${varr_sum_taxa[@]}") \
			<(printf '%s\n' "${varr_sum_read[@]}"))
			#sum on duplicates
			#apt install datamash
			#column range
			v_range=$(printf '%s\n' "${v_header[@]}" | grep -o "id_sample_" | wc -l)
			#compile
			mapfile -t varr_sum_post < <(datamash --group 1 sum 2-$((v_range+1)) \
			< <(printf '%s\n' "${varr_sum_pre[@]}") )
			#combine header and body
			printf '%s\n%s\n' "${v_header[@]}" "${varr_sum_post[@]}" > ${v_outfile}
		fi
		echo vi:"${v_i}"
	done
}
#EoFunc - taxa_map
func_demo () {
	printf 'FUNC_DEMO: DEMO starting\n'
	v_dir_main_in='/home/seqc_user/seqc_project/step0_data_in'
	v_dir_main_out='/home/seqc_user/seqc_project/final_reports'
	printf 'FUNC_DEMO: DEMO input directory: %s\n' "${v_dir_main_in}"
	printf 'FUNC_DEMO: DEMO output directory: %s\n' "${v_dir_main_out}"
	# take branch option
	v_opt_branch="${1}"
	# block tmp code with 0
	v_BLOCK=0
	# create small subset of agora taxa for demo
	v_file_out='/DB/REPO_tool/kraken/t2p/taxa2proc_demo_out.txt'
	if [[ ! -f "${v_file_out}" ]];then
	sed -n '1p;331p;420p;911p;1450p;1998p;2552p;4000p;4460p;7204p;' /DB/REPO_tool/kraken/t2p/taxa2proc_agora_out.txt > "${v_file_out}"
	fi
	#CAMISIM of AOGRA
	# expected proportion in taxonomic_profile_x.txt/ distributions/distribution_x.txt
	#redirect samtool in defaults/mini_config.ini /opt/conda/envs/env_util_camisim/bin/samtools
	# TODO: fully incorp into dockerfile
	#Pseudacidobacterium_ailaaui missing from camisim run files but present in genome dir ?!?!?!
	#special char fucks up parsing? temp soln of fixing camisim files
	v_dir_cami_genm='/DB/DEPO_demo/demo/camisim/AGORA_smol/genomes'
	v_dir_cami_parm='/DB/DEPO_demo/demo/camisim/AGORA_smol/run_params'
	v_dir_cami_read='/DB/DEPO_demo/demo/camisim/AGORA_smol/reads_sim'
	v_host_contam=( '"Homo sapiens"' '"Bos taurus"' '"Rattus norvegicus"' )
	#check for camisim input taxa file and make if absent
	if [[ ! -f "${v_dir_cami_parm}"/taxa_fix.txt ]];then
	#quoted strings
	#cat /DB/REPO_tool/kraken/taxa2proc_demo_out.txt | cut --fields 4 | sed 's/^/"/;s/$/"/' > "${v_dir_cami_parm}"/taxa_fix.txt
	#drop strain ids sed 's/-[^-]*//2g' file
	cat /DB/REPO_tool/kraken/taxa2proc_demo_out.txt | cut --fields 4 | sed 's/ [^ ]*//2g' | sed 's/^/"/;s/$/"/' > "${v_dir_cami_parm}"/taxa_fix.txt
	#unquoted
	#cat /DB/REPO_tool/kraken/taxa2proc_demo_out.txt | cut --fields 4 | awk '{printf $1}' > "${v_dir_cami_parm}"/taxa_fix.txt
	fi
	mapfile -t v_id_in < <( cat "${v_dir_cami_parm}"/taxa_fix.txt )
	#add host contamination
	v_id_in+=( "${v_host_contam[0]}" )
	printf 'datasets summary taxonomy taxon %s --report ids_only --as-json-lines | dataformat tsv taxonomy --template tax-summary | cut --fields 1,2' "${v_id_in[*]}" \
	> "${v_dir_cami_parm}"/v_id_out
	#datasets summary taxonomy taxon "Abiotrophia defectiva ATCC 49176" --report ids_only --as-json-lines | dataformat tsv taxonomy --template tax-summary | cut --fields 1,2
	#v_id_ncbi=$( bash /DB/DEPO_demo/demo/camisim/AGORA_smol/run_params/v_id_out 2> /DB/DEPO_demo/demo/camisim/AGORA_smol/run_params/v_id_fail | tail -n +2 | cut --fields 2 )
	bash "${v_dir_cami_parm}"/v_id_out 2> "${v_dir_cami_parm}"/v_id_fail | tail -n +2 > "${v_dir_cami_parm}"/v_id_DS
	mapfile -t v_id_ncbi < <( cat "${v_dir_cami_parm}"/v_id_DS | cut --fields 2 )
	mapfile -t v_id_taxa < <( cat "${v_dir_cami_parm}"/v_id_DS | cut --fields 1 )
	#mapfile -t v_id_ncbi < <( bash /DB/DEPO_demo/demo/camisim/AGORA_smol/run_params/v_id_out 2> /DB/DEPO_demo/demo/camisim/AGORA_smol/run_params/v_id_fail | tail -n +2 | cut --fields 2 )
	v_id_taxa=( "${v_id_taxa[@]// /_}" )
	v_len=${#v_id_taxa[@]}
	for (( v_i=0; v_i<${v_len}; v_i++ ));do
		if [ $v_i == 0 ];then
		#fail log
		printf 'genome_ID\tNCBI_ID\tno_attempts\n' > ${v_dir_cami_parm}/log_fail_agora_smol.txt
		v_fail=0
		fi
		printf '\n%s\n' "${v_i}"
		#check and skip if already existing
		printf 'FUNC_DEMO: Checking for previous DL of demo genomes\n'
		if [[ ! -d ${v_dir_cami_genm}/${v_id_taxa[v_i]} ]];then
		printf 'FUNC_DEMO: Genome not found: %s\n' "${v_dir_cami_genm}/${v_id_taxa[v_i]}"
		#pull genome --assembly-source RefSeq/GenBank "--assembly-level" flag: must be 'chromosome', 'complete', 'contig', 'scaffold'
		datasets download genome taxon ${v_id_ncbi[v_i]} --assembly-level complete --assembly-source RefSeq --assembly-version latest \
		--filename ${v_dir_cami_genm}/${v_id_taxa[v_i]}.zip --include genome --reference
		#check success
		if [[ $(ls -l ${v_dir_cami_genm}/${v_id_taxa[v_i]}.zip 2> /dev/null | wc -l) -eq 0 ]];then
			#retry genbank
			v_fail=1
			datasets download genome taxon ${v_id_ncbi[v_i]} --assembly-level complete --assembly-source GenBank --assembly-version latest \
			--filename ${v_dir_cami_genm}/${v_id_taxa[v_i]}.zip --include genome --reference
		fi
		#check success
		if [[ $(ls -l ${v_dir_cami_genm}/${v_id_taxa[v_i]}.zip 2> /dev/null | wc -l) -eq 0 ]];then
			#retry scaffold
			v_fail=2
			datasets download genome taxon ${v_id_ncbi[v_i]} --assembly-level scaffold --assembly-source RefSeq --assembly-version latest \
			--filename ${v_dir_cami_genm}/${v_id_taxa[v_i]}.zip --include genome --reference
		fi
		#check success
		if [[ $(ls -l ${v_dir_cami_genm}/${v_id_taxa[v_i]}.zip 2> /dev/null | wc -l) -eq 0 ]];then
			#retry contig
			v_fail=3
			datasets download genome taxon ${v_id_ncbi[v_i]} --assembly-level contig --assembly-source RefSeq --assembly-version latest \
			--filename ${v_dir_cami_genm}/${v_id_taxa[v_i]}.zip --include genome --reference
		fi
		#check success
		if [[ $(ls -l ${v_dir_cami_genm}/${v_id_taxa[v_i]}.zip 2> /dev/null | wc -l) -eq 0 ]];then
			#retry chromosome
			v_fail=4
			datasets download genome taxon ${v_id_ncbi[v_i]} --assembly-level chromosome --assembly-source RefSeq --assembly-version latest \
			--filename ${v_dir_cami_genm}/${v_id_taxa[v_i]}.zip --include genome --reference
		fi
		#check success
		if [[ $(ls -l ${v_dir_cami_genm}/${v_id_taxa[v_i]}.zip 2> /dev/null | wc -l) -eq 0 ]];then
			#failure -> error
			v_fail=5
			printf '%s\t%s\t%s\n' "${v_id_taxa[v_i]}" "${v_id_ncbi[v_i]}" "${v_fail}" >> ${v_dir_cami_parm}/log_fail_agora_smol.txt
		fi
		if [[ $(ls -l ${v_dir_cami_genm}/${v_id_taxa[v_i]}.zip 2> /dev/null | wc -l) -gt 0 ]];then
			#inflate
			unzip ${v_dir_cami_genm}/${v_id_taxa[v_i]}.zip -d ${v_dir_cami_genm}/${v_id_taxa[v_i]}
			#rm zip
			rm ${v_dir_cami_genm}/${v_id_taxa[v_i]}.zip
		fi
		fi
		#end of PA check
	#pull path - first entry only atm
	v_path=$( ls ${v_dir_cami_genm}/${v_id_taxa[v_i]}/ncbi_dataset/data/*/GCF*_genomic.fna | head -n 1 )
	#compile config files
		if [ $v_i == 0 ];then
		#metadata
		printf 'genome_ID\tOTU\tNCBI_ID\tnovelty_category\n' > ${v_dir_cami_parm}/metadata_agora_smol.tsv
		printf '%s\t%s\t%s\t%s\n' "${v_id_taxa[v_i]}" "${v_i}" "${v_id_ncbi[v_i]}" "known_strain" >> ${v_dir_cami_parm}/metadata_agora_smol.tsv
		#genome_to_id
		printf '%s\t%s\n' "${v_id_taxa[v_i]}" "${v_path}" > ${v_dir_cami_parm}/genome_to_id_agora_smol.tsv
		else
		printf '%s\t%s\t%s\t%s\n' "${v_id_taxa[v_i]}" "${v_i}" "${v_id_ncbi[v_i]}" "known_strain" >> ${v_dir_cami_parm}/metadata_agora_smol.tsv
		printf '%s\t%s\n' "${v_id_taxa[v_i]}" "${v_path}" >> ${v_dir_cami_parm}/genome_to_id_agora_smol.tsv
		fi
	#fi
	#check for empty log and rm if T
		if [ ${v_i} == ${#v_id_taxa[@]} ];then
		if [[ $(cat ${v_dir_cami_parm}/log_fail_agora_smol.txt | wc -l) -eq 1 ]];then
			rm ${v_dir_cami_parm}/log_fail_agora_smol.txt
		fi
		fi
	done
	# set makedb for demo
	#varr_some=('host_kd_hsapcontam' 'tool_k2_demo');BASH_seqc_makedb.sh -s ${varr_some[@]}
	BASH_seqc_makedb.sh -s 'tool_k2_demo' -s 'host_kd_hsapcontam' -s 'tool_ncbi_taxd'
	# run sim
	#generate config_agora.ini - https://stackoverflow.com/questions/17957196/using-variables-in-bash-script-to-set-ini-file-values-while-executing
	#pot use default_config as template
	v_file_config='/DB/DEPO_demo/demo/camisim/AGORA_smol/run_params/config_agora.ini'
	v_confi_tmp='/DB/DEPO_demo/demo/tmp'
	v_confi_lib='/opt/conda/envs/env_util_camisim/lib/camisim/'
	v_confi_run='/DB/DEPO_demo/demo/camisim/AGORA_smol/run_params/'
	v_confi_out='/DB/DEPO_demo/demo/camisim/AGORA_smol/reads_sim'
	v_confi_count=$(cat ${v_confi_run}genome_to_id_agora_smol.tsv | wc -l)
	v_confi_ncbi='/DB/REPO_tool/ncbi_NR'
	v_confi_n=10
	#set delim to tab in attempt to fix script collapse blocking
	cat <<-EOF > ${v_file_config}
		[Main]
		seed=42069
		#0:full 1:only community design 2:start w read sim
		phase=0
		max_processors=$venv_cpu_max
		#default:RL
		dataset_id=AGORA_smol
		output_directory=$v_confi_out
		temp_directory=$v_confi_tmp
		gsa=False
		pooled_gsa=False
		anonymous=True
		compress=1

		[ReadSimulator]
		#readsim=/DB/DEPO_demo/demo/camisim/CAMISIM/tools/art_illumina-2.3.6/art_illumina
		readsim=${v_confi_lib}tools/art_illumina-2.3.6/art_illumina
		#error_profiles=/DB/DEPO_demo/demo/camisim/CAMISIM/tools/art_illumina-2.3.6/profiles
		error_profiles=${v_confi_lib}tools/art_illumina-2.3.6/profiles
		samtools=/opt/conda/envs/env_util_camisim/bin/samtools
		profile=mbarc
		#default0.5
		size=0.5
		type=art
		#default:270,27
		fragments_size_mean=290
		fragment_size_standard_deviation=20

		[CommunityDesign]
		#distribution_file_paths=out/abundance0.tsv,out/abundance1.tsv,out/abundance2.tsv,out/abundance3.tsv,out/abundance4.tsv,out/abundance5.tsv,out/abundance6.tsv,out/abundance7.tsv,out/abundance8.tsv,out/abundance9.tsv
		ncbi_taxdump=$v_confi_ncbi
		#strain_simulation_template=/DB/DEPO_demo/demo/camisim/CAMISIM/scripts/StrainSimulationWrapper/sgEvolver/simulation_dir
		strain_simulation_template=${v_confi_lib}scripts/StrainSimulationWrapper/sgEvolver/simulation_dir
		number_of_samples=$v_confi_n

		[community0]
		metadata=${v_confi_run}metadata_agora_smol.tsv
		id_to_genome_file=${v_confi_run}genome_to_id_agora_smol.tsv
		id_to_gff_file=
		genomes_total=$v_confi_count
		num_real_genomes=$v_confi_count
		max_strains_per_otu=1
		ratio=1
		mode=differential
		log_mu=1
		log_sigma=2
		gauss_mu=1
		gauss_sigma=1
		view=False
		EOF
	#C2024-06-28 15:32:06 ERROR: [MetagenomeSimulationPipeline]  in line 117 GBP=1
	micromamba run -n env_util_camisim python /opt/conda/envs/env_util_camisim/lib/camisim/metagenomesimulation.py \
	/DB/DEPO_demo/demo/camisim/AGORA_smol/run_params/config_agora.ini
	#split into fwd/rev
	v_id_dir=( "_sample_" "2024.06.26_17.11.42_sample_" "2024.06.23_21.35.44_sample_" )
	v_len=$( ls -1 "${v_dir_cami_read}"/"${v_id_dir[0]}"*/reads/anonymous_reads.fq.gz | wc -l )
	for (( v_i=0; v_i<${v_len}; v_i++ ));do
		v_sample=$( printf '%s/%s%s/reads/anonymous_reads.fq.gz\n' "${v_dir_cami_read}" "${v_id_dir}" "${v_i}" )
		micromamba run -n env_util_seqkit seqkit split "${v_sample}" -i --id-regexp "([0-9])$" --by-id-prefix camisim_agora_smol_s"${v_i}"_ --out-dir "${v_dir_cami_read}"
	done
	#run qc with kneaddata
	# cat-final is not mergering!
	#agora simulation
	#tmp adj v_dir_cami_read='/DB/DEPO_demo/demo/camisim/AGORA_smol/reads_sim/gbp_05'
	v_len=$( ls -1 "${v_dir_cami_read}"/camisim_agora_smol_s*_1.fq.gz | wc -l )
	for (( v_i=0; v_i<${v_len}; v_i++ ));do
		micromamba run -n env_s1_kneaddata kneaddata \
		--remove-intermediate-output \
		--input1 "${v_dir_cami_read}"/camisim_agora_smol_s"${v_i}"_1.fq.gz \
		--input2 "${v_dir_cami_read}"/camisim_agora_smol_s"${v_i}"_2.fq.gz \
		--output ${v_dir_db}/DEPO_demo/demo/step1_kneaddata --reference-db /DB/REPO_host/hsap_contam/bowtie2/ \
		--threads ${venv_cpu_max} --max-memory 200g --cat-final-output \
		#--trimmomatic-options "ILLUMINACLIP:/data/adapters/TruSeq3-PE.fa:2:30:10: SLIDINGWINDOW:4:20 MINLEN:50" \
		--trimmomatic /opt/conda/envs/env_s1_kneaddata/share/trimmomatic --reorder
	done
	#Branch to short read assignment
	if [[ "${vopt_branch}" = "SR" ]] || [[ "${vopt_branch}" = "ALL" ]];then
		#Kraken
		v_dir_in='/DB/DEPO_demo/demo/step1_kneaddata'
		v_dir_out='/DB/DEPO_demo/demo/step4_kraken'
		var_path_db='/DB/REPO_tool/kraken/kdb_std8'
		var_path_db='/DB/REPO_tool/kraken/kdb_agora'
		var_path_db='/DB/REPO_tool/kraken/kdb_a2a'
		#ar_max_cpu=48
		mkdir "${v_dir_out}"
		v_len=$( ls -1 "${v_dir_in}"/camisim_agora_smol_s*_1_kneaddata.fastq | wc -l )
		for (( v_i=0; v_i<${v_len}; v_i++ ));do
		v_nom=( "${v_dir_in}"/camisim_agora_smol_s"${v_i}"_1_kneaddata.fastq )
		v_nom="${v_nom/#*\/}" && v_nom="${v_nom/%.fastq}"
		micromamba run -n env_s4_kraken kraken2 --db ${var_path_db} --threads ${var_max_cpu} \
		--unclassified-out "${v_dir_out}"/"${v_nom}"_k2_unclassed#.fq \
		--classified-out "${v_dir_out}"/"${v_nom}"_k2_classed#.fq \
		--output "${v_dir_out}"/"${v_nom}"_k2_out.txt --confidence 0.1 \
		--report "${v_dir_out}"/"${v_nom}"_k2_report.txt --report-minimizer-data \
		--paired "${v_dir_in}"/camisim_agora_smol_s"${v_i}"_1_kneaddata_paired_1.fastq \
		"${v_dir_in}"/camisim_agora_smol_s"${v_i}"_1_kneaddata_paired_2.fastq
		#mpa style - prob not needed
		micromamba run -n env_s4_kraken kraken2 --db ${var_path_db} --threads ${var_max_cpu} \
		--unclassified-out "${v_dir_out}"/"${v_nom}"_k2_unclassed#.fq \
		--classified-out "${v_dir_out}"/"${v_nom}"_k2_classed#.fq \
		--output "${v_dir_out}"/"${v_nom}"_k2_out_MPA.txt --confidence 0.1 \
		--report "${v_dir_out}"/"${v_nom}"_k2_report_MPA.txt --report-minimizer-data --use-mpa-style \
		--paired "${v_dir_in}"/camisim_agora_smol_s"${v_i}"_1_kneaddata_paired_1.fastq \
		"${v_dir_in}"/camisim_agora_smol_s"${v_i}"_1_kneaddata_paired_2.fastq
		done
		#Bracken
		v_dir_in='/DB/DEPO_demo/demo/step4_kraken'
		v_dir_out='/DB/DEPO_demo/demo/step4_kraken'
		var_path_db='/DB/REPO_tool/kraken/kdb_std8'
		var_path_db='/DB/REPO_tool/kraken/kdb_agora'
		var_path_db='/DB/REPO_tool/kraken/kdb_a2a'
		#var_max_cpu=48
		#mkdir "${v_dir_out}"
		v_len=$( ls -1 "${v_dir_in}"/camisim_agora_smol_s*_1_kneaddata_k2_report.txt | wc -l )
		for (( v_i=0; v_i<${v_len}; v_i++ ));do
		v_nom=( "${v_dir_in}"/camisim_agora_smol_s"${v_i}"_1_kneaddata_k2_report.txt )
		v_nom="${v_nom/#*\/}" && v_nom="${v_nom/%_1_kneaddata_k2_report.txt}"
		micromamba run -n env_s4_kraken bracken -d ${var_path_db} -t ${var_max_cpu} \
		-i "${v_dir_out}"/"${v_nom}"_1_kneaddata_k2_report.txt \
		-o "${v_dir_out}"/"${v_nom}"_S_bracken_out.txt -r 150 -l S
		done
		#combine bracken out
		mapfile -t varr_kjoin_in < <(printf '%s\n' $(ls "${v_dir_out}"/*_S_bracken_out.txt) )
		v_kjoin_out=/DB/DEPO_demo/demo/step4_kraken/kbrak_S_out.txt
		v_col_nom=("${varr_kjoin_in[@]/%_S_bracken_out.txt/}") && v_col_nom=("${v_col_nom[*]/#*\/}") && v_col_nom="${v_col_nom[*]// /,}"
		micromamba run -n env_s4_kraken combine_bracken_outputs.py \
		--files ${varr_kjoin_in[*]} --output ${v_kjoin_out} --names ${v_col_nom}
		#relocate to final output dir
		mv ${v_kjoin_out} "${v_dir_main_out}"
		if (( ${v_BLOCK} ));then
		#krakentools - way busted
		#convert to mpa prior to join
		mapfile -t varr_kjoin_in < <(printf '%s\n' $(ls "${v_dir_out}"/*_S_bracken_out.txt) )
		for v_i in "${!varr_kjoin_in[@]}";do
			v_out="${varr_kjoin_in[v_i]/bracken_out.txt/mpa.txt}"
			printf '%s\n' "${v_out}"
			micromamba run -n env_s4_kraken kreport2mpa.py -r "${varr_kjoin_in[v_i]}" -o ${v_out}
		done
		#combine output
		mapfile -t varr_kjoin_in < <(printf '%s\n' $(ls "${v_dir_out}"/*_S_mpa.txt) )
		v_kjoin_out=/DB/DEPO_demo/demo/step4_kraken/kbrak_S_out.txt
		fi
		#EoBLOCK
		#convert to mars input
	fi #EoBranch - short read
}
#EoFunc - demo
fi #EoCHECK = 0
# read options
if [[ ${v_scrp_check} -eq 1 ]];then
# Passing valid run flags enables logging AND script progression with vopt_log=1
# Generate flag based array out for log
	vopt_loger[0]=''
# Check for preexisting log via status file
# Perform checks/soln for multiple status files here
# TODO - Search for corresponding logs via run ID CONFIG:FS:run_ID:FS:MAG552
	vt_L=$( find "${venv_dir_proc}/logs" -name 'log_*_status.txt' 2> /dev/null | wc -l )
	if [[ ${vt_L} -gt 0 ]];then
		vopt_status=1
		v_stat_build=0
		v_logfile_status=$( find "${venv_dir_proc}/logs" -name 'log_*_status.txt' 2> /dev/null )
		# Pull variables from status file - TODO improve approach
		v_logfile=$(func_status_adj "get" "${v_logfile_status}" "ITEM" "run_log_file")
		v_logfile_ref=$(func_status_adj "get" "${v_logfile_status}" "ITEM" "run_ref_file")
		v_logfile_dbug=$(func_status_adj "get" "${v_logfile_status}" "ITEM" "run_bug_file")
		# Check if log exists
		[[ -f ${v_logfile} ]] && v_log_build=0 || v_log_build=1
		[[ -f ${v_logfile_ref} ]] && v_ref_build=0 || v_ref_build=1
		[[ -f ${v_logfile_dbug} ]] && v_bug_build=0 || v_bug_build=1
	else
		v_log_build=1
		v_ref_build=1
		v_bug_build=1
		v_stat_build=1
	fi
	OPTSTRING=":hvbi:o:c:e:t:n:u:p:ks:d:r:012"
	while getopts ${OPTSTRING} opt; do
		case ${opt} in
		h)
			func_help
			exit 0
			;;
		v)
			printf 'SeqC AS Flux pipeline - Version - %s\n' "${v_version}"
			exit 0
			;;
		b)
			echo "Option -b was triggered and DEBUG will be enabled"
			#run through gate if vopt_dbug=1: if (( ${vopt_dbug} ));then
			vopt_dbug=1
			vopt_log=1
			vopt_loger[${#vopt_loger[@]}]='-b debug=ON'
			if (( ${v_bug_build} ));then
			#create debug section of log
				v_logdate=$(date +"%Y%m%d")
				v_logfile_dbug=${v_logfile/.txt/_${v_logdate}_dbug.txt}
				v_log_head='# DEBUG Section'
				printf '%s\n%s\n%s\n' "${v_logblock0}" "${v_log_head}" "${v_logblock0}" > ${v_logfile_dbug}
			fi
			;;
		i)
		# Input directory
		# Drop trailing slash
			vopt_dir_I=${OPTARG/%\/}
			if ((vopt_dbug));then
			printf 'FUNC_MAMA_HELP_DBUG(LINE%s): input directory provided: %s\n' "${LINENO}" "${vopt_dir_I}" >> ${v_logfile_dbug}
			fi
			vopt_loger[${#vopt_loger[@]}]='-i '${vopt_dir_I}
			vopt_log=1
			;;
		o)
		# Output directory
		# Drop trailing slash
			vopt_dir_O=${OPTARG/%\/}
			if ((vopt_dbug));then
			printf 'FUNC_MAMA_HELP_DBUG(LINE%s): output directory provided: %s\n' "${LINENO}" "${vopt_dir_O}" >> ${v_logfile_dbug}
			fi
			vopt_loger[${#vopt_loger[@]}]='-o '${vopt_dir_O}
			vopt_log=1
			;;
		c)
			#if empty then default triggered
			vopt_com_log=1
			vopt_com=${OPTARG}
			if ((vopt_dbug));then
			printf 'FUNC_MAMA_HELP_DBUG(LINE%s): commands provided: %s\n' "${LINENO}" "${vopt_com}" >> ${v_logfile_dbug}
			fi
			vopt_loger[${#vopt_loger[@]}]='-c DEFAULT'
			vopt_log=1
			;;
		e)
		# head string
		# may needs to modify for full embrace of regex approach - same with tail
			vopt_head_log=1
			vopt_head=${OPTARG}
			if ((vopt_dbug));then
			printf 'FUNC_MAMA_HELP_DBUG(LINE%s): file name HEAD provided: %s\n' "${LINENO}" "${vopt_head}" >> ${v_logfile_dbug}
			fi
			vopt_loger[${#vopt_loger[@]}]='-e '${vopt_head}
			vopt_log=1
			;;
		t)
		# tail string
			vopt_tail_log=1
			vopt_tail=${OPTARG}
			if ((vopt_dbug));then
			printf 'FUNC_MAMA_HELP_DBUG(LINE%s): file name TAIL provided: %s\n' "${LINENO}" "${vopt_tail}" >> ${v_logfile_dbug}
			fi
			vopt_loger[${#vopt_loger[@]}]='-t '${vopt_tail}
			vopt_log=1
			;;
		n)
			# name file
			vopt_name=${OPTARG}
			if ((vopt_dbug));then
			printf 'FUNC_MAMA_HELP_DBUG(LINE%s): file name FILE provided: %s\n' "${LINENO}" "${vopt_name}" >> ${v_logfile_dbug}
			fi
			# basic check for file
			if [[ ! -f ${vopt_name} ]];then
				vq_name="$vopt_name"
				vq_dir=("." "step0_data_in" "final_reports")
				vopt_name=$(func_file_find "$vq_name" "${vq_dir[@]}")
				if [[ ! -f ${vopt_name} ]];then
			# TODO: implement fix if file missing
					if ((vopt_dbug));then
					printf 'FUNC_MAMA_HELP_DBUG(LINE%s): file name FILE missing: %s\n' "${LINENO}" "${vopt_name}" >> ${v_logfile_dbug}
					printf 'FUNC_MAMA_HELP_DBUG(LINE%s): EXITING\n' "${LINENO}" >> ${v_logfile_dbug}
					fi
					exit 1
				fi
			fi
			#with v long name list vopt log will be ugly as fuck - tmp fix with pos...make more robust
			mapfile -t v_tmp_nom < <( cat "${vopt_name}" )
			#apply steps and record array index for overwrite if req
			vopt_pos_name=${#vopt_loger[@]}
			if [[ ${#v_tmp_nom[@]} -le 10 ]];then
				vopt_loger[${#vopt_loger[@]}]='-n '${v_tmp_nom[*]}
			else
				vopt_loger[${#vopt_loger[@]}]='-n ('${#v_tmp_nom[@]}' entries from:'${vopt_name}')'
			fi
			vopt_log=1
			;;
		u)
			# micromamba env
			vopt_env=${OPTARG}
			if ((vopt_dbug));then
			printf 'FUNC_MAMA_HELP_DBUG(LINE%s): Check if uMamba env is cool: %s\n' "${LINENO}" "${vopt_env}" >> ${v_logfile_dbug}
			fi
			vopt_loger[${#vopt_loger[@]}]='-u '${vopt_env}
			vopt_log=1
			;;
		r)
			# Branch - if flag then gen steps - redunt 
			if [[ ${OPTARG} = "SR" ]] || [[ ${OPTARG} = "MAG" ]] || [[ ${OPTARG} = "ALL" ]];then
				vopt_branch=${OPTARG}
			else
				vopt_branch='ALL'
			fi
			if ((vopt_dbug));then
				printf 'FUNC_MAMA_HELP_DBUG(LINE%s): Running pipeline - branch:%s\n' "${LINENO}" "${vopt_branch}" >> ${v_logfile_dbug}
			fi
			vopt_loger[${#vopt_loger[@]}]='-r '${vopt_branch}
			#apply steps and record array index for overwrite if req
			#vopt_pos_step=${#vopt_loger[@]}
			#vopt_loger[${#vopt_loger[@]}]='-s '${vopt_step[*]}
			vopt_log=1
			;;
		p)
			#if empty then default triggered
			vopt_pac_log=1
			vopt_pac=${OPTARG}
			((vopt_dbug)) && printf 'FUNC_MAMA_HELP_DBUG(LINE%s): Check if package is cool: %s\n' "${LINENO}" "${vopt_pac}" >> ${v_logfile_dbug}
			vopt_loger[${#vopt_loger[@]}]='-p '${vopt_pac}
			vopt_log=1
			;;
		s)
			# Steps
			if [[ ${OPTARG} -eq 0 ]];then
			# if 0 then convert to array with all steps according to branch
				vopt_part=0
				if [[ ${vopt_branch} = 'SR' ]];then
					vopt_step=( {1..3} )
				fi
				if [[ ${vopt_branch} = 'ALL' ]];then
					vopt_step=( $( eval echo {1..6} ) )
				fi
			else
				#vopt_step=${OPTARG}
				vopt_step+=("$OPTARG")
				vopt_part=1
			fi
			((vopt_dbug)) && printf 'FUNC_MAMA_HELP_DBUG(LINE%s): Steps being run are: %s\n' "${LINENO}" "${vopt_step[*]}" >> ${v_logfile_dbug}
			#overwrite on pos if made with branch flag
			vopt_loger[${vopt_pos_step}]='-s '${vopt_step[*]}
			vopt_log=1
			;;
		d)
			# Datebases take multiple with additional -d flags
			printf 'Database option selected: %s\n' "${OPTARG}"
			vopt_loger[${#vopt_loger[@]}]='-d '${OPTARG}
			vopt_db+=("$OPTARG")
			vopt_db_log=1
			vopt_log=1
			;;
		k)
			# keep intermediary data
			vopt_keep=1
			if ((vopt_dbug));then
			printf 'FUNC_MAMA_HELP_DBUG(LINE%s): Keeping all intermediary data(vopt_keep: %s)\n' "${LINENO}" "${vopt_keep}" >> ${v_logfile_dbug}
			fi
			vopt_log=1
			;;
		0)
			# Checks formerly -k
			vopt_check_log=1
			if ((vopt_dbug));then
			printf 'FUNC_MAMA_HELP_DBUG(LINE%s): Perfmorming checks: %s\n' "${LINENO}" "${vopt_check_log}" >> ${v_logfile_dbug}
			fi
			vopt_log=1
			;;
		1)
			# secret option to run dumb demo
			func_demo ${vopt_branch}
			exit 1
			;;
		2)
			# secret option to envoke splash page
			func_splash
			source /etc/environment
			source /root/.bashrc
			exit 1
			;;
		:)
			echo "Option -${OPTARG} requires an argument."
			exit 1
			;;
		?)
			echo "Invalid option: -${OPTARG}."
			func_help
			exit 1
			;;
		esac
	done
  	shift $((OPTIND -1))
	# check and switch error output to dbug log
	(( ${vopt_dbug} )) && v_dir_err=${v_logfile_dbug} || v_dir_err='/dev/null'
	#generate step array if unspecified and branch provided
	if (( ${vopt_log} ));then
		if [[ -z ${vopt_step} ]];then
			if [[ ${vopt_branch} = 'SR' ]];then
				vopt_step=( {1..3} )
			fi
			if [[ ${vopt_branch} = 'ALL' ]];then
				vopt_step=( $( eval echo {1..6} ) )
			fi
			if ((vopt_dbug));then
				printf 'FUNC_MAMA_HELP_DBUG(LINE%s): Step unspecified and created according to branch: %s step: %s\n' "${LINENO}" "${vopt_branch}" "${vopt_step[*]}" >> ${v_logfile_dbug}
			fi
			#apply steps and record array index for overwrite if req
			vopt_pos_step=${#vopt_loger[@]}
			vopt_loger[${#vopt_loger[@]}]='-s '${vopt_step[*]}
		fi
		if (( ! ${vopt_pac_log} ));then
		# complete list per branch
			vopt_pac[0]=''
			if [[ ${vopt_branch} = 'SR' ]];then
				vref_pac=( '' 'kneaddata' 'kraken' 'mars' )
				vref_pac1='kneaddata'
				vref_pac2='kraken'
				vref_pac3='mars'
			fi
			if [[ ${vopt_branch} = 'ALL' ]];then
				vref_pac=( '' 'kneaddata' 'kraken' 'mars' )
				vref_pac1='kneaddata'
				vref_pac2='kraken'
				vref_pac3='mars'
			fi
			# create package list if none specified, linking to steps and branch
			# This is broken for multiple packs per step
			for vi in "${vopt_step[@]}"; do
				vref_nom="vref_pac${vi}"
				eval 'ref_array=("${'"$vref_nom"'[@]}")'
				for vii in "${ref_array[@]}"; do
					vopt_pac+=("$vii")
				done
			done
			if ((vopt_dbug));then
				printf 'FUNC_MAMA_HELP_DBUG(LINE%s): Packages unspecified and created according to branch and step\n\tbranch: %s step: %s pack: %s\n' "${LINENO}" "${vopt_branch}" "${vopt_step[*]}" "${vopt_pac[*]}" >> ${v_logfile_dbug}
			fi
			#remove empty levels
			vopt_pac=(${vopt_pac[@]})
			#block repeat with successful pac
			vopt_pac_log=1
		fi
	fi
fi #EoCHECK=1
if [[ ${vopt_check_log} -eq 1 ]];then
func_check
fi
# BEGIN build log files
if (( ${vopt_log} ));then
# TODO: system info, aprox runtime, elaborate for cases of long good/bad files
# history pull: v_com_log=$( history | tail -n 1 | awk '{$1=""; print substr($0,2)}' )
	# PRIMARY LOG
	if (( ${v_log_build} ));then
		#retain initial log file and overwrite variable with run specific log
		v_logdate=$(date +"%Y%m%d")
		cp ${v_logfile} ${v_logfile/.txt/_${v_logdate}.txt}
		v_logfile_base=${v_logfile}
		v_logfile=${v_logfile/.txt/_${v_logdate}.txt}
		rm ${v_logfile_base}
		# write pulled entered command
		printf 'Initial command provided for run: BASH_seqc_mama.sh %s\n' "${v_com_log}" >> ${v_logfile}
		printf 'Flag options:\n%s\n%s\n' "${vopt_loger[*]}" "${v_logblock1}" >> ${v_logfile}
		# input file name report
		if (( ! ${vopt_head_log} ));then vopt_head='*';fi
		if (( ! ${vopt_tail_log} ));then vopt_tail='*';fi
		# Check for user defined input dir
		if [[ -z ${vopt_dir_I} ]];then
			# if absent make default
			vin_I_dir=${v_dir_work}'/step0_data_in'
		else
			# if present make user input
			vin_I_dir=${vopt_dir_I}
		fi
		#breaks with -n = proc file eg MARS - diuvert 
		# IMPROVE
		if [[ ${vopt_pac} = 'mars' ]];then
			v_print_head='Running MARS from a previously generated taxonomic profile:'
			v_file_in_good='THIS SHOULD BE MORE ROBUST :3'
			printf '%s\n%s\n%s\n' "${v_print_head}" "${v_file_in_good[@]}" "${v_logblock1}" >> ${v_logfile}
			#file count
			v_runID_count=1
		else
			mapfile -t v_file_in_base < <( printf '%s\n' "$( <${vopt_name} )" )
			mapfile -t v_file_in_base < <( printf '%s\n' "${v_file_in_base[@]}" | sort )
			# uniq for final refine against bad
			mapfile -t v_file_in_uniq < <( printf '%s\n' "${v_file_in_base[@]}" | uniq )
			mapfile -t v_file_in_base < <( printf '%s\n' "${v_file_in_base[@]/#/${vopt_head}}" )
			mapfile -t v_file_in_base < <( printf '%s\n' "${v_file_in_base[@]/%/${vopt_tail}}" )
			mapfile -t v_file_in_good < <( find $( printf '%s\n' "${v_file_in_base[@]/#/${vin_I_dir}/}" ) -maxdepth 0 -type f 2> /tmp/file_in_bad )
			mapfile -t v_file_in_bad < <( printf '%s\n' "$(< /tmp/file_in_bad)" )
			# clean bad
			# remove head
			mapfile -t v_file_in_bad < <( printf '%s\n' "${v_file_in_bad[@]/"${vopt_head}"/__RM__}" )
			mapfile -t v_file_in_bad < <( printf '%s\n' "${v_file_in_bad[@]/#*__RM__/}" )
			# remove tail
			mapfile -t v_file_in_bad < <( printf '%s\n' "${v_file_in_bad[@]/"${vopt_tail}"/__RM__}" )
			mapfile -t v_file_in_bad < <( printf '%s\n' "${v_file_in_bad[@]/__RM__*/}" )
			#counts
			v_count_base=$( printf '%s\n' "$( <${vopt_name} )" | wc -l )
			v_count_uniq=$( printf '%s\n' "$( <${vopt_name} )" | sort | uniq | wc -l )
			v_count_dupe=$( printf '%s\n' "$( <${vopt_name} )" | sort | uniq -d | wc -l )
			v_count_good=$( printf '%s\n' "${v_file_in_good[@]}" | wc -l )
			#check if empty
			if [[ -z ${v_file_in_bad[@]} ]];then
				v_count_bad=0
			else
				v_count_bad=$( printf '%s\n' "${v_file_in_bad[@]}" | wc -l )
			fi
			# add to log
			printf 'File info: Sample ID (total):%s Sample ID (unique):%s Files (good):%s Unmatched IDs (bad):%s\n' "${v_count_base}" "${v_count_uniq}" "${v_count_good}" "${v_count_bad}" >> ${v_logfile}
			#retain dupe if >0 and log
			# expand approach to parse situation and dictate logging via relation of count vars
			if [[ ${v_count_dupe} -gt 0 ]];then
				v_file_in_dupe=$( printf '%s\n' "$( <${vopt_name} )" | sort | uniq -d )
				v_print_head='Duplicated IDs from ID file:'
				printf '%s\n%s\n%s\n' "${v_print_head}" "${v_file_in_dupe[@]}" "${v_logblock1}" >> ${v_logfile}
			fi
			v_print_head='Files included in processing (found matching ID):'
			printf '%s\n%s\n%s\n' "${v_print_head}" "$( printf '%s\n' "${v_file_in_good[@]}" )" "${v_logblock1}" >> ${v_logfile}
			if [[ ${v_count_bad} -gt 0 ]];then
				v_print_head='Files excluded in processing (missing or unmatched):'
				printf '%s\n%s\n%s\n' "${v_print_head}" "$( printf '%s\n' "${v_file_in_bad[@]}" )" "${v_logblock1}" >> ${v_logfile}
			else
				v_print_head='Files excluded in processing (missing or unmatched): 0! (BD)'
				printf '%s\n%s\n' "${v_print_head}" "${v_logblock1}" >> ${v_logfile}
			fi
			# Transfer variables retaining good - sort good/base - remove bad elements
			# CRIT add check to confirm transfer wc=/=wc etc
			# pot use: comm -2 -3 <(sort f1) <(sort f2) via:https://stackoverflow.com/questions/4780203/deleting-lines-from-one-file-which-are-in-another-file 
			# create txt of valid IDs
			comm -2 -3 <( printf '%s\n' "${v_file_in_uniq[@]}" ) <( printf '%s\n' "${v_file_in_bad[@]}" | uniq ) \
			> ${vopt_name/%\.*/_good.txt}
			# log
			v_print_head='ID abnormalities detected and corrected in provided name file:'
			printf '%s\n%s\n%s\n%s\n' "${v_print_head}" "(old XP) ${vopt_name}" "(NEW BD) ${vopt_name/%\.*/_good.txt}" "${v_logblock1}" >> ${v_logfile}
			# redirect var to new file
			vopt_name=${vopt_name/%\.*/_good.txt}
			# Determine multiplicity - if input is paired or joined
			# use to define steps accepting paired/single inputs - kneaddata, krak, spades
			vt_L=$( printf '%s\n' "$(< ${vopt_name[@]} )" | wc -l )
			# count for run id build
			v_runID_count=${vt_L}
			vt_R="${#v_file_in_good[@]}"
			if [[ ${vt_L} -eq ${vt_R} ]];then
				#single file per ID
				vopt_file_type='single'
			fi
			vt_L=$(( ${vt_L} * 2 ))
			if [[ ${vt_L} -eq ${vt_R} ]];then
				#paired file per ID
				vopt_file_type='paired'
			fi
			printf 'Input file type: %s\n%s\n' "${vopt_file_type}" "${v_logblock1}" >> ${v_logfile}
			# Check zip status - CRIT - extend to .tar files in dir
			#	pot. just exclude .tar
			vt_L=$( printf '%s\n' "${v_file_in_good[@]}" | grep -E "\.gz|gzip$" | wc -l )
			vt_R='0'
			if [[ ${vt_L} -gt ${vt_R} ]];then
				unpigz $( printf '%s\n' "${v_file_in_good[@]}" | grep -E "\.gz|gzip$" )
				# correct array for unzipped files
				# Sophisticate with better regex etc
				mapfile -t v_file_in_good < <( printf '%s\n' "${v_file_in_good[@]/.gz/}")
				mapfile -t v_file_in_good < <( printf '%s\n' "${v_file_in_good[@]/.gzip/}")
			fi
			# Check extension
			vt_L=$( printf '%s\n' "${v_file_in_good[@]}" | grep -o "\..*$" | uniq | wc -l )
			vt_R='1'
			vt_ext=$( printf '%s\n' "${v_file_in_good[@]}" | grep -o "\..*$" | uniq )
			if [[ ${vt_L} -gt ${vt_R} ]];then
				printf 'File extension UNdetermined: %s\n%s\n' "${vt_ext}" "${v_logblock1}" >> ${v_logfile}
			fi
			if [[ ${vt_L} -eq ${vt_R} ]];then
				printf 'File extension determined: %s\n%s\n' "${vt_ext}" "${v_logblock1}" >> ${v_logfile}
				# find variable region between ID and extension
				mapfile -t vt_ID < <( printf '%s\n' "$(< ${vopt_name[@]} )" )
				# pull first id/files
				mapfile -t vt_MID < <( printf '%s\n' "${v_file_in_good[@]}" | grep -E ${vt_ID[0]} )
				# remove head
				mapfile -t vt_MID < <( printf '%s\n' "${vt_MID[@]/"${vt_ID[0]}"/__RM__}" )
				mapfile -t vt_MID < <( printf '%s\n' "${vt_MID[@]/#*__RM__/}" )
				# remove tail
				mapfile -t vt_MID < <( printf '%s\n' "${vt_MID[@]/"${vt_ext}"/__RM__}" )
				mapfile -t vt_MID < <( printf '%s\n' "${vt_MID[@]/__RM__*/}" )
				printf 'File spacer determined(ID***.extension): %s\n%s\n' "${vt_MID[*]}" "${v_logblock1}" >> ${v_logfile}
				# swap to opt variable and add blank to mid
				mapfile -t vopt_mid < <( printf '\n' && printf '%s\n' "${vt_MID[@]}" )
				vopt_ext=${vt_ext[0]}
			fi
		fi
	fi
	# REFERENCE LOG
	if (( ${v_ref_build} ));then
		# build refs
		# CHECK if specifying single step results in correct corresponding vopt_pac
		# repeating ref gen
		v_logfile_ref="${v_logfile/.txt/_ref.txt}"
		if [[ ${vopt_branch} = 'SR' ]];then
			if (( ${vopt_part} ));then
				func_ref "seqc" > ${v_logfile_ref}
				for vi in ${vopt_step[@]};do
					[[ ${vi} -eq 1 ]] && func_ref "kneaddata" >> ${v_logfile_ref}
					[[ ${vi} -eq 2 ]] && func_ref "kraken" >> ${v_logfile_ref}
					[[ ${vi} -eq 3 ]] && func_ref "mars" >> ${v_logfile_ref}
				done
			else
				func_ref "SR" > ${v_logfile_ref}
			fi
		fi
		if [[ ${vopt_branch} = 'ALL' ]];then
			if (( ${vopt_part} ));then
				func_ref "seqc" > ${v_logfile_ref}
				for vi in ${vopt_step[@]};do
					[[ ${vi} -eq 1 ]] && func_ref "kneaddata" >> ${v_logfile_ref}
					[[ ${vi} -eq 2 ]] && func_ref "kraken" >> ${v_logfile_ref}
					[[ ${vi} -eq 3 ]] && func_ref "mars" >> ${v_logfile_ref}
				done
			else
				func_ref "ALL" > ${v_logfile_ref}
			fi
		fi
	fi
	# STATUS LOG
	# BEGIN Check and build of run status file
	# Check for status files
	if (( ${v_stat_build} ));then
		vopt_status=1
		# runID: runID=<vopt_branch><step len><final step><n samples>: vtesty=SR${#vtest[@]}${vtest[${#vtest[@]}-1]}n12
		v_runID=${vopt_branch}${#vopt_step[@]}${vopt_step[${#vopt_step[@]}-1]}${v_runID_count}
		# runID (updated): runID=<vopt_branch><v_rand_str>
		v_rand_str=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 3)
		v_runID=${vopt_branch}${v_rand_str}
		# create status log file var with value: log_<v_proj><log_date>_status.txt: log_seqc_project_20250320_status.txt
		#type/entry/value
		v_logfile_status="${v_logfile/.txt/_status.txt}"
		printf 'status_type:FS:status_variable:FS:status_value\n' > ${v_logfile_status}
		func_log "3" "CONFIG" "run_ID" "${v_runID}"
		func_log "3" "CONFIG" "file_type" "${vopt_file_type}"
		func_log "3" "CONFIG" "file_str_mid0" "${vopt_mid[0]}"
		func_log "3" "CONFIG" "file_str_mid1" "${vopt_mid[1]}"
		func_log "3" "CONFIG" "file_str_mid2" "${vopt_mid[2]}"
		func_log "3" "CONFIG" "file_str_ext" "${vopt_ext}"
		func_log "3" "CONFIG" "run_ENV" "NULL"
		func_log "3" "CONFIG" "run_PAC" "NULL"
		# CONTINUE TRANSFER OF CONTENT FROM LOG BLOCK
		func_log "3" "ITEM" "run_log_file" "${v_logfile}"
		func_log "3" "ITEM" "run_ref_file" "${v_logfile_ref}"
		func_log "3" "ITEM" "run_bug_file" "${v_logfile_dbug}"
		func_log "3" "ITEM" "run_sample_file" "${vopt_name}"
		func_log "3" "PATH" "proc_PATH" "NULL"
		for vi in "${vopt_step[@]}";do func_log "3" "PATH" $(printf 'step%s_PATH' "$vi") "NULL";done
		# control final exit proc with run_status TODO: set value as current step, when stepx of x done and good, set value DONE, granting exit proc
		func_log "3" "STATE" "run_status" "PENDING"
		for vi in "${vopt_step[@]}";do func_log "3" "STATE" $(printf 'step%s' "$vi") "PENDING";done
		# build status index for sample
		for vi in "${vopt_step[@]}";do v_start_index=$v_start_index'0';done
		# set sample index FID__<ID><000> where 0 is pending/error and 1 is complete and - is NA
		for vi in $( cat ${vopt_name} );do func_log "3" "STATE_FID" $vi "${v_start_index}";done
		# pull entry for assessment
		# grep -E 'STATE' /DB/DEPO_proc/logs/log_seqc_project_20250424_status.txt | sed "s/:FS:/:/g"| cut -d ':' --fields 3
		# with func_status_step
		#update status
		#vtar1='proc_PATH';vtar2='NULL';vrep1=$vtar1;vrep2='kitty';sed -i "s/$vtar1:FS:$vtar2/$vrep1:FS:$vrep2/g" $v_logfile_status
	# Perform variable config according to status file for following run
	fi # END run status file
fi # END of initial log and log check
# BEGIN steps
if (( ${vopt_log} ));then
	printf 'SeqC Stuff BEGINS @: %s\n' "$(date +"%Y.%m.%d %H.%M.%S (%Z)")"
	# Check and pull of databases for run
	# TODO - status approach to store and bypass check for restart
	vin_path_db[0]='/DB'
	for istep in "${vopt_step[@]}";do
		if [[ ${istep} -eq 1 ]];then
		#Kneaddata
		# if unspecified then default
			if [[ ${vopt_db_log} -eq 0 ]];then
				vopt_db='host_kd_hsapcontam'
			else
				#cycle and check for valid option
				if [[ "${vopt_db[@]}" =~ "host_kd_hsapcontam" ]] || [[ "${vopt_db[@]}" =~ "host_kd_hsap" ]];then
					printf 'Valid option for step detected\n' >> ${v_logfile}
				else
				# apply default
					vopt_db+=('host_kd_hsapcontam')
				fi
			fi
			for idb in "${vopt_db[@]}";do
				if [[ ${idb} = 'host_kd_hsapcontam' ]];then
				#TODO perform check - sophisticate with check fun
					vin_path_db[1]=${vin_path_db[0]}'/REPO_host/hsap_contam/bowtie2'
					vin_host_rm='/DB/REPO_host/hsap_contam/bowtie2'
					if [[ $(ls -1 "${vin_path_db[1]}"/*.bt2 2>/dev/null | wc -l) -lt 6 ]];then
						printf 'FUNC_CHECK: DB: %s not found, installing...\n' "${idb}" >> ${v_logfile}
						BASH_seqc_makedb.sh -s 'host_kd_hsapcontam'
					fi
					# Confirm DL
					if [[ $(ls -1 "${vin_path_db[1]}"/*.bt2 2>/dev/null | wc -l) -lt 6 ]];then
						printf 'FUNC_CHECK:CRITICAL ERROR: DB: %s not installed...\n' "${idb}" >> ${v_logfile}
						exit 1
					fi
				fi
			done
		fi
		if [[ "${vopt_branch}" = "SR" ]] || [[ "${vopt_branch}" = "ALL" ]];then
			if [[ ${istep} -eq 2 ]];then
			#Kraken/bracken
			# set db option
				# if unspecified then default
				v_size_db=30
				if [[ ${vopt_db_log} -eq 0 ]];then
					vopt_db='tool_k2_agora2apollo'
				else
					#cycle and check for valid option
					if [[ "${vopt_db[@]}" =~ "tool_k2_agora" ]] || [[ "${vopt_db[@]}" =~ "tool_k2_apollo" ]] || [[ "${vopt_db[@]}" =~ "tool_k2_agora2apollo" ]] || [[ "${vopt_db[@]}" =~ "tool_k2_std8" ]];then
						printf 'Valid option for step detected\n' >> ${v_logfile}
					else
						printf 'Invalid option for step detected...using default\n' >> ${v_logfile}
					# apply default
						vopt_db+=('tool_k2_agora2apollo')
					fi
				fi
				for idb in "${vopt_db[@]}";do
					if [[ ${idb} = 'tool_k2_agora' ]];then
						vin_path_db[2]=${vin_path_db[0]}'/REPO_tool/kraken/kdb_agora'
						v_size_db=50
						#perform check - sophisticate with check fun
						if [[ $(ls -1 ${vin_path_db[2]}/database* 2>/dev/null | wc -l) -lt 2 ]];then
							printf 'FUNC_CHECK: DB: %s not found, installing...\n' "${idb}"
							BASH_seqc_makedb.sh -s 'tool_k2_agora'
						fi
					fi
					if [[ ${idb} = 'tool_k2_apollo' ]];then
						vin_path_db[2]=${vin_path_db[0]}'/REPO_tool/kraken/kdb_apollo'
						v_size_db=50
						#perform check - sophisticate with check fun
						if [[ $(ls -1 ${vin_path_db[2]}/database* 2>/dev/null | wc -l) -lt 2 ]];then
							printf 'FUNC_CHECK: DB: %s not found, installing...\n' "${idb}"
							BASH_seqc_makedb.sh -s 'tool_k2_apollo'
						fi
					fi
					if [[ ${idb} = 'tool_k2_agora2apollo' ]];then
						vin_path_db[2]=${vin_path_db[0]}'/REPO_tool/kraken/kdb_a2a'
						v_size_db=69
						#perform check - sophisticate with check fun
						if [[ $(ls -1 ${vin_path_db[2]}/database* 2>/dev/null | wc -l) -lt 2 ]];then
							printf 'FUNC_CHECK: DB: %s not found, installing...\n' "${idb}"
							BASH_seqc_makedb.sh -s 'tool_k2_agora2apollo'
						fi
					fi
					if [[ ${idb} = 'tool_k2_std8' ]];then
						vin_path_db[2]=${vin_path_db[0]}'/REPO_tool/kraken/kdb_std8'
						v_size_db=8
						#perform check - sophisticate with check fun
						if [[ $(ls -1 ${vin_path_db[2]}/database* 2>/dev/null | wc -l) -lt 2 ]];then
							printf 'FUNC_CHECK: DB: %s not found, installing...\n' "${idb}"
							BASH_seqc_makedb.sh -s 'tool_k2_std8'
						fi
					fi
					if [[ ${idb} = 'tool_k2_demo' ]];then
						vin_path_db[2]=${vin_path_db[0]}'/REPO_tool/kraken/kdb_demo'
						#perform check - sophisticate with check fun
						if [[ $(ls -1 ${vin_path_db[2]}/database* 2>/dev/null | wc -l) -lt 2 ]];then
							printf 'FUNC_CHECK: DB: %s not found, installing...\n' "${idb}"
							BASH_seqc_makedb.sh -s 'tool_k2_std8'
						fi
					fi
				done
				# PERFORM TAXONOMY CHECK AND CONFIG HERE - mimic approach in makedb
				v_tdmp_n='/DB/REPO_tool/ncbi_NR/taxonomy'
				v_tdmp_k='/DB/REPO_tool/kraken/taxonomy'
				v_tdmp_u=${vin_path_db[2]}'/taxonomy'
				# check user/run specified db
				[[ ! $( find "${v_tdmp_n}" -name '*.dmp' 2> /dev/null | wc -l ) -gt 0 ]] && vtest_n=1 || vtest_n=0
				[[ ! $( find "${v_tdmp_k}" -name '*.dmp' 2> /dev/null | wc -l ) -gt 0 ]] && vtest_k=1 || vtest_k=0
				[[ ! $( find "${v_tdmp_u}" -name '*.dmp' 2> /dev/null | wc -l ) -gt 0 ]] && vtest_u=1 || vtest_u=0
				# DL core NCBI NR if 1
				(( $vtest_n )) && BASH_seqc_makedb.sh -s 'tool_ncbi_taxd'
				# link kraken core to NCBI NR if 1
				(( $vtest_k )) && ln -sf "${v_tdmp_n}" "${v_tdmp_k}"
				# link user kraken to kraken if 1
				(( $vtest_u )) && ln -sf "${v_tdmp_k}" "${v_tdmp_u}"
				# check if successful and exit if not, set general variable, currently used by taxonkit in s2
				[[ ! $( find "${v_tdmp_n}" -name '*.dmp' 2> /dev/null | wc -l ) -gt 0 ]] && vtest_n=1 || vtest_n=0
				(( $vtest_n )) && { echo 'TBD:CRITERROR'; exit 1; } || v_tdmp="${v_tdmp_n}" 
			fi
		fi
	done # END of DB check
	# SETUP NEW APPROACH - parse istep, ipack, vopt_branch > switches for steps
	# potential entries per level and branch - TODO incorp into improvements
	# valid pot tools not selected will be absent rather than =0, pot issue?
	v_pac_s1='kneaddata'
	v_pac_s2=( 'kraken' 'spades' )
	v_pac_s3=( 'mars' 'minimap2' 'strobealign' 'vamb' 'checkm2' )
	for istep in "${vopt_step[@]}";do
		if [[ ${istep} -eq 1 ]];then
			vstat_step=$( func_status_adj "get" "${v_logfile_status}" "STATE" "step"${istep} )
			#pull path vout_s1
			declare vout_s${istep}=$( func_status_adj "get" "${v_logfile_status}" "PATH" "step"${istep}"_PATH" )
			[[ "${vstat_step}" = 'PENDING' ]] && declare vrun_s${istep}=1 || declare vrun_s${istep}=0
			(( $vrun_s1 )) && for ipack in "${vopt_pac[@]}";do
				[[ "${ipack}" = 'kneaddata' ]] && declare vrun_s${istep}_${ipack}=1 #|| declare vrun_s${istep}_${ipack}=0
				#vprint=vrun_s${istep}_${ipack};printf 'vruns%s %s : %s\n' "${istep}" "${ipack}" "${!vprint}"
			done
		fi
		if [[ "${vopt_branch}" = "SR" ]] || [[ "${vopt_branch}" = "ALL" ]];then
			if [[ ${istep} -eq 2 ]];then
			declare vout_s${istep}=$( func_status_adj "get" "${v_logfile_status}" "PATH" "step"${istep}"_PATH" )
				vstat_step=$( func_status_adj "get" "${v_logfile_status}" "STATE" "step"${istep} )
				[[ "${vstat_step}" = 'PENDING' ]] && declare vrun_s${istep}=1 || declare vrun_s${istep}=0
				(( $vrun_s2 )) && for ipack in "${vopt_pac[@]}";do
					[[ "${ipack}" = 'kraken' ]] && declare vrun_s${istep}_${ipack}=1 #|| declare vrun_s${istep}_${ipack}=0
				#vprint=vrun_s${istep}_${ipack};printf 'vruns%s %s : %s\n' "${istep}" "${ipack}" "${!vprint}"
				done
			fi
			if [[ ${istep} -eq 3 ]];then
			declare vout_s${istep}=$( func_status_adj "get" "${v_logfile_status}" "PATH" "step"${istep}"_PATH" )
				vstat_step=$( func_status_adj "get" "${v_logfile_status}" "STATE" "step"${istep} )
				[[ "${vstat_step}" = 'PENDING' ]] && declare vrun_s${istep}=1 || declare vrun_s${istep}=0
				(( $vrun_s3 )) && for ipack in "${vopt_pac[@]}";do
					[[ "${ipack}" = 'mars' ]] && declare vrun_s${istep}_${ipack}=1 #|| declare vrun_s${istep}_${ipack}=0
			#	printf 'vruns%s : %s\n' "${istep}" "${vrun_s3_mars}"
				done
			fi
		fi
	done # End of step check
	# Pull environment and package for regulation
	vstat_env=$(func_status_adj "get" "${v_logfile_status}" "CONFIG" "run_ENV")
	vstat_pac=$(func_status_adj "get" "${v_logfile_status}" "CONFIG" "run_PAC")
fi # Eo_vopt_log
# START pipeline
if (( vrun_s1_kneaddata ));then
	#STEP1_QC
	istep=1
	#set status path to default
	vout_nom=vout_s${istep}
	[[ "${!vout_nom}" = NULL ]] && func_status_adj "set" "${v_logfile_status}" "PATH" "step"${istep}"_PATH" ${venv_dir_proc}'/step1_kneaddata'
	# Pull to vout_s1
	declare vout_s${istep}=$( func_status_adj "get" "${v_logfile_status}" "PATH" "step"${istep}"_PATH" )
	#TEMP: BASH_seqc_mama.sh -b -k -i "step0_data_in/" -n "step0_data_in/sample_id_n2.txt" -r "SR" -s "0" &
	# create unique ID for temp name file and set to var
	v_rand_str=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 5)
	vstat_name='/DB/DEPO_proc/tmp/tmp_status_'${v_rand_str}'.txt'
	# pull status for samples and direct to file for func_mama input
	func_status_step ${istep} 0 ${v_logfile_status} "STATE_FID" > "${vstat_name}"
	# Check for valid potential input and bypass if not
	[[ $( cat ${vstat_name} | wc -l ) -gt 0 ]] && vstat_name_pass=1 || vstat_name_pass=0
	if (( ${vstat_name_pass} ));then
		# define statement for status update appendment to run lines, run
		vstat_update=$(
			#printf ' && vtar1="STATE_FID:FS:"%%s;'
			printf '&& vtar1="STATE_FID:FS:v_SAMPLE_UNIQ";'
			printf 'vtar2=$( grep -E $vtar1 '$v_logfile_status' | sed "s/:FS:/:/g" | cut -d ":" --fields 3 );'
			printf 'vstr0=( $( grep -E $vtar1 '$v_logfile_status' | sed "s/:FS:/:/g" | cut -d ":" --fields 3 | fold -w1 ) );'
			printf 'vstr0['${istep}'-1]=1;'
			printf 'vrep1=$vtar1;'
			printf 'vrep2=$( IFS=;vrep2="${vstr0[*]}";echo $vrep2 );'
			printf 'sed -i "s/$vtar1:FS:$vtar2/$vrep1:FS:$vrep2/g" '$v_logfile_status
		)
		#step log
		v_print_head='Initialising step:'
		v_print_type='QC'
		v_TS=$(date)
		printf '%s%s of %s\tstep role:%s\tstart time:%s\n' "${v_print_head}" "${istep}" "${#vopt_step[@]}" "${v_print_type}" "${v_TS}" >> ${v_logfile}
		# kneaddata, expected input arg: /home/$proj_ID/step0_data_in/*R{1,2}fastq.gz step1_kneaddata/
		# parse IO for unique sample/file id with v_SAMPLE_UNIQ and set new line with v_LINO
		# removed: --cat-final-output
		#vopt_name='file_in_samples', replaced with vstat_name for restart proc
		vin_name=${vstat_name}
		vin_env='env_s1_kneaddata'
		vin_pac='kneaddata'
		# Set env and pac in status
		func_status_adj "set" "${v_logfile_status}" "CONFIG" "run_ENV" ${vin_env}
		func_status_adj "set" "${v_logfile_status}" "CONFIG" "run_PAC" ${vin_pac}
		#v_scrp_job=${seqc_dir_job}/'job_'${vin_env}'_'${vin_pac}'.sh'
		v_scrp_base=${vin_env}'_'${vin_pac}'.sh'
		printf 'Using software:%s from environment:%s\n' "${vin_pac}" "${vin_env}" >> ${v_logfile}
		# Check for user defined input dir
		if [[ -z ${vopt_dir_I} ]];then
			# if absent make default
			vin_I_dir=${v_dir_work}'/step0_data_in'
		else
			# if present make user input
			vin_I_dir=${vopt_dir_I}
			unset vopt_dir_I
		fi
		# Check for user defined output dir
		if [[ -z ${vopt_dir_O} ]];then
			# if absent make default
			vin_O_dir=${venv_dir_proc}'/step1_kneaddata'
		else
			# if present make user input
			vin_O_dir=${vopt_dir_O}
			unset vopt_dir_O
		fi
		if [[ -z ${vopt_mid} ]];then
			# if absent make default
			vopt_mid[0]=''
			vopt_mid[1]='_R1'
			vopt_mid[2]='_R2'
		fi
		if [[ -z ${vopt_ext} ]];then
			# if absent make default
			vopt_ext='.fastq'
		fi
		# adjust step according to file type
			[[ -z ${vin_head} ]] && vin_head=''
			[[ -z ${vin_tail} ]] && vin_tail=''
		# set output prefix
		if [[ "${vopt_file_type}" = 'paired' ]];then
			vin_I_com='--input1 '${vin_I_dir}'/v_SAMPLE_UNIQ'${vopt_mid[1]}${vopt_ext}' --input2 '${vin_I_dir}'/v_SAMPLE_UNIQ'${vopt_mid[2]}${vopt_ext}' --output-prefix v_SAMPLE_UNIQ_kneaddata'
			vin_O_com='--output '${vin_O_dir}
			vin_tidy='v_LINOpigz '${vin_I_dir}'/v_SAMPLE_UNIQ'${vopt_mid[1]}${vopt_ext}'v_LINOpigz '${vin_I_dir}'/v_SAMPLE_UNIQ'${vopt_mid[2]}${vopt_ext}
		fi
		if [[ "${vopt_file_type}" = 'single' ]];then
			vin_I_com='--unpaired '${vin_I_dir}'/v_SAMPLE_UNIQ'${vopt_mid[1]}${vopt_ext}' --output-prefix v_SAMPLE_UNIQ_kneaddata'
			vin_O_com='--output '${vin_O_dir}
			vin_tidy='v_LINOpigz '${vin_I_dir}'/v_SAMPLE_UNIQ'${vopt_mid[1]}${vopt_ext}
		fi
		# undetermined - default of paired
		if [[ ! "${vopt_file_type}" = 'single' ]] && [[ ! "${vopt_file_type}" = 'paired' ]];then
			vin_I_com='--input1 '${vin_I_dir}'/v_SAMPLE_UNIQ'${vopt_mid[1]}${vopt_ext}' --input2 '${vin_I_dir}'/v_SAMPLE_UNIQ'${vopt_mid[2]}${vopt_ext}' --output-prefix v_SAMPLE_UNIQ_kneaddata'
			vin_O_com='--output '${vin_O_dir}
			vin_tidy='v_LINOpigz '${vin_I_dir}'/v_SAMPLE_UNIQ'${vopt_mid[1]}${vopt_ext}'v_LINOpigz '${vin_I_dir}'/v_SAMPLE_UNIQ'${vopt_mid[2]}${vopt_ext}
		fi
		# proc check - ensure that too many processes are not called
		if [[ -z ${venv_proc_max} ]];then
			venv_proc_max=$(( ${venv_cpu_max} / 2 ))
		fi
		if [[ $(printf %.0f $(echo "${venv_cpu_max} * ${venv_proc_max}" | bc -l)) -gt "${v_sys_mem}" ]];then
			vt="${venv_proc_max}"
			while [[ $(printf %.0f $(echo "${venv_cpu_max} * ${vt}" | bc -l)) -gt "${v_sys_mem}" ]];do
				((vt--))
			done
			venv_proc_max="${vt}"
		fi
		if [[ ${vopt_com_log} -eq 0 ]];then
			# Insert as string to be combined and parsed prior to feed in awk - ex: vin_com=$(printf -- '--id v_SAMPLE_UNIQ --reference-db %s v_LINOpigz v_SAMPLE_UNIQ' "${venv_cpu_max}" )
			#vin_com_subL="${vstat_update}${vin_tidy}";vin_com_subR=$( printf ',va_nID%.0s' {1..3})
			#vin_com='{ printf " --remove-intermediate-output --reference-db %s --threads %s --processes %s --max-memory %sg --trimmomatic /opt/conda/envs/env_s1_kneaddata/share/trimmomatic --reorder'${vin_com_subL}'","'${vin_path_db[1]}'",'${venv_cpu_max}','${venv_proc_max}','${venv_mem_max}''${vin_com_subR}' }'
			vin_com=$(printf -- '--remove-intermediate-output --reference-db %s --threads %s --processes %s --max-memory %sg --trimmomatic /opt/conda/envs/env_s1_kneaddata/share/trimmomatic --reorder' "${vin_path_db[1]}" "${venv_cpu_max}" "${venv_proc_max}" "${venv_mem_max}")
		fi
		#[[ $( cat ${vstat_name} | wc -l ) -gt 0 ]] && func_mama "${istep}" "${vin_I_dir}" "${vin_I_com}" "${vin_O_dir}" "${vin_O_com}" "${vin_com}" "${vin_head}" "${vin_tail}" "${vin_name}" "${vin_env}" "${vin_pac}" "${v_scrp_job}" "${vopt_dbug}" "${vin_mkdr}" >> ${v_logfile} 2>>${v_dir_err}
		func_mama2 -s "${istep}" -e "${vin_env}" -p "${vin_pac}" -j "${v_scrp_base}" -I "${vin_I_dir}" -O "${vin_O_dir}" \
		-c "${vin_I_com}" -c "${vin_O_com}" -c "${vin_com}" -c "${vstat_update}" -c "${vin_tidy}" \
		-H "${vin_head}" -T "${vin_tail}" -N "${vin_name}" -b "${vopt_dbug}" -m "${vin_mkdr}" >> ${v_logfile} 2>>${v_dir_err}
		# POST STEP
		func_status_exit ${istep} ${vin_O_dir} '*kneaddata*{.log,.fastq}' '*kneaddata*{unmatched,contam}*.fastq' '*kneaddata*paired*.fastq' '_kneaddata_paired' '_1' '_2' '.fastq' 'DONE'
	else
		# Ops for namepass fail - TODO messaging etc
		eval "rm ${vstat_name}" 2> /dev/null
	fi # EoNamePass
fi #EoS1
if (( vrun_s2_kraken ));then
	#STEP2_ASSIGN - SR
	istep=2
	#set status path to default
	vout_nom=vout_s${istep}
	[[ "${!vout_nom}" = NULL ]] && func_status_adj "set" "${v_logfile_status}" "PATH" "step"${istep}"_PATH" ${venv_dir_proc}'/step2_kraken'
	declare vout_s${istep}=$( func_status_adj "get" "${v_logfile_status}" "PATH" "step"${istep}"_PATH" )
	#step log
	v_print_head='Initialising step:'
	v_print_type='Assignment - Taxonomy'
	v_TS=$(date)
	printf '%s%s of %s\tstep role:%s\tstart time:%s\n' "${v_print_head}" "${istep}" "${#vopt_step[@]}" "${v_print_type}" "${v_TS}" >> ${v_logfile}
	# create unique ID for temp name file and set to var
	v_rand_str=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 5)
	vstat_name='/DB/DEPO_proc/tmp/tmp_status_'${v_rand_str}'.txt'
	# pull status for samples and direct to file for func_mama input
	func_status_step ${istep} 0 ${v_logfile_status} "STATE_FID" > "${vstat_name}"
	# define statement for status update appendment to run lines, stage 0>a>1
	[[ $( cat ${vstat_name} | wc -l ) -gt 0 ]] && vstat_name_pass=1 || vstat_name_pass=0
	if (( ${vstat_name_pass} ));then
		vstat_update=$(
			printf '&& vtar1="STATE_FID:FS:v_SAMPLE_UNIQ";'
			printf 'vtar2=$( grep -E $vtar1 '$v_logfile_status' | sed "s/:FS:/:/g" | cut -d ":" --fields 3 );'
			printf 'vstr0=( $( grep -E $vtar1 '$v_logfile_status' | sed "s/:FS:/:/g" | cut -d ":" --fields 3 | fold -w1 ) );'
			printf 'vstr0['${istep}'-1]=a;'
			printf 'vrep1=$vtar1;'
			printf 'vrep2=$( IFS=;vrep2="${vstr0[*]}";echo $vrep2 );'
			printf 'sed -i "s/$vtar1:FS:$vtar2/$vrep1:FS:$vrep2/g" '$v_logfile_status
		)
		# Check for user defined input dir
		if [[ -z ${vout_s1} ]];then
			if [[ -z ${vopt_dir_I} ]];then
				vin_I_dir=${v_dir_work}'/step0_data_in'
			else
				vin_I_dir=${vopt_dir_I}
				unset vopt_dir_I
			fi
		else
			vin_I_dir=${vout_s1}
		fi
		# Check for user defined output dir
		if [[ -z ${vopt_dir_O} ]];then
			# if absent make default
			vin_O_dir=${venv_dir_proc}'/step2_kraken'
		else
			# if present make user input
			vin_O_dir=${vopt_dir_O}
			unset vopt_dir_O
		fi
		# pull string variables from status
		vopt_mid[0]=$(func_status_adj "get" "${v_logfile_status}" "CONFIG" "file_str_mid0")
		vopt_mid[1]=$(func_status_adj "get" "${v_logfile_status}" "CONFIG" "file_str_mid1")
		vopt_mid[2]=$(func_status_adj "get" "${v_logfile_status}" "CONFIG" "file_str_mid2")
		vopt_ext=$(func_status_adj "get" "${v_logfile_status}" "CONFIG" "file_str_ext")
		vin_name=${vstat_name}
		vin_env='env_s4_kraken'
		vin_pac='kraken2'
		func_status_adj "set" "${v_logfile_status}" "CONFIG" "run_ENV" ${vin_env}
		func_status_adj "set" "${v_logfile_status}" "CONFIG" "run_PAC" ${vin_pac}
		v_scrp_base=${vin_env}'_'${vin_pac}'.sh'
		printf 'Using software:%s from environment:%s\n' "${vin_pac}" "${vin_env}" >> ${v_logfile}
		vin_I_com='--paired '${vin_I_dir}'/v_SAMPLE_UNIQ'${vopt_mid[0]}${vopt_mid[1]}${vopt_ext}' '${vin_I_dir}'/v_SAMPLE_UNIQ'${vopt_mid[0]}${vopt_mid[2]}${vopt_ext}
		vin_O_com='--unclassified-out '${vin_O_dir}'/v_SAMPLE_UNIQ_k2_unclassed#.fastq --classified-out '${vin_O_dir}'/v_SAMPLE_UNIQ_k2_classed#.fastq --output '${vin_O_dir}'/v_SAMPLE_UNIQ_k2_out.txt --report '${vin_O_dir}'/v_SAMPLE_UNIQ_k2_report.txt'
		vin_head=''
		vin_tail=''
		vin_conf='0.20'
		vin_mkdr=1
		#check mem availability for --memory-mapping option
		if [[ ${venv_mem_max} -lt  ${v_size_db} ]];then
			printf 'Less memory available (%s) than size of DB (%s), using --memory-mapping option\n' "${venv_mem_max}" "${v_size_db}" >> ${v_logfile}
			vin_mem_map=' --memory-mapping'
		else
			vin_mem_map=''
		fi
		if [[ ${vopt_com_log} -eq 0 ]];then
			vin_com=$( printf -- '--db %s --threads %s --confidence %s --report-minimizer-data%s' "${vin_path_db[2]}" "${venv_cpu_max}" "${vin_conf}" "${vin_mem_map}" )
		fi
		# Standard
		func_mama2 -s "${istep}" -e "${vin_env}" -p "${vin_pac}" -j "${v_scrp_base}" -I "${vin_I_dir}" -O "${vin_O_dir}" \
		-c "${vin_I_com}" -c "${vin_O_com}" -c "${vin_com}" -c "${vstat_update}" -H "${vin_head}" -T "${vin_tail}" -N "${vin_name}" -b "${vopt_dbug}" -m "${vin_mkdr}">> ${v_logfile} 2>>${v_dir_err}
		# MPA style
		#vin_O_com='--unclassified-out '${vin_O_dir}'/v_SAMPLE_UNIQ_k2_unclassed#.fastq --classified-out '${vin_O_dir}'/v_SAMPLE_UNIQ_k2_classed#.fastq --output '${vin_O_dir}'/v_SAMPLE_UNIQ_k2_out_MPA.txt --report '${vin_O_dir}'/v_SAMPLE_UNIQ_k2_report_MPA.txt'
		#if [[ ${vopt_com_log} -eq 0 ]];then
		#vin_com=$( printf -- '--db %s --threads %s --confidence %s --report-minimizer-data --use-mpa-style%s' "${vin_path_db[2]}" "${venv_cpu_max}" "${vin_conf}" "${vin_mem_map}" )
		#fi
		#func_mama2 -s "${istep}" -e "${vin_env}" -p "${vin_pac}" -j "${v_scrp_base}" -I "${vin_I_dir}" -O "${vin_O_dir}" \
		#-c "${vin_I_com}" -c "${vin_O_com}" -c "${vin_com}" -c "${vstat_update}" -H "${vin_head}" -T "${vin_tail}" -N "${vin_name}" -b "${vopt_dbug}" -m "${vin_mkdr}">> ${v_logfile} 2>>${v_dir_err}
	fi # EoNamePass
	# Remove temp name for step1phase1
	eval "rm ${vstat_name}" 2> /dev/null
	#bracken
	# inherit I/O and name and db from kraken
	v_rand_str=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 5)
	vstat_name='/DB/DEPO_proc/tmp/tmp_status_'${v_rand_str}'.txt'
	# pull status for samples and direct to file for func_mama input
	func_status_step ${istep} "a" ${v_logfile_status} "STATE_FID" > "${vstat_name}"
	[[ $( cat ${vstat_name} | wc -l ) -gt 0 ]] && vstat_name_pass=1 || vstat_name_pass=0
	if (( ${vstat_name_pass} ));then
		vin_name=${vstat_name}
		# define statement for status update appendment to run lines, stage 0>a>1
		vstat_update=$(
			printf '&& vtar1="STATE_FID:FS:v_SAMPLE_UNIQ";'
			printf 'vtar2=$( grep -E $vtar1 '$v_logfile_status' | sed "s/:FS:/:/g" | cut -d ":" --fields 3 );'
			printf 'vstr0=( $( grep -E $vtar1 '$v_logfile_status' | sed "s/:FS:/:/g" | cut -d ":" --fields 3 | fold -w1 ) );'
			printf 'vstr0['${istep}'-1]=1;'
			printf 'vrep1=$vtar1;'
			printf 'vrep2=$( IFS=;vrep2="${vstr0[*]}";echo $vrep2 );'
			printf 'sed -i "s/$vtar1:FS:$vtar2/$vrep1:FS:$vrep2/g" '$v_logfile_status
		)
		vin_I_dir=${vin_O_dir}
		vin_env='env_s4_kraken'
		vin_pac='bracken'
		func_status_adj "set" "${v_logfile_status}" "CONFIG" "run_ENV" ${vin_env}
		func_status_adj "set" "${v_logfile_status}" "CONFIG" "run_PAC" ${vin_pac}
		v_scrp_base=${vin_env}'_'${vin_pac}'.sh'
		printf 'Using software:%s from environment:%s\n' "${vin_pac}" "${vin_env}" >> ${v_logfile}
		vin_I_com='-i '${vin_I_dir}'/v_SAMPLE_UNIQ_k2_report.txt'
		vin_O_dir=${vin_I_dir}
		vin_O_com='-o '${vin_O_dir}'/v_SAMPLE_UNIQ_S_bracken_out.txt'
		vin_head=''
		vin_tail=''
		vin_rlen='150'
		vin_rmin='10' # this is the ufcking min number of reads NOT threads
		vin_mkdr=0
		if [[ ${vopt_com_log} -eq 0 ]];then
			vin_com=$( printf -- '-d %s -t %s -r %s -l S' "${vin_path_db[2]}" "${vin_rmin}" "${vin_rlen}" )
		fi
		func_mama2 -s "${istep}" -e "${vin_env}" -p "${vin_pac}" -j "${v_scrp_base}" -I "${vin_I_dir}" -O "${vin_O_dir}" \
		-c "${vin_I_com}" -c "${vin_O_com}" -c "${vin_com}" -c "${vstat_update}" -H "${vin_head}" -T "${vin_tail}" -N "${vin_name}" -b "${vopt_dbug}" -m "${vin_mkdr}" >> ${v_logfile} 2>>${v_dir_err}
	fi # EoNamePass
	# Remove tmp name file
	eval "rm ${vstat_name}" 2> /dev/null
	# Mark completed samples as null for step 3
	v_rand_str=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 5)
	vstat_name='/DB/DEPO_proc/tmp/tmp_status_'${v_rand_str}'.txt'
	# pull status for samples and direct to file for func_mama input
	func_status_step ${istep} 1 ${v_logfile_status} "STATE_FID" > "${vstat_name}"
	[[ $( cat ${vstat_name} | wc -l ) -gt 0 ]] && vstat_name_pass=1 || vstat_name_pass=0
	if (( ${vstat_name_pass} ));then
		# define statement for status update appendment to run lines, stage -
		vstat_update=$(
			printf 'for vi in $( cat ${vstat_name} );do'
			printf ' vtar1="STATE_FID:FS:"$vi;'
			printf 'vtar2=$( grep -E $vtar1 '$v_logfile_status' | sed "s/:FS:/:/g" | cut -d ":" --fields 3 );'
			printf 'vstr0=( $( grep -E $vtar1 '$v_logfile_status' | sed "s/:FS:/:/g" | cut -d ":" --fields 3 | fold -w1 ) );'
			printf 'vstr0['${istep}']=-;'
			printf 'vrep1=$vtar1;'
			printf 'vrep2=$( IFS=;vrep2="${vstr0[*]}";echo $vrep2 );'
			printf 'sed -i "s/$vtar1:FS:$vtar2/$vrep1:FS:$vrep2/g" '$v_logfile_status
			printf ';done'
		)
		# run
		eval $vstat_update
		#combine bracken out
		mapfile -t varr_kjoin_in < <(printf '%s\n' $(ls "${vout_s2}"/*_S_bracken_out.txt) )
		# current var chain: v_kjoin_out -> v_k2mpa_out
		# krakbrak_S_out.txt changed to KB_S_out.txt
		# TODO - convert to mama str
		v_kjoin_out=${vout_s2}/KB_S_out.txt
		v_col_nom=("${varr_kjoin_in[@]/%_S_bracken_out.txt/}") && v_col_nom=("${v_col_nom[*]/#*\/}") && v_col_nom="${v_col_nom[*]// /,}"
		micromamba run -n env_s4_kraken python /opt/conda/envs/env_s4_kraken/bin/combine_bracken_outputs.py \
		--files ${varr_kjoin_in[*]} --output ${v_kjoin_out} --names ${v_col_nom} 2>>${v_dir_err}
		printf 'Generating complete lineage file\n' >> ${v_logfile}
		cat "${v_kjoin_out}" | cut --fields 2 | tail +2 | micromamba run -n env_util_taxonkit \
		taxonkit reformat -I 1 --add-prefix --data-dir "${v_tdmp%/}" --threads "${venv_cpu_max}" \
		--out-file "${v_kjoin_out/out/taxid}" >> ${v_logfile} 2>>${v_dir_err}
		# add headers
		v_k2mpa_out=${v_kjoin_out/out/mpa_out}
		v_k2mpa_header=$( printf 'taxid\tTaxon' )
		#full file: cat <( paste <(cat <(printf '%s\n' "${v_k2mpa_header}") "${v_kjoin_out/out/mpa_out}" ) <(cat "${v_kjoin_out}" )  ) > "${v_k2mpa_out}"
		#subset for mars - drop repeat of genus in species name
		cat <( paste <(cat <(printf '%s\n' "${v_k2mpa_header}") "${v_kjoin_out/out/taxid}" | sed -E 's/s__(\w+) /s__/g' ) <(cat "${v_kjoin_out}" | cut --complement --fields 1,2,3 ) \
		) > "${v_k2mpa_out}"
		# Adjust species name for special chars
		cut --fields 1 "${v_k2mpa_out}" > /DB/DEPO_proc/tmp/tmp_bk1.txt
		cut --fields 2 "${v_k2mpa_out}" | sed 's/sp./sp/g' | sed 's/(.*)//g' | sed 's/-/_/g' | sed 's/\//_/g' > /DB/DEPO_proc/tmp/tmp_bk2.txt
		cut --complement --fields 1,2 "${v_k2mpa_out}" > /DB/DEPO_proc/tmp/tmp_bk3.txt
		paste /DB/DEPO_proc/tmp/tmp_bk1.txt /DB/DEPO_proc/tmp/tmp_bk2.txt /DB/DEPO_proc/tmp/tmp_bk3.txt > "${v_k2mpa_out}"
		rm /DB/DEPO_proc/tmp/tmp_bk1.txt /DB/DEPO_proc/tmp/tmp_bk2.txt /DB/DEPO_proc/tmp/tmp_bk3.txt
		# Determine cols to retain
		# Fraction - frac changed to RA
		v_match='frac'
		v_bk_cols=( $( head ${v_kjoin_out/out/mpa_out} -n 1 ) )
		v_bk_index=()
		for vi_bk in ${!v_bk_cols[@]};do
			if [[ ${v_bk_cols[${vi_bk}]/#*_} != ${v_match} ]];then
				unset v_bk_cols[$vi_bk]
			fi
		done
		for vi_bk in ${!v_bk_cols[@]};do
			v_bk_index+=( $(($vi_bk + 1)) )
		done
		#make subset file
		v_bk_col_frac=$(printf ',%s' ${v_bk_index[@]})
		#frac changed to RA, bk2mpa_out to mpa_out
		v_k2mpa_out=${v_kjoin_out/out/mpa_out_RA}
		cat ${v_kjoin_out/out/mpa_out} | cut --fields 2${v_bk_col_frac} > "${v_k2mpa_out}"
		#drop col type for match with meta data
		sed -i "1,1s/_$v_match//g" "${v_k2mpa_out}"
		# Counts
		v_match='num'
		v_bk_cols=( $( head ${v_kjoin_out/out/mpa_out} -n 1 ) )
		v_bk_index=()
		for vi_bk in ${!v_bk_cols[@]};do
			if [[ ${v_bk_cols[${vi_bk}]/#*_} != ${v_match} ]];then
				unset v_bk_cols[$vi_bk]
			fi
		done
		for vi_bk in ${!v_bk_cols[@]};do
			v_bk_index+=( $(($vi_bk + 1)) )
		done
		#make subset file
		v_bk_col_num=$(printf ',%s' ${v_bk_index[@]})
		#num changed to RC, bk2mpa_out to mpa_out
		v_k2mpa_out=${v_kjoin_out/out/mpa_out_RC}
		cat ${v_kjoin_out/out/mpa_out} | cut --fields 2${v_bk_col_num} > "${v_k2mpa_out}"
		#drop col type for match with meta data
		sed -i "1,1s/_$v_match//g" "${v_k2mpa_out}"
		#default mars input is now "${v_k2mpa_out}" = /DB/DEPO_proc/step2_kraken/KB_S_mpa_out_RC.txt
		# POST STEP
		func_status_exit ${istep} ${vout_s2} '*{.txt,.fastq}' '*_{k2,bracken}_*{.txt,.fastq}' 'KB_S_{taxid,out,mpa_out}.txt' 'NULL' 'NULL' 'NULL' 'NULL' 'DONE'
		# Adjust final dir for KB_S_mpa_RC
		v_k2mpa_out="${vout_s2}/${v_k2mpa_out##*/}"
		# Put input for next step in status file and set value of status, --0
		v_start_index=$(printf -- '-%.0s' $(seq 1 $istep))"0"
		func_log "3" "STATE_FID" "v_k2mpa_out" "${v_start_index}"
		# set taxa sep flag for mars in case differing from kraken output
		# better soln TBD
		venv_mars_taxaSplit=';'
	else
	# Ops for namepass fail - TODO messaging etc
		eval "rm ${vstat_name}" 2> /dev/null
	fi # EoNamePass
fi #EoS2
if (( vrun_s3_mars ));then
	#STEP3_REPORT - SR
	istep=3
	#set status path to default
	vout_nom=vout_s${istep}
	[[ "${!vout_nom}" = NULL ]] && func_status_adj "set" "${v_logfile_status}" "PATH" "step"${istep}"_PATH" ${venv_dir_proc}'/step3_mars'
	declare vout_s${istep}=$( func_status_adj "get" "${v_logfile_status}" "PATH" "step"${istep}"_PATH" )
	#step log
	v_print_head='Initialising step:'
	v_print_type='Report - Taxonomy'
	v_TS=$(date)
	printf '%s%s of %s\tstep role:%s\tstart time:%s\n' "${v_print_head}" "${istep}" "${#vopt_step[@]}" "${v_print_type}" "${v_TS}" >> ${v_logfile}
	# MARS FINAL RECONFIG
	# TODO - make to run within internal mama call
	# Expected input file:
	#  "Taxon" read_counts_n_1 read_counts_n_2 read_counts_n_X
	#   d__bact..s__
	#   k__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__faecis
	#
	# create unique ID for temp name file and set to var
	v_rand_str=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 5)
	vstat_name='/DB/DEPO_proc/tmp/tmp_status_'${v_rand_str}'.txt'
	# pull status for samples and direct to file for func_mama input
	func_status_step ${istep} 0 ${v_logfile_status} "STATE_FID" > "${vstat_name}"
	[[ $( cat ${vstat_name} | wc -l ) -gt 0 ]] && vstat_name_pass=1 || vstat_name_pass=0
	if (( ${vstat_name_pass} ));then
		# define statement for status update appendment to run lines, run
		vstat_update=$(
			printf 'vtar1="STATE_FID:FS:"'$( cat ${vstat_name} )';'
			printf 'vtar2=$( grep -E $vtar1 '$v_logfile_status' | sed "s|:FS:|:|g" | cut -d ":" --fields 3 );'
			printf 'vstr0=( $( grep -E $vtar1 '$v_logfile_status' | sed "s|:FS:|:|g" | cut -d ":" --fields 3 | fold -w1 ) );'
			printf 'vstr0['${istep}'-1]=1;'
			printf 'vrep1=$vtar1;'
			printf 'vrep2=$( IFS=;vrep2="${vstr0[*]}";echo $vrep2 );'
			printf 'sed -i "s|$vtar1:FS:$vtar2|$vrep1:FS:$vrep2|g" '$v_logfile_status
		)
		#Check for file name from previous KB run, if missing revert to vopt name
		if [[ -z "${v_k2mpa_out}" ]]; then
			if (( ${vopt_dbug} ));then
				printf 'FUNC_general_DBUG(LINE%s): v_k2mpa_out not found, explicit direction to input file for mars req.\n' "${LINENO}" >> ${v_logfile_dbug}
			fi
			vin_name=${vopt_name}
			v_mars_kin="${vin_name}"
		fi
		if [[ ! -z "${v_k2mpa_out}" ]]; then
			if (( ${vopt_dbug} ));then
				printf 'FUNC_general_DBUG(LINE%s): v_k2mpa_out found, using it as input file for mars.\n' "${LINENO}" >> ${v_logfile_dbug}
			fi
			v_mars_kin="${v_k2mpa_out}"
		fi
		vin_env='env_util_mars'
		vin_pac='mars'
		func_status_adj "set" "${v_logfile_status}" "CONFIG" "run_ENV" ${vin_env}
		func_status_adj "set" "${v_logfile_status}" "CONFIG" "run_PAC" ${vin_pac}
		v_scrp_base=${vin_env}'_'${vin_pac}'.sh'
		printf 'Using software:%s from environment:%s\n' "${vin_pac}" "${vin_env}" >> ${v_logfile}
		vin_dir_I=' -i '${venv_dir_proc}'/step2_kraken/v_SAMPLE_UNIQ_k2_report.txt'
		vin_dir_O=' -o '${venv_dir_proc}'/step2_kraken/v_SAMPLE_UNIQ_S_bracken_out.txt'
		vin_path_db='/DB/REPO_tool/kraken/kdb_agora'
		#vopt_path_db='/DB/REPO_tool/kraken/kdb_std8'
		vin_head=''
		vin_tail=''
		vin_rlen='150'
		if [[ ${vopt_com_log} -eq 0 ]];then
			vin_com='{ printf " -d %s -t %s -r %s -l S","'${vin_path_db}'",'${venv_cpu_max}',"'${vopt_rlen}'" }'
		fi
		#TODO checks for compatibility prior to conversion
		#issue with d__virus/euk leading to 8 phylo levels
		#v_mars_out='/DB/DEPO_proc/tmp/profile_taxa_mars_prep.txt'
		##cat "${v_mars_out}" | cut --fields 2,3 | sed -E 's/d__(Vir|Euk).+k__/k__/g' > mars_reads.txt
		#modification to remove genus lvl id duplication
		#check with isolating genus vector g__xxx and species vector s__xxx-yyy and compare
		##cat <( paste <( cat "${v_mars_kin}" | cut --fields 1 | sed -E 's/s__(\w+) /s__/g' ) <( cat "${v_mars_kin}" | cut --complement --fields 1 ) ) > "${v_mars_out}"
		infile1=$v_mars_kin
		infile2='None'
		#Check for preexisting mars_out dir and append suffix if T
		# Check for user defined input dir
		if [[ -z ${vopt_dir_I} ]];then
			if [[ -z ${vout_s1} ]];then
				# if absent make default
				vin_I_dir=${v_dir_work}'/step0_data_in'
			else
				# if present make input the output of last step
				vin_I_dir=${vout_s2}
			fi
		else
			# if present make user input
			vin_I_dir=${vopt_dir_I}
			unset vopt_dir_I
		fi
		# Check for user defined output dir
		if [[ -z ${vopt_dir_O} ]];then
			# if absent make default
			vin_O_dir=${venv_dir_proc}'/step3_mars'
		else
			# if present make user input
			vin_O_dir=${vopt_dir_O}
			unset vopt_dir_O
		fi
		#tmp make out dir
		# pot. bugged/OoD
		if [ $var_BLOCK = 'F' ];then
			if [[ -d "${vin_O_dir}" ]];then
				if (( ${vopt_dbug} ));then
					printf 'FUNC_general_DBUG(LINE%s): Pre-existing MARS out dir, generating new dir\n' "${LINENO}" >> ${v_logfile_dbug}
				fi
				vin_O_dir=${vin_O_dir/%_?}_$(( $(find "${vin_O_dir/%_?}"_*/ -maxdepth 0 -type d 2>/dev/null | wc -l) + 1 ))
				if (( ${vopt_dbug} ));then
					printf 'FUNC_general_DBUG(LINE%s): New MARS out dir:%s\n' "${LINENO}" "${vin_O_dir}" >> ${v_logfile_dbug}
				fi
				# preexisting dir req as of mars log implementation
			fi
		fi
		if [[ ! -d "${vin_O_dir}" ]];then
			mkdir -p "${vin_O_dir}"
		fi
		#current function defaults 20250122
		#process_microbial_abundances(input_file1, input_file2, output_path=None, cutoff=0.000001, output_format="csv", stratification_file=None, flagLoneSpecies=False, taxaSplit="; ", removeCladeExtensionsFromTaxa=True, whichModelDatabase="full_db", userDatabase_path="", sample_read_counts_cutoff=1)
		#parse options
		#Overwrites for sanity
		unset vin_opt_mars
		venv_mars_userDatabase_path=None
		#?? venv_mars_readsTablePath
		#vin_O_dir='/home/seqc_user/seqc_project/final_reports/test'
		vin_opt_mars+=($(printf 'input_file1=%s' "${infile1}"))
		vin_opt_mars+=($(printf 'input_file2=%s' "${infile2}"))
		vin_opt_mars+=($(printf 'output_path=%s' "${vin_O_dir}"))
		vin_opt_mars+=($(printf 'cutoff=%s' "${venv_mars_cutoffMARS}"))
		vin_opt_mars+=($(printf 'output_format=%s' "${venv_mars_outputExtensionMARS}"))
		vin_opt_mars+=($(printf 'stratification_file=%s' "None"))
		vin_opt_mars+=($(printf 'flagLoneSpecies=%s' "${venv_mars_flagLoneSpecies}"))
		vin_opt_mars+=($(printf 'taxaSplit=%s' "${venv_mars_taxaSplit}"))
		vin_opt_mars+=($(printf 'removeCladeExtensionsFromTaxa=%s' "${venv_mars_removeCladeExtensionsFromTaxa}"))
		vin_opt_mars+=($(printf 'whichModelDatabase=%s' "${venv_mars_whichModelDatabase}"))
		vin_opt_mars+=($(printf 'userDatabase_path=%s' "${venv_mars_userDatabase_path}"))
		vin_opt_mars+=($(printf 'sample_read_counts_cutoff=%s' "${venv_mars_sample_read_counts_cutoff}"))
		# 2262-2263 - suppress panda warning
		#output_format=sys.argv[5] flagLoneSpecies=sys.argv[7] taxaSplit=sys.argv[8]
		#\nprint("vip11:",vip11)\
		micromamba run -n env_util_mars python -c $'import importlib,os,sys\
		\nimport pandas as pd\
		\npd.options.mode.chained_assignment = None\
		\nos.chdir("/opt/conda/envs/env_util_mars/lib/mars")\nimportlib.import_module("MARS")\
		\nos.chdir("/opt/conda/envs/env_util_mars/lib/mars/MARS")\nimport main\
		\nif sys.argv[2].strip() == "None": vip2 = None\
		\nelse: vip2 = sys.argv[2]\
		\nif sys.argv[4].strip() == "None": vip4 = None\
		\nelse: vip4 = float(sys.argv[4])\
		\nif sys.argv[6].strip() == "None": vip6 = None\
		\nelse: vip6 = sys.argv[6]\
		\nif sys.argv[7].strip() == "True": vip7 = True\
		\nelif sys.argv[7].strip() == "False": vip7 = False\
		\nelse: vip7 = sys.argv[7]\
		\nif sys.argv[9].strip() == "True": vip9 = True\
		\nelif sys.argv[9].strip() == "False": vip9 = False\
		\nelse: vip9 = sys.argv[9]\
		\nif sys.argv[11].strip() == "None": vip11 = None\
		\nelse: vip11 = sys.argv[11]\
		\nif sys.argv[12].strip() == "None": vip12 = None\
		\nelse: vip12 = int(sys.argv[12])\
		\nmain.process_microbial_abundances(\
		\nsys.argv[1], vip2, output_path=sys.argv[3], \
		\ncutoff=vip4, output_format=sys.argv[5], stratification_file=vip6, \
		\nflagLoneSpecies=vip7, taxaSplit=sys.argv[8], removeCladeExtensionsFromTaxa=vip9, \
		\nwhichModelDatabase=sys.argv[10], userDatabase_path=vip11, sample_read_counts_cutoff=vip12)'>> ${v_logfile} 2>>${v_dir_err} \
		"${vin_opt_mars[0]/#*=}" "${vin_opt_mars[1]/#*=}" "${vin_opt_mars[2]/#*=}" \
		"${vin_opt_mars[3]/#*=}" "${vin_opt_mars[4]/#*=}" "${vin_opt_mars[5]/#*=}" \
		"${vin_opt_mars[6]/#*=}" "${vin_opt_mars[7]/#*=}" "${vin_opt_mars[8]/#*=}" \
		"${vin_opt_mars[9]/#*=}" "${vin_opt_mars[10]/#*=}" "${vin_opt_mars[11]/#*=}" && eval $vstat_update
		# POST STEP
		v_exit_catch='{metrics,normalized_mapped,normalized_preMapped,normalized_unmapped,renormalized_mapped_forModelling,*.log,*.csv}'
		func_status_exit ${istep} ${vin_O_dir} '*' 'NULL' 'NULL' 'NULL' 'NULL' 'NULL' 'NULL' 'DONE'
		outfile='/home/seqc_user/seqc_project/final_reports/mars_out'
		mkdir -p "${outfile}"
		# OoD final out relocation approach
		if [ $var_BLOCK = 'F' ];then
		# check for pre existing output in mars
			if [[ -d "${outfile}"/"${vout_sX/#*\/}" ]];then
				if (( ${vopt_dbug} ));then
					printf 'FUNC_general_DBUG(LINE%s): Pre-existing FINAL MARS out dir, generating new dir\n' "${LINENO}" >> ${v_logfile_dbug}
				fi
				vin_O_dir="${outfile}"/"${vout_sX/#*\/}"
				vin_O_dir=${vin_O_dir/%_?}_$(( $(find "${vin_O_dir/%_?}"_*/ -maxdepth 0 -type d 2>/dev/null | wc -l) + 1 ))
				if (( ${vopt_dbug} ));then
					printf 'FUNC_general_DBUG(LINE%s): New MARS out dir:%s\n' "${LINENO}" "${vin_O_dir}" >> ${v_logfile_dbug}
				fi
				# transfer variables
				outfile="${vin_O_dir}"
			fi
		fi
		printf 'Relocation of final product: (from) %s -> (to) %s\n' "${vout_sX}" "${outfile}" >> ${v_logfile}
		mv -f --update --backup=simple "${vout_sX}/"* "${outfile}"
		# MARS status update and export for matlab - currently unused
		VLOG_MATLAB_MARS=1
	else
		# Ops for namepass fail - TODO messaging etc
		eval "rm ${vstat_name}" 2> /dev/null
	fi # EoNamePass
fi # EoSTAT3
# EoStandard SR run

#End of run log
if (( ${vopt_log} ));then
# set success/fail based on outcome
# cycle through step status and replace run_status
	for istep in "${vopt_step[@]}";do
		vstat_test=0
		vstat_step=$( func_status_adj "get" "${v_logfile_status}" "STATE" "step"${istep} )
		[[ "${vstat_step}" = 'PENDING' ]] && vstat_test=1 || vstat_test=0
		[[ "${vstat_step}" = 'DONE' ]] && vstat_done=1 || vstat_done=0
#		printf 'test:%s done:%s\n' "${vstat_test}" "${vstat_done}"
		( (( $vstat_test )) && [[ -z ${vstat_block} ]] ) && vstat_block=1
	done
	# be really sure
	( [[ -z ${vstat_block} ]] && (( $vstat_done )) ) && vstat_done=1 || vstat_done=0
	# log statement
	v_print_head='SeqC AS Flux pipeline run has completed'
	v_TS=$(date)
	if (( $vstat_done ));then
		func_status_adj "set" "${v_logfile_status}" "STATE" "run_status" "DONE"
		v_print_type='SUCCESS :D'
	else
		v_print_type='FAILURE XO'	
	fi
	printf '%s\n%s\n\tStatus: %s\nEnd time: %s\n%s\n' "${v_logblock0}" "${v_print_head}" "${v_print_type}" "${v_TS}" "${v_logblock0}" >> ${v_logfile}
	#STATE:FS:run_status:FS:PENDING
	if (( $vstat_done ));then
		# successful exiting
		# Relocate input taxonomy for mars to final out
		# PERSEPHONE FIX - REDUND
#		if [[ ! -z ${v_mars_kin} ]];then
#			mv ${v_mars_kin} /home/seqc_user/seqc_project/final_reports/
#		fi
		# exit keep-clean
		if (( ${vopt_keep} ));then
			printf 'All files retained\n' >> ${v_logfile}
		else
			# report size
			v_drop_size=$(eval "du -shc ${v_drop_exit}" | grep 'total')
			printf 'EXIT: Removing all intermediary files(%s)\n' "${v_drop_size}" >> ${v_logfile}
			# remove
			eval "rm ${v_drop_exit}" 2> /dev/null
		fi
		# append refs to main log
		v_print_head=$( printf '%s\n%s\n%s\n' "${v_logblock0}" "# Reference Section" "${v_logblock0}" )
		printf '%s\n%s\n' "${v_print_head}" "$(< ${v_logfile_ref} )" >> ${v_logfile}
		# append debug to main log if created
		if (( ${vopt_dbug} ));then
			printf '%s\n' "$(< ${v_logfile_dbug} )" >> ${v_logfile}
		fi
		# append status
		printf '%s\n' "$(< ${v_logfile_status} )" >> ${v_logfile}
		# append mars status for matlab
		if (( ${VLOG_MATLAB_MARS} ));then
			v_print_head=$( printf '%s\n%s\nVLOG_MATLAB_MARS=%s\n%s\n' "${v_logblock0}" "# Export Variable Section" "${VLOG_MATLAB_MARS}" "${v_logblock0}")
			printf '%s\n' "${v_print_head}" >> ${v_logfile}
		fi
		# Remove joined logs
		rm ${v_logfile_ref}
		rm ${v_logfile_dbug}
		rm ${v_logfile_status}
		# Relocate log to final outpput dir
		mv ${v_logfile} /home/seqc_user/seqc_project/final_reports/ 2> /dev/null
		# Relocate taxonomy output
		v_drop_catch='KB_S_mpa_out_{RC,RA}.txt'
		eval "mv ${vout_s2}/${v_drop_catch} /home/seqc_user/seqc_project/final_reports/" 2> /dev/null
		# TODO more elaborate permissions transfer approach
		# pot. grab user ID at start and set ownership directly
		chmod -R +777 /home/seqc_user/seqc_project/final_reports/*
	fi
	printf 'SeqC Stuff ENDS @: %s\n' "$(date +"%Y.%m.%d %H.%M.%S (%Z)")"
fi #END of exit log and check

if [[ ${v_scrp_check} -eq 0 ]];then
	#startup splash - ascii gen from: https://patorjk.com/software/taag, standard,slant,alpha,isometric1,impossible
	#https://medium.com/@Frozenashes/making-a-custom-startup-message-for-a-linux-shell-using-bashrc-and-bash-scripting-280268fdaa17
	func_splash() {
  	#if null create
		if [[ -z "${VEN_SPLASH}" ]]; then
			echo "VEN_SPLASH="\"1\" >> /etc/environment
			echo "export VEN_SPLASH=1" >>  /root/.bashrc
			echo "BASH_seqc_mama.sh -2" >> /root/.bashrc
			source /etc/environment
			source /root/.bashrc
			export VEN_SPLASH=1
			declare -x VEN_SPLASH=1
			exit 1
		fi
		if [[ ${VEN_SPLASH} -eq 0 ]];then echo "^-_-^"; fi
		if [[ ${VEN_SPLASH} -eq 1 ]];then
			printf '\nInitialising';sleep 0.5s;printf '.';sleep 0.5s;printf '.';sleep 0.5s;printf '.';sleep 0.5s;printf 'XP\n';sleep 0.5s
			#possible system info with screenfetch...
			#screenfetch -n
			cat << "EOF"
 ___                                   _                ____                              _
/ __|  ___  __ _ _   _  ___ _ __   ___(_)_ __   __ _   / ___|___  _ ____   _____ _ __ ___(_) ___  _ __
\__ \ / _ \/ _` | | | |/ _ | '_ \ / __| | '_ \ / _` | | |   / _ \| '_ \ \ / / _ | '__/ __| |/ _ \| '_ \
 __) |  __| (_| | |_| |  __| | | | (__| | | | | (_| | | |__| (_) | | | \ V |  __| |  \__ | | (_) | | | |
|___/ \___|\__, |\__,_|\___|_| |_|\___|_|_| |_|\__, | _\____\___/|_| |_|\_/ \___|_|  |___|_|\___/|_| |_|
    / \   ___ | |  ___ _ __ ___ | |__ | |_   _ |___// __|  ___  _   _ _ __ ___ ___  __| | |  ___| |_   ___  __
   / _ \ / __/ __|/ _ | '_ ` _ \| '_ \| | | | |  __ \__ \ / _ \| | | | '__/ __/ _ \/ _` | | |_  | | | | \ \/ /
  / ___ \\__ \__ |  __| | | | | | |_) | | |_| | |__| __) | (_) | |_| | | | (_|  __| (_| | |  _| | | |_| |>  <
 /_/   \_|___|___/\___|_| |_| |_|_.__/|_|\__, |     |___/ \___/ \__,_|_|  \___\___|\__,_| |_|   |_|\__,_/_/\_\
         _______              _______     |___/    _______              _______
        /::\    \            /::\    \            /::\    \            /::\    \
       /::::\    \          /::::\    \          /::::\    \          /::::\    \
      /::::::\    \        /::::::\    \        /::::::\    \        /::::::\    \
     /:::/\:::\    \      /:::/\:::\    \      /::::::::\    \      /:::/\:::\    \
    /:::/__\:::\    \    /:::/__\:::\    \    /:::/~~\:::\    \    /:::/  \:::\    \
    \:::\   \:::\    \  /::::\   \:::\    \  /:::/    \:::\    \  /:::/    \:::\    \
  ___\:::\   \:::\    \/::::::\   \:::\    \/:::/    / \:::\    \/:::/    / \:::\    \
 /\   \:::\   \:::\____\::/\:::\   \:::\____\::/____/   \:::\____\::/    /   \:::\____\
/::\   \:::\   \::/    /:/__\:::\   \::/    /:|    |    |:::|    |::____/     \::/    /
\:::\   \:::\   \/____/::\   \:::\   \/____/::|____|    |:::|____|::\    \     \/____/
 \:::\   \:::\____\   \:::\   \:::\____\   |:::\   _\___/:::/    /:::\    \
  \:::\  /:::/    /    \:::\   \::/    /    \:::\ |::| /:::/    / \:::\    \
   \:::\/:::/    /______\:::\   \/____/______\:::\|::|/:::/    /___\:::\    \    _____    _____     ______
    \::::::/    //::\    \:::\    \  /::\    \\::::::::::/    /:    \:::\    \ /::\____\/::\____\  |::|   |
     \::::/    //::::\    \:::\____\/::::\    \\::::::::/    /::\    \:::\____\:::/    /:::/    /  |::|   |
      \::/    //::::::\    \::/    /::::::\    \\::::::/____/::::\    \::/    /::/    /:::/    /   |::|   |
       ~~~~~~//:::/\:::\    \~~~~~/:::/\:::\    \ |::|___|/::/\:::\    \~~~~~:::/    /:::/    /    |::|   |
             /:::/__\:::\    \   /:::/__\:::\    \~~~~  /:::/__\:::\    \  /:::/    /:::/    /     |::|   |
            /::::\   \:::\    \  \:::\   \:::\    \    /::::\   \:::\    \/:::/    /:::/    /      |::|   |
           /::::::\   \:::\    \ _\:::\   \:::\    \  /::::::\   \:::\    \::/    /:::/    /___ ___|::|___|____ ____
          /:::/\:::\   \:::\____\  \:::\   \:::\____\/:::/\:::\   \:::\____\/    /:::/____/:::/\    \::::::::::|    |
         /:::/  \:::\  /:::/    /   \:::\   \::/    /:::/  \:::\   \::/    /    /:::|    ||::/::\____\:::::::::|____|
         \::/    \:::\/:::/    /:\   \:::\   \/____/\::/    \:::\   \/____/____/.:::|____|~~/:::/    /|~~~~~~~~~~
          \/____/ \::::::/    /:::\   \ ::\    \     \/____/ \:::\    \\:::\    \:::\    \ /:::/    /:|   |
                   \::::/    / \:::\   \:::\____\             \:::\____\\:::\    \:::\    /:::/    /::|   |
                   /:::/    /   \:::\  /:::/    /              \::/    / \:::\    \:::\__/:::/    /|::|   |
                  /:::/    /     \:::\/:::/    /                \/____/   \:::\    \::::::::/    / |::|   |
                 /:::/    /       \::::::/    /                            \:::\    \::::::/    /  |::|   |
                /:::/    /         \::::/    /                              \:::\____\::::/    /   |::|___|
                \::/    /           \::/    /                                \::/    /\::/____/     ~~~~~
         ____    \/____/    ____     \/____/        __          __         ___\/____/_ ~~__ _
        /  \ \   /\ \      /  \ \     /  \ \       |\ \        /\ \       /  \ \   /\_\ /  \ \
       / /\ \ \  \ \ \    / /\ \ \   / /\ \ \     /\__ \       \ \ \     / /\ \ \_/ / // /\ \ \
      / / /\ \_\ /\ \_\  / / /\ \_\ / / /\ \_\   / / __/       /\ \_\   / / /\ \___/ // / /\ \_\
     / / /_/ / // /\/_/ / / /_/ / // /_/__\/_/  / / /         / /\/_/  / / /  \/____// /_/_ \/_/
    / / /__\/ // / /   / / /__\/ // /____/\    / / /         / / /    / / /    / / // /____/\
   / / /_____// / /   / / /_____// /\____\/   / / /         / / /    / / /    / / // /\____\/
  / / /   ___/ / /_  / / /      / / /______  / /_/_____  __/ / /__  / / /    / / // / /_____
 / / /   /\__\/_/__\/ / /      / / /_______\/_________/\/\_\/_/___\/ / /    / / // / /_______\
 \/_/    \/________/\/_/       \/__________/\_________\/\/________/\/_/     \/_/ \/__________/
EOF
		sleep 1.0s
		# Additional startup info - expand
		printf 'Welcome %s!\n' "${venv_seqcusr}"
		# Create proc dirs as .gitkeep blocks action on fresh build - expand
		printf 'Checking for expected folder structure...\n'
		mkdir -p ${v_dir_db}/REPO_host/{hsap,hsap_contam,mmus,btau}/bowtie2/
		mkdir -p ${v_dir_db}/REPO_tool/{kraken,humann,checkm2,mmseqs2,ncbi_NR}/
		mkdir -p ${v_dir_db}/DEPO_demo/demo/{tmp,camisim/AGORA_smol/{genomes,run_params}}/
		#tmp failing to create now?!?!
		mkdir -p ${v_dir_db}/DEPO_proc/{logs,tmp}/ 2> /dev/null
		# relocate taxa2proc files
		mkdir -p ${v_dir_db}/REPO_tool/kraken/t2p
		mv /tmp/taxa2proc_*_out.txt ${v_dir_db}/REPO_tool/kraken/t2p
		# syslink of log dir
		# currently impossible with docker: ln -s ${v_logfile%/*}/ ${venv_dir_proc}
		# Display info
		printf 'Current directory       : %s\n' "$PWD"
		printf 'Expected input location : %s\n' "${venv_dir_in}"
		printf 'Expected output location: %s\n' "${venv_dir_out}"
	fi
	if [[ ${VEN_SPLASH} -eq 2 ]];then printf 'Sequencing Conversion Assembly-Sourced Flux pipeline -- SeqC AS Flux -- version %s\n' ${v_version}; fi
}
fi #Eocheck=0
((v_scrp_check++))
done #Eowhile
#EoB