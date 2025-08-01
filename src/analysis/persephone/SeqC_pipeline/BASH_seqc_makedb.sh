#!/bin/bash
#======================================================================================================#
# Title: make pipeline DBs
# Program by: Wiley Barton - 2022.02.07
# Modified for conda/docker pipeline - 2024.02.22
# Version for: PERSEPHONE
# last update - 2025.08.01
# Modified code sources:
#   check volume size: https://stackoverflow.com/questions/8110530/check-free-disk-space-for-current-partition-in-bash
#   semi-array in env var: https://unix.stackexchange.com/questions/393091/unable-to-use-an-array-as-environment-variable
# Notes: check and or generate databases according to user input for the completion of pipeline
#   on initial build of container:
#       1)run dockerfile:
#           docker build -t dock_seqc --ulimit nofile=65536:65536 .
#       2)run with vol mapping: docker run -it -u 0 -v C:\Users\0131549S\local\path\SeqC_stuff\seqc_db:/DB seqc_test_bnm
#       3)initialise this script via calls to BASH_seqc_mama.sh or directly
#  default host db structure: /DB/REPO_gref/host/btau/bowtie2/btau*.bt2
#  some=('tool_k2_agora');BASH_seqc_makedb.sh -s $some
#  All resources req free vol = 350576705537 (350GB) (20250130)
#ToDo:
#    logging in-line with general approach - linking with mama and env vars: v_logfile_dbug
#    more robust check of exact space req prior to invoke of builf func
#    link dled genomes between kraken
#    clear reduntancy with db build via drop of accession from get list
#   better compression: tar pigball: tar cvf - /data/share/kdb_a2a/ | pigz --best - > /data/share/kdb_a2a.tar.gz
#   evaluate and implement zenodo_get: pip3 install zenodo_get, zenodo_get -r 14888918
#   update hsap genome to: https://huttenhower.sph.harvard.edu/kneadData_databases/Homo_sapiens_hg39_T2T_Bowtie2_v0.1.tar.gz
#======================================================================================================#
# Set vars
v_debug=0
v_mkdb=0
v_chkdb=0
v_lsdb=0
v_force=0
# free blocks * block size (bytes)
v_vol_free=$(( $(stat --file-system --format="%a*%S" /) ))
#v_vol_used=$((10485760*10))
# estimate of standard vol for persephone 154 a2a (uncleaned) 7.4 hsap bt2 NEED TO FIX - BLOCKING IF ALREADY DOWNLOADED
# size of 1 megabyte MB
v_vol_mb=1048576
# size of 1 gigabyte GB
v_vol_gb=1073741824
# size of 1 GB in MB
v_vol_gm=1000
# fixed used size
#v_vol_used=$(printf %.0f $(echo "${v_vol_gb} * 161.4" | bc -l))
v_vol_used=0
# Arrays of core DBs, standard dir and retrieval command
if [[ -z "${v_dir_db}" ]]; then
    #set as default
    v_dir_db='/DB'
