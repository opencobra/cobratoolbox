# Set Docker syntax version
#syntax=docker/dockerfile:1
#escape=\
#====================================================================================================#
# Title: SeqC Pipeline Docker file: create environment for sequencing data processing
# Program by: Wiley Barton - 2024.02.22
# Modified for conda/docker pipeline - 2024.02.22
# Version for Persephone
# last update - 2025.07.01
#--------------------------------------------------
# Modified code sources:
# umamba merge via: https://micromamba-docker.readthedocs.io/en/latest/advanced_usage.html#adding-micromamba-to-an-existing-docker-image
# curly bracket expansion: https://stackoverflow.com/questions/40164660/bash-brace-expansion-not-working-on-dockerfile-run-command
#--------------------------------------------------
# Build the initial system with the aim of user led CLI runs
# Expected starting dir tree
# _/SeqC_pipeline
# |__ /seqc_input
# |  |__ 'input files'
# |__ /seqc_output
# |  |__ 'final output'
# |__ /seqc_proc
# |  |__ /DEPO_demo
# |  |__ /DEPO_proc
# |  |__ /REPO_host
# |  |__ /REPO_tool
# |-Dockerfile
# |-BASH_seqc_*.sh
# |-env_*_tool.yml
# |-taxa2proc_*_out.txt
#--------------------------------------------------
# Resources
#   alt. microbeannotator [https://doi.org/10.1186/s12859-020-03940-5]
#--------------------------------------------------
# ToDo+_+
# CRIT - resolve issue of .gitkeep blocking volume creation
#--------------------------------------------------
# CLI COMMS
# kill all: docker stop $(docker ps -aq), wsl --shutdown
# clear cache: docker buildx prune
# clean all: docker system prune
# windows bloated wsl issue: Optimize-VHD -Path "$env:LOCALAPPDATA\Docker\wsl\disk\docker_data.vhdx" -Mode Full
# windows config wsl for better resource use: wsl --shutdown; %UserProfile%\.wslconfig
#https://docs.docker.com/desktop/settings-and-maintenance/settings/#resources
#https://mrakelinggar.medium.com/set-up-configs-like-memory-limits-in-docker-for-windows-and-wsl2-80689997309c
#mac os https://medium.com/takemetoprod/configure-ram-settings-before-you-run-docker-on-mac-8680286324ff
# direct command: docker run --rm -v`pwd`:`pwd` trinityrnaseq/trinityrnaseq Trinity  --seqType fq --left `pwd`/reads.left.fq.gz --right `pwd`/reads.right.fq.gz --max_memory 1G --CPU 8 --output `pwd`/trinity_out_dir
#======================================================================================================#
ARG BUILDPLATFORM='linux/amd64'
#--------------------------------------------------------------------------------------------------
# Stage 1: Use micromamba base image
#--------------------------------------------------------------------------------------------------
FROM --platform=${BUILDPLATFORM} mambaorg/micromamba:latest AS micromamba
#--------------------------------------------------------------------------------------------------
# Stage 2: Base OS Setup (Ubuntu)
#--------------------------------------------------------------------------------------------------
FROM --platform=${BUILDPLATFORM} ubuntu:latest AS base_os
WORKDIR /home
#--------------------------------------------------------------------------------------------------
# Stage 3: Set environment variables and arguments for configurability
# ARG and ENV both invoke in build, ENV made variable in container
#--------------------------------------------------------------------------------------------------
ARG v_seqcusr="seqc_user"
ARG v_proj="seqc_project"
ARG USER_UID=1000
ARG USER_GID=1000
ARG MAMBA_USER=${v_seqcusr}
ARG varg_cpu_max=8
ARG varg_proc_max=4
ARG varg_mem_max=16
ARG v_dir_work=/home/${v_seqcusr}/${v_proj}
ARG varg_dir_db="/DB"
ARG varg_dir_work=${v_dir_work}
ARG v_path0=${v_dir_work}/{final_reports,scrp_job,scrp_run,step0_data_in}/
ARG v_path1=${v_dir_work}/${varg_dir_db}/REPO_host/{hsap,hsap_contam,mmus,btau}/bowtie2/
ARG v_path2=${v_dir_work}/${varg_dir_db}/REPO_tool/{kraken/t2p,humann,checkm2,mmseqs2,ncbi_NR}/
ARG v_path3=${v_dir_work}/${varg_dir_db}/DEPO_demo/{tmp,camisim/AGORA_smol/{genomes,run_params}}/
ARG v_path4=${v_dir_work}/${varg_dir_db}/DEPO_proc/{logs,tmp}/
# Set CORE environment variables
ENV venv_seqcusr=${v_seqcusr} \
    venv_proj=${v_proj} \
    venv_cpu_max=${varg_cpu_max} \
    venv_proc_max=${varg_proc_max} \
    venv_mem_max=${varg_mem_max} \
    v_dir_work=${v_dir_work} \
    venv_dir_db=${varg_dir_db} \
    venv_dir_work=${varg_dir_work}
ENV venv_dir_in=${venv_dir_work}/step0_data_in \
    venv_dir_out=${venv_dir_work}/final_reports \
    venv_dir_proc=${venv_dir_db}/DEPO_proc
