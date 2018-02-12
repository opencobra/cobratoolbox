<!-- MDTOC maxdepth:9 firsth1:1 numbering:0 flatten:0 bullets:1 updateOnSave:1 -->

- [Introduction](#introduction) 
- [Requirements](#requirements)  
- [Folder Structure and Files](#folder-structure-and-files)   
- [Usage](#usage)   
	- [Inputs](#inputs)
	- [Outputs](#outputs)
	- [Special uses](#Special-uses)
- [Status of implementation](#status-of-implementation)   
- [Examples](#examples)  
- [Spin offs](#Spin offs)
- [Benchmark](#benchmark)  
- [Toutorial](#toutorial)   

<!-- /MDTOC -->


Introduction
============
MgPipe is a MATLAB based pipeline to integrate microbial abundances (coming from metagenomic data) with constraint based modeling, creating individuals' personalized models. Almost all the pipeline is parallelized and the outputs saved in open format.   
The pipeline is divided in 3 parts:
[PART 1] Analysis on individuals' specific microbes abundances are computed. Individuals’ metabolic diversity in relation to microbiota size and disease presence as well as Classical multidimensional scaling (PCoA) on individuals' reaction repertoire are examples.
[PART 2]: 1 Constructing a global metabolic model (setup) containig all the microbes listed in the study. 2 Building individuals' specific models integrating abundance data retrieved from metagenomics. For each organism, reactions are coupled to objective function. 
[PART 3] Simulations under different diet regimes. Set of standard analysis to apply to the personalized models. PCA of computed MNPCs of patients as for example.

**WARNING :**Please take into consideration only the files listed in this document. Everything present in the folder but not listed and explained in this document is to be considered not relevant or obsolete.

Requirements
============

MgPipe requires Matrix Laboratory as well as the Cobra Toolbox to be installed with ILOG CPLEX as solver.
All toolboxes/solvers/files should be in the MATLAB path.  

Folder Structure and Files
==========================

The following files are supplied

| Filename                                       | Purpose                                                                |
| -----------------------------------------------|------------------------------------------------------------------------|
| Input.m                                        | *Input files to be modified by the user containing all the variables * |
| normCoverage.R                                 | *Script to format abundances (inserting abundance thresholds) to be processed into matlab*|
| After_Eugen.R                                  | *Code to create abundance tables without NA and in binary form*       |
| minimalRxnFlux.m                               | *function to enforce a minimal flux through a set of specific functions*|
| coupleRxnList2Rxn.m                            | *function to couple constraints: edited by fede*                       |
| FatSetupCreator.m                              | *function to create setup: parallelized and fast*                      |
| addMicrobeCommunityBiomass.m                   | *function to add community biomass: edited by fede*                     |
| createHostMicrobeModelDietFecalCompartments.m  | *function to create setup: edited by fede*                             |
| ImportSetDiet.m                                | *function to load and impose to a model a specific diet*               |
| Pipeline.m                                     | *Pipeline*                                                             |
| README.md                                      | *this file*                                                            |
| todo.txt                                       | *indications on the status of the implementation*                     |
| **Old Pipeline**                               | *Folder for storing old pipeline code*                                 |
| prepareCoverageFiles.R                         | *Script to format abundances to be processed into matlab*             |
| Genomic_analysis.m                             | *pipeline for analysis on genomic data(1/3)*                           |
| Create_specific_setups_temporary.m             | *pipeline for analysis on genomic data(2/3)*                           |
| evaluateSystemFluxes.m                         | *STILL TO TEST!!!*                                                     |
| **results**                                    | *Results folder*                                                       |
| ***compfile***                                 | *Results subfolder: contains object saved in open format*              |
| **fast setup**                                 | *Folder containing modified scripts to built fast setup*               |
| mergeTwoModels_AH_f.m                          | *function to merge models: fast version without genes info*            |
|createHostMicrobeModelDietFecalCompartments_f1.m| *function to create setup: fast version without genes info*            |



Usage
=====

Once installed the necessary dependences the pipeline is ready to be used at the condition that some input variables are inserted or changed from the default input file. Outputs are, as well, really interesting.  

## Inputs

Some specific information files needs to be loaded by the pipeline. For this reason they must be formatted and called in a specific way. See the [Examples] section for more information. The files needed are

| File                   | Description                                                                                  |
| -----------------------|----------------------------------------------------------------------------------------------|
| coverage2bas_all.csv   | table with mapping info (formatted by R script)                                              |
| Patients_status.csv    |  table of same length of number of patients (0 means patient with disease 1 means helthy)    |
|  **Aboundances**       |  folder containing abundance files                                                          |
| normCoverage.csv       |  table with abundances for each species (normalized to 1 with minimal threshold to define presence)|

Some variables, in the input file, needs to be created/modified to specify as for example paths of directories containing organisms’ models. The variables which needs to be created or changed from default are

| Variables    | Description                          |
| -------------|--------------------------------------|
| modpath      | path to microbiota models            |
| hostpath     | path to the host model               |
| csvpath      | path to csv files (where input files are stored)|
| abundancepath| path to the abundances files (where abundance files are stored)|
| resepath     |path to the directory to contain results|
| dietpath     |path from where to read the diet      |
| hostnam      | name that the host cell will have    |
| patnumb      | number of patients in the study      |
| objre        | name of objective function of microbes|
| dietnam      | name of the diet (csv file name without extension)|
| dietcomp     | name of the diet compartment        |
| patnumb      | number of patients in the study      |
| nwok         | number of cores dedicated for parallelization|
| fwok         | number of cores dedicated for parallelization of fastFVA|
| comobj       | community objective function          |
| reid         | identifier for set of reactions of which to run FVA (default fecal Exchanges)|
| modbuild     | if part 2.1 (pan model construction)needs to be executed|
| newFVA       | weather to use the new fastFVA (=1) or the old one (=0)|
| compmod      | if outputs in open format should be produced for each section (1=T)|
| patstat      | if documentations on patient status is provided (0 not 1 yes)|
| figform      | the output is vectorized picture ('-depsc'), change to '-dpng' for .png|



## Outputs

Patients' plots of metabolic diversity in relation to microbiota size and disease presence as well as Classical multidimensional scaling (PCoA) on patients reaction repertoire are outputs of the first part; they are directly saved into the current MATLAB folder as png files. Moreover a series of objects created by the first part cab be of interest of the user: they can be the object of further data analysis. For this reason the MATLAB workspace is saved into a file called “MapInfo.mat”. The saved variables are:

| Object                 | Description                                                                                  |
| -----------------------|----------------------------------------------------------------------------------------------|
| reac                   | cell array with all the unique set of reactions contained in the models                      |
| MicRea                 | binary matrix assessing presence of set of unique reactions for each of the microbes          |
| cleantab               |  binary matrix asessing presence of specific strains in different patients                   |
|  ReacPat               |  matrix with number of reactions per patients (species resolved)                             |
| Reacset                | matrix with names of reactions that each patient has                                         |
| reacTab                | matrix with presence/absence of reaction per patient: to compare different patients          |


[PART 2] creates, first, a global metabolic model of host and microbiota, secondly patients' specific models (personalized) are created with their specific objective function and coupling constrains. 
[PART 3] runs simulations (FVAs) and detect differences between personalized models.
The outputs are: 

| File                       | Description                                                                                  |
| ---------------------------|----------------------------------------------------------------------------------------------|
| Setup_allbacs.mat          | setup object containing all the models joined                                                |
| All_patients.mat           | cell array containing all the personalized modes                                             |
| FVAres.mat                 | object containing all the FVAs results                                                       |

If the specific option is enabled in the input file, most of the outputs are saved also in open format (xml, csv, rtf) in the dedicated folder. 

## Special uses

Data should be formatted as specified (see also “Examples” section).  The input files should have the names listed in the input section. To do this, running the R scripts is essential.
The first part of [part 2] is meant to be run only once to create a global host microbiota model. A fastest version of this part is available using scripts contained in the “fast setup folder”. The major drawback of this, is the loss of genetic information in the model. 
The user can decide to use the new fastFVA in section 3.
However he should be careful calculating the number of cores that would be needed. 
Priority should be given in assigning cores for each personalized model simulation (one core for patient), then, if more cores are available (ex. user running the pipeline on the HPC) the use of the new fastFVA is suggested. 
Please take note that if the specific option is enabled in the input file most of the outputs are saved also in open format (xml, csv, rtf) in the dedicated folder. 
This might substantially slow down computations.

Status of implementation
========================

[Part 1, 2, 3] are implemented structured and tested. Refinement and expansion of these sections is always possible but it is not on the priority (todo) list.  

[Part 0] will be implemented and it will take care of the metagenomic mapping: from reads trimming to creation of abundance tables. 

In the next future [PART 4] will also be implemented: it will be hybrid modeling of patient specific scenario. Simulations will be done in VisL-BacArena. 

A file “todo.txt” contains more specific indications on the status of the implementation. It can be modified to point out suggestions and it synthetizes what still needs to be implemented.

A tutorial showing how to use the pipeline will also be created. 

Also data and result export in open formats (.csv, .xml, .rtf, .tsv) will be soon available, with the idea of making the pipeline more flexible and connected with soft wares other than MATLAB 

Please report any problem opening threads in the issue section. Also any kind of suggestions concerning the direction to follow with the pipeline implementation are welcome.   


Examples
========

Examples of input and output data [part 1] are contained in the Koala folder.


Spin offs
=========

The following functions can result useful for the community and be used for other purposes besides the usage of this pipeline:

| Filename                                       | Purpose                                                                |
| -----------------------------------------------|------------------------------------------------------------------------|
| minimalRxnFlux.m                               | *function to enforce a minimal flux trough a set of specific functions*|
| FatSetupCreator.m                              | *function to create setup: parallelized (models merging)*              |
| ImportSetDiet.m                                | *function to load and impose to a model a specific diet*               |


Benchmark
=========

To be inplemented


Toutorial
=========
To be inplemented: A Jupyter toutorial will be implemented as soon as possible. 
