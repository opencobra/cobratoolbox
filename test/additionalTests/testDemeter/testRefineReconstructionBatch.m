% The COBRAToolbox: testRefineReconstructionBatch.m
%
% Purpose:
%     - tests that reconstructions refined through DEMETER in batch mode
%       capture the known properties of the strains and pass quality 
%       control  tests.
%
% Author:
%     - Almut Heinken - September 2021
%
% Note:
%     - The solver libraries must be included separately

% initialize the test
fileDir = fileparts(which('testRefineReconstructionBatch'));
cd(fileDir);

global CBTDIR

% Preparing input data

% define the path to the folder where the draft reconstructions are located (required).
draftFolder = [CBTDIR filesep 'papers' filesep '2021_demeter' filesep 'exampleDraftReconstructions'];

% print names of refined reconstructions that will be created
refinedModelIDs = printRefinedModelIDs(draftFolder);

% define path to file with taxonomic information (create as needed)
infoFilePath = [CBTDIR filesep 'papers' filesep '2021_demeter' filesep 'example_infoFile.xlsx'];

% define path to the folder with example comparative genomics data
spreadsheetFolder = [CBTDIR filesep 'papers' filesep '2021_demeter' filesep 'exampleSpreadsheets'];

% propagate experimental data
[infoFilePath,inputDataFolder] = prepareInputData(infoFilePath,'spreadsheetFolder',spreadsheetFolder);

% ensure text files with input data have been created. There should be nine
% text files.
dInfo = dir(inputDataFolder);
files={dInfo.name};
files(find(~contains(files,'.txt')))=[];
assert(length(files)==9)

% Refining reconstructions

% Define the number of workers for parallel computing
numWorkers = 4;

% Define a name for the reconstruction resource (optional)
reconVersion = 'TutorialExample';

% Run the pipeline
[reconVersion,refinedFolder,translatedDraftsFolder,summaryFolder] = runPipeline(draftFolder, 'infoFilePath', infoFilePath, 'inputDataFolder', inputDataFolder,'numWorkers', numWorkers, 'reconVersion', reconVersion);

% ensure that the ten test reconstructions have been refined.
dInfo = dir(refinedFolder);
files={dInfo.name};
files(find(~contains(files,'.mat')))=[];
assert(length(files)==10)

% Testing reconstructions

testResultsFolder = runTestSuiteTools(refinedFolder, infoFilePath, inputDataFolder, reconVersion, 'translatedDraftsFolder', translatedDraftsFolder, 'numWorkers', numWorkers);

% Debugging the reconstructions

% Run the debugging suite
[debuggingReport, fixedModels, failedModels]=runDebuggingTools(refinedFolder,testResultsFolder,inputDataFolder,reconVersion,'numWorkers',numWorkers);

% ensure that all refined reconstructions can grow anaerobically and on
% complex medium defined for the DEMETER pipeline
assert(~isfile(([testResultsFolder filesep 'notGrowing.mat'])))

% ensure that all refined reconstructions produce reasonable amounts of ATP
assert(~isfile(([testResultsFolder filesep 'tooHighATP.mat'])))

% ensure that all reconstructions agree with experimental data and there
% are no false negative predictions
testResults=readInputTableForPipeline([testResultsFolder filesep reconVersion '_PercentagesAgreement.xls']);

testResults(1,:)=[];
for i=1:size(testResults,1)
    testResults{i,2}=str2double(testResults{i,2});
    testResults{i,3}=str2double(testResults{i,3});
end
% remove cases with no data
testResults(find((cell2mat(testResults(:,2))==0)),:)=[];

% check that all findings agree 100%
assert(~any(cell2mat(testResults(:,3))<1))