ENV venv_dir_log=${venv_dir_proc}/logs
#log parameters
ENV v_logblock0='#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-' \
    v_logblock1='#------------------------------------------------------------------' \
    v_logblock2='#---------------------------------' \
    venv_log_init="log_"${v_proj}".txt"
# Set MARS environment variables
ARG varg_mars_readsTablePath=''
ARG varg_mars_outputExtensionMARS='csv'
ARG varg_mars_relAbunFilePath=''
ARG varg_mars_sample_read_counts_cutoff=1
ARG varg_mars_cutoffMARS='0.000001'
ARG varg_mars_OTUTable=''
ARG varg_mars_flagLoneSpecies='False'
ARG varg_mars_taxaSplit=';'
ARG varg_mars_removeCladeExtensionsFromTaxa='True'
#% Allowed Input (case-insensitive): "AGORA2", "APOLLO", "full_db", "user_db".
ARG varg_mars_whichModelDatabase='full_db'
ARG varg_mars_userDatabase_path=''
ARG varg_mars_taxaTable=''
ENV venv_mars_readsTablePath=${varg_mars_readsTablePath} \
    venv_mars_outputExtensionMARS=${varg_mars_outputExtensionMARS} \
    venv_mars_relAbunFilePath=${varg_mars_relAbunFilePath} \
    venv_mars_sample_read_counts_cutoff=${varg_mars_sample_read_counts_cutoff} \
    venv_mars_cutoffMARS=${varg_mars_cutoffMARS} \
    venv_mars_OTUTable=${varg_mars_OTUTable} \
    venv_mars_flagLoneSpecies=${varg_mars_flagLoneSpecies} \
    venv_mars_taxaSplit=${varg_mars_taxaSplit} \
    venv_mars_removeCladeExtensionsFromTaxa=${varg_mars_removeCladeExtensionsFromTaxa} \
    venv_mars_whichModelDatabase=${varg_mars_whichModelDatabase} \
    venv_mars_userDatabase_path=${varg_mars_userDatabase_path} \
    venv_mars_taxaTable=${varg_mars_taxaTable}
#--------------------------------------------------------------------------------------------------
# User build
#--------------------------------------------------------------------------------------------------
RUN groupadd --gid $USER_GID $MAMBA_USER && \
    useradd --uid $USER_UID --gid $USER_GID --create-home $MAMBA_USER && \
    usermod -aG sudo $MAMBA_USER && \
    echo "$MAMBA_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
#--------------------------------------------------------------------------------------------------
# Directory build
#--------------------------------------------------------------------------------------------------
#Temp root use
WORKDIR ${venv_dir_work}
RUN cd ${venv_dir_work}
USER 0
RUN [ "/bin/bash", "-c", "eval mkdir -p ${venv_dir_db} ${v_path0} ${v_path1} ${v_path2} ${v_path3} ${v_path4} 2> /dev/null" ]
RUN [ "/bin/bash", "-c", "eval mv ${venv_dir_work}/${venv_dir_db} / 2> /dev/null" ]
RUN chown -R ${USER_UID}:${USER_GID} ${venv_dir_db}
#--------------------------------------------------------------------------------------------------
# System dependencies installation
#--------------------------------------------------------------------------------------------------
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    apt-transport-https \
    bc \
    build-essential \
    ca-certificates \
    curl \
    datamash \
    dos2unix \
    emacs \
    gawk \
    git \
    less \
    lftp \
    libz-dev \
    pigz \
    pip \
    pkg-config \
    unzip \
    wget \
    zip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
#--------------------------------------------------------------------------------------------------
# Install NCBI CLI tools
#--------------------------------------------------------------------------------------------------
RUN curl -fsSL -o /bin/datasets https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/v2/linux-amd64/datasets && \
    curl -fsSL -o /bin/dataformat https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/v2/linux-amd64/dataformat && \
    chmod +x /bin/datasets /bin/dataformat
#--------------------------------------------------------------------------------------------------
# Clone required Git repositories
#--------------------------------------------------------------------------------------------------
RUN git clone --depth=1 --branch master https://github.com/DerrickWood/kraken2.git /lib/kraken2 && \
    git clone --depth=1 --branch master https://github.com/jenniferlu717/Bracken.git /lib/bracken && \
    git clone --depth=1 --branch master https://github.com/ThieleLAB/mars-pipeline.git /lib/mars
