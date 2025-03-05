#!/bin/bash
#======================================================================================================#
# Title: mama script: take run commands, est db link, run stepgen
# Program by: Wiley Barton - 2022.02.27
# Modified for conda/docker pipeline - 2024.02.22
# last update - 2025.01.30
# Modified code sources:
#   https://stackoverflow.com/questions/2043453/executing-multi-line-statements-in-the-one-line-command-line
# Notes: generate bash files according to user input for the completion of pipeline
#   on initial build of container:
#    1)run dockerfile:
#      docker build -t dock_seqc --ulimit nofile=65536:65536 .
#    2)run with vol mapping:
  #docker run --interactive --tty --user 0 --rm \
  #--mount type=bind,src=$(pwd)/seqc_input/,target=/home/seqc_user/seqc_project/step0_data_in \
  #--mount type=bind,src=$(pwd)/seqc_output/,target=/home/seqc_user/seqc_project/final_reports \
  #--mount type=volume,dst=/DB,volume-driver=local,volume-opt=type=none,volume-opt=o=bind,volume-opt=device=$(pwd)/seqc_proc dock_seqc \
  #dock_seqc /bin/bash
#    3)initialise this script via calls to BASH_seqc_mama.sh
# ToDo:
#  Resolve spp id/taxid with APOLLO reconstruction ID for complete DB pulling/report - SUPER COMLICATED!
#	Clean-up of unused data
#	redirect/suppress mars stand out
#  create and upload kraken etc. DBs for agora/apollo etc to dataverse and integrate pull over fresh creation
#  restructure logging to parsable long format: {ID}/t{VARIABLE}/t{VALUE}
#	LOG_MAMA_DBUG_LN100/tFILE_COUNT/t50
#	LOG_REF/tSeqC/t'the complete reference'
#  devise and implement an estimate of run time based on resources, file size, steps/stage, etc
#  check DB config at start and set logic gates for DBs with integration in mama steps
#  seq file mated ext detection ie R1_ R2_
#  internal run log file to track in/out dirs for all steps to use as run-resume core
#    precalculate step configs and vars according to submitted run
#  implement cross step paralelisation
#  -d DB dir in main func, use it!
#  debug opt expansion
#  flesh out func_demo to build complete demo run within /DB/DEPO_demo
#  auto compile file list from input dir in absence of provided list
#  expand splash to include system params: cpu, mem, du of key directories
#refs
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
seqc_dir_proc=
var_rep_ary[0]=''
var_rep_len=${#var_rep_ary[@]}
#size check -db
v_vol_real=$(du -bs $v_dir_db | cut -f1 )
v_vol_none=60000
v_scrp_check=0
#var_rep_ary[var_rep_len]='x/y/z/cat'*'.kitty'
#var_rep_out=${var_rep_ary[@]}
# Step logic gate variables
var_log_S0_0=0
var_log_S1_0=0
var_log_S2_0=0
var_log_S2_1=0
var_log_S2_2=0
var_log_S2_3=0
var_log_S3_0=0
var_log_S3_1=0
# Optional flag logic gates
# gate to only run log for valid run flags
vopt_log=0
vopt_dbug=0
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
v_version='1.0.0'
declare VEN_SPLASH
# user input of script
v_com_log="$@"
#----------------------------------------------------------------------------------------
# Directory check/config
#----------------------------------------------------------------------------------------
mkdir -p /DB/{DEPO_demo,DEPO_proc/{logs,tmp},REPO_host/{btau,hsap,hsap_contam,mmus}/bowtie2,REPO_tool/{checkm2,humann,kraken,mmseqs2,ncbi_NR}}/
# TODO check for and link req dirs ie ln -s "${v_ndmp}" "${v_kdmp}"
#----------------------------------------------------------------------------------------
# Logging check/config
#----------------------------------------------------------------------------------------
# after fresh build: v_logfile="log_"${v_proj}".txt" v_logdir=${v_dir_work}/logs
# TODO: improve to adjust .bashrc etc
# Determine logdir pos
if [[ ${v_logdir} = ${v_dir_work}/logs ]];then
	if [[ -d ${v_logdir} ]];then
		if [[ -d ${venv_dir_proc}/logs ]];then
		#move files
			mv ${v_logdir}/* ${venv_dir_proc}/logs/ 2> /dev/null 
		else
		#move dir
			mv ${v_logdir} ${venv_dir_proc} 2> /dev/null 
		fi
	#else
	#no default dir, check proc
	fi
	# remove if empty default
	if [[ ! -f ${v_logdir}/${v_logfile} ]];then 
		rm -rf ${v_logdir}
	fi
	#set to proc
	v_logdir=${venv_dir_proc}/logs
fi
# Merge vars - needs checks
v_logfile=${v_logdir}/${v_logfile}
#----------------------------------------------------------------------------------------
# Core programme
#----------------------------------------------------------------------------------------
while [[ ${v_scrp_check} -lt 2 ]];do
if [[ ${v_scrp_check} -eq 0 ]];then
# Functions
func_help () {
# Help content
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
func_mama () {
# Main pipeline function
# each call performs step with pre and post checks
# steps defined outside script
# TODO: Modify check structure to be compatible with new approach of 'input statements', pot. parse statement or use separate field for dir
#  call str change: local vloc_dir_I="${2}" -> local vloc_I_dir="${2}" local vloc_dir_O="${3}" -> local vloc_O_dir="${4}" 
#  call structure:  -s <step> -i <input dir> -o <output dir> -c <commands per stepgen@$v_com> -h <head of files, from first char to start of tail>
#     -t <file tail, ~extension, constant across all input> -n <unique names linking sample to file(s)> -e <explicit umamba environment>
#     -p <name of package used in step, currently redunt>
#    string=<h><t>=<'sample{1..9}_R{1,2}'><'.fastq.gz'>
# PRECHECK
	local vloc_step="${1}"
	#local vloc_dir_I="${2}"
	local vloc_I_dir="${2}"
	local vloc_I_com="${3}"
	#local vloc_dir_O="${3}"
	local vloc_O_dir="${4}"
	local vloc_O_com="${5}"
	local vloc_com="${6}"
	local vloc_head="${7}"
	local vloc_tail="${8}"
	local vloc_name="${9}"
	local vloc_env="${10}"
	local vloc_pac="${11}"
	local vloc_scrp="${12}"
	local vloc_dbug="${13}"
	local vloc_string=${vloc_head}${vloc_tail}
	# Check for input
	if [[ ! -d $vloc_I_dir ]];then
		echo "FUNC_MAMA: CRITICAL ERROR: Input directory for Step "$vloc_step "is missing"
		echo "FUNC_MAMA: CRITICAL HELP: Check validity of: "$vloc_I_dir
		exit 1
	fi
		# DEBUG input check
	if (( ${vloc_dbug} ));then
	printf 'FUNC_MAMA: DEBUG: step: %s dir_I: %s comm_I: %s dir_O: %s comm_O: %s coms: %s head: %s tail: %s name: %s env: %s pack: %s scrp: %s DEBUG: %s\n' \
	"${vloc_step}" "${vloc_I_dir}" "${vloc_I_com}" "${vloc_O_dir}" "${vloc_O_com}" "${vloc_com}" "${vloc_head}" "${vloc_tail}" "${vloc_name}" "${vloc_env}" "${vloc_pac}" "${vloc_scrp}" "${vloc_dbug}" >> ${v_logfile_dbug}
	fi
		# Check for output dir
	if (( ${vloc_dbug} ));then
		if [[ ! -d $vloc_O_dir ]];then
			echo "FUNC_MAMA: CRITICAL ERROR: Output directory for Step "$vloc_step "is missing" >> ${v_logfile_dbug}
			echo "FUNC_MAMA: CRITICAL HELP: Creating output directory for Step: "$vloc_step >> ${v_logfile_dbug}
		else
			if [ $( ls -1 $vloc_O_dir/$vloc_string 2>/dev/null | wc -l ) -gt 0 ];then
				echo "FUNC_MAMA: Stuff is already in output directory" >> ${v_logfile_dbug}
			fi
		fi
	fi
	if [[ ! -f $vloc_name ]];then
		echo "FUNC_MAMA: CRITICAL ERROR: Name file for Step "$vloc_step "is missing"
		echo "FUNC_MAMA: CRITICAL HELP: Attempting to create sample name file"
		echo "FUNC_MAMA: CRITICAL ERROR: Functionality currently missing, manually create :3"
		echo "  ex: var_sample_uniq=(sample{1..9});printf '%s\n' ${var_sample_uniq[@]} > file_in_samples"
		exit 1
	else
		if [ $( ls -1 $vloc_O_dir/$vloc_string 2>/dev/null | wc -l ) -gt 0 ];then
			echo "FUNC_MAMA: Input files located" >> ${v_logfile_dbug}
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
	fi
	#script generation
	# EXTERNAL: func_mama |"${istep}" |"${vin_I_dir}" |"${vin_I_com}" |"${vin_O_dir}" |"${vin_O_com}" |"${vin_com}" |"${vin_head}" |"${vin_tail}" |"${vin_name}" |"${vin_env}" |"${vin_pac}" |"${v_scrp_job}" |"${vopt_dbug}"
	# INTERNAL: func_mama |$vloc_step |$vloc_I_dir    |$vloc_I_com    |$vloc_O_dir    |$vloc_O_com    |$vloc_com    |$vloc_head    |$vloc_tail    |$vloc_name    |$vloc_env    |$vloc_pac    |$vloc_scrp      |$vloc_dbug
	# DESCRIBE: func      |pars-CLI   |internal       |pars-CLI       |internal       |pars-CLI       |pars-CLI     |pars-CLI      |pars-CLI      |pars-CLI      |internal     |internal     |pars-CLI        |internal
	BASH_seqc_stepgen.sh "${vloc_I_com}" "${vloc_O_com}" "${vloc_env}" "${vloc_pac}" "$vloc_com"
	bash $vloc_scrp "${vloc_name}"
	# POSTCHECK
	# TODO
}
#EoFunc - mama
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
	vlog_seqc=0
	vlog_kneaddata=0
	vlog_spades=0
	vlog_vamb=0
	vlog_checkm2=0
	vlog_minimap2=0
	vlog_humann=0
	vlog_kraken=0
	vlog_mmseqs2=0
	vlog_camisim=0
	vlog_mars=0
	vlog_seqkit=0
	vlog_taxonkit=0
	if [[ "${1}" = "ALL" ]];then
		vlog_seqc=1
		vlog_kneaddata=1
		vlog_spades=1
		vlog_vamb=1
		vlog_checkm2=1
		vlog_minimap2=1
		#vlog_humann=1
		vlog_kraken=1
		vlog_mmseqs2=1
		vlog_camisim=1
		vlog_mars=1
		vlog_seqkit=1
		vlog_taxonkit=1
	fi
	if [[ "${1}" = "SR" ]];then
		vlog_seqc=1
		vlog_kneaddata=1
		vlog_kraken=1
		vlog_mars=1
	fi
	if [[ "${1}" = "MAG" ]];then
		vlog_seqc=1
		vlog_kneaddata=1
		vlog_spades=1
		vlog_vamb=1
		vlog_checkm2=1
		vlog_minimap2=1
		vlog_mmseqs2=1
		vlog_mars=1
		vlog_seqkit=1
		vlog_taxonkit=1
	fi
	#seqc kneaddata spades vamb checkm2 minimap2 kraken mmseqs2 camisim mars seqkit taxonkit
	if [[ "${1}" = "seqc" ]];     then vlog_seqc=1;fi
	if [[ "${1}" = "kneaddata" ]];then vlog_kneaddata=1;fi
	if [[ "${1}" = "spades" ]];   then vlog_spades=1;fi
	if [[ "${1}" = "vamb" ]];     then vlog_vamb=1;fi
	if [[ "${1}" = "checkm2" ]];  then vlog_checkm2=1;fi
	if [[ "${1}" = "minimap2" ]]; then vlog_minimap2=1;fi
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
	if [[ "${vlog_spades}" -eq 1 ]];then
		v_nom='metaSPAdes'
		v_ver=$(micromamba run -n env_s2_spades spades.py --version)
		v_ref=$(printf 'Nurk, S., Meleshko, D., Korobeynikov, A. and Pevzner, P.A., 2017. metaSPAdes: a new versatile metagenomic assembler. Genome research, 27(5), pp.824-834. doi.org/10.1101/gr.213959.116\n')
		printf '%s\n%s\n\t%s\n' "${v_nom}" "${v_ver}" "${v_ref}"
	fi
	if [[ "${vlog_vamb}" -eq 1 ]];then
		v_nom='AVAMB'
		v_ver=$(micromamba run -n env_s3_vamb vamb --version)
		#sic:Líndez
		v_ref=$(printf 'Lindez, Pau Piera, et al. "Adversarial and variational autoencoders improve metagenomic binning." Communications Biology 6.1 (2023): 1073.')
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

		#EoBranch - short read
	fi
	#Branch to assembly
	if [[ "${vopt_branch}" = "MAG" ]] || [[ "${vopt_branch}" = "ALL" ]];then
		#run assembly with metaspades
		##interlaced/joined fqs --only-assembler on previously corrected reads
		###--merged "${v_dir_in}"/camisim_agora_smol_s"${v_i}"_1_kneaddata.fastq \
		#agora simulation
		v_dir_in='/DB/DEPO_demo/demo/step1_kneaddata'
		v_len=$( ls -1 "${v_dir_in}"/camisim_agora_smol_s*_1_kneaddata.fastq | wc -l )
		for (( v_i=0; v_i<${v_len}; v_i++ ));do
		micromamba run -n env_s2_spades spades.py --meta \
		-1 "${v_dir_in}"/camisim_agora_smol_s"${v_i}"_1_kneaddata_paired_1.fastq \
		-2 "${v_dir_in}"/camisim_agora_smol_s"${v_i}"_1_kneaddata_paired_2.fastq \
		--only-assembler -k 21,29,39,59,79,99 --threads 48 --memory 200 \
		-o /DB/DEPO_demo/demo/step2_spades/agora_smol/S"${v_i}"
		done
		#micromamba run -n env_s2_spades spades.py --meta -1 /DB/DEPO_demo/demo/step1_kneaddata/camisim_agora_smol_s1_1_kneaddata_paired_1.fastq \
		#-2 /DB/DEPO_demo/demo/step1_kneaddata/camisim_agora_smol_s1_1_kneaddata_paired_2.fastq --merged /DB/DEPO_demo/demo/step1_kneaddata/camisim_agora_smol_s1_1_kneaddata.fastq \
		#-k 21,29,39,59,79,99 --threads 48 --memory 200 -o /DB/DEPO_demo/demo/step2_spades/agora_smol/S1_TEST
		#VAMB util: combine contig fasta into single fasta file (catalogue) and drop <2kbp contigs
		# converts S from 0-9, 1-10
		##agora simulation
		micromamba run -n env_s3_avamb python /lib/vamb/src/concatenate.py \
		/DB/DEPO_demo/demo/step2_spades/agora_smol/catalogue.fna.gz \
		/DB/DEPO_demo/demo/step2_spades/agora_smol/S{0..9}/contigs.fasta
		#agora sim
		micromamba run -n env_s3_minimap2 minimap2 -t 28 \
		-d /DB/DEPO_demo/demo/step2_spades/agora_smol/catalogue.mmi \
		/DB/DEPO_demo/demo/step2_spades/agora_smol/catalogue.fna.gz
		#bam map to contigs -K NUM       minibatch size for mapping [500M] 1G
		#agora sim https://broadinstitute.github.io/picard/explain-flags.html
		#micromamba run -n env_s3_minimap2 samtools view -F 0x904 /DB/DEPO_demo/demo/step3_minimap/camisim_s0.bam | less
		v_dir_in='/DB/DEPO_demo/demo/step1_kneaddata'
		v_len=$( ls -1 "${v_dir_in}"/camisim_agora_smol_s*_1_kneaddata.fastq | wc -l )
		for (( v_i=0; v_i<${v_len}; v_i++ ));do
		micromamba run -n env_s3_minimap2 minimap2 -t 48 -N 5 -a -x sr \
		/DB/DEPO_demo/demo/step2_spades/agora_smol/catalogue.mmi --split-prefix mmsplit \
		"${v_dir_in}"/camisim_agora_smol_s"${v_i}"_1_kneaddata_paired_1.fastq \
		"${v_dir_in}"/camisim_agora_smol_s"${v_i}"_1_kneaddata_paired_2.fastq | \
		micromamba run -n env_s3_minimap2 samtools sort -F 3584 --threads 48 --output-fmt BAM \
		-o /DB/DEPO_demo/demo/step3_minimap/camisim_s"${v_i}".bam
		done
		#bin - without --minfasta, does not generate bins just everything else --model vae,aae,vae(both)
		#micromamba run -n env_s3_avamb python vamb/src/create_fasta.py /DB/demo/example_run/contigs/catalogue.fna.gz /DB/demo/example_run/avamb_outdir/vae_clusters.tsv /DB/demo/example_run/avamb_bins 200000
		#agora sim
		micromamba run -n env_s3_avamb vamb -o C -p 48 --outdir /DB/DEPO_demo/demo/step3_vamb/agora_smol \
		--fasta /DB/DEPO_demo/demo/step2_spades/agora_smol/catalogue.fna.gz \
		--bamfiles /DB/DEPO_demo/demo/step3_minimap/camisim_s*.bam --minfasta 200000 --model vae
		#QC with checkm2 ~10min/sample
		micromamba run -n env_s3_checkm2 checkm2 predict \
		--input /DB/DEPO_demo/demo/step3_vamb/agora_smol/bins/S*/*.fna \
		--output-directory /DB/DEPO_demo/demo/step3_checkm2 \
		--threads 48 --database_path /DB/REPO_tool/checkm2/CheckM2_database/uniref100.KO.1.dmnd \
		--force
		#mmseqs taxonomic assignment
		## DB config
		#create taxa db
		micromamba run -n env_s4_mmseqs2 mmseqs databases NR /DB/DEPO_demo/mmseqs_proc/ncbi_NR /DB/demo/tmp
		#alt approach to resolv mapping is empty issue
		micromamba install -n env_s4_mmseqs2 -c bioconda -c conda-forge blast
		#create tax mapping for NR - pot issue arising from irregular database install
		micromamba run -n env_s4_mmseqs2 mmseqs nrtotaxmapping /DB/DEPO_demo/REPO_tool/ncbi_NR/pdb.accession2taxid /DB/DEPO_demo/REPO_tool/ncbi_NR/prot.accession2taxid /DB/DEPO_demo/mmseqs_proc/ncbi_NR /DB/DEPO_demo/mmseqs_proc/ncbi_NR_mapping --threads 72
		#DB subset
		#adjust to feed in from db creation in seqc_makedb
		##pull list of taxa for agora2 - https://superuser.com/questions/642555/how-can-i-view-all-files-in-a-websites-directory?newreg=d78fd16672e14931adf176961b9e991f
		lftp -e "cls -1 > agora_taxa_raw.txt; exit" "https://www.vmh.life/files/reconstructions/AGORA2/version2.01/sbml_files/individual_reconstructions/"
		##parse to pull input for DB refinement
		awk 'BEGIN {FS="\t";OFS=FS} {if(NR >= 0){print $1}}' /DB/DEPO_demo/demo/agora_taxa_raw.txt | awk -F '.xml' '{print "\""gensub(/_/," ","g",$1)"\""}' > /DB/DEPO_demo/demo/agora_taxa_awk.txt
		mapfile -t v_id_in < <( cat /DB/DEPO_demo/demo/agora_taxa_awk.txt )
		printf 'datasets summary taxonomy taxon %s --report ids_only --as-json-lines | dataformat tsv taxonomy --template tax-summary | cut --fields 1,2' "${v_id_in[*]}" > /DB/DEPO_demo/demo/v_id_out
		#datasets summary taxonomy taxon "Abiotrophia defectiva ATCC 49176" --report ids_only --as-json-lines | dataformat tsv taxonomy --template tax-summary | cut --fields 1,2
		v_id_mmseq=$( bash /DB/DEPO_demo/demo/v_id_out 2> /DB/DEPO_demo/demo/v_id_fail | tail -n +2 | cut --fields 2 )
		#mapfile -t v_id_mmseq < <( bash /DB/DEPO_demo/demo/v_id_out 2> /DB/DEPO_demo/demo/v_id_fail | tail -n +2 | cut --fields 2 )
		#datasets download genome taxon ${v_id_ncbi} --assembly-level complete --assembly-source RefSeq --assembly-version latest --filename 
		#testing mars/ant https://www.johndcook.com/blog/2022/08/16/python-pickle/
		##micromamba env create --name py_test python=3.8 -c conda-forge
		##git clone -b master https://github.com/ThieleLab/mars-pipeline.git /DB/DEPO_demo/demo/mars_ant
		##ant_pik_out = pickle.load(open("/DB/DEPO_demo/demo/mars_ant/ANT/agora2_species.pkl", "rb"))
		##with open("ant_pik_out.txt","a") as f: pprint.pprint(ant_pik_out, stream=f)
		##subset
		micromamba run -n env_s4_mmseqs2 mmseqs filtertaxseqdb /DB/DEPO_demo/mmseqs_proc/ncbi_NR \
		/DB/DEPO_demo/mmseqs_proc/ncbi_NR_AGORA2_240610_TEST --taxon-list ${v_id_mmseq// /,} 
		#from dled NR: createdb /DB/demo/tmp//5184093044113700545/nr.gz /DB/DEPO_demo/mmseqs_proc/ncbi_NR --compressed 0 -v 3
		#micromamba run -n env_s4_mmseqs2 mmseqs createdb /DB/DEPO_demo/REPO_tool/ncbi_NR/nr.gz /DB/DEPO_demo/mmseqs_proc/ncbi_NR --compressed 0 -v 3
		micromamba run -n env_s4_mmseqs2 mmseqs createtaxdb /DB/DEPO_demo/mmseqs_proc/ncbi_NR /DB/DEPO_demo/demo/tmp --threads 72 -v 3 --tax-db-mode 1
		#micromamba run -n env_s4_mmseqs2 mmseqs createtaxdb /DB/DEPO_demo/mmseqs_proc/ncbi_NR /tmp
		##query db - input
		##agora sim mkdir /DB/DEPO_demo/demo/step4_mmseqs2
		micromamba run -n env_s4_mmseqs2 mmseqs createdb \
		/DB/DEPO_demo/demo/step3_checkm2/protein_files/vae_*.faa \
		/DB/DEPO_demo/demo/step4_mmseqs2/DBquery_agora_smol
		##agora sim - assign taxonomy - ~538G mem @ 10n w/ 21spp ~start@07/01/2024 04:56:20 PM]
		micromamba run -n env_s4_mmseqs2 mmseqs taxonomy /DB/DEPO_demo/demo/step4_mmseqs2/DBquery_agora_smol \
		/DB/DEPO_demo/mmseqs_proc/ncbi_NR \
		/DB/DEPO_demo/demo/step4_mmseqs2/result_taxonomy_agora_smol \
		/DB/DEPO_demo/demo/tmp --tax-lineage 1 --tax-lineage 2 --lca-ranks species,genus,family,order,superkingdom
		#convert to taxa summary tsv - mmseqs createtsv queryDB taxonomyResult taxonomyResult.tsv
		##CAMI
		micromamba run -n env_s4_mmseqs2 mmseqs createtsv \
		/DB/DEPO_demo/demo/step4_mmseqs2/DBquery_agora_smol \
		/DB/DEPO_demo/demo/step4_mmseqs2/result_taxonomy_agora_smol \
		/DB/DEPO_demo/demo/step4_mmseqs2/result_taxonomy_agora_smol.tsv
		#kraken style report - mmseqs taxonomyreport seqTaxDB taxonomyResult taxonomyResult_report
		micromamba run -n env_s4_mmseqs2 mmseqs taxonomyreport \
		/DB/DEPO_demo/mmseqs_proc/ncbi_NR \
		/DB/DEPO_demo/demo/step4_mmseqs2/result_taxonomy_agora_smol \
		/DB/DEPO_demo/demo/step4_mmseqs2/result_kreport_agora_smol.tsv
		##target db - expected taxa???
		#micromamba run -n env_s4_mmseqs2 mmseqs createdb /DB/demo/mmseqs/examples/DB.fasta targetDB
		##index db - use on core dbs - one index per db
		#micromamba run -n env_s4_mmseqs2 mmseqs createindex targetDB /DB/demo/tmp
		##alignment of query and target... very fast search with -s 1.0, high sensitivity with -s 7.0, --format-output "query,target,qaln,taln"
		#micromamba run -n env_s4_mmseqs2 mmseqs search queryDB targetDB resultDB /DB/demo/tmp
		##convert results to BLAST tsv???
		#micromamba run -n env_s4_mmseqs2 mmseqs convertalis queryDB targetDB resultDB resultDB.m8
		#clustering
		##convert fasta to mmseqs2 db
		#micromamba run -n env_s4_mmseqs2 mmseqs createdb /DB/demo/mmseqs/examples/DB.fasta DB
		##cluster
		#micromamba run -n env_s4_mmseqs2 mmseqs cluster DB DB_clu /DB/demo/tmp
		##cluster tsv
		#micromamba run -n env_s4_mmseqs2 mmseqs createtsv DB DB DB_clu DB_clu.tsv #optional
		##adjust modify params with https://github.com/soedinglab/MMseqs2/wiki#how-to-set-the-right-alignment-coverage-to-cluster
		##add seq info to cluster file with following... opt?
		#micromamba run -n env_s4_mmseqs2 mmseqs createseqfiledb DB DB_clu DB_clu_seq
		#micromamba run -n env_s4_mmseqs2 mmseqs result2flat DB DB DB_clu_seq DB_clu_seq.fasta
		#clustering with linclust - much faster
		## same DB as above
		#micromamba run -n env_s4_mmseqs2 mmseqs linclust DB DB_clu /DB/demo/tmp
		micromamba run -n env_s4_mmseqs2 mmseqs taxonomy /DB/DEPO_demo/mmseqs_proc/queryDB /DB/DEPO_demo/mmseqs_proc/ncbi_NR taxonomyResult /DB/DEPO_demo/demo/tmp --tax-lineage 1  --lca-ranks genus,family,order,superkingdom
		#aggregatetax module
		# collapses entire query db to single taxa... pot use with filtering with filtertaxdb
		micromamba run -n env_s4_mmseqs2 mmseqs aggregatetax \
		/DB/DEPO_demo/mmseqs_proc/ncbi_NR \
		/DB/DEPO_demo/demo/step4_mmseqs2/DBquery_agora_smol \
		/DB/DEPO_demo/demo/step4_mmseqs2/result_taxonomy_agora_smol \
		/DB/DEPO_demo/demo/step4_mmseqs2/result_taxagg_agora_smol \
		--tax-lineage 2 --lca-ranks species,genus,family,order,superkingdom
		#create tsv
		micromamba run -n env_s4_mmseqs2 mmseqs createtsv \
		/DB/DEPO_demo/demo/step4_mmseqs2/DBquery_agora_smol \
		/DB/DEPO_demo/demo/step4_mmseqs2/result_taxagg_agora_smol \
		/DB/DEPO_demo/demo/step4_mmseqs2/result_taxagg_agora_smol.tsv
		#map taxonomy to reads/contig for count data
		v_dir_bam_head_in='/DB/DEPO_demo/demo/step3_minimap/camisim_s'
		v_dir_bam_tail_in='.bam'
		v_profile_in='/DB/DEPO_demo/demo/step4_mmseqs2/result_taxonomy_agora_smol.tsv'
		v_outfile_in='/DB/DEPO_demo/demo/step4_mmseqs2/result_taxonomy_join_agora_smol.tsv'
		func_taxa_map "${v_dir_bam_head_in}" "${v_dir_bam_tail_in}" "${v_profile_in}" "${v_outfile_in}" "${vopt_dbug}"
		#Continue with generation of input for mars-ant
		if (( ${v_BLOCK} ));then
		#SUBOPT demos - pre trash
		echo 'IN BLOCK'
		#EoBLOCK - temp code
		fi
		#EoBranch - MAG
	fi
}
#EoFunc - demo
fi
#EoCHECK = 0
# read options
if [[ ${v_scrp_check} -eq 1 ]];then
# Passing valid run flags enables logging with vopt_log=1
# Generate flag based array out for log
	vopt_loger[0]=''
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
			#create debug section of log
			v_logdate=$(date +"%Y%m%d")
			v_logfile_dbug=${v_logfile/.txt/_${v_logdate}_dbug.txt}
			v_log_head='# DEBUG Section'
			printf '%s\n%s\n%s\n' "${v_logblock0}" "${v_log_head}" "${v_logblock0}" > ${v_logfile_dbug}
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
			# check in step0/
				if [[ ! -f 'step0_data_in/'${vopt_name} ]];then
				# check in final_reports/
					if [[ ! -f 'final_reports/'${vopt_name} ]];then
						if ((vopt_dbug));then
						printf 'FUNC_MAMA_HELP_DBUG(LINE%s): file name FILE missing: %s\n' "${LINENO}" "${vopt_name}" >> ${v_logfile_dbug}
						fi
					else
						vopt_name='final_reports/'${vopt_name}
					fi
				else
					vopt_name='step0_data_in/'${vopt_name}
				fi
				if [[ ! -f ${vopt_name} ]];then
			# TODO: implement fix if file missing
					if ((vopt_dbug));then
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
			if ((vopt_dbug));then
			printf 'FUNC_MAMA_HELP_DBUG(LINE%s): Check if package is cool: %s\n' "${LINENO}" "${vopt_pac}" >> ${v_logfile_dbug}
			fi
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
				if [[ ${vopt_branch} = 'MAG' ]];then
					vopt_step=( {1..5} )
				fi
				if [[ ${vopt_branch} = 'ALL' ]];then
					vopt_step=( $( eval echo {1..6} ) )
				fi
			else
				vopt_step=${OPTARG}
				vopt_part=1
			fi
			if ((vopt_dbug));then
			printf 'FUNC_MAMA_HELP_DBUG(LINE%s): Steps being run are: %s\n' "${LINENO}" "${vopt_step[*]}" >> ${v_logfile_dbug}
			fi
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
	#generate step array if unspecified and branch provided
	if (( ${vopt_log} ));then
		if [[ -z ${vopt_step} ]];then
			if [[ ${vopt_branch} = 'SR' ]];then
				vopt_step=( {1..3} )
			fi
			if [[ ${vopt_branch} = 'MAG' ]];then
				vopt_step=( {1..5} )
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
			fi
			if [[ ${vopt_branch} = 'MAG' ]];then
				vref_pac=( '' 'kneaddata' 'spades' 'avamb' 'checkm2' )
			fi
			if [[ ${vopt_branch} = 'ALL' ]];then
				vref_pac=( '' 'kneaddata' 'kraken' 'mars' 'spades' 'avamb' 'checkm2' )
			fi
			# create package list if none specified, linking to steps and branch
			for vi in ${vopt_step[@]};do
				vopt_pac[${vi}]=${vref_pac[${vi}]}
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
fi
#EoCHECK=1
if [[ ${vopt_check_log} -eq 1 ]];then
func_check
fi
# BEGIN build log file
if (( ${vopt_log} ));then
# TODO: system info, aprox runtime, elaborate for cases of long good/bad files
# history pull: v_com_log=$( history | tail -n 1 | awk '{$1=""; print substr($0,2)}' )
	#retain initial log file and overwrite variable with run specific log
	v_logdate=$(date +"%Y%m%d")
	cp ${v_logfile} ${v_logfile/.txt/_${v_logdate}.txt}
	v_logfile_base=${v_logfile}
	v_logfile=${v_logfile/.txt/_${v_logdate}.txt}
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
	else
		mapfile -t v_file_in_base < <( printf '%s\n' "$( <${vopt_name} )" )
		mapfile -t v_file_in_base < <( printf '%s\n' "${v_file_in_base[@]}" | sort )
		# uniq for final refine against bad
		mapfile -t v_file_in_uniq < <( printf '%s\n' "${v_file_in_base[@]}" | uniq )
		mapfile -t v_file_in_base < <( printf '%s\n' "${v_file_in_base[@]/#/${vopt_head}}" )
		mapfile -t v_file_in_base < <( printf '%s\n' "${v_file_in_base[@]/%/${vopt_tail}}" )
		#mapfile -t v_file_in_good < <( find ${vin_I_dir}/${v_file_in_base[@]} -maxdepth 0 -type f 2> /tmp/file_in_bad )
		mapfile -t v_file_in_good < <( find $( printf '%s\n' "${v_file_in_base[@]/#/${vin_I_dir}/}" ) -maxdepth 0 -type f 2> /tmp/file_in_bad )
		#mapfile -t v_file_in_bad < <( cat /tmp/file_in_bad )
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
			#vt_ext=$( printf '%s\n' $( ls final_reports/* | grep -o "\..*$" ) | uniq )
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
			# swap to opt variable
			mapfile -t vopt_mid < <( printf '%s\n' "${vt_MID[@]}" )
			vopt_ext=${vt_ext[0]}
		fi
		#printf '%s\n' "${v_file_in_good[@]}" | grep "\.fast[q,a]$"
	fi
	# build refs
	# CHECK if specifying single step results in correct corresponding vopt_pac
	# repeating ref gen
	v_logfile_ref="${v_logfile/.txt/_ref.txt}"
	#seqc kneaddata spades vamb checkm2 minimap2 kraken mmseqs2 camisim mars seqkit taxonkit
  	if [[ ${vopt_branch} = 'SR' ]];then
		if (( ${vopt_part} ));then
			func_ref "seqc" > ${v_logfile_ref}
			for vi in ${vopt_step[@]};do
				if [[ ${vi} -eq 1 ]];then
					func_ref "kneaddata" >> ${v_logfile_ref}
				fi
				if [[ ${vi} -eq 2 ]];then
					func_ref "kraken" >> ${v_logfile_ref}
				fi
				if [[ ${vi} -eq 3 ]];then
					func_ref "mars" >> ${v_logfile_ref}
				fi
			done
		else
			func_ref "SR" > ${v_logfile_ref}
		fi
  	fi
	if [[ ${vopt_branch} = 'MAG' ]];then
		if (( ${vopt_part} ));then
			func_ref "seqc" > ${v_logfile_ref}
			for vi in ${vopt_step[@]};do
				if [[ ${vi} -eq 1 ]];then
					func_ref "kneaddata" >> ${v_logfile_ref}
				fi
				if [[ ${vi} -eq 2 ]];then
					func_ref "kraken" >> ${v_logfile_ref}
				fi
				if [[ ${vi} -eq 3 ]];then
					func_ref "mars" >> ${v_logfile_ref}
				fi
			done
		else
		func_ref "MAG" > ${v_logfile_ref}
		#  vopt_pac=( 'kneaddata' 'spades' 'avamb' 'checkm2' )
		fi
	fi
	if [[ ${vopt_branch} = 'ALL' ]];then
		if (( ${vopt_part} ));then
			func_ref "seqc" > ${v_logfile_ref}
			for vi in ${vopt_step[@]};do
				if [[ ${vi} -eq 1 ]];then
					func_ref "kneaddata" >> ${v_logfile_ref}
				fi
				if [[ ${vi} -eq 2 ]];then
					func_ref "kraken" >> ${v_logfile_ref}
				fi
				if [[ ${vi} -eq 3 ]];then
					func_ref "mars" >> ${v_logfile_ref}
				fi
			done
		else
			func_ref "ALL" > ${v_logfile_ref}
		fi
		#vopt_pac=( 'kneaddata' 'spades' 'avamb' 'checkm2' )
	fi
fi
# END of initial log and log check
# check and switch error output to dbug log
if (( ${vopt_dbug} ));then
	v_dir_err=${v_logfile_dbug}
else
	v_dir_err='/dev/null'
fi
# Set optional arguments for particular step
# BEGIN steps
# EXTERNAL: func_mama |"${istep}" |"${vin_I_dir}" |"${vin_I_com}" |"${vin_O_dir}" |"${vin_O_com}" |"${vin_com}" |"${vin_head}" |"${vin_tail}" |"${vin_name}" |"${vin_env}" |"${vin_pac}" |"${v_scrp_job}" |"${vopt_dbug}"
# INTERNAL: func_mama |$vloc_step |$vloc_I_dir    |$vloc_I_com    |$vloc_O_dir    |$vloc_O_com    |$vloc_com    |$vloc_head    |$vloc_tail    |$vloc_name    |$vloc_env    |$vloc_pac    |$vloc_scrp      |$vloc_dbug
# DESCRIBE: func      |pars-CLI   |internal       |pars-CLI       |internal       |pars-CLI       |pars-CLI     |pars-CLI      |pars-CLI      |pars-CLI      |internal     |internal     |pars-CLI        |internal
#CRIT symlink from proc vol to home/seqc_proj/whatev
#CRIT compression at steps via un/pigz
if (( ${vopt_log} ));then
	printf 'SeqC Stuff BEGINS @: %s\n' "$(date +"%Y.%m.%d %H.%M.%S (%Z)")"
fi
for istep in "${vopt_step[@]}";do
	if [[ ${istep} -eq 1 ]];then
		#STEP1_QC
		#step log
		v_print_head='Initialising step:'
		v_print_type='QC'
		v_TS=$(date)
		printf '%s%s of %s\tstep role:%s\tstart time:%s\n' "${v_print_head}" "${istep}" "${#vopt_step[@]}" "${v_print_type}" "${v_TS}" >> ${v_logfile}
		# kneaddata, expected input arg: /home/$proj_ID/step0_data_in/*R{1,2}fastq.gz step1_kneaddata/
		# parse IO for unique sample/file id with v_SAMPLE_UNIQ
		# removed: --cat-final-output
		# vopt=from bash_seqc_mama opts, vin<-vopt
		# set db option
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
				vin_host_rm='/DB/REPO_host/hsap_contam/bowtie2'
				if [[ $(ls -1 "${vin_host_rm}"/*.bt2 2>/dev/null | wc -l) -lt 6 ]];then
					printf 'FUNC_CHECK: DB: %s not found, installing...\n' "${idb}" >> ${v_logfile}
					BASH_seqc_makedb.sh -s 'host_kd_hsapcontam'
				fi
			fi
		done
		#vopt_name='file_in_samples'
		vin_name=${vopt_name}
		vin_env='env_s1_kneaddata'
		vin_pac='kneaddata'
		v_scrp_job=${seqc_dir_job}/'job_'${vin_env}'_'${vin_pac}'.sh'
		printf 'Using software:%s from environment:%s\n' "${vin_pac}" "${vin_env}" >> ${v_logfile}
		#vopt_dir_I=' --input1 /home/seqc_user/seqc_project/step0_data_in/va_nID_R1.fastq  --input2 /home/seqc_user/seqc_project/step0_data_in/va_nID_R2.fastq'
		#vin_dir_I=' --input1 ${vin_I_dir}/v_SAMPLE_UNIQ_1.fastq --input2 ${vin_I_dir}/v_SAMPLE_UNIQ_2.fastq'
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
			vopt_mid[0]='_R1'
			vopt_mid[1]='_R2'
		fi
		if [[ -z ${vopt_ext} ]];then
			# if absent make default
			vopt_ext='.fastq'
		fi
		# adjust step according to file type
		# set output prefix
		if [[ "${vopt_file_type}" = 'paired' ]];then
			vin_I_com=' --input1 '${vin_I_dir}'/v_SAMPLE_UNIQ'${vopt_mid[0]}${vopt_ext}' --input2 '${vin_I_dir}'/v_SAMPLE_UNIQ'${vopt_mid[1]}${vopt_ext}' --output-prefix v_SAMPLE_UNIQ_kneaddata'
			vin_O_com=' --output '${vin_O_dir}
			vin_head=''
			vin_tail=''
		fi
		if [[ "${vopt_file_type}" = 'single' ]];then
			vin_I_com=' --unpaired '${vin_I_dir}'/v_SAMPLE_UNIQ'${vopt_mid[0]}${vopt_ext}' --output-prefix v_SAMPLE_UNIQ_kneaddata'
			vin_O_com=' --output '${vin_O_dir}
			vin_head=''
			vin_tail=''
		fi
		# undetermined - default of paired
		if [[ ! "${vopt_file_type}" = 'single' ]] && [[ ! "${vopt_file_type}" = 'paired' ]];then
			vin_I_com=' --input1 '${vin_I_dir}'/v_SAMPLE_UNIQ'${vopt_mid[0]}${vopt_ext}' --input2 '${vin_I_dir}'/v_SAMPLE_UNIQ'${vopt_mid[1]}${vopt_ext}' --output-prefix v_SAMPLE_UNIQ_kneaddata'
			vin_O_com=' --output '${vin_O_dir}
			vin_head=''
			vin_tail=''
		fi
		if [[ ${vopt_com_log} -eq 0 ]];then
			#insert as awk print block - ex: vopt_com='{ printf "--output-format tsv --output-basename %s",va_nID }'
			#improve with adjustment to :--processes <1>
			if [[ -z ${venv_proc_max} ]];then
				venv_proc_max=$(( ${venv_cpu_max} / 2 ))
			fi
			vin_com='{ printf " --remove-intermediate-output --reference-db %s --threads %s --processes %s --max-memory %sg --trimmomatic /opt/conda/envs/env_s1_kneaddata/share/trimmomatic --reorder","'${vin_host_rm}'",'${venv_cpu_max}','${venv_proc_max}','${venv_mem_max}' }'
		fi
		#WORKING EX
		##BASH_seqc_stepgen.sh "${vopt_dir_I}" '/home/seqc_user/seqc_project/final_reports' 'env_s1_kneaddata' 'kneaddata' "${vopt_com}"
		func_mama "${istep}" "${vin_I_dir}" "${vin_I_com}" "${vin_O_dir}" "${vin_O_com}" "${vin_com}" "${vin_head}" "${vin_tail}" "${vin_name}" "${vin_env}" "${vin_pac}" "${v_scrp_job}" "${vopt_dbug}" >> ${v_logfile} 2>>${v_dir_err}
		# POST STEP
		# create DONE dir - TODO more checks
		v_exit_TS=$(date +"%Y%m%d%H%M")
		v_exit_dir='done_'${v_exit_TS}
		mkdir ${vin_O_dir}/${v_exit_dir}
		# move content
		v_exit_catch='*kneaddata*{.log,.fastq}'
		eval "mv ${vin_O_dir}/${v_exit_catch} ${vin_O_dir}/${v_exit_dir}" 2> /dev/null
		# Create step output variable for ref
		vout_s1=${vin_O_dir}/${v_exit_dir}
		vout_sX=${vout_s1}
		# step keep-clean
		if (( ${vopt_keep} ));then
			printf 'KEEP active - Retaining all files\n' >> ${v_logfile}
		else
			v_drop_catch='*kneaddata*{unmatched,contam}*.fastq'
			eval "rm ${vout_sX}/${v_drop_catch}" 2> /dev/null
			#statment for final drop
			v_drop_catch='*kneaddata*paired*.fastq'
			v_drop_exit=${v_drop_exit}' '${vout_sX}/${v_drop_catch}
		fi
		# exit logging
		v_print_size=$( du -sh ${vout_sX} | cut -f 1 )
		v_print_count=$( find ${vout_sX} | wc -l )
		printf 'Step product location:\t%s\nStep run script location:\t%s\nStep output size(disk use):\t%s\nStep output count(files):\t%s\n%s\n' \
		"${vout_sX}" "${v_scrp_job}" "${v_print_size}" "${v_print_count}" "${v_logblock1}" >> ${v_logfile}
  	fi
  	#EoS1
  	if [[ "${vopt_branch}" = "SR" ]] || [[ "${vopt_branch}" = "ALL" ]];then
		if [[ ${istep} -eq 2 ]];then
			#STEP2_ASSIGN - SR
			#step log
			v_print_head='Initialising step:'
			v_print_type='Assignment - Taxonomy'
			v_TS=$(date)
			printf '%s%s of %s\tstep role:%s\tstart time:%s\n' "${v_print_head}" "${istep}" "${#vopt_step[@]}" "${v_print_type}" "${v_TS}" >> ${v_logfile}
			for ipack in "${vopt_pac[@]}";do
				#Kraken
				if [[ ${ipack} = 'kraken' ]];then
					# Check for user defined input dir
					if [[ -z ${vopt_dir_I} ]];then
						if [[ -z ${vout_s1} ]];then
							# if absent make default
							vin_I_dir=${v_dir_work}'/step0_data_in'
						else
							# if present make input the output of last step
							vin_I_dir=${vout_s1}
						fi
					else
						# if present make user input
						vin_I_dir=${vopt_dir_I}
						unset vopt_dir_I
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
					#tmp make out dir
					if [[ ! -d "${vin_O_dir}" ]];then
						mkdir "${vin_O_dir}"
					fi
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
							vin_path_db='/DB/REPO_tool/kraken/kdb_agora'
							v_size_db=50
							#perform check - sophisticate with check fun
							if [[ $(ls -1 ${vin_path_db}/database* 2>/dev/null | wc -l) -lt 2 ]];then
								printf 'FUNC_CHECK: DB: %s not found, installing...\n' "${idb}"
								BASH_seqc_makedb.sh -s 'tool_k2_agora'
							fi
						fi
						if [[ ${idb} = 'tool_k2_apollo' ]];then
							vin_path_db='/DB/REPO_tool/kraken/kdb_apollo'
							v_size_db=50
							#perform check - sophisticate with check fun
							if [[ $(ls -1 ${vin_path_db}/database* 2>/dev/null | wc -l) -lt 2 ]];then
								printf 'FUNC_CHECK: DB: %s not found, installing...\n' "${idb}"
								BASH_seqc_makedb.sh -s 'tool_k2_apollo'
							fi
						fi
						if [[ ${idb} = 'tool_k2_agora2apollo' ]];then
							vin_path_db='/DB/REPO_tool/kraken/kdb_a2a'
							v_size_db=69
							#perform check - sophisticate with check fun
							if [[ $(ls -1 ${vin_path_db}/database* 2>/dev/null | wc -l) -lt 2 ]];then
								printf 'FUNC_CHECK: DB: %s not found, installing...\n' "${idb}"
								BASH_seqc_makedb.sh -s 'tool_k2_agora2apollo'
							fi
						fi
						if [[ ${idb} = 'tool_k2_std8' ]];then
							vin_path_db='/DB/REPO_tool/kraken/kdb_std8'
							v_size_db=8
							#perform check - sophisticate with check fun
							if [[ $(ls -1 ${vin_path_db}/database* 2>/dev/null | wc -l) -lt 2 ]];then
								printf 'FUNC_CHECK: DB: %s not found, installing...\n' "${idb}"
								BASH_seqc_makedb.sh -s 'tool_k2_std8'
							fi
						fi
						if [[ ${idb} = 'tool_k2_demo' ]];then
							vin_path_db='/DB/REPO_tool/kraken/kdb_demo'
							#perform check - sophisticate with check fun
							if [[ $(ls -1 ${vin_path_db}/database* 2>/dev/null | wc -l) -lt 2 ]];then
								printf 'FUNC_CHECK: DB: %s not found, installing...\n' "${idb}"
								BASH_seqc_makedb.sh -s 'tool_k2_std8'
							fi
						fi
					done
					#vin_name='file_in_samples'
					vin_name=${vopt_name}
					vin_env='env_s4_kraken'
					vin_pac='kraken2'
					v_scrp_job=${seqc_dir_job}/'job_'${vin_env}'_'${vin_pac}'.sh'
					printf 'Using software:%s from environment:%s\n' "${vin_pac}" "${vin_env}" >> ${v_logfile}
					#vin_I_dir=${venv_dir_proc}'/step1_kneaddata'
					vin_I_com=' --paired '${vin_I_dir}'/v_SAMPLE_UNIQ_kneaddata_paired_1.fastq '${vin_I_dir}'/v_SAMPLE_UNIQ_kneaddata_paired_2.fastq'
					#vin_O_dir=${venv_dir_proc}'/step2_kraken'
					vin_O_com=' --unclassified-out '${vin_O_dir}'/v_SAMPLE_UNIQ_k2_unclassed#.fastq --classified-out '${vin_O_dir}'/v_SAMPLE_UNIQ_k2_classed#.fastq --output '${vin_O_dir}'/v_SAMPLE_UNIQ_k2_out.txt --report '${vin_O_dir}'/v_SAMPLE_UNIQ_k2_report.txt'
					vin_head=''
					vin_tail=''
					vin_conf='0.20'
					#check mem availability for --memory-mapping option
					if [[ ${venv_mem_max} -lt  ${v_size_db} ]];then
						printf 'Less memory available (%s) than size of DB (%s), using --memory-mapping option\n' "${venv_mem_max}" "${v_size_db}" >> ${v_logfile}
						vin_mem_map=' --memory-mapping'
					else
						vin_mem_map=''
					fi
					if [[ ${vopt_com_log} -eq 0 ]];then
						vin_com='{ printf " --db %s --threads %s --confidence %s --report-minimizer-data","'${vin_path_db}'",'${venv_cpu_max}','${vin_conf}' }'
					fi
					#standard
					func_mama "${istep}" "${vin_I_dir}" "${vin_I_com}" "${vin_O_dir}" "${vin_O_com}" "${vin_com}" "${vin_head}" "${vin_tail}" "${vin_name}" "${vin_env}" "${vin_pac}" "${v_scrp_job}" "${vopt_dbug}" >> ${v_logfile} 2>>${v_dir_err}
					#mpa style
					#vin_dir_O=' --unclassified-out ${venv_dir_proc}/step2_kraken/v_SAMPLE_UNIQ_k2_unclassed#.fastq --classified-out ${venv_dir_proc}/step2_kraken/v_SAMPLE_UNIQ_k2_classed#.fastq --output ${venv_dir_proc}/step2_kraken/v_SAMPLE_UNIQ_k2_out_MPA.txt --report ${venv_dir_proc}/step2_kraken/v_SAMPLE_UNIQ_k2_report_MPA.txt'
					#if [[ ${vopt_com_log} -eq 0 ]];then
					#  vin_com='{ printf " --db %s --threads %s --confidence %s --report-minimizer-data --use-mpa-style","'${vin_path_db}'",'${venv_cpu_max}','${vin_conf}' }'
					#fi
					#func_mama "${istep}" "${vin_I_dir}" "${vin_I_com}" "${vin_O_dir}" "${vin_O_com}" "${vin_com}" "${vin_head}" "${vin_tail}" "${vin_name}" "${vin_env}" "${vin_pac}" "${v_scrp_job}" "${vopt_dbug}"
					#bracken
					# inherit I/O and name and db from kraken
					vin_I_dir=${vin_O_dir}
					vin_env='env_s4_kraken'
					vin_pac='bracken'
					v_scrp_job=${seqc_dir_job}/'job_'${vin_env}'_'${vin_pac}'.sh'
					printf 'Using software:%s from environment:%s\n' "${vin_pac}" "${vin_env}" >> ${v_logfile}
					vin_I_com=' -i '${vin_I_dir}'/v_SAMPLE_UNIQ_k2_report.txt'
					vin_O_dir=${vin_I_dir}
					vin_O_com=' -o '${vin_O_dir}'/v_SAMPLE_UNIQ_S_bracken_out.txt'
					vin_head=''
					vin_tail=''
					vin_rlen='150'
					if [[ ${vopt_com_log} -eq 0 ]];then
						vin_com='{ printf " -d %s -t %s -r %s -l S","'${vin_path_db}'",'${venv_cpu_max}','${vin_rlen}' }'
					fi
					func_mama "${istep}" "${vin_I_dir}" "${vin_I_com}" "${vin_O_dir}" "${vin_O_com}" "${vin_com}" "${vin_head}" "${vin_tail}" "${vin_name}" "${vin_env}" "${vin_pac}" "${v_scrp_job}" "${vopt_dbug}" >> ${v_logfile} 2>>${v_dir_err}
					# POST STEP
					# create DONE dir - TODO more checks
					v_exit_TS=$(date +"%Y%m%d%H%M")
					v_exit_dir='done_'${v_exit_TS}
					mkdir ${vin_O_dir}/${v_exit_dir}
					# move content
					v_exit_catch='*_{k2,bracken}_*{.txt,.fastq}'
					eval "mv ${vin_O_dir}/${v_exit_catch} ${vin_O_dir}/${v_exit_dir}" 2> /dev/null
					# Create step output variable for ref
					vout_s2=${vin_O_dir}/${v_exit_dir}
					#combine bracken out
					mapfile -t varr_kjoin_in < <(printf '%s\n' $(ls "${vout_s2}"/*_S_bracken_out.txt) )
					# current var chain: v_kjoin_out -> v_k2mpa_out
					# krakbrak_S_out.txt changed to KB_S_out.txt
					v_kjoin_out=${vout_s2}/KB_S_out.txt
					v_col_nom=("${varr_kjoin_in[@]/%_S_bracken_out.txt/}") && v_col_nom=("${v_col_nom[*]/#*\/}") && v_col_nom="${v_col_nom[*]// /,}"
					micromamba run -n env_s4_kraken python /opt/conda/envs/env_s4_kraken/bin/combine_bracken_outputs.py \
					--files ${varr_kjoin_in[*]} --output ${v_kjoin_out} --names ${v_col_nom}
					#generate complete lineage of taxa according to the taxid
					#for use with mars
					#TODO improve name structure
					v_kdmp='/DB/REPO_tool/kraken/taxonomy/'
					v_ndmp='/DB/REPO_tool/ncbi_NR/taxonomy/'
					if [[ ! $( find "${v_kdmp}" -name '*.dmp' 2> /dev/null | wc -l ) -gt 0 ]];then
						printf 'FUNC_MAMA (run): taxdmp missing @ %s\n' "${v_kdmp}"
						if [[ ! $( find "${v_ndmp}" -name '*.dmp' 2> /dev/null | wc -l ) -gt 0 ]];then
							printf 'FUNC_MAMA (run): Core taxdmp missing @ %s\n\tResolving\n' "${v_ndmp}"
							#better approach needed
							mkdir -p "${v_ndmp}"
				            wget --no-check-certificate https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz -O "${v_ndmp}"taxdump.tar.gz
            				tar -xvf "${v_ndmp}"taxdump.tar.gz -C "${v_ndmp}"
							v_tdmp="${v_ndmp}"
						else
							v_tdmp="${v_ndmp}"
						fi
					else
					v_tdmp="${v_kdmp}"
					fi
					printf 'Generating complete lineage file\n' >> ${v_logfile}
					time cat "${v_kjoin_out}" | cut --fields 2 | tail +2 | micromamba run -n env_util_taxonkit \
					taxonkit reformat -I 1 --add-prefix --data-dir "${v_tdmp%/}" --threads "${venv_cpu_max}" \
					--out-file "${v_kjoin_out/out/taxid}"
					#add headers
					#bk2mpa_out changed to mpa_out
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
					#determine cols to retain
					#fraction - frac changed to RA
					v_match='frac'
					v_bk_cols=( $( head ${v_kjoin_out/out/mpa_out} -n 1 ) )
					v_bk_index=()
					for vi_bk in ${!v_bk_cols[@]};do
						if [[ ${v_bk_cols[${vi_bk}]/#*_} != ${v_match} ]];then
							#echo ${v_bk_cols[${vi_bk}]/#*_}
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
					sed -i "1 s/_$v_match//" "${v_k2mpa_out}"
					#counts
					v_match='num'
					v_bk_cols=( $( head ${v_kjoin_out/out/mpa_out} -n 1 ) )
					v_bk_index=()
					for vi_bk in ${!v_bk_cols[@]};do
						if [[ ${v_bk_cols[${vi_bk}]/#*_} != ${v_match} ]];then
							#echo ${v_bk_cols[${vi_bk}]/#*_}
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
					sed -i "1 s/_$v_match//" "${v_k2mpa_out}"
					#default mars input is now "${v_k2mpa_out}" = /DB/DEPO_proc/step2_kraken/KB_S_mpa_out_RC.txt
					vout_sX=${vout_s2}
					# step keep-clean
					if (( ${vopt_keep} ));then
						printf 'KEEP active - Retaining all files\n' >> ${v_logfile}
					else
						v_drop_catch='*_{k2,bracken}_*{.txt,.fastq}'
						eval "rm ${vout_sX}/${v_drop_catch}" 2> /dev/null
						#statment for final drop
						v_drop_catch='KB_*.txt'
						v_drop_exit=${v_drop_exit}' '${vout_sX}/${v_drop_catch}
					fi
					# exit logging
					v_print_size=$( du -sh ${vout_sX} | cut -f 1 )
					v_print_count=$( find ${vout_sX} | wc -l  )
					printf 'Step product location:\t%s\nStep run script location:\t%s\nStep output size(disk use):\t%s\nStep output count(files):\t%s\n%s\n' \
					"${vout_sX}" "${v_scrp_job}" "${v_print_size}" "${v_print_count}" "${v_logblock1}" >> ${v_logfile}
					# set taxa sep flag for mars in case differing from kraken output
					# better soln TBD
					venv_mars_taxaSplit=';'
				fi
				#EoKraken
			done
		fi
		#EoS2
		if [[ ${istep} -eq 3 ]];then
			#STEP3_REPORT - SR
			#step log
			v_print_head='Initialising step:'
			v_print_type='Report - Taxonomy'
			v_TS=$(date)
			printf '%s%s of %s\tstep role:%s\tstart time:%s\n' "${v_print_head}" "${istep}" "${#vopt_step[@]}" "${v_print_type}" "${v_TS}" >> ${v_logfile}
			for ipack in "${vopt_pac[@]}";do
				if [[ ${ipack} = 'mars' ]];then
					# MARS FINAL RECONFIG
					# TODO 
					#   make to run within internal mama call
					# Expected input file:
					#  "Taxon" read_counts_n_1 read_counts_n_2 read_counts_n_X
					#   d__bact..s__
					#   k__Bacteria;p__Bacteroidota;c__Bacteroidia;o__Bacteroidales;f__Bacteroidaceae;g__Bacteroides;s__faecis
					#
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
					v_scrp_job=${seqc_dir_job}/'job_'${vin_env}'_'${vin_pac}'.sh'
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
					#temp mars file for extra modification
					v_mars_out='/DB/DEPO_proc/tmp/profile_taxa_mars_prep.txt'
					#TODO checks for compatibility prior to conversion
					#issue with d__virus/euk leading to 8 phylo levels
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
					#printf '%s\n' "${vin_opt_mars[@]}"
					#OoD approach
					#optArgMars=$(printf 'infile1=%s,infile2=%s,outfile=%s,cutoff=None,output_format=csv,stratification_file=None,flagLoneSpecies=False,taxaSplit=|' "${infile1}" "${infile2}" "${vin_O_dir}")
					#IFS=',' read -r -a vin_opt_mars <<< "$optArgMars"
					# check and switch error output to dbug log
					if (( ${vopt_dbug} ));then
						v_dir_err=${v_logfile_dbug}
					else
						v_dir_err='/dev/null'
					fi
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
					\nwhichModelDatabase=sys.argv[10], userDatabase_path=vip11, sample_read_counts_cutoff=vip12)' \
					"${vin_opt_mars[0]/#*=}" "${vin_opt_mars[1]/#*=}" "${vin_opt_mars[2]/#*=}" \
					"${vin_opt_mars[3]/#*=}" "${vin_opt_mars[4]/#*=}" "${vin_opt_mars[5]/#*=}" \
					"${vin_opt_mars[6]/#*=}" "${vin_opt_mars[7]/#*=}" "${vin_opt_mars[8]/#*=}" \
					"${vin_opt_mars[9]/#*=}" "${vin_opt_mars[10]/#*=}" "${vin_opt_mars[11]/#*=}" >> ${v_logfile} 2>>${v_dir_err}
					# POST STEP
					# create DONE dir - TODO more checks
					v_exit_TS=$(date +"%Y%m%d%H%M")
					v_exit_dir='done_'${v_exit_TS}
					mkdir ${vin_O_dir}/${v_exit_dir}
					# move content
					#v_exit_catch='*'
					v_exit_catch='{metrics,normalized_mapped,normalized_preMapped,normalized_unmapped,renormalized_mapped_forModelling,*.log,*.csv}'
					eval "mv ${vin_O_dir}/${v_exit_catch} ${vin_O_dir}/${v_exit_dir}" 2> /dev/null
					# Create step output variable for ref
					vout_s3=${vin_O_dir}/${v_exit_dir}
					# exit logging
					vout_sX=${vout_s3}
					v_print_size=$( du -sh ${vout_sX} | cut -f 1 )
					v_print_count=$( find ${vout_sX} | wc -l  )
					printf 'Step product location:\t%s\nStep run script location:\t%s\nStep output size(disk use):\t%s\nStep output count(files):\t%s\n%s\n' \
					"${vout_sX}" "${v_scrp_job}" "${v_print_size}" "${v_print_count}" "${v_logblock1}" >> ${v_logfile}
					# Relocation to final out
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
					mv "${vout_sX}/"* "${outfile}"
					# MARS status update and export for matlab
					# add approach to export new dir
					VLOG_MATLAB_MARS=1
				fi
				#EoMARS
			done
			#EoIPACK_S3
		fi
		#EoSTEP3
  	fi
  	#EoStandard SR run
	if [[ "${vopt_branch}" = "MAG" ]] || [[ "${vopt_branch}" = "ALL" ]];then
		if [[ ${istep} -eq 2 ]];then
			#STEP2_ASSEMBLE
			#step log
			v_print_head='Initialising step:'
			v_print_type='Assembly'
			v_TS=$(date)
			printf '%s%s of %s\tstep role:%s\tstart time:%s\n' "${v_print_head}" "${istep}" "${#vopt_step[@]}" "${v_print_type}" "${v_TS}" >> ${v_logfile}
			#spades
			if [[ ${ipack} = 'spades' ]];then
				# expected to be fed from s1
				# expand approach to accom more varied inputs eg unpaired fq
				# Check for user defined input dir
				if [[ -z ${vopt_dir_I} ]];then
					if [[ -z ${vout_s1} ]];then
						# if absent make default
						vin_I_dir=${v_dir_work}'/step0_data_in'
					else
						# if present make input the output of last step
						vin_I_dir=${vout_s1}
					fi
				else
					# if present make user input
					vin_I_dir=${vopt_dir_I}
					unset vopt_dir_I
				fi
				# Check for user defined output dir
				if [[ -z ${vopt_dir_O} ]];then
					# if absent make default
					vin_O_dir=${venv_dir_proc}'/step2_spades'
				else
					# if present make user input
					vin_O_dir=${vopt_dir_O}
					unset vopt_dir_O
				fi
				#micromamba run -n env_s2_spades spades.py --meta -1 /DB/DEPO_proc/step1_kneaddata/SRR19064978_1_kneaddata_paired_1.fastq -2 /DB/DEPO_proc/step1_kneaddata/SRR19064978_1_kneaddata_paired_2.fastq 
				#--only-assembler -k 21,29,39,59,79,99 --threads 4 --memory 20 -o /DB/DEPO_proc/step2_spades/S1
				vin_env='env_s2_spades'
				vin_pac='spades.py'
				vin_name=${vopt_name}
				v_scrp_job=${seqc_dir_job}/'job_'${vin_env}'_'${vin_pac}'.sh'
				printf 'Using software:%s from environment:%s\n' "${vin_pac}" "${vin_env}" >> ${v_logfile}
				vin_I_com=' --meta -1 '${vin_I_dir}'/v_SAMPLE_UNIQ_kneaddata_paired_1.fastq --input2 '${vin_I_dir}'/v_SAMPLE_UNIQ_kneaddata_paired_2.fastq'
				vin_O_com=' -o '${vin_O_dir}'/MS_OUT_v_SAMPLE_UNIQ'
				vin_head=''
				vin_tail=''
				if [[ ${vopt_com_log} -eq 0 ]];then
					#insert as awk print block - ex: vopt_com='{ printf "--output-format tsv --output-basename %s",va_nID }'
					vin_com='{ printf " --only-assembler -k 21,29,39,59,79,99 --threads %s --memory %s",'${venv_cpu_max}','${venv_mem_max}' }'
				fi
				func_mama "${istep}" "${vin_I_dir}" "${vin_I_com}" "${vin_O_dir}" "${vin_O_com}" "${vin_com}" "${vin_head}" "${vin_tail}" "${vin_name}" "${vin_env}" "${vin_pac}" "${v_scrp_job}" "${vopt_dbug}"
				vout_s2=${vin_O_dir}
				# exit logging
				vout_sX=${vout_s2}
				v_print_size=$( du -sh ${vout_sX} | cut -f 1 )
				v_print_count=$( find ${vout_sX} | wc -l  )
				printf 'Step product location:\t%s\nStep run script location:\t%s\nStep output size(disk use):\t%s\nStep output count(files):\t%s\n%s\n' \
				"${vout_sX}" "${v_scrp_job}" "${v_print_size}" "${v_print_count}" "${v_logblock1}" >> ${v_logfile}
			fi
			#EoSPADES
		fi
		#EoS2 - MAG
		if [[ ${istep} -eq 3 ]];then
			#STEP3_BIN
			#step log
			v_print_head='Initialising step:'
			v_print_type='Binning'
			v_TS=$(date)
			printf '%s%s of %s\tstep role:%s\tstart time:%s\n' "${v_print_head}" "${istep}" "${#vopt_step[@]}" "${v_print_type}" "${v_TS}" >> ${v_logfile}
			if [[ ${ipack} = 'minimap2' ]];then
				# map contigs
				# expected to be fed from s2
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
					vin_O_dir=${venv_dir_proc}'/step3_minimap'
				else
					# if present make user input
					vin_O_dir=${vopt_dir_O}
					unset vopt_dir_O
				fi
				vin_env='env_s3_minimap2'
				vin_pac='minimap2'
				vin_name=${vopt_name}
				printf 'Using software:%s from environment:%s\n' "${vin_pac}" "${vin_env}" >> ${v_logfile}
				# VAMB util: combine contig fasta into single fasta file (catalogue) and drop <2kbp contigs
				# converts S from 0-9, 1-10
				micromamba run -n env_s3_vamb python /opt/conda/envs/env_s3_vamb/lib/vamb/src/concatenate.py \
				${vin_O_dir}/catalogue.fna.gz \
				${vin_I_dir}/MS_OUT_*/contigs.fasta
				# minimap index
				v_scrp_job=${seqc_dir_job}/'job_'${vin_env}'_'${vin_pac}'A.sh'
				vin_I_com=' '${vin_O_dir}'/catalogue.fna.gz'
				vin_O_com=' -d '${vin_O_dir}/catalogue.mmi
				vin_head=''
				vin_tail=''
				# micromamba run -n env_s3_minimap2 minimap2 -t 28 -d /DB/DEPO_demo/demo/step2_spades/agora_smol/catalogue.mmi /DB/DEPO_demo/demo/step2_spades/agora_smol/catalogue.fna.gz
				if [[ ${vopt_com_log} -eq 0 ]];then
					#insert as awk print block - ex: vopt_com='{ printf "--output-format tsv --output-basename %s",va_nID }'
					vin_com='{ printf " -t %s",'${venv_cpu_max}' }'
				fi
				func_mama "${istep}" "${vin_I_dir}" "${vin_I_com}" "${vin_O_dir}" "${vin_O_com}" "${vin_com}" "${vin_head}" "${vin_tail}" "${vin_name}" "${vin_env}" "${vin_pac}" "${v_scrp_job}" "${vopt_dbug}"
				#bam map to contigs -K NUM       minibatch size for mapping [500M] 1G
				#agora sim https://broadinstitute.github.io/picard/explain-flags.html
				#micromamba run -n env_s3_minimap2 samtools view -F 0x904 /DB/DEPO_demo/demo/step3_minimap/camisim_s0.bam | less
				# pot artifact of '-F 3584 ' in samtools sort
				# WONT WORK IF VOUT_S1 IS UNDEFINED - CRIT FIX
				# Clean fastq req for map
				# w/o complete run assume vout_s1 = vin_I_dir
				# ADDITIONAL TESTING REQ
				if [[ -z ${vout_s1} ]];then
					# if absent make default
					vout_s1=${vin_I_dir}
				fi
				v_scrp_job=${seqc_dir_job}/'job_'${vin_env}'_'${vin_pac}'B.sh'
				vin_I_com=' -t '${venv_cpu_max}' -N 5 -a -x sr '${vin_O_dir}'/catalogue.mmi --split-prefix mmsplit '${vout_s1}'/v_SAMPLE_UNIQ_kneaddata_paired_1.fastq '${vout_s1}'/v_SAMPLE_UNIQ_kneaddata_paired_2.fastq'
				vin_O_com=' | micromamba run -n env_s3_minimap2 samtools sort --threads '${venv_cpu_max}' --output-fmt BAM -o '${vin_O_dir}'/v_SAMPLE_UNIQ.bam'
				vin_head=''
				vin_tail=''
				if [[ ${vopt_com_log} -eq 0 ]];then
					#insert as awk print block - ex: vopt_com='{ printf "--output-format tsv --output-basename %s",va_nID }'
					vin_com=''
				fi
				func_mama "${istep}" "${vin_I_dir}" "${vin_I_com}" "${vin_O_dir}" "${vin_O_com}" "${vin_com}" "${vin_head}" "${vin_tail}" "${vin_name}" "${vin_env}" "${vin_pac}" "${v_scrp_job}" "${vopt_dbug}"
				vout_s3A=${vin_O_dir}
				#
				# exit logging
				vout_sX=${vout_s3A}
				v_print_size=$( du -sh ${vout_sX} | cut -f 1 )
				v_print_count=$( find ${vout_sX} | wc -l  )
				printf 'Step product location:\t%s\nStep run script location:\t%s\nStep output size(disk use):\t%s\nStep output count(files):\t%s\n%s\n' \
				"${vout_sX}" "${v_scrp_job}" "${v_print_size}" "${v_print_count}" "${v_logblock1}" >> ${v_logfile}
			fi
			if [[ ${ipack} = 'vamb' ]];then
				# Check for user defined input dir
				# expected to be fed from s3A - minimap2 w/ cat.mmi, cat.fna, .bam 
				if [[ -z ${vopt_dir_I} ]];then
					if [[ -z ${vout_s1} ]];then
						# if absent make default
						vin_I_dir=${v_dir_work}'/step0_data_in'
					else
						# if present make input the output of last step
						vin_I_dir=${vout_s3A}
					fi
				else
					# if present make user input
					vin_I_dir=${vopt_dir_I}
					unset vopt_dir_I
				fi
				# Check for user defined output dir
				if [[ -z ${vopt_dir_O} ]];then
					# if absent make default
					vin_O_dir=${venv_dir_proc}'/step3_vamb'
				else
					# if present make user input
					vin_O_dir=${vopt_dir_O}
					unset vopt_dir_O
				fi
				# comm for Vamb 4.1.4.dev136+g5090ecc
				#micromamba run -n env_s3_vamb vamb bin avamb -m (min contig len) 2000 -p (threads) --cuda (use GPU) --seed 42069 --fasta --bamdir --minfasta (min bin size) -o (binsplit) C
				# integrate: --abundance_tsv   Path to TSV file of precomputed abundances with header being "contigname(\t<samplename>)*"
				vin_len_contig='2000'
				vin_len_bin='100000'
				vin_seed='42069'
				vin_split='C'
				vin_log_cuda=0
				vin_env='env_s3_vamb'
				vin_pac='vamb'
				vin_name=${vopt_name}
				v_scrp_job=${seqc_dir_job}/'job_'${vin_env}'_'${vin_pac}'C.sh'
				printf 'Using software:%s from environment:%s\n' "${vin_pac}" "${vin_env}" >> ${v_logfile}
				vin_I_com=' bin avamb -m '${vin_len_contig}' -p '${venv_cpu_max}' --seed '${vin_seed}' --fasta '${vin_I_dir}'catalogue.fna.gz --bamdir '${vin_I_dir}' --minfasta '${vin_len_bin}' -o '${vin_split}
				#'--input1 '${vin_I_dir}'/v_SAMPLE_UNIQ_1.fastq --input2 '${vin_I_dir}'/v_SAMPLE_UNIQ_2.fastq'
				vin_O_com=' --outdir '${vin_O_dir}
				vin_head=''
				vin_tail=''
				#bin - without --minfasta, does not generate bins just everything else --model vae,aae,vae(both)
				#micromamba run -n env_s3_avamb python vamb/src/create_fasta.py /DB/demo/example_run/contigs/catalogue.fna.gz /DB/demo/example_run/avamb_outdir/vae_clusters.tsv /DB/demo/example_run/avamb_bins 200000
				if [[ ${vopt_com_log} -eq 0 ]];then
					#insert as awk print block - ex: vopt_com='{ printf "--output-format tsv --output-basename %s",va_nID }'
					if [[ ${vin_log_cuda} -eq 1 ]];then
						# config for additional positional args
						vin_com='{ printf "--cuda" }'
					else
						vin_com=''
					fi
				fi
				func_mama "${istep}" "${vin_I_dir}" "${vin_I_com}" "${vin_O_dir}" "${vin_O_com}" "${vin_com}" "${vin_head}" "${vin_tail}" "${vin_name}" "${vin_env}" "${vin_pac}" "${v_scrp_job}" "${vopt_dbug}"
				vout_s3B=${vin_O_dir}
				# exit logging
				vout_sX=${vout_s3B}
				v_print_size=$( du -sh ${vout_sX} | cut -f 1 )
				v_print_count=$( find ${vout_sX} | wc -l  )
				printf 'Step product location:\t%s\nStep run script location:\t%s\nStep output size(disk use):\t%s\nStep output count(files):\t%s\n%s\n' \
				"${vout_sX}" "${v_scrp_job}" "${v_print_size}" "${v_print_count}" "${v_logblock1}" >> ${v_logfile}
			fi
			if [[ ${ipack} = 'checkm2' ]];then
				# QC on bins
				# expected to be fed from s3B - vamb
				if [[ -z ${vopt_dir_I} ]];then
					if [[ -z ${vout_s1} ]];then
						# if absent make default
						vin_I_dir=${v_dir_work}'/step0_data_in'
					else
						# if present make input the output of last step
						vin_I_dir=${vout_s3B}
					fi
				else
					# if present make user input
					vin_I_dir=${vopt_dir_I}
					unset vopt_dir_I
				fi
				# Check for user defined output dir
				if [[ -z ${vopt_dir_O} ]];then
					# if absent make default
					vin_O_dir=${venv_dir_proc}'/step3_checkm2'
				else
					# if present make user input
					vin_O_dir=${vopt_dir_O}
					unset vopt_dir_O
				fi
				# Check for checkm DB and install if absent
				if [[ $( ls -1 $v_dir_db'/REPO_tool/checkm2' 2>/dev/null | wc -l ) -gt 0 ]];then
					if (( ${vopt_dbug} ));then
						printf 'FUNC_MAMA DBUG: Using previously installed CheckM2 database'
					fi
				else
					if (( ${vopt_dbug} ));then
						printf 'FUNC_MAMA DBUG: Using previously installed CheckM2 database'
					fi
					BASH_seqc_makedb.sh -s 'tool_cm2_dmnd'
				fi
				vin_env='env_s3_checkm2'
				vin_pac='checkm2'
				vin_name=${vopt_name}
				v_scrp_job=${seqc_dir_job}/'job_'${vin_env}'_'${vin_pac}'.sh'
				printf 'Using software:%s from environment:%s\n' "${vin_pac}" "${vin_env}" >> ${v_logfile}
				vin_I_com=' predict --input '${vin_I_dir}'/bins/S*/*.fna'
				vin_O_com=' --output-directory '${vin_O_dir}
				vin_head=''
				vin_tail=''
				vin_db='DB/REPO_tool/checkm2/CheckM2_database/uniref100.KO.1.dmnd'
				#QC with checkm2 ~10min/sample
				micromamba run -n env_s3_checkm2 checkm2 predict \
				--input /DB/DEPO_demo/demo/step3_vamb/agora_smol/bins/S*/*.fna \
				--output-directory /DB/DEPO_demo/demo/step3_checkm2 \
				--threads 48 --database_path /DB/REPO_tool/checkm2/CheckM2_database/uniref100.KO.1.dmnd \
				--force
				if [[ ${vopt_com_log} -eq 0 ]];then
					#insert as awk print block - ex: vopt_com='{ printf "--output-format tsv --output-basename %s",va_nID }'
					vin_com='{ printf " --threads %s --database_path %s  --force",'${venv_cpu_max}',"'${vin_db}'" }'
				fi
				func_mama "${istep}" "${vin_I_dir}" "${vin_I_com}" "${vin_O_dir}" "${vin_O_com}" "${vin_com}" "${vin_head}" "${vin_tail}" "${vin_name}" "${vin_env}" "${vin_pac}" "${v_scrp_job}" "${vopt_dbug}"
				#changed to vout_s3C from vout_s3_vamb
				vout_s3C=${vin_O_dir}
				# exit logging
				vout_sX=${vout_s3C}
				v_print_size=$( du -sh ${vout_sX} | cut -f 1 )
				v_print_count=$( find ${vout_sX} | wc -l  )
				printf 'Step product location:\t%s\nStep run script location:\t%s\nStep output size(disk use):\t%s\nStep output count(files):\t%s\n%s\n' \
				"${vout_sX}" "${v_scrp_job}" "${v_print_size}" "${v_print_count}" "${v_logblock1}" >> ${v_logfile}
			fi
		fi
		#EoS3 - MAG
		#STEP4_ASSIGN
		if [[ ${istep} -eq 4 ]];then
			#step log
			v_print_head='Initialising step:'
			v_print_type='Annotation'
			v_TS=$(date)
			printf '%s%s of %s\tstep role:%s\tstart time:%s\n' "${v_print_head}" "${istep}" "${#vopt_step[@]}" "${v_print_type}" "${v_TS}" >> ${v_logfile}
			# assignment of ... with ...
			printf 'this will do something'
			printf 'Using software:%s from environment:%s\n' "${vin_pac}" "${vin_env}" >> ${v_logfile}
			# exit logging
			vout_sX=${vout_s3C}
			v_print_size=$( du -sh ${vout_sX} | cut -f 1 )
			v_print_count=$( find ${vout_sX} | wc -l  )
			printf 'Step product location:\t%s\nStep run script location:\t%s\nStep output size(disk use):\t%s\nStep output count(files):\t%s\n%s\n' \
			"${vout_sX}" "${v_scrp_job}" "${v_print_size}" "${v_print_count}" "${v_logblock1}" >> ${v_logfile}
		fi
		#EoS4 - MAG
	fi
	#EoStandard MAG run
done
#EoSTEP_check
#End of run log
if (( ${vopt_log} ));then
# set success/fail based on outcome
	v_print_head='SeqC AS Flux pipeline run has completed'
	v_print_type='FAILURE XO'
	v_print_type='SUCCESS :D'
	v_TS=$(date)
	printf '%s\n%s\n\tStatus: %s\nEnd time: %s\n%s\n' "${v_logblock0}" "${v_print_head}" "${v_print_type}" "${v_TS}" "${v_logblock0}" >> ${v_logfile}
	# Relocate input taxonomy for mars to final out
	# PERSEPHONE FIX
	if [[ ! -z ${v_mars_kin} ]];then
		mv ${v_mars_kin} /home/seqc_user/seqc_project/final_reports/
	fi
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
	# append mars status for matlab
	if (( ${VLOG_MATLAB_MARS} ));then
		v_print_head=$( printf '%s\n%s\nVLOG_MATLAB_MARS=%s\n%s\n' "${v_logblock0}" "# Export Variable Section" "${VLOG_MATLAB_MARS}" "${v_logblock0}")
		printf '%s\n' "${v_print_head}" >> ${v_logfile}
	fi
	# Remove joined logs
	rm ${v_logfile_ref}
	rm ${v_logfile_dbug}
	# Relocate log to final outpput dir
	mv ${v_logfile} /home/seqc_user/seqc_project/final_reports/ 2> /dev/null
	# Relocate taxonomy output
	v_drop_catch='KB_S_mpa_out_{RC,RA}.txt'
	eval "mv ${vout_s2}/${v_drop_catch} /home/seqc_user/seqc_project/final_reports/" 2> /dev/null
fi
if (( ${vopt_log} ));then
	printf 'SeqC Stuff ENDS @: %s\n' "$(date +"%Y.%m.%d %H.%M.%S (%Z)")"
fi
#END of exit log and check
# Step mama input template
if [ $var_BLOCK = 'F' ];then
	if [[ ${ipack} = 'spades' ]];then
  	# expected to be fed from s1
  	#step log
	v_print_head='Initialising step:'
	v_print_type='Annotation'
	v_TS=$(date)
	printf '%s%s of %s\tstep role:%s\tstart time:%s\n' "${v_print_head}" "${istep}" "${#vopt_step[@]}" "${v_print_type}" "${v_TS}" >> ${v_logfile}
  	# Check for user defined input dir
    if [[ -z ${vopt_dir_I} ]];then
		if [[ -z ${vout_s1} ]];then
			# if absent make default
			vin_I_dir=${v_dir_work}'/step0_data_in'
		else
			# if present make input the output of last step
			vin_I_dir=${vout_s1}
		fi
    else
		# if present make user input
		vin_I_dir=${vopt_dir_I}
		unset vopt_dir_I
    fi
    # Check for user defined output dir
    if [[ -z ${vopt_dir_O} ]];then
		# if absent make default
		vin_O_dir=${venv_dir_proc}'/step2_spades'
    else
		# if present make user input
		vin_O_dir=${vopt_dir_O}
		unset vopt_dir_O
    fi
    vin_env='env_s2_spades'
    vin_pac='spades'
    vin_name=${vopt_name}
    v_scrp_job=${seqc_dir_job}/'job_'${vin_env}'_'${vin_pac}'.sh'
    printf 'Using software:%s from environment:%s\n' "${vin_pac}" "${vin_env}" >> ${v_logfile}
    vin_I_com=' --input1 '${vin_I_dir}'/v_SAMPLE_UNIQ_1.fastq --input2 '${vin_I_dir}'/v_SAMPLE_UNIQ_2.fastq'
    vin_O_com=' --output '${vin_O_dir}
    vin_head=''
    vin_tail=''
    if [[ ${vopt_com_log} -eq 0 ]];then
		#insert as awk print block - ex: vopt_com='{ printf "--output-format tsv --output-basename %s",va_nID }'
		vin_com='{ printf " --remove-intermediate-output --reference-db %s --threads %s --max-memory %sg --trimmomatic /opt/conda/envs/env_s1_kneaddata/share/trimmomatic --reorder","'${vin_host_rm}'",'${venv_cpu_max}','${venv_mem_max}' }'
    fi
    #multiline approach
    if [[ ${vopt_com_log} -eq 0 ]];then
		read -r -d '' vin_com << EOM 
		{ printf "--output-format tsv --output-basename %s --input-format fasta --pathways metacyc --memory-use maximum ",va_nID }
		{ printf "\n%s\n","notha row bro" }
EOM
    fi
	func_mama "${istep}" "${vin_I_dir}" "${vin_I_com}" "${vin_O_dir}" "${vin_O_com}" "${vin_com}" "${vin_head}" "${vin_tail}" "${vin_name}" "${vin_env}" "${vin_pac}" "${v_scrp_job}" "${vopt_dbug}"
	vout_s2=${vin_O_dir}
	vout_sX=${vout_s2}
	# step keep-clean
	if (( ${vopt_keep} ));then
		printf 'KEEP active - Retaining all files\n' >> ${v_logfile}
	else
		v_drop_catch='*_{k2,bracken}_*{.txt,.fastq}'
		eval "rm ${vout_sX}/${v_drop_catch}" 2> /dev/null
		#statment for final drop
		v_drop_catch='KB_*.txt'
		v_drop_exit=${v_drop_exit}' '${vout_sX}/${v_drop_catch}
	fi
	# exit logging
	v_print_size=$( du -sh ${vout_sX} | cut -f 1 )
	v_print_count=$( find ${vout_sX} | wc -l  )
	printf 'Step product location:\t%s\nStep run script location:\t%s\nStep output size(disk use):\t%s\nStep output count(files):\t%s\n%s\n' \
	"${vout_sX}" "${v_scrp_job}" "${v_print_size}" "${v_print_count}" "${v_logblock1}" >> ${v_logfile}
  fi

  fi
  #EoBLOCK
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
  ____                                   _                ____                              _
 / ___|  ___  __ _ _   _  ___ _ __   ___(_)_ __   __ _   / ___|___  _ ____   _____ _ __ ___(_) ___  _ __
 \___ \ / _ \/ _` | | | |/ _ | '_ \ / __| | '_ \ / _` | | |   / _ \| '_ \ \ / / _ | '__/ __| |/ _ \| '_ \
  ___) |  __| (_| | |_| |  __| | | | (__| | | | | (_| | | |__| (_) | | | \ V |  __| |  \__ | | (_) | | | |
 |____/ \___|\__, |\__,_|\___|_| |_|\___|_|_| |_|\__, |  \____\___/|_| |_|\_/ \___|_|  |___|_|\___/|_| |_|
      / \   ___ |_|_ ___ _ __ ___ | |__ | |_   _ |___/  / ___|  ___  _   _ _ __ ___ ___  __| |  |  ___| |_   ___  __
     / _ \ / __/ __|/ _ | '_ ` _ \| '_ \| | | | |  ____ \___ \ / _ \| | | | '__/ __/ _ \/ _` |  | |_  | | | | \ \/ /
    / ___ \\__ \__ |  __| | | | | | |_) | | |_| | |____| ___) | (_) | |_| | | | (_|  __| (_| |  |  _| | | |_| |>  <
   /_/   \_|___|___/\___|_| |_| |_|_.__/|_|\__, |       |____/ \___/ \__,_|_|  \___\___|\__,_|  |_|   |_|\__,_/_/\_\
         _______              _______    |___/     _______              _______
        /::\    \            /::\    \            /::\    \            /::\    \
       /::::\    \          /::::\    \          /::::\    \          /::::\    \
      /::::::\    \        /::::::\    \        /::::::\    \        /::::::\    \
     /:::/\:::\    \      /:::/\:::\    \      /::::::::\    \      /:::/\:::\    \
    /:::/__\:::\    \    /:::/__\:::\    \    /:::/~~\:::\    \    /:::/  \:::\    \
    \:::\   \:::\    \  /::::\   \:::\    \  /:::/    \:::\    \  /:::/    \:::\    \
  ___\:::\   \:::\    \/::::::\   \:::\    \/:::/    / \:::\    \/:::/    / \:::\    \
 /\   \:::\   \:::\____\::/\:::\   \:::\____\::/____/   \:::\____\::/    /   \:::\____\
/::\   \:::\   \::/    /:/__\:::\   \::/    /:|    |    |:::|    |::____/     \::/    /
\:::\   \:::\   \/____/::\   \:::\   \/____/::|____|    |:::|____/::\    \     \/____/
 \:::\   \:::\____\   \:::\   \:::\____\   |:::\   _\___/:::/    /:::\    \
  \:::\  /:::/    /    \:::\   \::/    /    \:::\ |::| /:::/    / \:::\    \
   \:::\/:::/    /______\:::\   \/____/______\:::\|::|/:::/    /___\:::\    \    _____    _____       ______
    \::::::/    //::\    \:::\    \  /::\    \\::::::::::/    /:    \:::\    \ /::\____\/::\____\    |::|   |
     \::::/    //::::\    \:::\____\/::::\    \\::::::::/    /::\    \:::\____\:::/    /:::/    /    |::|   |
      \::/    //::::::\    \::/    /::::::\    \\::::::/____/::::\    \::/    /::/    /:::/    /     |::|   |
       ~~~~~~//:::/\:::\    \~~~~~/:::/\:::\    \ |::|___|/::/\:::\    \~~~~~:::/    /:::/    /      |::|   |
             /:::/__\:::\    \   /:::/__\:::\    \~~~~  /:::/__\:::\    \  /:::/    /:::/    /       |::|   |
            /::::\   \:::\    \  \:::\   \:::\    \    /::::\   \:::\    \/:::/    /:::/    /        |::|   |
           /::::::\   \:::\    \ _\:::\   \:::\    \  /::::::\   \:::\    \::/    /:::/    /___ _____|::|___|____ ____
          /:::/\:::\   \:::\____\  \:::\   \:::\____\/:::/\:::\   \:::\____\/    /:::/____/:::/\    \::::::::::::|    |
         /:::/  \:::\  /:::/    /   \:::\   \::/    /:::/  \:::\   \::/    /    /:::|    ||::/::\____\:::::::::::|____|
         \::/    \:::\/:::/    /:\   \:::\   \/____/\::/    \:::\   \/____/____/.:::|____|~~/:::/    /:|~~~~~~~~~~
          \/____/ \::::::/    /:::\   \ ::\    \     \/____/ \:::\    \\:::\    \:::\    \ /:::/    /::|   |
                   \::::/    / \:::\   \:::\____\             \:::\____\\:::\    \:::\    /:::/    /|::|   |
                   /:::/    /   \:::\  /:::/    /              \::/    / \:::\    \:::\__/:::/    / |::|   |
                  /:::/    /     \:::\/:::/    /                \/____/   \:::\    \::::::::/    /  |::|   |
                 /:::/    /       \::::::/    /                            \:::\    \::::::/    /   |::|___|
                /:::/    /         \::::/    /                              \:::\____\::::/    /     ~~~~~
                \::/    /           \::/    /                                \::/    /\::/____/
         ____    \/____/      ____   \/____/__          __           __       \/____/  ~~ __    ____
        /  \ \    /\ \       /  \ \      /  \ \        |\ \         /\ \        /  \ \   /\_\  /  \ \
       / /\ \ \   \ \ \     / /\ \ \    / /\ \ \      /\__ \        \ \ \      / /\ \ \_/ / / / /\ \ \
      / / /\ \_\  /\ \_\   / / /\ \_\  / / /\ \_\    / / __/        /\ \_\    / / /\ \___/ / / / /\ \_\
     / / /_/ / / / /\/_/  / / /_/ / / / /_/__\/_/   / / /          / /\/_/   / / /  \/____/ / /_/_ \/_/
    / / /__\/ / / / /    / / /__\/ / / /____/\     / / /          / / /     / / /    / / / / /____/\
   / / /_____/ / / /    / / /_____/ / /\____\/    / / /          / / /     / / /    / / / / /\____\/
  / / /    ___/ / /_   / / /       / / /______   / /_/_____   __/ / /__   / / /    / / / / / /_____
 / / /    /\__\/_/__\ / / /       / / /_______\ /_________/\ /\_\/_/___\ / / /    / / / / / /_______\
 \/_/     \/________/ \/_/        \/__________/ \_________\/ \/________/ \/_/     \/_/  \/__________/
EOF
		sleep 1.0s
		# Additional startup info - expand
		printf 'Welcome %s!\n' "${v_seqcusr}"
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
		#mkdir -p ${v_dir_db}/{REPO_host/{hsap,hsap_contam,mmus,btau}/bowtie2/\
		#,REPO_tool/{kraken,humann,checkm2,mmseqs2,ncbi_NR}\
		#,DEPO_demo/demo/{tmp,camisim/AGORA_smol/{genomes,run_params}}\
		#,DEPO_proc/{logs,tmp}\
		#}/
		# syslink of log dir
		# currently impossible with docker: ln -s ${v_logfile%/*}/ ${venv_dir_proc}
		# Display info
		printf 'Current directory       : %s\n' "$PWD"
		printf 'Expected input location : %s\n' "${venv_dir_in}"
		printf 'Expected output location: %s\n' "${venv_dir_out}"
	fi
	if [[ ${VEN_SPLASH} -eq 2 ]];then printf 'Sequencing Conversion Assembly-Sourced Flux pipeline -- SeqC AS Flux -- version %s\n' ${v_version}; fi
}
fi
#Eocheck=0
((v_scrp_check++))
done
#Eowhile
#EoB