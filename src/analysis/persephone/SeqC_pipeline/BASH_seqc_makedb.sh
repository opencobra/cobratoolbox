#!/bin/bash
#======================================================================================================#
# Title: make pipeline DBs
# Program by: Wiley Barton - 2022.02.07
# Modified for conda/docker pipeline - 2024.02.22
# Version for: PERSEPHONE
# last update - 2025.09.19
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
# --- Helper: check size --- TODO check and implement
check_db_size() {
    #varr_db_check[$vn]=$(check_db_size "${varr_db_path[$vn]}" "${varr_db_size[$vn]}")
    local path="$1" size="$2"
    local current expected
    current=$(du -BM "$path" 2>/dev/null | awk '{print $1}' | tail -1 | tr -d 'M')
    expected=$(printf %.0f "$(echo "$v_vol_gm * $size" | bc -l)")
    [[ ${current:-0} -gt $expected ]] && echo 1 || echo 0
}
# --- Declare arrays ---
declare -A db_name db_path db_gets db_pack db_size db_check
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
varr_db_check[$vn]=$(check_db_size "${varr_db_path[$vn]}" "${varr_db_size[$vn]}")
# host - ncbi-bt2 - btau - 3.7G ~ 30min w/ 6 threads
((vn++))
varr_db_name[$vn]='host_kd_btau'
varr_db_path[$vn]=${varr_db_path[0]}'/REPO_gref/host/btau'
varr_db_gets[$vn]='datasets download genome accession GCF_002263795.3 --include genome --filename '${varr_db_path[$vn]}'/btau_ARS-UCD2.0.zip && unzip -qq '${varr_db_path[$vn]}'/btau_ARS-UCD2.0.zip -d '${varr_db_path[$vn]}' && micromamba run -n env_s1_kneaddata bowtie2-build --threads '${venv_cpu_max}' '${varr_db_path[$vn]}'/ncbi_dataset/data/GCF_002263795.3/GCF_002263795.3_ARS-UCD2.0_genomic.fna '${varr_db_path[$vn]}'/bowtie2/btau_ucd2'
varr_db_size[$vn]=3.7
varr_db_check[$vn]=$(check_db_size "${varr_db_path[$vn]}" "${varr_db_size[$vn]}")
# host - bowtie2 - mmus 3.5G
((vn++))
varr_db_name[$vn]='host_kd_mmus'
varr_db_path[$vn]=${varr_db_path[0]}'/REPO_gref/host/mmus/bowtie2'
#varr_db_gets[3]='micromamba run -n env_s1 kneaddata_database --download mouse_C57BL bowtie2 '${varr_db_path[3]}'/C57BL.tar.gz'
varr_db_gets[$vn]='wget --no-check-certificate http://huttenhower.sph.harvard.edu/kneadData_databases/mouse_C57BL_6NJ_Bowtie2_v0.1.tar.gz -O '${varr_db_path[$vn]}'/C57BL.tar.gz'
varr_db_pack[$vn]=${varr_db_pack[0]}${varr_db_path[$vn]}'/C57BL.tar.gz'' --directory '${varr_db_path[$vn]}
varr_db_size[$vn]=3.5
varr_db_check[$vn]=$(check_db_size "${varr_db_path[$vn]}" "${varr_db_size[$vn]}")
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
varr_db_check[$vn]=$(check_db_size "${varr_db_path[$vn]}" "${varr_db_size[$vn]}")
#NCBI
# taxdump - 0.5G (493M)
((vn++))
varr_db_name[$vn]='tool_ncbi_taxd'
varr_db_path[$vn]=${varr_db_path[0]}'/REPO_tool/ncbi_NR'
varr_db_gets[$vn]='wget --no-check-certificate https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/taxdump.tar.gz -O '${varr_db_path[$vn]}'/taxdump.tar.gz'
varr_db_pack[$vn]='mkdir -p '${varr_db_path[$vn]}'/taxonomy && '${varr_db_pack[0]}${varr_db_path[$vn]}'/taxdump.tar.gz --directory '${varr_db_path[$vn]}'/taxonomy'
varr_db_size[$vn]=0.5
varr_db_check[$vn]=$(check_db_size "${varr_db_path[$vn]}" "${varr_db_size[$vn]}")
# kraken/bracken
## premade - pluspf smol - 8G
((vn++))
varr_db_name[$vn]='tool_k2_std8'
varr_db_path[$vn]=${varr_db_path[0]}'/REPO_tool/kraken'
varr_db_gets[$vn]='wget --no-check-certificate https://genome-idx.s3.amazonaws.com/kraken/k2_pluspf_08gb_20240605.tar.gz -O '${varr_db_path[$vn]}'/kdb_std8.tar.gz'
varr_db_pack[$vn]=${varr_db_pack[0]}${varr_db_path[$vn]}'/kdb_std8.tar.gz --directory '${varr_db_path[$vn]}'/kdb_std8'
varr_db_size[$vn]=8
varr_db_check[$vn]=$(check_db_size "${varr_db_path[$vn]}" "${varr_db_size[$vn]}")
# Custom agora/apollo - apollo @ 4.5G
# <A2A,AGORA,APOLLO><NR,FULL><SSP,SPP> - legacy mask eg.'tool_k2_apollo/kdb_apollo' = apollo_NR_SSP
#tar -I pigz --transform='s,^kdb_a2a_ssp/,kraken_db/,' -xvf _repo/wbm_modelingcode/src/SeqC_pipeline/seqc_proc/REPO_tool/kraken/kdb_a2a_ssp.tar.gz --directory _repo/BACKUP/new_KRAK/
## apollo
((vn++))
varr_db_name[$vn]='tool_k2_apollo'
varr_db_path[$vn]=${varr_db_path[0]}'/REPO_tool/kraken/kdb_apollo'
varr_db_gets[$vn]='wget --no-check-certificate https://zenodo.org/records/14884732/files/kdb_apollo.tar.gz -O '${varr_db_path[$vn]}'.tar.gz'
#varr_db_pack[$vn]='tar -I pigz -xvf '${varr_db_path[$vn]}'.tar.gz --directory '${varr_db_path[0]}'/REPO_tool/kraken/'
varr_db_pack[$vn]="tar -I pigz --transform='s,^kdb_apollo_ssp/,kdb_apollo/,' -xvf '${varr_db_path[$vn]}'.tar.gz --directory '${varr_db_path[0]}'/REPO_tool/kraken/"
varr_db_size[$vn]=4.5
varr_db_check[$vn]=$(check_db_size "${varr_db_path[$vn]}" "${varr_db_size[$vn]}")
## agora2 - 14G pre 7.5G post
((vn++))
varr_db_name[$vn]='tool_k2_agora'
varr_db_path[$vn]=${varr_db_path[0]}'/REPO_tool/kraken/kdb_agora'
varr_db_gets[$vn]='wget --no-check-certificate https://zenodo.org/records/14884741/files/kdb_agora.tar.gz -O '${varr_db_path[$vn]}'.tar.gz'
varr_db_pack[$vn]="tar -I pigz --transform='s,^kdb_agora_ssp/,kdb_agora/,' -xvf '${varr_db_path[$vn]}'.tar.gz --directory '${varr_db_path[0]}'/REPO_tool/kraken/"
varr_db_size[$vn]=14
varr_db_check[$vn]=$(check_db_size "${varr_db_path[$vn]}" "${varr_db_size[$vn]}")
## agora2 and apollo - 154G pre 69 post - 84G genomes - TODO ADJUST FOR FINAL BUILD 238 - 20250919 - 8.6G ~ 1HR
((vn++))
#previous record 14888918
varr_db_name[$vn]='tool_k2_agora2apollo'
varr_db_path[$vn]=${varr_db_path[0]}'/REPO_tool/kraken/kdb_a2a'
varr_db_gets[$vn]='wget --no-check-certificate https://zenodo.org/records/16969998/files/kdb_a2a_ssp.tar.gz -O '${varr_db_path[$vn]}'.tar.gz'
varr_db_pack[$vn]="tar -I pigz --transform='s,^kdb_a2a_ssp/,kdb_a2a/,' -xvf '${varr_db_path[$vn]}'.tar.gz --directory '${varr_db_path[0]}'/REPO_tool/kraken/"
varr_db_size[$vn]=8.6
varr_db_check[$vn]=$(check_db_size "${varr_db_path[$vn]}" "${varr_db_size[$vn]}")
##smol demo - actual size needed
((vn++))
varr_db_name[$vn]='tool_k2_demo'
varr_db_path[$vn]=${varr_db_path[0]}'/REPO_tool/kraken/kdb_demo'
varr_db_size[$vn]=8
varr_db_check[$vn]=$(check_db_size "${varr_db_path[$vn]}" "${varr_db_size[$vn]}")
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
# updated ncbi taxdmp retrieval
func_makedb_ncbi () {
    # Coordinate NCBI taxonomy dump setup
    # Use:
    #   func_makedb_ncbi                → setup everything except user taxonomy link
    #   func_makedb_ncbi '/DB/.../kdb'  → setup including user taxonomy link
    # taxdmp 67.22M @ 16s
    # GB accession2taxid 2.37G @ 4m 5s
    # WGS accession2taxid 6.36G @ 11m 7s
    local v_tdmp_n='/DB/REPO_tool/ncbi_NR/taxonomy'
    local v_tdmp_k='/DB/REPO_tool/kraken/taxonomy'
    local v_tdmp_u=""
    [[ -n "$1" ]] && v_tdmp_u="${1}/taxonomy"
    # helper: check if directory has file(s) matching pattern
    has_files() {
        local dir=$1 pattern=$2
        shopt -s nullglob
        local files=("$dir"/$pattern)
        shopt -u nullglob
        (( ${#files[@]} > 0 ))
    }
    # helper: robust decompression for accession2taxid files
    decompress_acc2tax() {
        local f
        shopt -s nullglob
        for f in "$v_tdmp_n"/*.accession2taxid*; do
            [[ ! -e "$f" ]] && continue
            case "$f" in
                *.gz)  unpigz -f "$f" ;;
                *.xz)  unxz -f "$f" ;;
                *.zip) unzip -o "$f" -d "$(dirname "$f")" && rm -f "$f" ;;
                *.accession2taxid) ;; # already decompressed
            esac
        done
        shopt -u nullglob
    }
    # Check presence of required files
    decompress_acc2tax
    local need_ncbi=0 need_acc2tax=0 need_kraken=0 need_user=0
    has_files "$v_tdmp_n" "*.dmp"               || need_ncbi=1
    has_files "$v_tdmp_n" "*.accession2taxid*"  || need_acc2tax=1
    has_files "$v_tdmp_k" "*.dmp"               || need_kraken=1
    [[ -n "$v_tdmp_u" ]] && has_files "$v_tdmp_u" "*.dmp" || need_user=1
    # Download NCBI taxdump if missing
    if (( need_ncbi )); then
        for vi in "${!varr_db_name[@]}"; do
            if [[ "${varr_db_name[$vi]}" == "tool_ncbi_taxd" ]]; then
                bash -c "${varr_db_gets[$vi]}"
                bash -c "${varr_db_pack[$vi]}"
            fi
        done
    fi
    # Download accession2taxid files if missing
    if (( need_acc2tax )); then
        mkdir -p "$v_tdmp_n"
        wget --quiet --show-progress --tries=5 --timeout=30 \
          https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/accession2taxid/nucl_gb.accession2taxid.gz \
          -O "$v_tdmp_n/nucl_gb.accession2taxid.gz"
        wget --quiet --show-progress --tries=5 --timeout=30 \
          https://ftp.ncbi.nlm.nih.gov/pub/taxonomy/accession2taxid/nucl_wgs.accession2taxid.gz \
          -O "$v_tdmp_n/nucl_wgs.accession2taxid.gz"
        decompress_acc2tax
    fi
    # Link Kraken core taxonomy to NCBI taxonomy if missing
    if (( need_kraken )); then
        rm -rf "$v_tdmp_k"
        ln -s "$v_tdmp_n" "$v_tdmp_k"
    fi
    # Link user taxonomy directory to Kraken taxonomy if requested
    if [[ -n "$v_tdmp_u" && $need_user -eq 1 ]]; then
        mkdir -p "$(dirname "$v_tdmp_u")"
        rm -rf "$v_tdmp_u"
        ln -s "$v_tdmp_k" "$v_tdmp_u"
    fi
    # Final check — ensure taxonomy is usable
    if ! has_files "$v_tdmp_n" "*.dmp"; then
        echo "ERROR: Failed to set up NCBI taxonomy in $v_tdmp_n" >&2
        return 1
    fi
    # Set global variable for NCBI taxonomy directory
    v_tdmp="$v_tdmp_n"
    export v_tdmp
} #EoF
func_makedb_krak () {
    # build list 2025.08.23
    #real    47m33.964s
    #user    173m19.684s
    #sys     2m46.981s
    #Cleaning Kraken2 database...
    #Database disk usage: 39G
    #After cleaning, database uses 16G
    # a2a_NR_ssp - UPLOAD - 16G/8.5Gz - 
    # a2a_NR_spp - 
    # apollo_NR_ssp -
    # apollo_NR_spp -
    # agora_NR_ssp - MADE - 14G
    # agora_NR_spp -
    # Generate kraken/bracken DBs
    #func_makedb_krak '/DB/REPO_tool/kraken/kdb_a2a' '/DB/REPO_tool/t2p/t2p_A2A_NR_species_log_DL.txt' '35' '150'
    # Compress for export:
    #tar -C _repo/wbm_modelingcode/src/SeqC_pipeline/seqc_proc/REPO_tool/kraken/kdb_a2a_ssp \
    #--transform 's,^,kdb_a2a_ssp/,' -cvf - . | pigz --best > \
    #_repo/wbm_modelingcode/src/SeqC_pipeline/seqc_proc/REPO_tool/kraken/kdb_a2a_ssp.tar.gz
#2min
    #tar -I pigz --transform='s,^kdb_a2a_ssp/,kraken_db/,' -xvf _repo/wbm_modelingcode/src/SeqC_pipeline/seqc_proc/REPO_tool/kraken/kdb_a2a_ssp.tar.gz --directory _repo/BACKUP/new_KRAK/
    local vDBNAME=$1       # kraken DB name
    local v_file_in=$2     # taxa2proc file
    local vKMER=$3         # kmer length
    local vREAD=$4         # read length
    local v_kdmp='/DB/REPO_tool/ncbi_NR/taxonomy/' # NCBI taxonomy dump path
    local KRAKEN="/opt/conda/envs/env_s4_kraken/bin/kraken2-build" # kraken2-build path
    local BRACKEN="/opt/conda/envs/env_s4_kraken/bin/bracken" # bracken path
    printf 'filein-1:%s\tDB-2:%s\tkmer-3:%s\tread-4:%s\n' \
        "${v_file_in}" "${vDBNAME}" "${vKMER}" "${vREAD}"
    # makedb
    mkdir -p "${vDBNAME}"
    # Ensure the NCBI taxonomy dump is present
    func_makedb_ncbi "${vDBNAME}"
    # Get column index for material_link
    vLINK=$(awk -F'\t' '{for(i=1;i<=NF;i++) if($i=="material_link"){print i; exit}}' "$v_file_in")
    # Get unique genome paths
    mapfile -t varr_path_uniq < <(cut -f "${vLINK}" "$v_file_in" | sort -u)
    echo "Unzipping and adding genomes in parallel..."
    # Export vars/functions so GNU parallel can see them
    export vDBNAME KRAKEN venv_cpu_max
    export -f micromamba
    # Parallel unzip + kraken2-build
    printf "%s\n" "${varr_path_uniq[@]}" | \
    parallel --jobs "${venv_cpu_max}" --halt soon,fail=1 '
        vpath="{}"
        # Unzip genome if compressed
        if [[ "$vpath" == *.zip ]]; then
            unzip -q -o "$vpath" -d "$(dirname "$vpath")"
            vpath_unzipped=$(find "$(dirname "$vpath")" -type f -name "*.fna*" | head -n1)
        else
            vpath_unzipped="$vpath"
        fi
        "$KRAKEN" --add-to-library "$vpath_unzipped" --db "${vDBNAME}"
        #micromamba run -n env_s4_kraken kraken2-build \
        #    --add-to-library "$vpath_unzipped" \
        #    --db "${vDBNAME}"
    '
    echo "Building Kraken2 database..."
    time "$KRAKEN" --build --db "${vDBNAME}" --threads "${venv_cpu_max}"
    #time micromamba run -n env_s4_kraken kraken2-build \
    #    --build --db "${vDBNAME}" --threads "${venv_cpu_max}"
    echo "Building Bracken database..."
    time "$BRACKEN"-build -x "/opt/conda/envs/env_s4_kraken/bin/" \
        -d "${vDBNAME}" -t "${venv_cpu_max}" -k "${vKMER}" -l "${vREAD}"
    #vKEX='/opt/conda/envs/env_s4_kraken/bin/'
    #export PATH="/opt/conda/envs/env_s4_kraken/lib/bracken/src:$PATH"
    #time micromamba run -n env_s4_kraken bracken-build \
    #    -x "${vKEX}" -d "${vDBNAME}" -t "${venv_cpu_max}" \
    #    -k "${vKMER}" -l "${vREAD}"
    echo "Cleaning Kraken2 database..."
    #TODO - block clean from deleting taxdmp and acc2taxid files in ncbi dir
    echo "Compressing accession2taxid files..."
    pigz "${v_kdmp}"*accession2taxid
    chattr +i "${v_kdmp}"/*
    "$KRAKEN" --clean --db "${vDBNAME}" --threads "${venv_cpu_max}"
    #micromamba run -n env_s4_kraken kraken2-build \
    #    --clean --db "${vDBNAME}" --threads "${venv_cpu_max}"
    chattr -i "${v_kdmp}"/*
} # EoF
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
#TODO set and export env vars for dbs - permission fix req.
#func_var_eval
#EoB