#--------------------------------------------------------------------------------------------------
# Establish Micromamba & Conda Environments
#--------------------------------------------------------------------------------------------------
ARG MAMBA_USER_ID=${USER_UID}
ARG MAMBA_USER_GID=${USER_GID}
ENV MAMBA_ROOT_PREFIX="/opt/conda"
# Copy Micromamba binaries from stage 1
ENV MAMBA_USER=$MAMBA_USER
ENV MAMBA_ROOT_PREFIX="/opt/conda"
ENV MAMBA_EXE="/bin/micromamba"
COPY --from=micromamba "$MAMBA_EXE" "$MAMBA_EXE"
COPY --from=micromamba /usr/local/bin/_*.sh /usr/local/bin/
RUN /usr/local/bin/_dockerfile_initialize_user_accounts.sh && /usr/local/bin/_dockerfile_setup_root_prefix.sh
#----------------------------------------------------------------------------------------
# Populate with core seqc scripts
#----------------------------------------------------------------------------------------
#COPY --chown=$MAMBA_USER:$MAMBA_USER BASH_*.sh /usr/bin/
COPY --chown=${USER_UID}:${USER_GID} BASH_*.sh /usr/bin/
COPY --chown=${USER_UID}:${USER_GID} env_*.yml /tmp/
COPY --chown=${USER_UID}:${USER_GID} taxa2proc_*_out.txt /tmp/
RUN chown -R ${USER_UID}:${USER_GID} /lib
RUN chown -R ${USER_UID}:${USER_GID} /tmp
RUN chown -R ${USER_UID}:${USER_GID} /DB
# Install Conda environments
COPY env_*.yml /tmp/
# Clean lock
RUN micromamba clean --locks
RUN micromamba install --yes --name base --file /tmp/env_base.yml && \
    micromamba clean --all --yes && \
    micromamba config append channels conda-forge && \
    micromamba config append channels bioconda && \
    micromamba config remove channels defaults && \
    micromamba config set channel_priority flexible && \
    micromamba create --yes --file /tmp/env_s1_kneaddata.yml && \
    micromamba create --yes --file /tmp/env_s4_kraken.yml && \
    micromamba create --yes --file /tmp/env_util_seqkit.yml && \
    micromamba create --yes --file /tmp/env_util_taxonkit.yml && \
    micromamba create --yes --file /tmp/env_util_enasearch.yml && \
    micromamba create --yes --file /tmp/env_util_mars.yml && \
    micromamba clean --all --yes
# Move Git repositories to their respective environments
RUN mv /lib/kraken2 /opt/conda/envs/env_s4_kraken/lib/ && \
    mv /lib/bracken /opt/conda/envs/env_s4_kraken/lib/ && \
    mv /lib/mars /opt/conda/envs/env_util_mars/lib/
# Install and configure 
RUN cd /opt/conda/envs/env_s4_kraken/lib/kraken2/ && ./install_kraken2.sh . && \
    cd /opt/conda/envs/env_s4_kraken/lib/bracken/ && ./install_bracken.sh .
RUN [ "/bin/bash", "-c", "mv /opt/conda/envs/env_s4_kraken/lib/kraken2/kraken2{,-build,-inspect} /opt/conda/envs/env_s4_kraken/bin" ]
RUN [ "/bin/bash", "-c", "mv /opt/conda/envs/env_s4_kraken/lib/bracken/bracken{,-build} /opt/conda/envs/env_s4_kraken/bin" ]
RUN [ "/bin/bash", "-c", "mv /opt/conda/envs/env_s4_kraken/lib/bracken/src /opt/conda/envs/env_s4_kraken/bin" ]
RUN [ "/bin/bash", "-c", "mv /opt/conda/envs/env_s4_kraken/lib/bracken/analysis_scripts/combine_bracken_outputs.py /opt/conda/envs/env_s4_kraken/bin" ]
#--------------------------------------------------------------------------------------------------
# Fix for: Kneaddata, ENA Search, regrex extension, permissions, windows file conversion
#--------------------------------------------------------------------------------------------------
USER 0
RUN [ "/bin/bash", "-c", "rm -f /opt/conda/envs/env_s1_kneaddata/share/trimmomatic-0.39-2/trimmomatic" ]
RUN sed -i 's/data\/warehouse/portal\/api/' /opt/conda/envs/env_util_enasearch/lib/python2.7/site-packages/enasearch/__init__.py
RUN [ "/bin/bash", "-c", "shopt -s extglob" ]
# Conversion for stoopid windows compat. TODO: EXTND TO ALL VULN FILES EX SAMPLE_ID
RUN [ "/bin/bash", "-c", "chmod 777 /usr/bin/BASH_*.sh" ]
RUN [ "/bin/bash", "-c", "find /usr/bin -name BASH_seqc_*.sh -exec dos2unix {} +" ]
#----------------------------------------------------------------------------------------
# Setup splash
#----------------------------------------------------------------------------------------
RUN printf '%s\n%s' "export VEN_SPLASH=1" "BASH_seqc_mama.sh -2" >> /root/.bashrc
#--------------------------------------------------------------------------------------------------
# Set up user and shell
#--------------------------------------------------------------------------------------------------
USER ${MAMBA_USER}
SHELL [ "/usr/local/bin/_dockerfile_shell.sh" ]
ENTRYPOINT [ "/usr/local/bin/_entrypoint.sh" ]
CMD [ "/bin/bash"]
#--------------------------------------------------------------------------------------------------
# Initialise log
#--------------------------------------------------------------------------------------------------
RUN printf '%s\nStart of pipeline log -- Docker Initialized@: %s\n%s\n' "${v_logblock0}" "$(date)" "${v_logblock0}" > /tmp/${venv_log_init}
#EoB