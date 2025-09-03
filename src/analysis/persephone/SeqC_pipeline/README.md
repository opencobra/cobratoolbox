How to do stuff... seqc stuff 🙀
# Commands to facilitate running the server component of the protocol (_Seqc As Flux_ pipeline)
## Project Overview
This document contains the code and instructions for running the _SeqC_ pipeline for genetic sequencing data processing. _SeqC_ is designed to streamline the analysis of sequencing data for use as input to microbial flux models.
## Pipeline Components
The _SeqC_ pipeline coordinates the following bioinformatics tools to generate input for microbial metabolic models:

- Raw sequencing data in the form of fastq files are processed with _kneaddata_ which permorms critical quality control accordingly:
  - Adapter removal and sliding window base trimming from [_Trimmomatic_](http://www.usadellab.org/cms/?page=trimmomatic)
  - Removal of tandem repeat sequences [_TRF_](https://tandem.bu.edu/trf/trf.html)
  - Removal of host-derived contaminant sequences (e.g., _H. sapiens_) with [_Bowtie2_](https://bowtie-bio.sourceforge.net/bowtie2/index.shtml)
  - Additional documentation for [_Kneaddata_](https://huttenhower.sph.harvard.edu/kneaddata/).

- High quality reads are subsequently assigned to taxonomy using a combination of _Kraken2_ and _Bracken_, which captures taxonomy through query sequence _k_-mer alignment to an indexed reference database with lowest common ancestor assignment and adjust abundance for enhanced accuracy, respectively.
  - Additional documentation for [_Kraken2_](https://ccb.jhu.edu/software/kraken2/).
  - Additional documentation for [_Bracken_](https://ccb.jhu.edu/software/bracken/).
- The resulting taxonomic profiles are fed to _MARS_ which performs the following before releasing a final profile:
  - Filtration of taxonomic units according to those represented by entries to model databases.
  - Assessment and resolution of taxonomic identifiers.
  - Additional documentation for [_MARS_](https://github.com/ThieleLab/mars-pipeline).
- Genomes according to the contents of [_AGORA2_](https://github.com/VirtualMetabolicHuman/AGORA2) and [_APOLLO_](https://www.biorxiv.org/content/10.1101/2023.10.02.560573v1) are retrieved using the NCBI [_datasets_](https://www.ncbi.nlm.nih.gov/datasets/docs/v2/) software.
- Format and reference of phylogeny is performed with the use of [_TaxonKit_](https://bioinf.shenwei.me/taxonkit/).

## Prerequisites
- User operating system
  - Ubuntu 20.04 or later
  - Windows 10 or 11 (>=21H2)
  - MacOS 15.3.2 (24D81)
- Git version 2.43 or later
- Docker version 24.0.5 or later
- Recommended resources
  - CPU:
  - RAM: >=20GB
  - Storage: >=100GB + ~3.2 x Input data
- Refer to provider documentation for additional info
  - [Docker](https://docs.docker.com/desktop/)

## Docker system structure

` _/SeqC_pipeline`\
` |__ /seqc_input`\
` |  |__ 'input files'`\
` |__ /seqc_output`\
` |  |__ 'final output'`\
` |__ /seqc_proc`\
` |  |__ /DEPO_demo`\
` |  |__ /DEPO_proc`\
` |  |__ /REPO_host`\
` |  |__ /REPO_tool`\
` |-Dockerfile`\
` |-BASH_seqc_*.sh`\
` |-env_*_tool.yml`\
` |-taxa2proc_*_out.txt`

## Installation

### Git

```bash
sudo apt install git
```
#### Setup git SSH for user
- [GitHub SSH setup](https://medium.com/@julkhair/quickly-create-or-set-up-github-ssh-in-ubuntu-23-04-example-ad47ca1dbfa)
- [GitLab SSH setup](https://docs.gitlab.com/ee/user/ssh.html)

#### Generate key
```bash
ssh-keygen -t ed25519 -C "you.email@googlemail.com"
```
#### Copy public key and add to GitLab account
```bash
less /home/you.name/.ssh/id_ed25519.pub
```
#### Connect to GitLab
```bash
ssh -T git@gitlab.com
```
#### Configure Git
```bash
git config --global user.name "Your Name"
git config --global user.email "your_email@example.com"
```
#### Clone repo
```bash
git clone git@gitlab.com:thielelab/wbm_modelingcode.git --branch wiley_SeqC_v1
```
#### Move to SeqC subdirectory
```bash
cd /path/to/git_repo/wbm_modelingcode/src/SeqC_pipeline
```
## Acquire test FASTQ files via SRA Toolkit
- [SRA Toolkit Installation](https://github.com/ncbi/sra-tools/wiki/02.-Installing-SRA-Toolkit)

### Download SRA Toolkit
```bash
wget --output-document sratoolkit.tar.gz https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/current/sratoolkit.current-ubuntu64.tar.gz
tar -vxzf sratoolkit.tar.gz
export PATH=$PATH:$PWD/sratoolkit.3.1.1-ubuntu64/bin
```
#### Download FASTQ files from PD study
```bash
fasterq-dump --split-files SRR19064983 SRR19064978 SRR19064976
```
#### Move FASTQ files to `seqc_input` subdirectory
```bash
mv /dir/with/data/*.fastq /dir/to/git_repo/
```
## Docker
#### Install Docker
```bash
sudo snap install docker
```
#### Build Docker image
Set cpu and mem variables high to run fast. Adjust according to system being used.
```bash
docker build -t dock_seqc --ulimit nofile=65536:65536 --build-arg varg_cpu_max=48 --build-arg varg_mem_max=200 .
```
#### Run Docker container
Intended to be run without alteration.
```bash
docker run --interactive --tty --user 0 --rm --memory=16g --cpus=4 --mount "type=bind,src=$(pwd)/seqc_input,target=/home/seqc_user/seqc_project/step0_data_in" --mount "type=bind,src=$(pwd)/seqc_output,target=/home/seqc_user/seqc_project/final_reports" --mount "type=volume,dst=/DB,volume-driver=local,volume-opt=type=none,volume-opt=o=bind,volume-opt=device=$(pwd)/seqc_proc" dock_seqc /bin/bash
```
Windows version
```bash
docker run --interactive --tty --user 0 --rm --memory=16g --cpus=4 --mount "type=bind,src=$($pwd)/seqc_input,target=/home/seqc_user/seqc_project/step0_data_in" --mount "type=bind,src=$($pwd)/seqc_output,target=/home/seqc_user/seqc_project/final_reports" --mount "type=bind,src=$($pwd)/seqc_proc,target=/DB" dock_seqc /bin/bash
```
## Inside _SeqC_ image
#### Create sample id file for test batch
Requires a unique sample ID corresponding to each pair of fastq files. Each ID is on a seperate line.
For example:
```bash
var_sample_uniq=(SRR19064976 SRR19064978 SRR19064983);printf '%s\n' ${var_sample_uniq[@]} > sample_id.txt
```
#### Perform a complete run
Flags: -b: debug messaging enabled; -i: directory of input files; -n: sample ID file; -r: branch of pipeline to run; -s: steps to run (0=all steps of branch) -k: keep all intermediary files
```bash
BASH_seqc_mama.sh -b -k -i 'step0_data_in/' -n 'step0_data_in/sample_id.txt' -r "SR" -s '0'
```
#### Run a taxonomic profile file thorugh _MARS_
Flags: -n: complete path to taxonomic profile file
```bash
BASH_seqc_mama.sh -r "SR" -s 3 -n '/DB/DEPO_proc/step2_kraken/krakbrak_S_bk2mpa_out_num.txt'
```
### Running directly from MATLAB
Initialise MATLAB
```bash
/usr/local/MATLAB/R2020b/bin/matlab
```
Build docker image from MATLAB
```bash
comm_build = 'docker build -t dock_seqc --ulimit nofile=65536:65536 --build-arg varg_cpu_max=4 --build-arg varg_mem_max=20 .'
[status,cmdout] = system(comm_build)
```
Docker core run command
```bash
comm_run_main = 'docker run --interactive --tty --user 0 --rm --memory=16g --cpus=4 --mount type=bind,src=$(pwd)/seqc_input/,target=/home/seqc_user/seqc_project/step0_data_in --mount type=bind,src=$(pwd)/seqc_output/,target=/home/seqc_user/seqc_project/final_reports --mount type=volume,dst=/DB,volume-driver=local,volume-opt=type=none,volume-opt=o=bind,volume-opt=device=$(pwd)/seqc_proc dock_seqc /bin/bash'
```
Apptainer accommodation (tested on Apptainer version 1.3.4)
```bash
# Convert docker to .sif - req sudo if user is not member of docker group
comm_build = 'apptainer build apter_seqc.sif docker-daemon://dock_seqc:latest'
[status,cmdout] = system(comm_build)
#test - sudo
# TMP interactive: sudo apptainer run --cwd /home/seqc_user/seqc_project --writable-tmpfs --no-mount tmp -e --cpus 4 --memory 20G --no-home --mount type=bind,src=$(pwd)/seqc_input,dst=/home/seqc_user/seqc_project/step0_data_in --mount type=bind,src=$(pwd)/seqc_output/,dst=/home/seqc_user/seqc_project/final_reports --mount type=bind,src=$(pwd)/seqc_proc,dst=/DB aptr_seqc.sif /bin/bash
comm_run_main = 'apptainer exec --cpus 4 --memory 20G --no-home --mount type=bind,src=$(pwd)/seqc_input,dst=/home/seqc_user/seqc_project/step0_data_in --mount type=bind,src=$(pwd)/seqc_output,dst=/home/seqc_user/seqc_project/final_reports --mount type=bind,src=$(pwd)/seqc_proc,dst=/DB apter_seqc.sif /bin/bash'
```
#### Test core bash script
```bash
#MATLAB variable containing bash command
comm_run_test = 'BASH_seqc_mama.sh -h'
comm_run = [ comm_run_main ' ' comm_run_test ]
#run creation command
[status,cmdout] = system(comm_run)
#Expected output
>> [status,cmdout] = system(comm_run)

status =

     0

cmdout =

    ' 
 Usage (CLI): /usr/bin/BASH_seqc_mama.sh [-h] [-i </input/dir>] [-b] [-o </output/dir>] [-s <array>]
        [-e <regex>] [-t <regrex>] [-n <string>] [-k] [-r <string>]
 Usage (Internal): /usr/bin/BASH_seqc_mama.sh [-h] [-i </input/dir>] [-b] [-o </output/dir>] [-c <step commands>]
        [-s <array>] [-e <regex>] [-t <regrex>] [-n <string>] [-u <string>] [-p <string>] [-r <string>]
 -h       : Show this help message
 -v       : Display software version
 -i INPUT : Directory containing input (/path/to/input)
 -b DEBUG : Enable debug output
 -a ALL   : Confirm with Y to install all databases to -d
 -d DB dir: Databases for step, set according to following options
         Host decontam: 'host_kd_hsapcontam' (DEFAULT) 'host_kd_btau' 'host_kd_mmus'
         Taxonomy:      'tool_k2_agora' (DEFAULT) 'tool_k2_apollo' 'tool_k2_std8'
 -o OUTPUT: Directory to contain final output (/path/to/output)
 -r BrANCH: Branch of pipeline to use, one of SR, MAG, ALL
        (default: SR)
 -c COMMS : Commands applied to step
 -s STEPS : Steps of pipeline to run with '0' complete run 
        (steps=( 1 2 3 4 5 6 7 8 9 ))
 -e HeAD  : Head of files, from first char to start of variable region
        sample_01.fastq
        ...
        sample_10.fastq
        ^^^^^^^
 -t TAIL  : File tail, ~extension, constant across all input
        sample_01.fastq
        ...
        sample_10.fastq
                 ^^^^^^
 -n NAME  : Unique names linking sample to input file(s)
        Plain text file with entries separated by new line
        e.g., sample_01_R1.fastq sample_01_R2.fastq .. sample_10_R1.fastq sample_10_R2.fastq ->
        sample_01
        ...
        sample_10
 -u uMAMBA: Explicit micromamba environment
 -p PACK  : Name of package used in step, currently redunt
 -k checK : Perform checks
 -1 Demo  : Conduct a demo run of the pipeline using synthetic data
     '
```
#### Create sample name file
```bash
#variable of sample names as string
v_names = 'SRR19064976 SRR19064978 SRR19064983'
#variable of id file remote location
v_name_file = '/home/seqc_user/seqc_project/step0_data_in/sample_id.txt'
#create file of sample IDs within the container - NB: stoopid quotes!
comm_run_mkid = [ '''var_sample_uniq=(' v_names ');printf "%s\n" ${var_sample_uniq[@]} > ' v_name_file '''' ]
#combine core and sub commands
comm_run = [ comm_run_main ' -c ' comm_run_mkid ]
#run creation command
[status,cmdout] = system(comm_run)
# input directory
v_dir_in = 'step0_data_in/'
```
#### Complete short read run command
```bash
comm_run_seqc = sprintf('BASH_seqc_mama.sh -b -k -i "%s" -n "%s" -r "SR" -s 0',v_dir_in,v_name_file)
comm_run = [ comm_run_main ' ' comm_run_seqc ]
[status,cmdout] = system(comm_run)
```
#### Just run _MARS_
```bash
v_name_file = '/DB/DEPO_proc/step2_kraken/krakbrak_S_bk2mpa_out_num.txt'
comm_run_mars = [ 'BASH_seqc_mama.sh -r ''SR'' -s 3 -n ''' v_name_file '''' ]
comm_run = [ comm_run_main ' ' comm_run_mars ]
[status,cmdout] = system(comm_run)

#Expected output
>> [status,cmdout] = system(comm_run)

status =

     0


cmdout =

    'Running pipeline - branch:SR
     Check if steps are cool
     Check if name is cool
     FUNC_general: v_k2mpa_out not found, explicit direction to input file for mars req.
     mars out dir there
     ; None None
     ;
                 0               1              2              3                   4             5                             6
     0    Bacteria    Bacteroidota    Bacteroidia  Bacteroidales      Bacteroidaceae   Bacteroides  Bacteroides cellulosilyticus
     1    Bacteria    Bacteroidota    Bacteroidia  Bacteroidales      Bacteroidaceae   Bacteroides            Bacteroides ovatus
     2    Bacteria    Bacteroidota    Bacteroidia  Bacteroidales      Bacteroidaceae   Bacteroides      Bacteroides acidifaciens
     3    Bacteria    Bacteroidota    Bacteroidia  Bacteroidales      Bacteroidaceae   Bacteroides         Bacteroides eggerthii
     4    Bacteria    Bacteroidota    Bacteroidia  Bacteroidales      Bacteroidaceae   Bacteroides         Bacteroides uniformis
     ..        ...             ...            ...            ...                 ...           ...                           ...
     391  Bacteria    Bacteroidota    Bacteroidia  Bacteroidales      Prevotellaceae     Segatella            Segatella baroniae
     392  Bacteria    Bacteroidota    Bacteroidia  Bacteroidales      Prevotellaceae    Hoylesella           Hoylesella buccalis
     393  Bacteria    Bacteroidota    Bacteroidia  Bacteroidales  Porphyromonadaceae  Gabonibacter     Gabonibacter massiliensis
     394  Bacteria  Lentisphaerota  Lentisphaeria  Victivallales      Victivallaceae   Victivallis          Victivallis vadensis
     395  Bacteria    Synergistota    Synergistia  Synergistales      Synergistaceae   Synergistes      Synergistes sp. 3_1_syn1

     [396 rows x 7 columns]
     fb ratio could not be calculated
     fb ratio could not be calculated
     FUNC_general: MARS complete :D'

```
## Outputs
After running the SeqC pipeline, the following output files will be generated (actual names are TBD):
- `log_seqc_project_<date>.txt`: A summary of the sequencing results.
- `sample_data.csv`: Processed sample data.
The files will be located in the `seqc_output/` directory.
## Known Issues
- Operating System
  - Windows (11?)
    - Terminal error: Docker: Error response from daemon: failed to populate volume: error while mounting volume ... failed to mount local volume: mount ... flags: 0x1000: no such file or directory
## Troubleshooting
### ssh timeout
```bash
#navigate to C:/Users/$USER/.ssh
#add:
Host *
  ServerAliveInterval 20
  TCPKeepAlive no
```
### System config for non-sudo use of Docker
```bash
sudo groupadd docker
sudo gpasswd -a $USER docker
sudo chmod 666 /var/run/docker.sock
```
### Pull test batch of samples from IBD dataset
```bash
# pull complete list of samples
wget https://ibdmdb.org/downloads/html/rawfiles_MGX_2017-08-12.html -O ibd_db.html
grep -e '.tar' ibd_db.html | grep -Eo "tar'>.*.tar" | sed "s/tar'>//" > ibd_db.txt
mapfile -t varr_ibd_get < <( cat ibd_db.txt )
# demo 5 samples: mapfile -t varr_ibd_get < <( printf '%s\n' "CSM5MCXD.tar" "CSM5MCY2.tar" "CSM67U9J.tar" "CSM67UAW.tar" "CSM67UB9.tar" )
# acquire 100 samples (0:99 of list) exclude: 0 2 12 14 16 34 47 52 67 68 69 78 96 97 104 109 110 111 118
# about 5hrs, 216G - 480G uncompressed
# KD:458G KB:575G
# total time:1day, 13hour, 34 minute, 16second
#for vi in 1 {3..11} 13 15 {17..33} {35..46} {48..51} {53..66} {70..77} {79..95} {98..103} {105..108} {112..117};do
for vi in {0..99};do
wget https://g-227ca.190ebd.75bc.data.globus.org/ibdmdb/raw/HMP2/MGX/2018-05-04/"${varr_ibd_get[$vi]}"
tar -xf "${varr_ibd_get[$vi]}"
rm "${varr_ibd_get[$vi]}"
done
# create sample ID file for run
cat ibd_db.txt | sed "s/.tar//" | head -n 100 > step0_data_in/sample_id.txt
### Fresh build of kraken database for agora2 + apollo, 3111 total genomes, 6,872,357 sequences
#with 200GB mem and 48 threads:
#real 201m25.512s
#user 607m32.265s
#sys 9m49.810s
#size: du -sh /DB/REPO_tool/kraken/kdb_a2a 154G (pre-clean), ~kraken/ 238G
BASH_seqc_makedb.sh -s 'tool_k2_agora2apollo'
time micromamba run -n env_s1_kneaddata kneaddata --input1 step0_data_in/SRR19064978_1.fastq --input2 step0_data_in/SRR19064978_2.fastq --output /DB/DEPO_proc/step1_kneaddata --remove-intermediate-output --reference-db /DB/REPO_host/hsap_contam/bowtie2 --threads 4 --processes 2 --max-memory 20g --trimmomatic /opt/conda/envs/env_s1_kneaddata/share/trimmomatic --reorder
#real    69m26.385s
#user    117m28.751s
#sys     3m40.777s
time micromamba run -n env_s1_kneaddata kneaddata --input1 step0_data_in/SRR19064978_1.fastq --input2 step0_data_in/SRR19064978_2.fastq --output /DB/DEPO_proc/step1_kneaddata --remove-intermediate-output --reference-db /DB/REPO_host/hsap_contam/bowtie2 --threads 4 --processes 4 --max-memory 20g --trimmomatic /opt/conda/envs/env_s1_kneaddata/share/trimmomatic --reorder
#real    25m28.979s
#user    90m25.340s
#sys     3m17.191s
#TMP - docker2singularity/apptainer
# mounting - https://apptainer.org/docs/user/main/bind_paths_and_mounts.html
# conversion - https://apptainer.org/user-docs/3.8/singularity_and_docker.html
#install - sudo add-apt-repository -y ppa:apptainer/ppa - sudo apt install -y apptainer
#save docker image - docker save dock_seqc:latest -o dock_seqc.tar
#build - XXnamespace privilages - sudo singularity build apto_seqc.sif dock_seqc.tar - alt: singularity build lolcow_tar.sif docker-archive://lolcow.tar
#build - directly from local image - req sudo if user is not member of docker group - singularity build singo_seqc.sif docker-daemon://dock_seqc:latest
#test - sudo apptainer exec --mount type=bind,src=$(pwd)/apptainer_test/seqc_input,dst=/home/seqc_user/seqc_project/step0_data_in singo_seqc.sif /bin/bash BASH_seqc_mama.sh -h
# success with apptainer version 1.3.4
```
## _nota bene_
This _README_ file was compiled with assistance and reference from a generative AI model [ChatGPT](https://chatgpt.com/) 
### End of file