fi
vn=0
varr_db_name[$vn]=''
varr_db_path[$vn]=${v_dir_db}
varr_db_gets[$vn]=''
varr_db_pack[$vn]='tar -xzf '
varr_db_check[$vn]=''
varr_db_size[$vn]=${v_vol_gb}
# Host repo
# host - bowtie2 - hsap and microbe contam 7.4G - real    16m42.229s
#'host_kd_hsapcontam' 'host_kd_btau' 'host_kd_mmus'
#'tool_k2_std8' 'tool_k2_apollo' 'tool_k2_agora'
#vn=1
((vn++))
varr_db_name[$vn]='host_kd_hsapcontam'
varr_db_path[$vn]=${varr_db_path[0]}'/REPO_gref/host/hsap_contam/bowtie2'
# cert issue 20240316 - mkdir /DB/hsap/;wget --no-check-certificate http://huttenhower.sph.harvard.edu/kneadData_databases/Homo_sapiens_hg37_and_human_contamination_Bowtie2_v0.1.tar.gz -O /DB/hsap/hsap_hg37_bowtie.tar.gz
#varr_db_gets[1]='micromamba run -n env_s1 kneaddata_database --download human_genome bowtie2 '${varr_db_path[1]}'/hg37_and_contam.tar.gz'
varr_db_gets[$vn]='wget --no-check-certificate http://huttenhower.sph.harvard.edu/kneadData_databases/Homo_sapiens_hg37_and_human_contamination_Bowtie2_v0.1.tar.gz -O '${varr_db_path[$vn]}'/hsap_hg37_contam.tar.gz'
varr_db_pack[$vn]=${varr_db_pack[0]}${varr_db_path[$vn]}'/hsap_hg37_contam.tar.gz'' --directory '${varr_db_path[$vn]}
# check - if size > 1 then assume preexisting
# TODO - set to compression size as min threshold
varr_db_size[$vn]=7.4
# Pull current size
vt_L=$(du -BM ${varr_db_path[$vn]} 2> /dev/null | cut --fields 1 | tail -1 | sed 's|M||g')
# Pull expected size
vt_R=$(printf %.0f $(echo "${v_vol_gm} * ${varr_db_size[$vn]}" | bc -l))
# test and set accordingly
[[ ${vt_L} -gt ${vt_R} ]] && varr_db_check[$vn]=1 || varr_db_check[$vn]=0
# host - ncbi-bt2 - btau - 3.7G ~ 30min w/ 6 threads
((vn++))
varr_db_name[$vn]='host_kd_btau'
varr_db_path[$vn]=${varr_db_path[0]}'/REPO_gref/host/btau'
varr_db_gets[$vn]='datasets download genome accession GCF_002263795.3 --include genome --filename '${varr_db_path[$vn]}'/btau_ARS-UCD2.0.zip && unzip -qq '${varr_db_path[$vn]}'/btau_ARS-UCD2.0.zip -d '${varr_db_path[$vn]}' && micromamba run -n env_s1_kneaddata bowtie2-build --threads '${venv_cpu_max}' '${varr_db_path[$vn]}'/ncbi_dataset/data/GCF_002263795.3/GCF_002263795.3_ARS-UCD2.0_genomic.fna '${varr_db_path[$vn]}'/bowtie2/btau_ucd2'
varr_db_size[$vn]=3.7
vt_L=$(du -BM ${varr_db_path[$vn]} 2> /dev/null | cut --fields 1 | tail -1 | sed 's|M||g')
vt_R=$(printf %.0f $(echo "${v_vol_gm} * ${varr_db_size[$vn]}" | bc -l))
[[ ${vt_L} -gt ${vt_R} ]] && varr_db_check[$vn]=1 || varr_db_check[$vn]=0
# host - bowtie2 - mmus 3.5G
((vn++))
varr_db_name[$vn]='host_kd_mmus'
varr_db_path[$vn]=${varr_db_path[0]}'/REPO_gref/host/mmus/bowtie2'
#varr_db_gets[3]='micromamba run -n env_s1 kneaddata_database --download mouse_C57BL bowtie2 '${varr_db_path[3]}'/C57BL.tar.gz'
varr_db_gets[$vn]='wget --no-check-certificate http://huttenhower.sph.harvard.edu/kneadData_databases/mouse_C57BL_6NJ_Bowtie2_v0.1.tar.gz -O '${varr_db_path[$vn]}'/C57BL.tar.gz'
varr_db_pack[$vn]=${varr_db_pack[0]}${varr_db_path[$vn]}'/C57BL.tar.gz'' --directory '${varr_db_path[$vn]}
varr_db_size[$vn]=3.5
vt_L=$(du -BM ${varr_db_path[$vn]} 2> /dev/null | cut --fields 1 | tail -1 | sed 's|M||g')
vt_R=$(printf %.0f $(echo "${v_vol_gm} * ${varr_db_size[$vn]}" | bc -l))
[[ ${vt_L} -gt ${vt_R} ]] && varr_db_check[$vn]=1 || varr_db_check[$vn]=0
# Tool repo
#checkm2 - 2.9G
((vn++))
#checkm2 database --download # It seems to not be working at the moment. As it was suggested (https://github.com/chklovski/CheckM2/issues/83#issuecomment-1767129760)
varr_db_name[$vn]='tool_cm2_dmnd'
varr_db_path[$vn]=${varr_db_path[0]}'/REPO_tool/checkm2'
varr_db_gets[$vn]='micromamba run -n env_s3_checkm2 checkm2 database --download --path '${varr_db_path[$vn]}/
varr_db_pack[$vn]=''
#varr_db_gets[4]='wget https://zenodo.org/records/5571251/files/checkm2_database.tar.gz -O '${varr_db_path[4]}'/CheckM2_database.tar.gz'
#varr_db_pack[4]=${varr_db_pack[0]}${varr_db_path[4]}'/CheckM2_database.tar.gz'' --directory '${varr_db_path[4]}
varr_db_size[$vn]=2.9
vt_L=$(du -BM ${varr_db_path[$vn]} 2> /dev/null | cut --fields 1 | tail -1 | sed 's|M||g')
vt_R=$(printf %.0f $(echo "${v_vol_gm} * ${varr_db_size[$vn]}" | bc -l))
[[ ${vt_L} -gt ${vt_R} ]] && varr_db_check[$vn]=1 || varr_db_check[$vn]=0
#NCBI
# taxdump - 0.5G (493M)
((vn++))
varr_db_name[$vn]='tool_ncbi_taxd'
varr_db_path[$vn]=${varr_db_path[0]}'/REPO_tool/ncbi_NR'
varr_db_gets[$vn]='wget --no-check-certificate https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz -O '${varr_db_path[$vn]}'/taxdump.tar.gz'
varr_db_pack[$vn]='mkdir -p '${varr_db_path[$vn]}'/taxonomy && '${varr_db_pack[0]}${varr_db_path[$vn]}'/taxdump.tar.gz --directory '${varr_db_path[$vn]}'/taxonomy'
varr_db_size[$vn]=0.5
vt_L=$(du -BM ${varr_db_path[$vn]} 2> /dev/null | cut --fields 1 | tail -1 | sed 's|M||g')
vt_R=$(printf %.0f $(echo "${v_vol_gm} * ${varr_db_size[$vn]}" | bc -l))
[[ ${vt_L} -gt ${vt_R} ]] && varr_db_check[$vn]=1 || varr_db_check[$vn]=0
# kraken/bracken
## premade - pluspf smol - 8G
((vn++))
varr_db_name[$vn]='tool_k2_std8'
varr_db_path[$vn]=${varr_db_path[0]}'/REPO_tool/kraken'
varr_db_gets[$vn]='wget --no-check-certificate https://genome-idx.s3.amazonaws.com/kraken/k2_pluspf_08gb_20240605.tar.gz -O '${varr_db_path[$vn]}'/kdb_std8.tar.gz'
varr_db_pack[$vn]=${varr_db_pack[0]}${varr_db_path[$vn]}'/kdb_std8.tar.gz --directory '${varr_db_path[$vn]}'/kdb_std8'
varr_db_size[$vn]=8
vt_L=$(du -BM ${varr_db_path[$vn]} 2> /dev/null | cut --fields 1 | tail -1 | sed 's|M||g')
vt_R=$(printf %.0f $(echo "${v_vol_gm} * ${varr_db_size[$vn]}" | bc -l))
[[ ${vt_L} -gt ${vt_R} ]] && varr_db_check[$vn]=1 || varr_db_check[$vn]=0
# custom agora/apollo - apollo @ 4.5G
## apollo
((vn++))
varr_db_name[$vn]='tool_k2_apollo'
varr_db_path[$vn]=${varr_db_path[0]}'/REPO_tool/kraken/kdb_apollo'
varr_db_gets[$vn]='wget --no-check-certificate https://zenodo.org/records/14884732/files/kdb_apollo.tar.gz -O '${varr_db_path[$vn]}'.tar.gz'
varr_db_pack[$vn]='tar -I pigz -xvf '${varr_db_path[$vn]}'.tar.gz --directory '${varr_db_path[0]}'/REPO_tool/kraken/'
varr_db_size[$vn]=4.5
vt_L=$(du -BM ${varr_db_path[$vn]} 2> /dev/null | cut --fields 1 | tail -1 | sed 's|M||g')
vt_R=$(printf %.0f $(echo "${v_vol_gm} * ${varr_db_size[$vn]}" | bc -l))
[[ ${vt_L} -gt ${vt_R} ]] && varr_db_check[$vn]=1 || varr_db_check[$vn]=0
## agora2 - 50G (clean?) TODO confirm
((vn++))
varr_db_name[$vn]='tool_k2_agora'
varr_db_path[$vn]=${varr_db_path[0]}'/REPO_tool/kraken/kdb_agora'
varr_db_gets[$vn]='wget --no-check-certificate https://zenodo.org/records/14884741/files/kdb_agora.tar.gz -O '${varr_db_path[$vn]}'.tar.gz'
varr_db_pack[$vn]='tar -I pigz -xvf '${varr_db_path[$vn]}'.tar.gz --directory '${varr_db_path[0]}'/REPO_tool/kraken/'
varr_db_size[$vn]=50
vt_L=$(du -BM ${varr_db_path[$vn]} 2> /dev/null | cut --fields 1 | tail -1 | sed 's|M||g')
vt_R=$(printf %.0f $(echo "${v_vol_gm} * ${varr_db_size[$vn]}" | bc -l))
[[ ${vt_L} -gt ${vt_R} ]] && varr_db_check[$vn]=1 || varr_db_check[$vn]=0
## agora2 and apollo - 154G pre 69 post - 84G genomes - TODO ADJUST FOR FINAL BUILD 238
((vn++))
varr_db_name[$vn]='tool_k2_agora2apollo'
varr_db_path[$vn]=${varr_db_path[0]}'/REPO_tool/kraken/kdb_a2a'
varr_db_gets[$vn]='wget --no-check-certificate https://zenodo.org/records/14888918/files/kdb_a2a.tar.gz -O '${varr_db_path[$vn]}'.tar.gz'
varr_db_pack[$vn]='tar -I pigz -xvf '${varr_db_path[$vn]}'.tar.gz --directory '${varr_db_path[0]}'/REPO_tool/kraken/'
varr_db_size[$vn]=69
vt_L=$(du -BM ${varr_db_path[$vn]} 2> /dev/null | cut --fields 1 | tail -1 | sed 's|M||g')
vt_R=$(printf %.0f $(echo "${v_vol_gm} * ${varr_db_size[$vn]}" | bc -l))
[[ ${vt_L} -gt ${vt_R} ]] && varr_db_check[$vn]=1 || varr_db_check[$vn]=0
##smol demo - actual size needed
((vn++))
varr_db_name[$vn]='tool_k2_demo'
varr_db_path[$vn]=${varr_db_path[0]}'/REPO_tool/kraken/kdb_demo'
if [[ "$(du ${varr_db_path[$vn]} 2> /dev/null | cut --fields 1 | tail -1)" -gt 1 ]];then 
varr_db_check[$vn]=1
else
varr_db_check[$vn]=0
fi
varr_db_size[$vn]=8
vt_L=$(du -BM ${varr_db_path[$vn]} 2> /dev/null | cut --fields 1 | tail -1 | sed 's|M||g')
vt_R=$(printf %.0f $(echo "${v_vol_gm} * ${varr_db_size[$vn]}" | bc -l))
[[ ${vt_L} -gt ${vt_R} ]] && varr_db_check[$vn]=1 || varr_db_check[$vn]=0
# humann
func_help () {
# Help content
    printf "Usage: $0 [-h] [-f] [-a Y] [-d /DB] [-c] [-s array]\n"
    printf " -h  : Show this help message\n"
    printf " -f FORCE : Force install\n"
    printf " -b DEBUG : Enable debug output\n"
    printf " -a ALL : Confirm with Y to install all databases to -d\n"
    printf " -d DB dir : Database directory (/path/to/DB) (default: /DB)\n"
    printf " -c CHECK : Check for expected DB configuration\n"
    printf " -s SOME : one entry per DB: -s 'host_kd_btau' -s 'tool_k2_agora'\n"
    printf " -s SOME : Selective install of DB to -d \n\tAvailable:'host_kd_hsapcontam' 'host_kd_btau' 'host_kd_mmus' 'tool_cm2_dmnd' 'tool_ncbi_taxd' 'tool_k2_agora' 'tool_k2_apollo' 'tool_k2_agora2apollo' 'tool_k2_std8'\n"
}
func_sys_eval () {
#check system params
    echo "one day this might do something"
}
func_var_eval () {
# check input and export variable
# pot. use to change declaration of vars
# global declare vars each with : delim for pipeline reference
if [[ -z "${ven_db_name}" ]]; then
    ven_db_name=$( IFS=:; printf '%s' "${varr_db_name[*]}" )
    export ven_db_name
    echo "VEN_DB_NAME="\"$ven_db_name\" >> /etc/environment
fi
if [[ -z "${ven_db_gets}" ]]; then
    ven_db_gets=$( IFS=:; printf '%s' "${varr_db_gets[*]}" )
    export ven_db_gets
    echo "VEN_DB_GETS="\"$ven_db_gets\" >> /etc/environment
fi
if [[ -z "${ven_db_path}" ]]; then
    ven_db_path=$( IFS=:; printf '%s' "${varr_db_path[*]}" )
    export ven_db_path
    echo "VEN_DB_PATH="\"$ven_db_path\" >> /etc/environment
fi
if [[ -z "${ven_db_pack}" ]]; then
    ven_db_pack=$( IFS=:; printf '%s' "${varr_db_pack[*]}" )
    export ven_db_pack
    echo "VEN_DB_PACK="\"$ven_db_pack\" >> /etc/environment
fi
source /etc/environment
} #EoF
func_check () {
# check if databases are present where they should be
# run checksum to confirm
# inherit DB DL target from -s via varr_db_name
# TODO
#  structure to perform previous install/config check for all DBs

#DB dir to check
vin_check_db_dir="${1}"
# if vin_check is not empty, check and make dir, else run general check
if [[ ! -z $vin_check_db_dir ]];then
    printf 'FUNC_CHECK (makedb): Checking for requested DB subdir @:%s\n' "${vin_check_db_dir}"
    if [[ ! -d "${vin_check_db_dir}" ]];then
        printf 'FUNC_CHECK (makedb): Making requested DB subdir @:%s\n' "${vin_check_db_dir}"
        mkdir -p "${vin_check_db_dir}"
    fi
else
    if [ ! -d $v_dir_db ];then
        echo "FUNC_CHECK (makedb): The base directory for DBs does not exist"
        echo "FUNC_CHECK (makedb): Does the var_dir_db look right:->"$v_dir_db"<-"
        exit 0
    else
        if [ ! -d $v_dir_db'/REPO_gref/host' ];then
            echo "FUNC_CHECK (makedb): The sub-directory for host data does not exist"
            v_log_repo_host=0
        else
            if [ $( ls -1 $v_dir_db'/REPO_gref/host' 2>/dev/null | wc -l ) -gt 0 ];then
                echo "FUNC_CHECK (makedb): The host repo is populated"
                v_dir_repo_host=$( ls -1 $v_dir_db'/REPO_gref/host')
                varr_repo_host[0]=""
                array_len=${#varr_repo_host[@]}
                for i in $( echo $v_dir_repo_host );do
                    vchk=$(du -s $v_dir_db'/REPO_gref/host/'${i} | cut -f 1 )
                    if [ ${vchk} -gt 5 ];then 
                        echo "FUNC_CHECK (makedb): Size check on repo passed ("$i" @ "${vchk}")"
                        if [ $i = 'human' ]||[ $i = 'hsap' ];then
                            var_DB_HOST_hsap=$v_dir_db'/REPO_gref/host/'$i
                            varr_repo_host[array_len]='hsap'
                            array_len=${#varr_repo_host[@]}
                        fi
                        if [ $i = 'human' ]||[ $i = 'hsap_contam' ];then
                            var_DB_HOST_hsapcontam=$v_dir_db'/REPO_gref/host/'$i
                            varr_repo_host[array_len]='hsap_contam'
                            array_len=${#varr_repo_host[@]}
                        fi
                        if [ $i = 'cow' ]||[ $i = 'btau' ];then
                            var_DB_HOST_btau=$v_dir_db'/REPO_gref/host/'$i
                            varr_repo_host[array_len]='btau'
                            array_len=${#varr_repo_host[@]}
                        fi
                    else
                        echo "FUNC_CHECK: Size check on repo FAILED ("$i" @ "${vchk}")"
                    fi
                done
            else
                echo "FUNC_CHECK: The host repo is empty"
                v_dir_repo_host=0
            fi
            if [ $( ls -1 $v_dir_db'/REPO_tool' 2>/dev/null | wc -l ) -gt 0 ];then
                echo "FUNC_CHECK: The tool repo is populated"
                v_dir_repo_tool=$( ls -1 $v_dir_db'/REPO_tool')
                varr_repo_tool[0]=""
                array_len=${#varr_repo_tool[@]}
                for i in $( echo $v_dir_repo_tool );do
                    #for i in $( eval "echo $v_dir_repo_host" );do
                    vchk=$(du -s $v_dir_db'/REPO_tool/'${i} | cut -f 1 )
                    if [ ${vchk} -gt 10 ];then
                        echo "FUNC_CHECK: Size check on repo passed ("$i" @ "${vchk}")"
                        if [ $i = 'checkm' ]||[ $i = 'checkm2' ];then
                            var_DB_TOOL_checkm2=$v_dir_db'/REPO_tool/'$i
                            varr_repo_tool[array_len]='checkm2'
                            array_len=${#varr_repo_tool[@]}
                        fi
                    else
                    echo "FUNC_CHECK: Size check on repo FAILED ("$i" @ "${vchk}")"
                    fi
                done
            else
                echo "FUNC_CHECK: The tool repo is empty"
                v_dir_repo_tool=0
            fi
        fi
    fi
fi
} #EoF
func_makedb_krak () {
    #Generate kraken/bracken DBs
    #Req input of
    #  list of taxa eg Abiotrophia defectiva
    #bring in variables
    v_file_in=$1
    v_file_out=$2
    vDBNAME=$3
    v_dir_k2_genm=$4
    vKMER=$5
    vREAD=$6
    #expected k2 resources
    printf 'filein-1:%s\tfileout-2:%s\tDB-3:%s\tgenome-4:%s\tkmer-5:%s\tread-6:%s\n' ${v_file_in} ${v_file_out} ${vDBNAME} ${v_dir_k2_genm} ${vKMER} ${vREAD}
    # prepare kraken db dirs
    # CHANGE WITH default added /taxonomy in ncbi
    v_ndmp='/DB/REPO_tool/ncbi_NR/taxonomy/'
    v_kdmp='/DB/REPO_tool/kraken/taxonomy/'
    vmk1=0
    vmk2=0
    #check for central ncbi taxdmp
    if [[ ! $( find "${v_kdmp}" -name '*.dmp' 2> /dev/null | wc -l ) -gt 0 ]];then
        printf 'FUNC_MAKE_KDB (makedb): Kraken taxdmp missing @ %s\n' "${v_kdmp}"
        mkdir -p "${v_kdmp}"
        if [[ ! $( find "${v_ndmp}" -name '*.dmp' 2> /dev/null | wc -l ) -gt 0 ]];then
            printf 'FUNC_MAKE_KDB (makedb): Core taxdmp missing @ %s\n\tResolving\n' "${v_ndmp}"
            #better approach needed
            mkdir -p "${v_ndmp}"
            wget --no-check-certificate https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz -O "${v_ndmp}"taxdump.tar.gz
            tar -xvf "${v_ndmp}"taxdump.tar.gz -C "${v_ndmp}"
            ln -s "${v_ndmp}"* ${v_kdmp%/}
            vmk1=1
        else
            ln -s "${v_ndmp}"* ${v_kdmp%/}
            vmk1=1
        fi
    fi
    # check for accession2taxid files for kraken
    # proc moved here from DB specific calls
    #ncbi acc2taxid
    # check if unzipped and present
    if [[ ! $( find "${v_kdmp}" -name '*.accession2taxid' 2> /dev/null | wc -l ) -gt 0 ]];then
        if [[ ! $( find "${v_kdmp}" -name '*.accession2taxid.gz' 2> /dev/null | wc -l ) -gt 0 ]];then
            printf 'FUNC_MAKE: Kraken accession2taxid missing @ %s\n' "${v_kdmp}"
            vmk2=1
            if [[ ! -d "${v_kdmp}" ]];then
                echo "FUNC_MAKE: making kraken dmp dir."
                mkdir -p "${v_kdmp}"
            fi
        fi
        if (( ${vmk2} ));then
            printf 'FUNC_MAKE: Kraken accession2taxid DL @ %s\n' "${v_kdmp}"
            vDIRpre=$(pwd)
            cd "${v_kdmp}"
            wget --no-check-certificate https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/accession2taxid/nucl_gb.accession2taxid.gz \
            -O "${v_kdmp}"nucl_gb.accession2taxid.gz
            wget --no-check-certificate https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/accession2taxid/nucl_wgs.accession2taxid.gz \
            -O "${v_kdmp}"nucl_wgs.accession2taxid.gz
            cd "${vDIRpre}"
        fi
    fi
    # decompress if present
    if [[ $( find "${v_kdmp}" -name '*.accession2taxid.gz' 2> /dev/null | wc -l ) -gt 0 ]];then
        unpigz "${v_kdmp}"*accession2taxid.gz
    fi
    # check for db dir
    if [[ ! -d "${vDBNAME}" ]];then
        printf 'FUNC_MAKE_KDB (makedb): %s missing, DB dir will be created\n' "${vDBNAME}"
        mkdir -p "${vDBNAME}"
        #check for preexisting taxdump and nucl_gb/wgs content
        if [[ $( find "${v_kdmp}" -name '*.dmp' 2> /dev/null | wc -l ) -gt 0 ]];then
            printf 'FUNC_MAKE_KDB (makedb): Kraken dmp found @ %s and symlinked\n' "${v_kdmp}"
            ln -s ${v_kdmp} ${vDBNAME%/}
        fi
    fi
    # confirm taxonomy link in DB and DL if not
    if [[ ! -d "${vDBNAME}/taxonomy" ]];then
        printf 'FUNC_MAKE_KDB (makedb): %s missing, taxonomy will be linked to dir\n' "${vDBNAME}/taxonomy"
        if [[ $( find "${v_kdmp}" -name '*.dmp' 2> /dev/null | wc -l ) -gt 0 ]];then
            printf 'FUNC_MAKE_KDB (makedb): Kraken dmp found @ %s and symlinked\n' "${v_kdmp}"
            ln -s ${v_kdmp} ${vDBNAME%/}
        else
            if [[ ! $( find "${v_ndmp}" -name '*.dmp' 2> /dev/null | wc -l ) -gt 0 ]];then
                printf 'FUNC_MAKE_KDB (makedb): Core taxdmp missing @ %s\n\tResolving\n' "${v_ndmp}"
                #better approach needed
                mkdir -p "${v_ndmp}"
                wget --no-check-certificate https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz -O "${v_ndmp}"taxdump.tar.gz
                tar -xvf "${v_ndmp}"taxdump.tar.gz -C "${v_ndmp}"
                ln -s "${v_ndmp}"* "${v_kdmp%/}"
            else
                ln -s "${v_ndmp}"* "${v_kdmp%/}"
            fi
            # extra attempt to ensure correct content of taxonomy dir.
            ln -s "${v_ndmp}"* "${v_kdmp%/}"
            ln -s "${v_kdmp}" "${vDBNAME}"
        fi
        # if still missing DL fresh directly
        if [[ ! -d "${vDBNAME}/taxonomy" ]];then
            printf 'FUNC_MAKE_KDB (makedb): symlink unsuccessful, DL directly to DB\n'
            wget --no-check-certificate https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz -O "${vDBNAME}"/taxdump.tar.gz
            mkdir -p "${vDBNAME}/taxonomy" && tar -xvf "${vDBNAME}"/taxdump.tar.gz -C "${vDBNAME}/taxonomy" && mv "${vDBNAME}"/taxdump.tar.gz "${vDBNAME}/taxonomy"
        fi
    # check contents to confirm .dmp entities
    else
    printf 'extra check'
    fi
    # check for and make kraken taxa file for new DB
    if [[ ! -f "${v_file_out}" ]];then
        printf '%s missing, new file will be created\n' "${v_file_out}"
        # CRIT: parse taxa name for ENA ERR accession and pull+append correct taxid
        # for ENA: micromamba install -n enasearch -c bioconda -c conda-forge enasearch : micromamba create --yes --file env_util_enasearch.yml
        # replace ood line @706: sed -i 's/data\/warehouse/portal\/api/' /opt/conda/envs/env_util_enasearch/lib/python2.7/site-packages/enasearch/__init__.py
        #    micromamba run -n env_util_enasearch enasearch retrieve_run_report --accession "ERR209817" --fields tax_id
        # subset for ENA ERR accession
        v_grab='ERR'
        v_grep_in=${v_file_in}
        v_grep_incl=${v_file_in/.*/_ncbi.txt}
        v_grep_excl=${v_file_in/.*/_ena.txt}
        grep -v "$v_grab" $v_grep_in > $v_grep_incl
        grep -e "$v_grab" $v_grep_in > $v_grep_excl
        v_grab='ERR[0-9]+'
        mapfile -t varr_enaid < <( grep -Eo "${v_grab}" $v_grep_excl )
        for vi in ${!varr_enaid[@]};do
        #for vi in {0..9};do
            if [[ ! -z ${varr_enaid[vi]} ]];then
            varr_enataxid+=( $(micromamba run -n env_util_enasearch enasearch retrieve_run_report --accession "${varr_enaid[vi]}" --fields tax_id 2> /dev/null | \
            cut --fields 2 | sed -n '2p;') )
            fi
        done
        #combine input name to assesion and pull taxonomy
        paste <(printf '%s\n' "$(< $v_grep_excl)") <(printf '%s\n' "${varr_enataxid[@]}") | micromamba run -n env_util_taxonkit \
        taxonkit lineage --data-dir "${vDBNAME}"/taxonomy/ --threads "${venv_cpu_max}" -i 2 -n \
        --out-file "${v_file_out/%/.tmp_ena}"
        #pull non ena - prev input=v_file_in
        time cat "${v_grep_incl}" | micromamba run -n env_util_taxonkit taxonkit name2taxid \
        --data-dir "${vDBNAME}"/taxonomy/ --fuzzy --threads "${venv_cpu_max}" | micromamba run -n env_util_taxonkit \
        taxonkit lineage --data-dir "${vDBNAME}"/taxonomy/ --threads "${venv_cpu_max}" -i 2 -n \
        --out-file "${v_file_out/%/.tmp_ncbi}"
        # Join and remove tmps
        v_ln0=$( wc -l ${v_grep_incl} | cut --fields 1 -d ' ' )
        v_ln1=$( wc -l ${v_grep_excl} | cut --fields 1 -d ' ' )
        if [[ "${v_ln0}" -gt 0 ]] && [[ "${v_ln1}" -gt 0 ]];then
            cat "${v_file_out/%/.tmp_ena}" "${v_file_out/%/.tmp_ncbi}" > "${v_file_out}"
        else
            if [[ "${v_ln0}" -gt 0 ]];then
                cat "${v_file_out/%/.tmp_ncbi}" > "${v_file_out}"
            fi
            if [[ "${v_ln1}" -gt 0 ]];then
                cat "${v_file_out/%/.tmp_ena}" > "${v_file_out}"
            fi
        fi
        rm "${v_file_out/%/.tmp_ena}" "${v_file_out/%/.tmp_ncbi}"
        unset varr_enataxid
        # exception replacement - dumb
        # apollo
        if [[ "${v_file_out}" == '/DB/REPO_tool/kraken/t2p/taxa2proc_a2a_out.txt' ]];then
        v_grab='Blautia torques'
        v_repl='411460\tcellular organisms;Bacteria;Terrabacteria group;Bacillota;Clostridia;Lachnospirales;Lachnospiraceae;Mediterraneibacter;[Ruminococcus] torques;[Ruminococcus] torques ATCC 27756\t[Ruminococcus] torques ATCC 27756'
        sed -i "s/$v_grab.*/$v_grab\t$v_repl/" "${v_file_out}"
        fi
        if [[ "${v_file_out}" == '/DB/REPO_tool/kraken/t2p/taxa2proc_agora_out.txt' ]];then
        #https://bacdive.dsmz.de/strain/132900
        v_grab='Blautia massiliensis GD9'
        v_repl='1737424\tcellular organisms;Bacteria;Terrabacteria group;Bacillota;Clostridia;Lachnospirales;Lachnospiraceae;Blautia;Blautia massiliensis (ex Durand et al. 2017)\tBlautia massiliensis (ex Durand et al. 2017)'
        sed -i "s/$v_grab.*/$v_grab\t$v_repl/" "${v_file_out}"
        #FDA-ARGOS
        v_grab='Comamonas terrigena FDAARGOS 394 pRIID 98'
        v_repl='32013\tcellular organisms;Bacteria;Pseudomonadota;Betaproteobacteria;Burkholderiales;Comamonadaceae;Comamonas;Comamonas terrigena\tComamonas terrigena'
        sed -i "s/$v_grab.*/$v_grab\t$v_repl/" "${v_file_out}"
        v_grab='Guyana massiliensis LF 3'
        v_repl='1504823\tcellular organisms;Bacteria;unclassified Bacteria;bacterium LF-3\tbacterium LF-3'
        sed -i "s/$v_grab.*/$v_grab\t$v_repl/" "${v_file_out}"
        v_grab='Jeddahella massiliensis OL 1'
        v_repl='1504822\tcellular organisms;Bacteria;unclassified Bacteria;bacterium OL-1\tbacterium OL-1'
        sed -i "s/$v_grab.*/$v_grab\t$v_repl/" "${v_file_out}"
        v_grab='Polynesia massiliensis MS3'
        v_repl='1329795\tcellular organisms;Bacteria;Terrabacteria group;Bacillota;Clostridia;Eubacteriales;Clostridiaceae;unclassified Clostridiaceae;Clostridiaceae bacterium MS3\tClostridiaceae bacterium MS3'
        sed -i "s/$v_grab.*/$v_grab\t$v_repl/" "${v_file_out}"
        fi
    fi
    # v_file_out structure:
    # taxa name in | taxid | full taxonomy | taxa name out
    #cat /DB/REPO_tool/kraken/taxa2proc_apollo_out.txt | cut -f 2 | head -n 1
    # subset uniq taxid
    mapfile -t varr_taxid_uniq < <( cat "${v_file_out}" | cut --fields 2 | sort | uniq )
    #cycle through entry of taxa2proc and pull taxid, dl genome, unzip, add
    #v_dir_k2_genm='/DB/REPO_tool/kraken/genomes/apollo'
    # TODO search and symlink for other genome subdirs
    # ln -s ${v_dir_k2_genm_source}/* ${v_dir_k2_genm_target}/ 
    #make if not there
    if [[ ! -d "${v_dir_k2_genm}" ]];then
        echo "making genome dir."
        mkdir -p "${v_dir_k2_genm}"
    fi
    #check for log and remove failed ids from input
    if [[ -f "${v_dir_k2_genm}/log_fail.txt" ]];then
    mapfile -t varr_taxid_uniq < <( comm -3 <( printf '%s\n' "${varr_taxid_uniq[@]}" ) <( cat "${v_dir_k2_genm}/log_fail.txt" | sed 1d | cut --fields 1 ) )
    else
        #create fail log if missing
        printf 'NCBI_ID\tno_attempts\n' > ${v_dir_k2_genm}/log_fail.txt
    fi
    # remove elements from array eg uncultured taxa
    varr_drop=(77133)
    for v_grab in "${varr_drop[@]}";do
        for vi in "${!varr_taxid_uniq[@]}";do
            if [[ ${varr_taxid_uniq[vi]} = $v_grab ]];then
                unset 'varr_taxid_uniq[vi]'
            fi
        done
    done
    #remove whitespace
    varr_taxid_uniq=( $(printf '%s\n' "${varr_taxid_uniq[@]}") )
    for v_i in "${!varr_taxid_uniq[@]}";do
        if (( v_i < "${#varr_taxid_uniq[@]}" ));then
            if [ $v_i == 0 ];then
                printf 'FUNC_MAKE_KDB (makedb): Beginning genome pull\n'
            fi
            # check for preexisting genome dir, bypass if present
            if [[ ! -d ${v_dir_k2_genm}/${varr_taxid_uniq[v_i]} ]];then
            #why getting through?!
                v_fail=0
                printf 'generating genome from taxid:%s\n' "${varr_taxid_uniq[v_i]}"
                #datasets download genome taxon 46125 --assembly-level complete --assembly-source RefSeq --assembly-version latest --include genome --reference
                #--assembly-level chromosome complete contig scaffold
                #--assembly-source RefSeq GenBank
                #--assembly-version latest
                #First try with complete reference genome
                datasets download genome taxon "${varr_taxid_uniq[v_i]}" --assembly-level complete \
                --assembly-source RefSeq --assembly-version latest --include genome --reference \
                --filename ${v_dir_k2_genm}/${varr_taxid_uniq[v_i]}.zip 2> /dev/null
                #check success - if fail try chromosome
                if [[ $(ls -l ${v_dir_k2_genm}/${varr_taxid_uniq[v_i]}.zip 2> /dev/null | wc -l) -eq 0 ]];then
                    ((v_fail++))
                    datasets download genome taxon "${varr_taxid_uniq[v_i]}" --assembly-level chromosome \
                --assembly-source RefSeq --assembly-version latest --include genome --reference \
                --filename ${v_dir_k2_genm}/${varr_taxid_uniq[v_i]}.zip 2> /dev/null
                fi
                #check success - if fail try contig
                if [[ $(ls -l ${v_dir_k2_genm}/${varr_taxid_uniq[v_i]}.zip 2> /dev/null | wc -l) -eq 0 ]];then
                    ((v_fail++))
                    datasets download genome taxon "${varr_taxid_uniq[v_i]}" --assembly-level contig \
                --assembly-source RefSeq --assembly-version latest --include genome --reference \
                --filename ${v_dir_k2_genm}/${varr_taxid_uniq[v_i]}.zip 2> /dev/null
                fi
                #check success - if fail try scaffold
                if [[ $(ls -l ${v_dir_k2_genm}/${varr_taxid_uniq[v_i]}.zip 2> /dev/null | wc -l) -eq 0 ]];then
                    ((v_fail++))
                    datasets download genome taxon "${varr_taxid_uniq[v_i]}" --assembly-level scaffold \
                --assembly-source RefSeq --assembly-version latest --include genome --reference \
                --filename ${v_dir_k2_genm}/${varr_taxid_uniq[v_i]}.zip 2> /dev/null
                fi
                #check success - if fail try chromosome no ref
                if [[ $(ls -l ${v_dir_k2_genm}/${varr_taxid_uniq[v_i]}.zip 2> /dev/null | wc -l) -eq 0 ]];then
                    ((v_fail++))
                    datasets download genome taxon "${varr_taxid_uniq[v_i]}" --assembly-level chromosome \
                --assembly-source RefSeq --assembly-version latest --include genome \
                --filename ${v_dir_k2_genm}/${varr_taxid_uniq[v_i]}.zip 2> /dev/null
                fi
                #check success - if fail try contig no ref
                if [[ $(ls -l ${v_dir_k2_genm}/${varr_taxid_uniq[v_i]}.zip 2> /dev/null | wc -l) -eq 0 ]];then
                    ((v_fail++))
                    datasets download genome taxon "${varr_taxid_uniq[v_i]}" --assembly-level contig \
                --assembly-source RefSeq --assembly-version latest --include genome \
                --filename ${v_dir_k2_genm}/${varr_taxid_uniq[v_i]}.zip 2> /dev/null
                fi
                #check success - if fail try scaffold no ref
                if [[ $(ls -l ${v_dir_k2_genm}/${varr_taxid_uniq[v_i]}.zip 2> /dev/null | wc -l) -eq 0 ]];then
                    ((v_fail++))
                    datasets download genome taxon "${varr_taxid_uniq[v_i]}" --assembly-level scaffold \
                --assembly-source RefSeq --assembly-version latest --include genome \
                --filename ${v_dir_k2_genm}/${varr_taxid_uniq[v_i]}.zip 2> /dev/null
                fi
                #check success - if fail try genbank - complete
                if [[ $(ls -l ${v_dir_k2_genm}/${varr_taxid_uniq[v_i]}.zip 2> /dev/null | wc -l) -eq 0 ]];then
                    ((v_fail++))
                    datasets download genome taxon "${varr_taxid_uniq[v_i]}" --assembly-level complete \
                    --assembly-source GenBank --assembly-version latest --include genome --reference \
                    --filename ${v_dir_k2_genm}/${varr_taxid_uniq[v_i]}.zip 2> /dev/null
                fi
                #check success - if fail try genbank - contig
                if [[ $(ls -l ${v_dir_k2_genm}/${varr_taxid_uniq[v_i]}.zip 2> /dev/null | wc -l) -eq 0 ]];then
                    ((v_fail++))
                    datasets download genome taxon "${varr_taxid_uniq[v_i]}" --assembly-level contig \
                    --assembly-source GenBank --assembly-version latest --include genome --reference \
                    --filename ${v_dir_k2_genm}/${varr_taxid_uniq[v_i]}.zip 2> /dev/null
                fi
                #check success - if fail try genbank - contig no ref
                if [[ $(ls -l ${v_dir_k2_genm}/${varr_taxid_uniq[v_i]}.zip 2> /dev/null | wc -l) -eq 0 ]];then
                    ((v_fail++))
                    datasets download genome taxon "${varr_taxid_uniq[v_i]}" --assembly-level contig \
                    --assembly-source GenBank --assembly-version latest --include genome \
                    --filename ${v_dir_k2_genm}/${varr_taxid_uniq[v_i]}.zip 2> /dev/null
                fi
                #check success - if fail try genbank - scaffold no reference
                if [[ $(ls -l ${v_dir_k2_genm}/${varr_taxid_uniq[v_i]}.zip 2> /dev/null | wc -l) -eq 0 ]];then
                    ((v_fail++))
                    datasets download genome taxon "${varr_taxid_uniq[v_i]}" --assembly-level scaffold \
                    --assembly-source GenBank --assembly-version latest --include genome \
                    --filename ${v_dir_k2_genm}/${varr_taxid_uniq[v_i]}.zip 2> /dev/null
                fi
                #check success - if fail try refseq - drop level field
                if [[ $(ls -l ${v_dir_k2_genm}/${varr_taxid_uniq[v_i]}.zip 2> /dev/null | wc -l) -eq 0 ]];then
                    ((v_fail++))
                    datasets download genome taxon "${varr_taxid_uniq[v_i]}" \
                    --assembly-source GenBank --assembly-version latest --include genome \
                    --filename ${v_dir_k2_genm}/${varr_taxid_uniq[v_i]}.zip 2> /dev/null
                fi
                #check success - if fail try genbank - drop level field
                if [[ $(ls -l ${v_dir_k2_genm}/${varr_taxid_uniq[v_i]}.zip 2> /dev/null | wc -l) -eq 0 ]];then
                    ((v_fail++))
                    datasets download genome taxon "${varr_taxid_uniq[v_i]}" \
                    --assembly-source RefSeq --assembly-version latest --include genome \
                    --filename ${v_dir_k2_genm}/${varr_taxid_uniq[v_i]}.zip 2> /dev/null
                fi
                if [[ $(ls -l ${v_dir_k2_genm}/${varr_taxid_uniq[v_i]}.zip 2> /dev/null | wc -l) -eq 0 ]];then
                #pot continue attempts as with camism smaples ie retry genbank
                    ((v_fail++))
                    printf '%s\t%s\n' "${varr_taxid_uniq[v_i]}" "${v_fail}" >> ${v_dir_k2_genm}/log_fail.txt
                fi
                if [[ $(ls -l ${v_dir_k2_genm}/${varr_taxid_uniq[v_i]}.zip 2> /dev/null | wc -l) -gt 0 ]];then
                    #inflate
                    yes | unzip ${v_dir_k2_genm}/${varr_taxid_uniq[v_i]}.zip -d ${v_dir_k2_genm}/${varr_taxid_uniq[v_i]}
                    #rm zip
                    rm ${v_dir_k2_genm}/${varr_taxid_uniq[v_i]}.zip
                fi
                if [[ $(ls -l ${v_dir_k2_genm}/${varr_taxid_uniq[v_i]} 2> /dev/null | wc -l) -gt 0 ]];then
                    #pull path - first entry
                    #v_path=( $( ls ${v_dir_k2_genm}/${varr_taxid_uniq[v_i]}/ncbi_dataset/data/GC{A,F}_*/GC{A,F}_*_genomic.fna | head -n 1 ) )
                    #pull path - all
                    v_path=( $( ls ${v_dir_k2_genm}/${varr_taxid_uniq[v_i]}/ncbi_dataset/data/GC{A,F}_*/GC{A,F}_*_genomic.fna 2> /dev/null ) )
                    #add to db
                    for vii in "${!v_path[@]}";do
                        #parallelize with adaptation of -P in: find genomes/ -name '*.fa' -print0 | xargs -0 -I{} -n1 kraken2-build --add-to-library {} --db $DBNAME
                        micromamba run -n env_s4_kraken kraken2-build --threads ${venv_cpu_max} \
                        --add-to-library "${v_path[vii]}" --db ${vDBNAME}
                        # pot pigz or delete after kdb insertion
                    done
                    #compile config files
                fi
            fi
            #check for empty log and rm if T
            if [ ${v_i} == ${#varr_taxid_uniq[@]} ];then
                if [[ $(cat ${v_dir_k2_genm}/log_fail.txt | wc -l) -eq 1 ]];then
                    rm ${v_dir_k2_genm}/log_fail.txt
                fi
            fi
        fi
    done
    # Build
    time micromamba run -n env_s4_kraken kraken2-build --build --db ${vDBNAME} --threads ${venv_cpu_max}
    # build bracken database file
    vKEX='/opt/conda/envs/env_s4_kraken/bin/'
    #add to path, find better approach
    export PATH="/opt/conda/envs/env_s4_kraken/lib/bracken/src:$PATH"
    time micromamba run -n env_s4_kraken bracken-build \
    -x ${vKEX} -d ${vDBNAME} -t ${venv_cpu_max} -k ${vKMER} -l ${vREAD}
    # Clean-up
    # kraken clean DB
    micromamba run -n env_s4_kraken kraken2-build --clean --db ${vDBNAME} --threads ${venv_cpu_max}
    # TODO remove contents of genome dir ... needs consideration of other usage of contents
    # compress
    pigz "${v_kdmp}"*accession2taxid
} #EoF
func_makedb () {
# pull missing databases and align them with the pipeline v_mkdb=1 compile du of all dbs
#host_kd_hsapcontam host_kd_btau host_kd_mmus tool_cm2_dmnd
#from check confirm presence/auth of DBs and bypass creation - done with v_force/varr_check
# TODO logging for force/check
if [ $v_mkdb -eq 1 ];then
    echo "FUNC_MAKE: Checking if DB creation makes sense"
    if [[ $v_vol_free -gt $v_vol_used ]];then
        echo "FUNC_MAKE: More disk space is available than needed... noice"
        printf 'FUNC_MAKE: varr_db_name: %s\n' "${varr_db_name[@]}"
        for vi in ${!varr_db_name[@]};do
            if [[ $vi -ge 1 ]];then
                printf 'FUNC_MAKE: Working on DB for: %s\n' "${varr_db_name[vi]}"
                #printf 'vi@:%s\tvarr_db_name:%s\tvarr_db_path:%s\tvarr_db_gets:%s\tvarr_db_pack:%s\t' "${vi}" "${varr_db_name[$vi]}" "${varr_db_path[$vi]}" "${varr_db_gets[$vi]}" "${varr_db_pack[$vi]}"
                if [ ${varr_db_name[$vi]} = 'host_kd_hsapcontam' ];then
                # check pass if force = 1 or check = 0
                    if (( ${v_force} )) || (( ! ${varr_db_check[$vi]} ));then
                        #add log output to include location and size,7.48G  6.92MB/s    in 10m 7s
                        #3736219777/3736219777
                        echo "FUNC_MAKE: Making host decontamination DB: Hsap with contam (kneaddata)"
                        #if [[ ! $( find "${varr_db_path[$vi]}"/* 2> /dev/null | wc -l ) -gt 6 ]];then
                            eval ${varr_db_gets[$vi]}
                            eval ${varr_db_pack[$vi]}
                            echo "FUNC_MAKE: DB content @: "${varr_db_path[$vi]}
                        #fi
                    else
                        printf 'FUNC_MAKE: Pre-existing Content present for DB: %s\n' "${varr_db_name[vi]}"
                    fi
                fi
                if [ ${varr_db_name[$vi]} = 'host_kd_btau_BLOCK' ];then
                    #add log output to include location and size,3.48G  6.92MB/s    in 10m 7s
                    if (( ${v_force} )) || (( ! ${varr_db_check[$vi]} ));then
                        echo "FUNC_MAKE: Making host decontamination DB: Btau (kneaddata)"
                        eval ${varr_db_gets[$vi]}
                        eval ${varr_db_pack[$vi]}
                        echo "FUNC_MAKE: DB content @: "${varr_db_path[$vi]}
                    else
                        printf 'FUNC_MAKE: Pre-existing Content present for DB: %s\n' "${varr_db_name[vi]}"
                    fi
                fi
                if [ ${varr_db_name[$vi]} = 'host_kd_mmus_BLOCK' ];then
                    #add log output to include location and size,3.48G  6.92MB/s    in 10m 7s
                    if (( ${v_force} )) || (( ! ${varr_db_check[$vi]} ));then
                        echo "FUNC_MAKE: Making host decontamination DB: Mmus (kneaddata)"
                        eval ${varr_db_gets[$vi]}
                        eval ${varr_db_pack[$vi]}
                        echo "FUNC_MAKE: DB content @: "${varr_db_path[$vi]}   
                    else
                        printf 'FUNC_MAKE: Pre-existing Content present for DB: %s\n' "${varr_db_name[vi]}"
                    fi
                fi
                if [ ${varr_db_name[$vi]} = 'tool_cm2_dmnd' ];then
                    if (( ${v_force} )) || (( ! ${varr_db_check[$vi]} ));then
                        #add log output to include location and size,2.9G  6.92MB/s    in 10m 7s
                        #checkm db continuation from dockerfile
                        # and set the database location manually: checkm2 database --setdblocation ${varr_db_path[4]}/CheckM2_database/uniref100.KO.1.dmnd
                        echo "FUNC_MAKE: Making genome QC DB (checkm2)"
                        eval ${varr_db_gets[$vi]}
                        eval ${varr_db_pack[$vi]}
                        micromamba run -n env_s3_checkm2 checkm2 database --setdblocation ${varr_db_path[$vi]}/CheckM2_database/uniref100.KO.1.dmnd
                        echo "FUNC_MAKE: DB content @: "${varr_db_path[$vi]}"/CheckM2_database"
                    else
                        printf 'FUNC_MAKE: Pre-existing Content present for DB: %s\n' "${varr_db_name[vi]}"
                    fi
                fi
                if [ ${varr_db_name[$vi]} = 'tool_ncbi_taxd' ];then
                    #add log output to include location and size,3.48G  6.92MB/s    in 10m 7s
                    if (( ${v_force} )) || (( ! ${varr_db_check[$vi]} ));then
                        echo "FUNC_MAKE: Making reference DB: taxdump (ncbi)"
                        eval ${varr_db_gets[$vi]}
                        eval ${varr_db_pack[$vi]}
                        echo "FUNC_MAKE: DB content @: "${varr_db_path[$vi]}
                    else
                        printf 'FUNC_MAKE: Pre-existing Content present for DB: %s\n' "${varr_db_name[vi]}"
                    fi
                fi
                if [ ${varr_db_name[$vi]} = 'tool_k2_std8' ];then
                    #add log output to include location and size,3.48G  6.92MB/s    in 10m 7s
                    if (( ${v_force} )) || (( ! ${varr_db_check[$vi]} ));then
                        echo "FUNC_MAKE: Making reference DB: standard plus protozoa and fungi (kraken2)"
                        func_check "${varr_db_path[$vi]}"'/kdb_std8'
                        eval ${varr_db_gets[$vi]}
                        eval ${varr_db_pack[$vi]}
                        echo "FUNC_MAKE: DB content @: "${varr_db_path[$vi]}
                        #make bracken - optimise param approach
                        vKEX='/opt/conda/envs/env_s4_kraken/bin/'
                        vKMER=35
                        vREAD=150
                        vDBNAME="${varr_db_path[$vi]}"'/kdb_std8'
                        #add to path, find better approach
                        export PATH="/opt/conda/envs/env_s4_kraken/lib/bracken/src:$PATH"
                        time micromamba run -n env_s4_kraken bracken-build \
                        -d ${vDBNAME} -t ${venv_cpu_max} -k ${vKMER} -l ${vREAD}
                        #-x ${vKEX} -d ${vDBNAME} -t ${venv_cpu_max} -k ${vKMER} -l ${vREAD}
                    else
                        printf 'FUNC_MAKE: Pre-existing Content present for DB: %s\n' "${varr_db_name[vi]}"
                    fi
                fi
                if [ ${varr_db_name[$vi]} = 'tool_k2_demo' ];then
                    #add log output to include location and size,3.48G  6.92MB/s    in 10m 7s
                    if (( ${v_force} )) || (( ! ${varr_db_check[$vi]} ));then
                        echo "FUNC_MAKE: Making reference DB: smol demo DB (kraken2)"
                        #eval ${varr_db_gets[$vi]}
                        #eval ${varr_db_pack[$vi]}
                        # check for core kdmp
                        v_kdmp=/DB/REPO_tool/kraken/taxonomy/
                        vmk1=0
                        vmk2=0
                        #ncbi taxdmp
                        if [[ ! $( find "${v_kdmp}" -name '*.dmp' 2> /dev/null | wc -l ) -gt 0 ]];then
                            printf 'Kraken dmp missing @ %s\n' "${v_kdmp}"
                            vmk1=1
                            if [[ ! -d "${v_kdmp}" ]];then
                                echo "FUNC_MAKE: making kraken dmp dir."
                                mkdir -p "${v_kdmp}"
                            fi
                        fi
                        #ncbi acc2taxid
                        if [[ ! $( find "${v_kdmp}" -name '*.accession2taxid.gz' 2> /dev/null | wc -l ) -gt 0 ]];then
                            printf 'FUNC_MAKE: Kraken accession2taxid missing @ %s\n' "${v_kdmp}"
                            vmk2=1
                            if [[ ! -d "${v_kdmp}" ]];then
                                echo "FUNC_MAKE: making kraken dmp dir."
                                mkdir -p "${v_kdmp}"
                            fi
                        fi
                        if (( ${vmk2} ));then
                            printf 'FUNC_MAKE: Kraken accession2taxid DL @ %s\n' "${v_kdmp}"
                            vDIRpre=$(pwd)
                            cd "${v_kdmp}"
                            wget --no-check-certificate https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/accession2taxid/nucl_gb.accession2taxid.gz \
                            -O "${v_kdmp}"nucl_gb.accession2taxid.gz
                            wget --no-check-certificate https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/accession2taxid/nucl_wgs.accession2taxid.gz \
                            -O "${v_kdmp}"nucl_wgs.accession2taxid.gz
                            gunzip "${v_kdmp}"*accession2taxid.gz
                            cd "${vDIRpre}"
                        fi
                        if (( ${vmk1} ));then
                            vDIRpre=$(pwd)
                            cd "${v_kdmp}"
                            wget --no-check-certificate https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz \
                            -O "${v_kdmp}"taxdump.tar.gz
                            tar zxf taxdump.tar.gz
                            cd "${vDIRpre}"
                        fi
                        #check for db dir
                        v_kdmp=/DB/REPO_tool/kraken/taxonomy/
                        vDBNAME='/DB/REPO_tool/kraken/kdb_demo'
                        vKMER=35
                        vREAD=150
                        #venv_cpu_max=12
                        if [[ ! -d "${vDBNAME}" ]];then
                            printf '%s missing, DB dir will be created\n' "${vDBNAME}"
                            mkdir -p "${vDBNAME}"
                            #check for preexisting taxdump and nucl_gb/wgs content
                            if [[ $( find "${v_kdmp}" -name '*.dmp' 2> /dev/null | wc -l ) -gt 0 ]];then
                                printf 'Kraken dmp found @ %s and symlinked\n' "${v_kdmp}"
                                ln -s ${v_kdmp} ${vDBNAME}
                            fi
                        fi
                        #check for simulation genomes
                        v_kdmp='/DB/DEPO_demo/demo/camisim/AGORA_smol/genomes/*/ncbi_dataset/data/GC{A,F}_*/GC{A,F}_*_genomic.fna'
                        if [[ $( eval find "${v_kdmp}" 2> /dev/null | wc -l ) -gt 0 ]];then
                            for taxa_in in $( eval find "${v_kdmp}" 2> /dev/null );do
                                printf 'FUNC_MAKE: Adding genome to kraken DB:\n%s\n' "${taxa_in}"
                                micromamba run -n env_s4_kraken kraken2-build --threads ${venv_cpu_max} --add-to-library "${taxa_in}" --db ${vDBNAME}
                            done
                        fi
                        if [[ ! $( eval find "${v_kdmp}" 2> /dev/null | wc -l ) -gt 0 ]];then
                            #do something to build if fail in demo
                            printf 'FUNC_MAKE: Missing genomes for kraken DB'
                        fi
                        #build db
                        # incorporate --clean to reduce disk use
                        time micromamba run -n env_s4_kraken kraken2-build --threads ${venv_cpu_max} --build --db ${vDBNAME}
                        # build bracken database file
                        #vKMER=35
                        #vREAD=150
                        time micromamba run -n env_s4_kraken bracken-build \
                        -d ${vDBNAME} -t ${venv_cpu_max} -k ${vKMER} -l ${vREAD}
                        echo "FUNC_MAKE: DB content @: "${varr_db_path[$vi]}
                    else
                        printf 'FUNC_MAKE: Pre-existing Content present for DB: %s\n' "${varr_db_name[vi]}"
                    fi
                fi
                #EoDEMO
                #if [ ${varr_db_name[$vi]} = 'tool_k2_apollo' ] || [ ${varr_db_name[$vi]} = 'tool_k2_agora' ];then fi
                if [ ${varr_db_name[$vi]} = 'tool_k2_apollo' ];then
                    if (( ${v_force} )) || (( ! ${varr_db_check[$vi]} ));then
                        #/DB/REPO_tool/kraken/taxonomy/nucl_ 2.26G  9.88MB/s    in 7m 50s
                        #/DB/REPO_tool/kraken/taxonomy/nucl_ 4.82G  5.88MB/s    in 10m 45s
                        #combine apollo and agora etc into this section for efficiency
                        #add log output to include location and size,3.48G  6.92MB/s    in 10m 7s
                        #REQ of preexisting ncbi nr taxonomy
                        echo "FUNC_MAKE: Making reference DB: APOLLO taxa (kraken2)"
                        # First attempt to DL premade DB
                        eval ${varr_db_gets[$vi]}
                        eval ${varr_db_pack[$vi]}
                        # Remove tar
                        rm ${varr_db_path[$vi]}'.tar.gz'
                        if [[ $( find "${varr_db_path[$vi]}" 2> /dev/null | wc -l ) -eq 0 ]];then
                        # taxa @ species from 'combined_taxonomy_info_withAGORA2'
                        #   results in 610 keeps and 969 drops!
                        #   non spp entries! eg Bacteroidetes oral      976
                        # build taxa list with taxonkit
                        # ToDo link to updated list of taxa/tids to bypass manual
                        #    add check for redun with dl genomes and/or -A for datasets download
                        #    store premade db somewhere for direct pull
                        #    incorp to function structure
                        #imperf approach ex. Bacteroidales nov. ERR2221200   185298  Bacteroidales str. KB12
                        # CRIT 20240717 NCBI-krak broken @ https://github.com/DerrickWood/kraken2/issues/852
                        #rsync error: error in socket IO (code 10) at clientserver.c(139) [Receiver=3.3.0]
                        #standard approach - busted 20240718
                        #micromamba run -n env_s4_kraken kraken2-build --threads 24 --download-taxonomy --db ${vin_DBNAME} --use-ftp
                        vin_DBNAME='/DB/REPO_tool/kraken/kdb_apollo'
                        # taxonkit t12 @ 10    | @ 20         | @ 100        | @ 1865
                        #real    1m5.703s  real  1m9.925s  real    1m10.376s 1m8.238s
                        #user    1m18.589s user  1m21.169s user    1m21.109s 1m28.250s
                        #sys     0m6.014s  sys   0m8.056s  sys     0m8.761s  0m6.468s
                        vin_file_in='/DB/REPO_tool/kraken/t2p/taxa2proc_apollo.txt'
                        vin_file_out='/DB/REPO_tool/kraken/t2p/taxa2proc_apollo_out.txt'
                        vin_dir_k2_genm='/DB/REPO_tool/kraken/genomes/apollo'
                        vin_KMER=35
                        vin_READ=150
                        func_makedb_krak ${vin_file_in} ${vin_file_out} ${vin_DBNAME} ${vin_dir_k2_genm} ${vin_KMER} ${vin_READ}
                        #micromamba run -n env_s4_kraken kraken2-inspect --db ${vDBNAME} | less -S
                        fi
                        echo "FUNC_MAKE: DB content @: "${varr_db_path[$vi]}
                    else
                        printf 'FUNC_MAKE: Pre-existing Content present for DB: %s\n' "${varr_db_name[vi]}"
                    fi
                fi
                if [ ${varr_db_name[$vi]} = 'tool_k2_agora' ];then
                    #add log output to include location and size,3.48G  6.92MB/s    in 10m 7s
                    if (( ${v_force} )) || (( ! ${varr_db_check[$vi]} ));then
                        echo "FUNC_MAKE: Making reference DB: AGORA taxa (kraken2)"
                        # First attempt to DL premade DB
                        eval ${varr_db_gets[$vi]}
                        eval ${varr_db_pack[$vi]}
                        # Remove tar
                        rm ${varr_db_path[$vi]}'.tar.gz'
                        if [[ $( find "${varr_db_path[$vi]}" 2> /dev/null | wc -l ) -eq 0 ]];then
                        #build taxa list for agora2
                        v_file_pull='/DB/REPO_tool/kraken/t2p/taxa2proc_agora_raw.txt'
                        v_file_proc='/DB/REPO_tool/kraken/t2p/taxa2proc_agora_awk.txt'
                        v_file_out='/DB/REPO_tool/kraken/t2p/taxa2proc_agora_out.txt'
                        v_file_fail='/DB/REPO_tool/kraken/t2p/taxa2proc_agora_fail.txt'
                        # bypass if final out is present
                        if [[ -f "${v_file_out}" ]];then
                            v_file_proc="${v_file_out}"
                        else
                            ##pull list of taxa for agora2 - https://superuser.com/questions/642555/how-can-i-view-all-files-in-a-websites-directory?newreg=d78fd16672e14931adf176961b9e991f
                            lftp -e "cls -1 > ${v_file_pull}; exit" \
                            "https://www.vmh.life/files/reconstructions/AGORA2/version2.01/sbml_files/individual_reconstructions/"
                            ##parse to pull input for DB refinement
                            awk 'BEGIN {FS="\t";OFS=FS} {if(NR >= 0){print $1}}' ${v_file_pull} | \
                            awk -F '.xml' '{print gensub(/_/," ","g",$1)}' > ${v_file_proc}
                            #quoted lines: awk -F '.xml' '{print "\""gensub(/_/," ","g",$1)"\""}' > ${v_file_proc}
                            mapfile -t v_id_in < <( cat ${v_file_proc} )
                        fi
                        vin_file_in="${v_file_proc}"
                        vin_file_out='/DB/REPO_tool/kraken/t2p/taxa2proc_agora_out.txt'
                        vin_DBNAME='/DB/REPO_tool/kraken/kdb_agora'
                        vin_dir_k2_genm='/DB/REPO_tool/kraken/genomes/agora'
                        vin_KMER=35
                        vin_READ=150
                        #real    4m8.255s
                        #user    182m51.315s
                        #sys     1m44.437s
                        func_makedb_krak ${vin_file_in} ${vin_file_out} ${vin_DBNAME} ${vin_dir_k2_genm} ${vin_KMER} ${vin_READ}
                        fi
                        echo "FUNC_MAKE: DB content @: "${varr_db_path[$vi]}
                    else
                        printf 'FUNC_MAKE: Pre-existing Content present for DB: %s\n' "${varr_db_name[vi]}"
                    fi
                fi
                if [ ${varr_db_name[$vi]} = 'tool_k2_agora2apollo' ];then
                    #add log output to include location and size,3.48G  6.92MB/s    in 10m 7s
                    if (( ${v_force} )) || (( ! ${varr_db_check[$vi]} ));then
                        echo "FUNC_MAKE: Making reference DB: AGORA2+APOLLO taxa (kraken2)"
                        # First attempt to DL premade DB
                        eval ${varr_db_gets[$vi]}
                        eval ${varr_db_pack[$vi]}
                        # Remove tar
                        rm ${varr_db_path[$vi]}'.tar.gz'
                        if [[ $( find "${varr_db_path[$vi]}" 2> /dev/null | wc -l ) -eq 0 ]];then
                        #pull from mama demo - build taxa list for agora2
                        v_file_pull='/DB/REPO_tool/kraken/t2p/taxa2proc_a2a_raw.txt'
                        v_file_proc='/DB/REPO_tool/kraken/t2p/taxa2proc_a2a_awk.txt'
                        v_file_out='/DB/REPO_tool/kraken/t2p/taxa2proc_a2a_out.txt'
                        v_file_fail='/DB/REPO_tool/kraken/t2p/taxa2proc_a2a_fail.txt'
                        # bypass if final out is present
                        if [[ -f "${v_file_out}" ]];then
                            v_file_proc="${v_file_out}"
                        else
                            lftp -e "cls -1 > ${v_file_pull}; exit" \
                            "https://www.vmh.life/files/reconstructions/AGORA2/version2.01/sbml_files/individual_reconstructions/"
                            ##parse to pull input for DB refinement
                            awk 'BEGIN {FS="\t";OFS=FS} {if(NR >= 0){print $1}}' ${v_file_pull} | \
                            awk -F '.xml' '{print gensub(/_/," ","g",$1)}' > ${v_file_proc}
                            #quoted lines: awk -F '.xml' '{print "\""gensub(/_/," ","g",$1)"\""}' > ${v_file_proc}
                            mapfile -t v_id_in < <( cat ${v_file_proc} )
                        fi
                        vin_file_in="${v_file_proc}"
                        vin_file_out='/DB/REPO_tool/kraken/t2p/taxa2proc_a2a_out.txt'
                        vin_DBNAME='/DB/REPO_tool/kraken/kdb_a2a'
                        vin_dir_k2_genm='/DB/REPO_tool/kraken/genomes/a2a'
                        vin_KMER=35
                        vin_READ=150
                        #real    4m8.255s
                        #user    182m51.315s
                        #sys     1m44.437s
                        func_makedb_krak ${vin_file_in} ${vin_file_out} ${vin_DBNAME} ${vin_dir_k2_genm} ${vin_KMER} ${vin_READ}
                        fi
                        echo "FUNC_MAKE: DB content @: "${varr_db_path[$vi]}
                    else
                        printf 'FUNC_MAKE: Pre-existing Content present for DB: %s\n' "${varr_db_name[vi]}"
                    fi
                fi
                if [ ${varr_db_name[$vi]} = 'tool_mmseq_agora' ];then
                #throws error: /usr/bin/BASH_seqc_makedb.sh: line 755: [: =: unary operator expected
                    #still needs proper config, depends on preexisting primary mmseq DB and config
                    #add log output to include location and size,3.48G  6.92MB/s    in 10m 7s
                    if (( ${v_force} )) || (( ! ${varr_db_check[$vi]} ));then
                        echo "FUNC_MAKE: Making reference DB: AGORA taxa (mmseq2)"
                        v_file_pull='/DB/REPO_tool/kraken/t2p/taxa2proc_agora_raw.txt'
                        v_file_proc='/DB/REPO_tool/kraken/t2p/taxa2proc_agora_awk.txt'
                        v_file_out='/DB/REPO_tool/kraken/t2p/taxa2proc_agora_out.txt'
                        v_file_fail='/DB/REPO_tool/kraken/t2p/taxa2proc_agora_fail.txt'
                        ##pull list of taxa for agora2 - https://superuser.com/questions/642555/how-can-i-view-all-files-in-a-websites-directory?newreg=d78fd16672e14931adf176961b9e991f
                        lftp -e "cls -1 > ${v_file_pull}; exit" "https://www.vmh.life/files/reconstructions/AGORA2/version2.01/sbml_files/individual_reconstructions/"
                        ##parse to pull input for DB refinement
                        awk 'BEGIN {FS="\t";OFS=FS} {if(NR >= 0){print $1}}' ${v_file_pull} | \
                        awk -F '.xml' '{print "\""gensub(/_/," ","g",$1)"\""}' > ${v_file_proc}
                        mapfile -t v_id_in < <( cat ${v_file_proc} )
                        printf 'datasets summary taxonomy taxon %s --report ids_only --as-json-lines | dataformat tsv taxonomy --template tax-summary | cut --fields 1,2' "${v_id_in[*]}" > "${v_file_out}"
                        #datasets summary taxonomy taxon "Abiotrophia defectiva ATCC 49176" --report ids_only --as-json-lines | dataformat tsv taxonomy --template tax-summary | cut --fields 1,2
                        v_id_mmseq=$( bash "${v_file_out}" 2> "${v_file_fail}" | tail -n +2 | cut --fields 2 )
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
                        eval ${varr_db_gets[$vi]}
                        eval ${varr_db_pack[$vi]}
                        echo "FUNC_MAKE: DB content @: "${varr_db_path[$vi]}
                    else
                        printf 'FUNC_MAKE: Pre-existing Content present for DB: %s\n' "${varr_db_name[vi]}"
                    fi
                fi
            fi
        done
    else
    echo "FUNC_MAKE: LESS disk space is available than needed... not noice"
    printf 'FUNC_MAKEDB_DBUG(LINE%s): Vol FREE:%s\tVol USED:%s (if selected resources are pulled)\n' "${LINENO}" "${v_vol_free}" "${v_vol_used}"
    exit 1
    fi
else
    echo "FUNC_MAKE: This function was not cleared to make the DBs"
    exit 1
fi
echo "FUNC_MAKE: EoF"
} #EoF
#check input
OPTSTRING=":hfba:d:cs:"
while getopts ${OPTSTRING} opt; do
    case ${opt} in
        h)
            func_help
            exit 0
            ;;
        f)
            echo "Option -f was triggered and DB DL will be forced"
            v_force=1
            ;;
        b)
            echo "Option -c was triggered and DB config will be checked"
            v_debug=1
            ;;
        a)
            echo "Option -a was triggered with Argument: ${OPTARG}"
            if [ ${OPTARG} == "Y" ];then
                echo "proceeding with building all DBs"
                v_mkdb=1
            else
                v_mkdb=0
            fi
            ;;
        d)
            echo "Option -d was triggered with Argument: ${OPTARG}"
            if [ ${OPTARG} == $v_dir_db ];then
                echo "standard DB location...NICE"
            else
                echo "non-standard DB location...BOLD"
                v_dir_db=${OPTARG}
            fi
            ;;
        c)
            echo "Option -c was triggered and DB config will be checked"
            v_chkdb=1
            ;;
        s)
            echo "Option -s was triggered with Argument: ${OPTARG[@]}"
            echo "SOME DBs will be installed"
            v_mkdb=1
            #convert argument to array
            vop_some+=("$OPTARG")
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
if [[ ${#vop_some[@]} -gt 0 ]];then
    varr_db_some=${vop_some[@]}
    #unset elements in ${!varr_db_name[@]} absent from -s
    #move to outside case
    varr_keep[0]=''
    varr_drop[0]=''
    #varr_db_some=( 'tool_k2_agora' 'nya' 'tool_k2_demo' );varr_db_name=( 'host_kd_hsapcontam' 'host_kd_btau' 'host_kd_mmus' 'tool_cm2_dmnd' 'tool_ncbi_taxd' 'tool_k2_agora' 'tool_k2_apollo' 'tool_k2_std8' 'tool_k2_demo' )
    for vi in ${varr_db_some[@]};do
        echo $vi
        for vii in ${!varr_db_name[@]};do
            if [[  $vi == ${varr_db_name[vii]} ]];then
                varr_keep+=($vii)
            fi
            if [[  $vi != ${varr_db_name[vii]} ]];then
                varr_drop+=($vii)
            fi
        done
    done
    for vi in ${varr_keep[@]};do
        for vii in ${!varr_drop[@]};do
            if [[ ${vi} == ${varr_drop[vii]} ]];then
                unset varr_drop[$vii]
            fi
        done
    done
    for vi in ${varr_drop[@]};do
        unset varr_db_name[$vi]
    done
    printf 'FUNC_MAKE_opts: %s\n' "${varr_db_name[@]}"
    unset varr_drop;unset varr_keep
fi

if (( ${v_debug} ));then
    echo "v_checkDB: "$v_chkdb;echo "v_makeDB: "$v_mkdb
fi
#func <-h> <-a Y> <-d /DB> <-c> <-s ${some_array[@]}>
if ((v_mkdb == 1));then
    printf 'FUNC_MAKE_pre: %s\n' "${varr_db_name[@]}"
    # perform calculation of req space according to selected DBs here
    for vi in ${!varr_db_name[@]};do
        if [[ $vi -ge 1 ]];then
            if (( ${v_force} )) || (( ! ${varr_db_check[$vi]} ));then
                #calculate size of resource and combine
                v_vol_part=$(printf %.0f $(echo "${varr_db_size[0]} * ${varr_db_size[$vi]}" | bc -l))
                v_vol_used=$(printf %.0f $(echo "${v_vol_used} + ${v_vol_part}" | bc -l))
            fi
        fi
    done
    if (( ${v_debug} ));then
        printf 'FUNC_MAKEDB_DBUG(LINE%s): Vol FREE:%s\tVol USED:%s (if selected resources are pulled)\n' "${LINENO}" "${v_vol_free}" "${v_vol_used}" >> ${v_logfile_dbug}
    fi
    func_makedb
    if [ $v_debug -eq 1 ];then
        echo "this would make some DBSSSSSS"
        echo "they would be in: "$v_dir_db
    fi
fi
if ((v_chkdb == 1));then
    func_check
    if [ $v_debug -eq 1 ];then
        echo "this would look for some DBSSSSSS"
        echo "they would be in: "$v_dir_db
    fi
fi
#TODO set and export env vars for dbs
func_var_eval
#EoB