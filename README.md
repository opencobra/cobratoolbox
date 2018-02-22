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
- [Author & Documentation Date](#Author_&_Documentation_Date)  

<!-- /MDTOC -->


Introduction
============
MgPipe is a MATLAB based pipeline to integrate microbial abundances (coming from metagenomic data) with constraint based modeling, creating individuals' personalized models. Almost all the pipeline is parallelized.   
The pipeline is divided in 3 parts:
[PART 1] Analysis of individuals' specific microbes abundances is computed. Individuals’ metabolic diversity in relation to microbiota size and disease presence as well as Classical multidimensional scaling (PCoA) on individuals' reaction repertoire are examples.
[PART 2]: 1 Constructing a global metabolic model (setup) containing all the microbes listed in the study. 2 Building individuals' specific models integrating abundance data retrieved from metagenomics. For each organism, reactions are coupled to their objective function. 
[PART 3] Simulations under different diet regimes. Set of standard analysis to apply to the personalized models. PCA of computed MNPCs of individuals as for example.

**WARNING :**Please take into consideration only the files listed in this document. Everything present in the folder but not listed and explained in this document is to be considered not relevant or obsolete.

Requirements
============

MgPipe requires Matrix Laboratory as well as the Cobra Toolbox to be installed with ILOG CPLEX as solver.
All toolboxes/solvers/files should be in the MATLAB path.
MgPipe was created (and tested) for AGORA 1.0 please first download AGORA version 1.0 from https://vmh.uni.lu/#downloadview 
and place the mat files into a dedicated folder.  

Main Folder Structure and Files
==========================

The following files are supplied

| Filename                                       | Purpose                                                                |
| -----------------------------------------------|------------------------------------------------------------------------|
| StartMgPipe.m                                  | *driver, containing all the input variables, to be modified by the user* |
| fastSetupCreator.m                             | *function to create "global" setup*                                             |
| addMicrobeCommunityBiomass.m                   | *function to add community biomass*                                    |
| MgPipe.m                                       | *Pipeline*                                                             |
| parsave.m                                      | *function to allow object saving in parallel loops*                    |
| getMappingInfo.m                               | *function to extract further information from the mapping*             |
| plotMappingInfo.m                              | *function plot extracted information from the mapping*                 |
| createPersonalizedModel.m                      | *function to create personalized models*                               |
| microbiotaModelSimulator.m                     | *function to simulate under different diets the created models (called from MGPipe)*|
| makeDummyModel.m                               | *function to create a dummy model*                                     |
| mgSimResCollect.m                              | *function to collect and output simulation results*                    |
| README.md                                      | *this file*                                                            |
| **setConstraints**                             | *Folder containing diets and related scripts*                          |
| setDietConstraints.m                           | *script to impose a specific diet and add essential elements to microbiota models*|
| **examples**                                   | *folder containing necessary files to replicate the pipeline tutorial* |
| **results**                                    | *Results folder*                                                       |
| ***compfile***                                 | *Results subfolder: contains objects saved in open format*             |


Usage
=====

Once installed the necessary dependencies the pipeline is ready to be used at the condition that some input variables are inserted or changed from the default input file (StartMgPipe.m). 


Running the script called “StartMgPipe.m” (after having changed the necessary inputs) is the only action required from the user to start the pipeline.

The pipeline can be stopped at every moment as all the results are saved as soon as they are computed. 
In case of accidental or volunteer halt in the execution, the pipeline can be simply restarted without loss of time: already saved results (from previous runs) are automatically detected and not recomputed.    

## Inputs

Some specific information files need to be loaded by the pipeline. For this reason, they must be formatted and called in a specific way. See the [Examples] section for more information. The files needed are

| File                   | Description                                                                                  |
| -----------------------|----------------------------------------------------------------------------------------------|
| normCoverage.csv       |  table with abundances for each species (normalized to 1, with a minimal value as threshold to define presence)|
| Patients_status.csv    |  optional: table of the same length of the number of individuals (0 means patient with disease 1 means healthy)|

Some variables, in the input file, needs to be created/modified to specify inputs (as for example paths of directories containing organisms models). The variables which need to be created or changed from default are

| Variables    | Description                          |
| -------------|--------------------------------------|
| modPath      | path to microbes models              |
| infoPath     | path to csv files (where input files are stored)|
| resePath     | path to the directory containing results|
| objre        | name of objective function of microbes|
| sDiet        | which type of diet to apply to the microbiota models|
| figForm      | the output is vectorized picture ('-depsc'), change to '-dpng' for .png|
| nWok         | number of cores dedicated for parallelization|
| autoFix      | option to automatically solve possible issues (autofix=1 means on, =0 off)   |
| compMod      | if outputs in open format should be produced for some sections (1=T)|
| patStat      | if documentation on patient status is provided (0 not 1 yes)|
| rDiet        | if to simulate also a rich diet (rdiet=1)|
| extSolve     | option to save microbiota models with diet to simulate with different language (autofix=1 means yes, =0 no)          |
| fvaType      | which FVA function to use (fastFVA =1) |




The ‘autorun’ variable controls the behavior of the pipeline. The autorun functionality is automatically on. 
This functionality enables the pipeline to automatically run and detect outputs. By changing ‘autorun’ variable to 0 it is possible to enter in manual / debug mode.   

**WARNING :**you should not change the ‘autorun’ variable value. Manual mode is strongly discouraged and should be used only for debugging purposes.


## Outputs

Individuals' plots of metabolic diversity in relation to microbiota size and disease presence as well as Classical multidimensional scaling (PCoA) on patients reaction repertoire are outputs of the first part [PART 1]; they are directly saved into the current MATLAB folder as figure files. Moreover, a series of objects created by the first part can be of interest to the user as they could be the object of further analysis. For this reason, the MATLAB workspace is saved into a file called “MapInfo.mat”. The saved variables are:

| Object                 | Description                                                                                  |
| -----------------------|----------------------------------------------------------------------------------------------|
| reac                   | cell array with all the unique set of reactions contained in the models                      |
| micRea                 | binary matrix assessing presence of set of unique reactions for each of the microbes          |
| binOrg                 | binary matrix assessing presence of specific strains in different individuals                   |
| reacPat                | matrix with number of reactions per individual (species resolved)                             |
| reacSet                | matrix with names of reactions that each individual has                                         |
| reacTab                | binary matrix with presence/absence of reaction per individual: to compare different individuals   |
| reacAbun               | matrix with abundance of reaction per individual: to compare different individuals         |


[PART 2] creates, first, a global microbiota metabolic model, secondly, individuals' specific models (personalized) are created with their specific objective function and coupling constraints. 
[PART 3] runs simulations (FVAs) and detects metabolic differences between personalized models.
The outputs are: 

| File                       | Description                                                                                  |
| ---------------------------|----------------------------------------------------------------------------------------------|
| Setup_allbacs.mat          | setup object containing all the models joined                                                |
| microbiota_model_XXX.mat   | mat.file containing the personalized model                                                   |
| simRes.mat                 | object containing NMPCs (FVAct), all the FVAs results (NSct), values of the objective function (Presol), names of infeasible models (InFesMat)|

If the specific option is enabled in the input file, some of the outputs are saved also in open format (.csv) in the dedicated folder. 

## Special uses

Data should be formatted exactly as specified (see also “Examples” section).  The input files should have names as listed in the input section.
The first part of [part 2] is meant to be run only once to create a global microbiota model. 
The user can decide to use different FVA functions in part 3.
The user should be careful calculating the number of cores to allocate. 
Priority should be given in assigning cores for each personalized model simulation (one core for each individual), then, if more cores are available (ex. user running the pipeline on the HPC) the use of fastFVA is suggested. 
Please take note that if the specific option is enabled in the input file some of the outputs are saved also in open format (csv) in the dedicated folder. 
By setting ‘autorun’=0 autorun function will be disabled. You are now running in manual / debug mode. Please note that the usage in manual mode is strongly discouraged and should be used only for 
debugging purposes.

**WARNING :**MgPipe was created (and tested) for AGORA 1.0. The use of models from any different source was not tested and it is not guaranteed to work. 

Status of implementation
========================

[Part 1, 2, 3] are implemented structured and tested. Refinement and expansion of these sections is always possible but it is not on the priority (todo) list.  

A tutorial showing how to use the pipeline will also be created. 

Data and result export in open formats (.csv) has to be better tested and further developed, the final aim is to make the pipeline more flexible and connected with software other than MATLAB 

Please report any problem opening threads in the issue section. Also, any suggestion with the pipeline implementation is welcome.   


Examples
========

Examples of input and output data [part 1] are contained in the examples folder.


Spin offs
=========

The following functions can result useful for the community and be used for other purposes besides the usage of this pipeline:

| Filename                                       | Purpose                                                                |
| -----------------------------------------------|------------------------------------------------------------------------|
| fastSetupCreator.m                              | *function to create setup: parallelized (models merging)*              |
| addMicrobeCommunityBiomass.m                    | *function to add community biomass*                    |

The correct functioning of this functions outside the functionalities used in the pipeline is not assured. The users can report related issues on the dedicated page.

Benchmark
=========

To be implemented


Toutorial
=========
To be inplemented: A livescript toutorial will be implemented as soon as possible. 


Author & Documentation Date
===========================
*Federico Baldini, 22.02.18*

*[federico.baldini@uni.lu](federico.baldini@uni.lu)*
