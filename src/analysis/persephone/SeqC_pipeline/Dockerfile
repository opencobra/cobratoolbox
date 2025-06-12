#syntax=docker/dockerfile:1
#escape=\
#====================================================================================================#
# Title: SeqC Pipeline Docker file: create environment for sequencing data processing
# Program by: Wiley Barton - 2024.02.22
# Modified for conda/docker pipeline - 2024.02.22
# Version for Persephone
# last update - 2025.03.11
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
# direct command: docker run --rm -v`pwd`:`pwd` trinityrnaseq/trinityrnaseq Trinity  --seqType fq --left `pwd`/reads.left.fq.gz --right `pwd`/reads.right.fq.gz --max_memory 1G --CPU 8 --output `pwd`/trinity_out_dir
#======================================================================================================#
#----------------------------------------------------------------------------------------
# START
#----------------------------------------------------------------------------------------
ARG BUILDPLATFORM='linux/amd64'
#--------------------------------------------------------------------------------------------------
# Stage 1: Use micromamba base image
# bring in the micromamba image so we can copy files from it - mambaorg/micromamba:1.5.8
#--------------------------------------------------------------------------------------------------
FROM --platform=${BUILDPLATFORM} mambaorg/micromamba:latest AS micromamba
#--------------------------------------------------------------------------------------------------
# Stage 2: Base OS Setup (Ubuntu)
# This is the image micromamba is added to:
#--------------------------------------------------------------------------------------------------
FROM --platform=${BUILDPLATFORM} ubuntu:latest AS base_os
WORKDIR /home
#establish variables
#ARG and ENV both invoke in build, ENV made variable in container
# run parameters
ENV v_proj="seqc_project"
ENV v_seqcusr="seqc_user"
#maximum cpus/threads to use, recommend 48
ARG varg_cpu_max=8
ENV venv_cpu_max=${varg_cpu_max}
#maximum proccess to use, recommend 48
ARG varg_proc_max=4
ENV venv_proc_max=${varg_proc_max}
#maximum memory to use in G, recommend 200
ARG varg_mem_max=16
ENV venv_mem_max=${varg_mem_max}
ENV v_dir_work=/home/${v_seqcusr}/${v_proj}
ENV v_dir_db=/DB
ENV venv_dir_proc=${v_dir_db}/DEPO_proc
ENV venv_dir_out=${v_dir_work}/final_reports
ENV venv_dir_in=${v_dir_work}/step0_data_in
# MARS parameters
ARG varg_mars_readsTablePath=''
ENV venv_mars_readsTablePath=${varg_mars_readsTablePath}
ARG varg_mars_outputExtensionMARS='csv'
ENV venv_mars_outputExtensionMARS=${varg_mars_outputExtensionMARS}
ARG varg_mars_relAbunFilePath=''
ENV venv_mars_relAbunFilePath=${varg_mars_relAbunFilePath}
ARG varg_mars_sample_read_counts_cutoff=1
ENV venv_mars_sample_read_counts_cutoff=${varg_mars_sample_read_counts_cutoff}
#handle conversion of sci to float 1e-6(default) to 0.000001
ARG varg_mars_cutoffMARS='0.000001'
ENV venv_mars_cutoffMARS=${varg_mars_cutoffMARS}
ARG varg_mars_OTUTable=''
ENV venv_mars_OTUTable=${varg_mars_OTUTable}
#% A boolean to indicate if the genus name is in the name of the species e.g.
#% Prevotella copri. If genus name is in species name set to false. 
#% Otherwise set to true. OPTIONAL, defaults to false.
ARG varg_mars_flagLoneSpecies='False'
ENV venv_mars_flagLoneSpecies=${varg_mars_flagLoneSpecies}
ARG varg_mars_taxaSplit=';'
ENV venv_mars_taxaSplit=${varg_mars_taxaSplit}
ARG varg_mars_removeCladeExtensionsFromTaxa='True'
ENV venv_mars_removeCladeExtensionsFromTaxa=${varg_mars_removeCladeExtensionsFromTaxa}
#% Allowed Input (case-insensitive): "AGORA2", "APOLLO", "full_db", "user_db".
ARG varg_mars_whichModelDatabase='full_db'
ENV venv_mars_whichModelDatabase=${varg_mars_whichModelDatabase}
ARG varg_mars_userDatabase_path=''
ENV venv_mars_userDatabase_path=${varg_mars_userDatabase_path}
ARG varg_mars_taxaTable=''
ENV venv_mars_taxaTable=${varg_mars_taxaTable}
#USER ${v_seqcusr}
#log parameters
ENV v_logblock0='#=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-'
ENV v_logblock1='#------------------------------------------------------------------'
ENV v_logblock2='#---------------------------------'
ENV v_logfile="log_"${v_proj}".txt"
ENV v_logdir=${v_dir_work}/logs
#initialise log
RUN printf '%s\nStart of pipeline log -- Docker Initialized@: %s\n%s\n' "${v_logblock0}" "$(date)" "${v_logblock0}" > $v_logfile
#build workflow dirs - op moved to mama due to .gitkeep block on initial build
RUN [ "/bin/bash", "-c", "mkdir -p ${v_dir_work}/{final_reports,logs,scrp_job,scrp_run,step0_data_in}/" ]
WORKDIR ${v_dir_work}
RUN cd ${v_dir_work}
#move logfile
RUN [ "/bin/bash", "-c", "mv /home/${v_logfile} ${v_logdir}" ]
#----------------------------------------------------------------------------------------
# Install ubuntu packages - stable layer
#----------------------------------------------------------------------------------------
RUN apt-get update && DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y --no-install-recommends \
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
    libz-dev \
    lftp \
    pip \
    pigz \
    pkg-config \
    unzip \
    wget \
    zip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN apt-get update
