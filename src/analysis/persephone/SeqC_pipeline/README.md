# SeqC Pipeline (Persephone)
## Metagenomic Processing for Microbial Flux Modeling

![Pipeline Version](https://img.shields.io/badge/version-1.0.2-blue)
![Platform](https://img.shields.io/badge/platform-Docker%20%7C%20Apptainer-orange)
![Category](https://img.shields.io/badge/category-Bioinformatics-green)

The **SeqC Pipeline** (part of the **Persephone** framework) is a comprehensive bioinformatics suite designed to transform raw metagenomic sequencing data into high-fidelity taxonomic profiles. These profiles are optimized specifically for integration into microbial metabolic models, providing the critical bridge between sequencing data and flux balance analysis. This readme will illustrate... How to do stuff... seqc stuff 🙀

Updated: 2026.04.23

---

## 🧬 Pipeline Architecture

The pipeline follows a modular multi-stage workflow:

1.  **Quality Control & Decontamination** Raw sequencing data in the form of fastq files are processed with _kneaddata_ which permorms critical quality control accordingly:
    - [**Trimmomatic**](http://www.usadellab.org/cms/?page=trimmomatic): Adapter removal and quality-based read trimming (sliding window).
    - [**TRF**](https://tandem.bu.edu/trf/trf.html): Removal of tandem repeats.
    - [**Bowtie2**](https://bowtie-bio.sourceforge.net/bowtie2/index.shtml): Decontamination of host-derived sequences (e.g., Human/Bovine/Murine).
    - Additional documentation for [**Kneaddata**](https://huttenhower.sph.harvard.edu/kneaddata/).
2.  **Taxonomic Profiling** High quality reads are subsequently assigned to taxonomy using a combination of _Kraken2_ and _Bracken_, which captures taxonomy through query sequence _k_-mer alignment to an indexed reference database with lowest common ancestor assignment and adjust abundance for enhanced accuracy, respectively.
    - [**Kraken2**](https://ccb.jhu.edu/software/kraken2/): High-speed k-mer based taxonomic assignment.
    - [**Bracken**](https://ccb.jhu.edu/software/bracken/): Bayesian re-estimation of abundances for species-level resolution.
3.  **Model Integration (MARS)**:
    - Filtration of taxonomic units based on presence in microbial metabolic model databases (AGORA2, APOLLO).
    - Resolution of phylogenetic nomenclature and model mapping.
    - Additional documentation for [**MARS**](https://github.com/ThieleLab/mars-pipeline).
4.  **Reference Management**:
    - Automatic retrieval of genomes via NCBI Datasets.
    - Phylogeny formatting with TaxonKit.
    Genomes according to the contents of [_AGORA2_](https://github.com/VirtualMetabolicHuman/AGORA2) and [_APOLLO_](https://www.biorxiv.org/content/10.1101/2023.10.02.560573v1) are retrieved using the NCBI [_datasets_](https://www.ncbi.nlm.nih.gov/datasets/docs/v2/) software.
    - Format and reference of phylogeny is performed with the use of [_TaxonKit_](https://bioinf.shenwei.me/taxonkit/).

---

## 💻 System Prerequisites

### Operating Systems
- **Linux**: Ubuntu 20.04+ (Native support)
- **Windows**: Windows 10/11 with WSL2
- **MacOS**: MacOS 14.0+ (Sequoia)

### Resource Requirements
> [!IMPORTANT]
> Metagenomic processing is resource-intensive. Below are the minimum guidelines:

| Resource | Minimum | Recommended |
| :--- | :--- | :--- |
| **CPU** | 4 Cores | 16+ Cores |
| **RAM** | 20 GB | 64+ GB |
| **Storage** | 100 GB | 500 GB+ (NVMe highly recommended) |

**Storage Calculation Tip:**
Total required space $\approx$ 100GB (Databases) + (3.2 $\times$ Raw Input Size).

---

## 📂 Directory Structure

```text
 ./SeqC_pipeline/            # Main pipeline directory
  ├── seqc_input/            # [USER] Place raw FASTQ files here
  |  └── 'input files'
  ├── seqc_output/           # [AUTO] Final analysis results
  |  └── 'final output'
  ├── seqc_proc/             # [TEMP] Working directory for DBs and cache
  |  ├── DEPO_demo
  |  ├── DEPO_proc
  |  ├── REPO_gref
  |  └── REPO_tool
  ├── Dockerfile             # Docker build definition
  ├── Apptainer.def          # Apptainer build definition
  ├── BASH_seqc_*.sh         # Main pipeline controller
  ├── env_*_tool.yml         # Environment configuration
  └── taxa2proc_*_out.txt    # Taxonomy processing output
```

---

## 🚀 Getting Started

### 1. Installation
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
Clone the repository and navigate to the pipeline directory:
see for additional info [COBRA toolbox](https://opencobra.github.io/cobratoolbox/stable/installation.html)
```bash
git clone --depth=1 https://github.com/opencobra/cobratoolbox.git cobratoolbox
cd cobratoolbox/src/analysis/persephone/SeqC_pipeline
```

### 2. Execution Options

#### Option A: MATLAB Wrapper (Recommended)
The most integrated way to run the pipeline within the Persephone ecosystem is via the MATLAB wrapper. It automatically handles container building, volume mapping, and storage estimation.

```matlab
% In MATLAB command window:
status = runSeqC(...
    'repoPathSeqC', pwd, ...
    'outputPathSeqC', './results', ...
    'fileIDSeqC', 'sample_list.txt', ...
    'runApptainer', true ... % Set to true for HPC
);
```
Direct MATLAB execution
Initialise MATLAB
```bash
/usr/local/MATLAB/R2020b/bin/matlab
```
Build docker image from MATLAB
```matlab
comm_build = 'docker build -t dock_seqc --ulimit nofile=65536:65536 --build-arg varg_cpu_max=4 --build-arg varg_mem_max=20 .'
[status,cmdout] = system(comm_build)
```
Docker core run command
```matlab
comm_run_main = 'docker run --interactive --tty --user 0 --rm --memory=16g --cpus=4 --mount type=bind,src=$(pwd)/seqc_input/,target=/home/seqc_user/seqc_project/step0_data_in --mount type=bind,src=$(pwd)/seqc_output/,target=/home/seqc_user/seqc_project/final_reports --mount type=volume,dst=/DB,volume-driver=local,volume-opt=type=none,volume-opt=o=bind,volume-opt=device=$(pwd)/seqc_proc dock_seqc /bin/bash'
```
#### Test core bash script
```matlab
%MATLAB variable containing bash command
comm_run_test = 'BASH_seqc_mama.sh -h'
comm_run = [ comm_run_main ' ' comm_run_test ]
%run creation command
[status,cmdout] = system(comm_run)
%Expected output
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
```matlab
%variable of sample names as string
v_names = 'SRR19064976 SRR19064978 SRR19064983'
%variable of id file remote location
v_name_file = '/home/seqc_user/seqc_project/step0_data_in/sample_id.txt'
%create file of sample IDs within the container - NB: stoopid quotes!
comm_run_mkid = [ '''var_sample_uniq=(' v_names ');printf "%s\n" ${var_sample_uniq[@]} > ' v_name_file '''' ]
%combine core and sub commands
comm_run = [ comm_run_main ' -c ' comm_run_mkid ]
%run creation command
[status,cmdout] = system(comm_run)
% input directory
v_dir_in = 'step0_data_in/'
```
#### Complete short read run command
```matlab
comm_run_seqc = sprintf('BASH_seqc_mama.sh -b -k -i "%s" -n "%s" -r "SR" -s 0',v_dir_in,v_name_file)
comm_run = [ comm_run_main ' ' comm_run_seqc ]
[status,cmdout] = system(comm_run)
```
#### Just run _MARS_
```matlab
v_name_file = '/DB/DEPO_proc/step2_kraken/krakbrak_S_bk2mpa_out_num.txt'
comm_run_mars = [ 'BASH_seqc_mama.sh -r ''SR'' -s 3 -n ''' v_name_file '''' ]
comm_run = [ comm_run_main ' ' comm_run_mars ]
[status,cmdout] = system(comm_run)

%Expected output
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

#### Option B: Docker (Local/Server)
Build the image with specific resource limits:
```bash
docker build -t dock_seqc \
    --ulimit nofile=65536:65536 \
    --build-arg varg_cpu_max=8 \
    --build-arg varg_mem_max=20 \
    --build-arg varg_proc_max=2 \
    --build-arg USER_UID=$(id -u) \
    --build-arg USER_GID=$(id -g) .
```
Alternatively, set USER_UID/GID to arbitrary values:
```bash
docker build -t dock_seqc \
    --ulimit nofile=65536:65536 \
    --build-arg varg_cpu_max=8 \
    --build-arg varg_mem_max=20 \
    --build-arg varg_proc_max=2 \
    --build-arg USER_UID=42069 \
    --build-arg USER_GID=42069 .
```
Run the container with the following command:
Intended to be run without alteration.
Linux Version
```bash
docker run --interactive --tty --user $(id -u):$(id -g) --rm --memory=16g --cpus=4 --mount "type=bind,src=$(pwd)/seqc_input,target=/home/seqc_user/seqc_project/step0_data_in" --mount "type=bind,src=$(pwd)/seqc_output,target=/home/seqc_user/seqc_project/final_reports" --mount "type=volume,dst=/DB,volume-driver=local,volume-opt=type=none,volume-opt=o=bind,volume-opt=device=$(pwd)/seqc_proc" dock_seqc /bin/bash
```
MacOS version
```bash
docker run --interactive --tty --user 0 --rm --memory=16g --cpus=4 --mount "type=bind,src=$(pwd)/seqc_input,target=/home/seqc_user/seqc_project/step0_data_in" --mount "type=bind,src=$(pwd)/seqc_output,target=/home/seqc_user/seqc_project/final_reports" --mount "type=volume,dst=/DB,volume-driver=local,volume-opt=type=none,volume-opt=o=bind,volume-opt=device=$(pwd)/seqc_proc" dock_seqc /bin/bash
```
Windows version
```bash
docker run --interactive --tty --user $(id -u):$(id -g) --rm --memory=16g --cpus=4 --mount "type=bind,src=$($pwd)/seqc_input,target=/home/seqc_user/seqc_project/step0_data_in" --mount "type=bind,src=$($pwd)/seqc_output,target=/home/seqc_user/seqc_project/final_reports" --mount "type=bind,src=$($pwd)/seqc_proc,target=/DB" dock_seqc /bin/bash
```
#### Option C: Apptainer (HPC / Cluster)
For HPC systems using SLURM, generate the batch script using `runSeqC.m`. This will dynamically request high-speed NVMe storage based on your input size.

```bash
# Manual Build
apptainer build --fakeroot --bind="$TMPDIR:/tmp" --build-arg varg_cpu_max=4 --build-arg varg_mem_max=10 --build-arg varg_proc_max=4 apter_seqc.sif Apptainer.def
```
```bash
# Run
apptainer exec --cwd /home/seqc_user/seqc_project --writable-tmpfs --no-mount tmp --no-home -e --mount type=bind,src=$(pwd)/seqc_input,dst=/home/seqc_user/seqc_project/step0_data_in --mount type=bind,src=$(pwd)/seqc_output,dst=/home/seqc_user/seqc_project/final_reports --mount type=bind,src=$(pwd)/seqc_proc,dst=/DB apter_seqc.sif /bin/bash BASH_seqc_mama.sh -b -k -i "step0_data_in/" -n "sample_id.txt" -r "SR" -s 0 -d "host_kd_hsapcontam" -d "tool_k2_std8"
```
---

## 🛠 Manual Operation (Inside Container)

If you need to run specific pipeline stages manually:

### 1. Initialize Databases
Select your desired taxonomy database (AGORA2, APOLLO, or Standard-8):
```bash
BASH_seqc_makedb.sh -s "host_kd_hsapcontam" -s "tool_k2_agora"
```

### 2. Run Pipeline Commands
```bash
# Execute full pipeline (Short-Read branch)
# Flags: 
# -b: debug messaging enabled
# -i: directory of input files
# -n: sample ID file
# -r: branch of pipeline to run
# -s: steps to run (0=all steps of branch)
# -k: keep all intermediary files
BASH_seqc_mama.sh -b -k -i "/data/in" -n "samples.txt" -r "SR" -s 0
```
### 3. Full list of flags with help function
```bash
BASH_seqc_mama.sh -h
```
---
## Outputs
After running the SeqC pipeline, the following output files will be generated (actual names are TBD):
- `log_seqc_project_<date>.txt`: A summary of the sequencing results.
- `sample_data.csv`: Processed sample data.
The files will be located in the `seqc_output/` directory.

## ❓ Troubleshooting

### Connection Issues (SSH)
If your SSH connections to the cluster time out, update your `~/.ssh/config`:
```text
Host *
  ServerAliveInterval 20
  TCPKeepAlive no
```
### Docker Permissions
To run docker without `sudo`:
```bash
sudo usermod -aG docker $USER
newgrp docker
```
### System config for non-sudo use of Docker
```bash
sudo groupadd docker
sudo gpasswd -a $USER docker
sudo chmod 666 /var/run/docker.sock
```
---

## 📑 Notes
> [!NOTE]
> _nota bene_
> This pipeline was developed for the **Thiele Lab** and is maintained as part of the **Persephone Pipeline** for metabolic modeling.

> This _README_ file was compiled with assistance and reference from a generative AI model [ChatGPT](https://chatgpt.com/) 
### End of file
