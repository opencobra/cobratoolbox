# mgPipe

## Introduction

mgPipe is a MATLAB based pipeline to integrate microbial abundances (coming
from metagenomic data) with constraint-based modeling, creating
individuals' personalized models.  The pipeline is divided into 3 parts: [PART 1]
Analysis of individuals' specific microbes abundances is computed. Individuals'
metabolic diversity in relation to microbiota size and disease presence as well
as Classical multidimensional scaling (PCoA) on individuals' reaction
repertoire are examples.  [PART 2]: 1 Constructing a global metabolic model
(setup) containing all the microbes listed in the study. 2 Building
individuals' specific models integrating abundance data retrieved from
metagenomics. For each organism, reactions are coupled to their objective
function.  [PART 3] Simulations under different diet regimesand analysis of the
predicted metabolic profile (PCoA of computed MNPCs of
individuals).

**WARNING:** Please take into consideration only the files listed in this
document. Everything present in the folder but not listed and explained in this
document is to be considered not relevant or obsolete.

## Requirements

mgPipe requires `Matrix Laboratory`, the `Parallel Computing Toolbox`, as well
as, the COBRA Toolbox to be installed. Please refer to
the [installation instructions](https://opencobra.github.io/cobratoolbox/stable/installation.html).
The usage of `ILOG CPLEX` solver is strongly advised to obtain the best speed performance
(required for the fastFVA.m function).

MgPipe was created (and tested) for AGORA 1.0 please first download AGORA
version 1.0 from https://www.vmh.life/#downloadview and place the mat files into
a dedicated folder.

## Main Folder Structure and Files

The following files are essential for the usage of the pipeline and are
supplied in the current folder and in `papers/2018_microbiomeModelingToolbox`

| Filename                                       | Purpose                                                                |
| -----------------------------------------------|------------------------------------------------------------------------|
| startMgPipe.m                                  | *driver, containing all the input variables, to be modified by the user* |
| initMgPipe.m                                   | *function containing all the input variables launching the pipeline*   |
| loadUncModels.m                                | *function to load unconstrain and prune the models*                         |
| fastSetupCreator.m                             | *function to create "global" setup*                                    |
| checkNomenConsist.m                            | *function to check that microbes have the right nomenclature*          |
| detectOutput.m                                 | *function to check if a specific file was already created and saved*   |
| getIndividualSizeName.m                        | *get information on number and ID of organisms and individuals*|
| addMicrobeCommunityBiomass.m                   | *function to add community biomass*                                    |
| mgPipe.m                                       | *pipeline*                                                             |
| parsave.m                                      | *function to allow object saving in parallel loops*                    |
| getMappingInfo.m                               | *function to extract information from the mapping*             |
| plotMappingInfo.m                              | *function plot extracted information from the mapping*                 |
| createPersonalizedModel.m                      | *function to create personalized models*                               |
| microbiotaModelSimulator.m                     | *function to simulate under different diets the created models (called from mgPipe)*|
| makeDummyModel.m                               | *function to create a dummy model*                                     |
| mgSimResCollect.m                              | *function to collect and output simulation results*                    |
| extractFullRes.m                               | *function to retrieve and export all the results (fluxes) computed during the simulations*|
| README.md                                      | *this file*                                                            |
| useDiet.m                                      | *function to impose a specific diet and add essential elements to microbiota models*|
| adaptVMHDietToAGORA.m                          | *function to convert a specific diet from VMH into an AGORA compatible one*|
| ***compfile***                                 | *Results subfolder: contains objects saved in open format*             |

## Usage

Once installed the necessary dependencies the pipeline is ready to be used at
the condition that some input variables are inserted or changed from the
default input file `startMgPipe.m` or directly in the input function
`initMgPipe.m`.

Running the script called `startMgPipe.m` (after having changed the necessary
inputs) is the only action required from the user to start the
pipeline.

The pipeline can be stopped at every moment as all the results are saved as
soon as they are computed.  In case of accidental or volunteer halt in the
execution, the pipeline can be simply restarted without loss of time running
again `startMgPipe.m` : already saved results (from previous runs) are
automatically detected and not recomputed.

## Inputs

Some specific information files need to be loaded by the pipeline. For this
reason, they must be formatted and called in a specific way. See the examples
folder in `papers/2018_microbiomeModelingToolbox` for more information.
The files needed are

| File                   | Description                                                                                  |
| -----------------------|----------------------------------------------------------------------------------------------|
| normCoverage.csv       |  table with abundances for each species (normalized to 1, with a minimum value as a threshold to define presence)|
| sampInfo.csv           |  optional: table of the same length of the number of individuals (0 means patient with disease 1 means healthy)|

Some variables, in the input file, needs to be created/modified to specify
inputs (for example paths of directories containing organisms models). The
variables which need to be created or changed from default are

| Variables       | Description                          |
| ----------------|--------------------------------------|
| modPath         | path to microbes models              |
| resPath         | path to the directory containing results|
| dietFilePath    | path to and name of the file with dietary information|
| abunFilePath    | path to and name of the file with abundance information|
| indInfoFilePath | path to csv file for stratification criteria (if empty or not existent no criteria is used)|
| objre           | name of the objective function of microbes|
| figForm         | the output is a vectorized picture ('-depsc'), change to '-dpng' for .png|
| numWorkers      | number of cores dedicated for parallelization|
| autoFix         | option to automatically solve possible issues (true means on)   |
| compMod         | if outputs in open format should be produced for some sections |
| rDiet           | if to simulate also a rich diet (rdiet=true)|
| extSolve        | option to save microbiota models with diet to simulate with a different language (true means yes)          |
| fvaType         | which FVA function to use (fastFVA =true for fastFVA) |

The `autorun` variable controls the behavior of the pipeline. The autorun
functionality is automatically off.  This functionality enables the pipeline to
automatically run and detect outputs. By changing `autorun` variable to false, it is
possible to enter in manual / debug mode.

**WARNING**: concerning the `autorun` variable value: manual mode is
strongly discouraged and should be used only for debugging purposes.

## Outputs

Individuals' plots of metabolic diversity in relation to microbiota size and
disease presence as well as Classical multidimensional scaling (PCoA) on
patients reaction repertoire are outputs of the first part [PART 1]; they are
directly saved into the current MATLAB folder as figure files. Moreover, a
series of objects created by the first part can be of interest to the user as
they could be the object of further analysis. For this reason, the MATLAB
workspace is saved into a file called `MapInfo.mat`. The saved variables are:

| Object                 | Description                                                                                  |
| -----------------------|----------------------------------------------------------------------------------------------|
| reac                   | cell array with all the unique set of reactions contained in the models                      |
| micRea                 | binary matrix assessing presence of a set of unique reactions for each of the microbes          |
| binOrg                 | binary matrix assessing the presence of specific strains in different individuals                   |
| reacPat                | matrix with number of reactions per individual (species resolved)                             |
| reacSet                | matrix with names of reactions that each individual has                                         |
| reacTab                | binary matrix with presence/absence of reaction per individual: to compare different individuals   |
| reacAbun               | matrix with abundance of reaction per individual: to compare different individuals         |

[PART 2] creates, first, a global microbiota metabolic model. Secondly,
individuals' specific models (personalized) are created with their specific
objective function and coupling constraints.  [PART 3] runs simulations
(FVAs) and detects metabolic differences between personalized models. The
outputs are:

| File                       | Description                                                                                  |
| ---------------------------|----------------------------------------------------------------------------------------------|
| Setup_allbacs.mat          | setup object containing all the models joined                                                |
| microbiota_model_XXX.mat   | .mat file containing the personalized model                                                   |
| simRes.mat                 | .mat file containing NMPCs (FVAct), the complementary FVAs results (NSct), values of the objective function (Presol), names of infeasible models (InFesMat)|

For simplicity, besides the .mat files containing all the results, the main results are also saved in open format (.csv) in the dedicated results folder. The saved tables are:

| File                       | Description                                                                                  |
| ---------------------------|----------------------------------------------------------------------------------------------|
| ID.csv                     | table containing list of metabolites for which simulations(FVA)and NMPCs are computed        |
| standard.csv               | table containing metabolite resolved NMPCs for each individual under the same diet conditions|
| sDiet_allFlux.csv          | table containing metabolite resolved min and max value of uptake and secretion for each individual under the same diet conditions|
| rich.csv (if eneabled)     | table containing metabolite resolved NMPCs for each individual under rich diet conditions|
| rDiet_allFlux.csv (if eneabled)| table containing metabolite resolved min and max value of uptake and secretion for each individual under rich diet conditions|

If the specific option is enabled in the input file, some of the other outputs are also saved in open format (.csv) in the dedicated folder.

## Additional information on usage

Data should be formatted exactly as specified (see also
`papers/2018_microbiomeModelingToolbox`).  The input files should
have names as listed in the input section.  The first part of [part 2] is meant
to be run only once to create a global microbiota model.  The user can decide
to use different FVA functions in part 3.  The user should be carefully
calculating the number of cores to allocate.  Priority should be given in
assigning cores for each personalized model simulation (one core for each
individual), then, if more cores are available (ex. user running the
pipeline on the HPC) the use of fastFVA is suggested.  Please take
note that if the specific option is enabled in the input file some of
the outputs are also saved in open format (csv) in the dedicated
folder.  By setting `autorun`=0 autorun function will be disabled. You
are now running in manual / debug mode. Please note that the usage in
manual mode is strongly discouraged and should be used only for
debugging purposes.

**WARNING**: mgPipe was created (and tested) for AGORA 1.0. The use of models
from any different source was not tested and it is not guaranteed to work.

# Status of implementation

[Part 1, 2, 3] are implemented structured and tested.

A tutorial showing how to use the pipeline was created.

Data and result export in open formats (.csv) has to be better tested and
further developed, the final aim is to make the pipeline more flexible and
connected with software other than MATLAB

Please report any problem opening threads in the issue section. Also, any
suggestion with the pipeline implementation is welcome.

## Examples

Examples of input are in the examples folder `papers/2018_microbiomeModelingToolbox`.

## Spinoffs

The following functions can result useful for the community and be used for
other purposes besides the usage of this pipeline:

| Filename                                       | Purpose                                                                |
| -----------------------------------------------|------------------------------------------------------------------------|
| fastSetupCreator.m                              | *function to create setup: parallelized (models merging)*              |
| addMicrobeCommunityBiomass.m                    | *function to add community biomass*                    |

The correct functioning of this functions outside the functionalities used in
the pipeline is not assured. The users can report related issues on the
dedicated page.

## Tutorial

A livescript tutorial `mgPipeTutorial.mlx` and its correspondent version `mgPipeTutorial.m` are available in
`tutorials/analysis/microbiomeModelingToolbox/`.

## Funding

This study received funding from the Luxembourg National Research Fund(FNR), through the ATTRACT programme (FNR/A12/01), and the OPEN
grant (FNR/O16/11402054), as well as the European Research Council(ERC) under the European Union?s Horizon 2020 research and innovation
programme (grant agreement No 757922).

## Author & Documentation Date

*Federico Baldini, 26.07.18*

*Luxembourg Centre for Systems Biomedicine, University of Luxembourg, Campus Belval, Esch-sur-Alzette, Luxembourg*

*[federico.baldini@uni.lu](federico.baldini@uni.lu)*