#Install NCBI CLI
RUN curl -o /bin/datasets 'https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/v2/linux-amd64/datasets'
RUN curl -o /bin/dataformat 'https://ftp.ncbi.nlm.nih.gov/pub/datasets/command-line/v2/linux-amd64/dataformat'
RUN chmod +x /bin/datasets /bin/dataformat
#----------------------------------------------------------------------------------------
# Pull git repos
#----------------------------------------------------------------------------------------
RUN [ "/bin/bash", "-c", "git clone -b master https://github.com/DerrickWood/kraken2 /lib/kraken2" ]
RUN [ "/bin/bash", "-c", "git clone -b master https://github.com/jenniferlu717/Bracken /lib/bracken" ]
RUN [ "/bin/bash", "-c", "git clone -b master https://github.com/ThieleLAB/mars-pipeline /lib/mars" ]
# For all users and all repositories
RUN git config --system --add safe.directory '*'
#----------------------------------------------------------------------------------------
# Establish mamba
# if your image defaults to a non-root user, then you may want to make the
# next 3 ARG commands match the values in your image. You can get the values
# by running: docker run --rm -it my/image id -a
#----------------------------------------------------------------------------------------
ARG MAMBA_USER=${v_seqcusr}
ARG MAMBA_USER_ID=57439
ARG MAMBA_USER_GID=57439
#ARG MAMBA_USER_ID=0
#ARG MAMBA_USER_GID=0
ENV MAMBA_USER=$MAMBA_USER
ENV MAMBA_ROOT_PREFIX="/opt/conda"
ENV MAMBA_EXE="/bin/micromamba"
COPY --from=micromamba "$MAMBA_EXE" "$MAMBA_EXE"
COPY --from=micromamba /usr/local/bin/_activate_current_env.sh /usr/local/bin/_activate_current_env.sh
COPY --from=micromamba /usr/local/bin/_dockerfile_shell.sh /usr/local/bin/_dockerfile_shell.sh
COPY --from=micromamba /usr/local/bin/_entrypoint.sh /usr/local/bin/_entrypoint.sh
COPY --from=micromamba /usr/local/bin/_dockerfile_initialize_user_accounts.sh /usr/local/bin/_dockerfile_initialize_user_accounts.sh
COPY --from=micromamba /usr/local/bin/_dockerfile_setup_root_prefix.sh /usr/local/bin/_dockerfile_setup_root_prefix.sh
RUN /usr/local/bin/_dockerfile_initialize_user_accounts.sh && /usr/local/bin/_dockerfile_setup_root_prefix.sh
#Modify ownership - TMP
RUN chown -R $MAMBA_USER:$MAMBA_USER /lib
#extend regex
RUN [ "/bin/bash", "-c", "shopt -s extglob"]
USER $MAMBA_USER
SHELL ["/usr/local/bin/_dockerfile_shell.sh"]
ENTRYPOINT ["/usr/local/bin/_entrypoint.sh"]
# Optional: if you want to customize the ENTRYPOINT and have a conda environment activated, then do this:
#ENTRYPOINT ["/usr/local/bin/_entrypoint.sh", "my_entrypoint_program"]
# Modify the CMD statement:
#CMD ["/bin/bash"]
#----------------------------------------------------------------------------------------
# Populate with core seqc scripts
#----------------------------------------------------------------------------------------
COPY --chown=$MAMBA_USER:$MAMBA_USER BASH_*.sh /usr/bin/
COPY --chown=$MAMBA_USER:$MAMBA_USER env_*.yml /tmp/
COPY --chown=$MAMBA_USER:$MAMBA_USER taxa2proc_*_out.txt /tmp/
#/DB/REPO_tool/kraken/
#----------------------------------------------------------------------------------------
# Populate base conda env
#----------------------------------------------------------------------------------------
#export environment info: micromamba env export --no-build --name base > test.yml
RUN micromamba install --yes --name base --file /tmp/env_base.yml && micromamba clean --all --yes && \
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
# Move git executables to respective env
USER root
RUN [ "/bin/bash", "-c", "mv /lib/kraken2 /opt/conda/envs/env_s4_kraken/lib/" ]
RUN [ "/bin/bash", "-c", "mv /lib/bracken /opt/conda/envs/env_s4_kraken/lib/" ]
RUN cd /opt/conda/envs/env_s4_kraken/lib/kraken2/ && ./install_kraken2.sh .
RUN cd /opt/conda/envs/env_s4_kraken/lib/bracken/ && ./install_bracken.sh .
RUN [ "/bin/bash", "-c", "mv /opt/conda/envs/env_s4_kraken/lib/kraken2/kraken2{,-build,-inspect} /opt/conda/envs/env_s4_kraken/bin" ]
RUN [ "/bin/bash", "-c", "mv /opt/conda/envs/env_s4_kraken/lib/bracken/bracken{,-build} /opt/conda/envs/env_s4_kraken/bin" ]
RUN [ "/bin/bash", "-c", "mv /opt/conda/envs/env_s4_kraken/lib/bracken/src /opt/conda/envs/env_s4_kraken/bin" ]
RUN [ "/bin/bash", "-c", "mv /opt/conda/envs/env_s4_kraken/lib/bracken/analysis_scripts/combine_bracken_outputs.py /opt/conda/envs/env_s4_kraken/bin" ]
RUN [ "/bin/bash", "-c", "mv /lib/mars /opt/conda/envs/env_util_mars/lib/" ]
# Fix for dysfunc build of kneaddata
RUN [ "/bin/bash", "-c", "rm /opt/conda/envs/env_s1_kneaddata/share/trimmomatic-0.39-2/trimmomatic" ]
# Fix for OoD script of enasearch
RUN sed -i 's/data\/warehouse/portal\/api/' /opt/conda/envs/env_util_enasearch/lib/python2.7/site-packages/enasearch/__init__.py
#RUN [ "/bin/bash", "-c", "sed -i s/data\/warehouse/portal\/api/ /opt/conda/envs/env_util_enasearch/lib/python2.7/site-packages/enasearch/__init__.py" ]
# Initialise mamba env
ARG MAMBA_DOCKERFILE_ACTIVATE=1
USER root
# Kraken build fix for linux 
RUN micromamba install --yes --name env_s4_kraken kraken2 -c bioconda -c conda-forge
#----------------------------------------------------------------------------------------
# Post setup root required reconfig
#----------------------------------------------------------------------------------------
RUN [ "/bin/bash", "-c", "chmod 777 /usr/bin/BASH_*.sh" ]
# Conversion for stoopid windows compat.
RUN [ "/bin/bash", "-c", "find /usr/bin -name BASH_seqc_*.sh -exec dos2unix {} +" ]
RUN echo "export VEN_SPLASH=1" >>  /root/.bashrc
RUN echo "BASH_seqc_mama.sh -2" >> /root/.bashrc
#EoB