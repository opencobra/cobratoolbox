% The COBRAToolbox: testSbmlTestModelToMat.m
%
% Purpose:
%     - tests the batch conversion of SBML models to .mat files.
%
% Authors:
%     - Original file: Jacek Wachowiak
%     - Updated to check models for similarity: Thomas Pfau - Sept 2017
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%
% Coverage exemptions:
%     Line 62: unreachable. The file was checked to be absent at line 43, and neither readCbModel
%     nor a failed save leaves it behind for an input (only a disk failure while saving could).
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSbmlTestModelToMat.m'));
cd(fileDir);

%Create Temporary Folders
SBMLFolder = tempname;
mkdir(SBMLFolder);

MATFolder = tempname;
mkdir(MATFolder);

%copy all xml files from the models to the temp folder 
modeldir = getDistributedModelFolder('iIT341.xml');

modelfiles = dir(modeldir);

modelNames = cell(0);
models = cell(0);
%We will use up to 3 model files for the test.
for i = 1:numel(modelfiles)    
     if numel(models) >= 3
        break;
    end
    if ~isempty(regexp(modelfiles(i).name,'.*\.xml$'))
        copyfile([modeldir filesep, modelfiles(i).name],SBMLFolder);
        models{end+1} = readCbModel([modeldir filesep modelfiles(i).name]);
        modelNames{end+1} = modelfiles(i).name;
    end
end
sbmlTestModelToMat(SBMLFolder,MATFolder)
matModels = cell(0);
for i = 1:size(models,2)
    %We load them, as otherwise the ID would change to the mat file and
    %they would no longer be equivalent.
    load([MATFolder filesep strrep(modelNames{i},'.xml','.mat')]);
    matModels{end+1} = model;
    
end

%Test that the models are the same
assert(numel(matModels) == numel(models));
for i = 1:numel(matModels)
    assert(isSameCobraModel(matModels{i},models{i}));
end

%clear all the xml files from the temporary dir.
delete([SBMLFolder filesep '*.xml'])
delete([MATFolder filesep '*.mat'])

%create an invalid xml file (and test with the defaults)
tempfolder = tempname;
mkdir(tempfolder);
cd(tempfolder);
defaultname = 'm_model_collection';
mkdir(defaultname);

invalidFile = fopen([defaultname filesep 'Invalid.xml'],'w');
fprintf(invalidFile,'Not a vlid XML\n');
fclose(invalidFile);
%Test with defaults, and nothing works
sbmlTestModelToMat()
defaultfoldercontent = dir(defaultname);

% the invalid file, '.' and '..'
assert(size(defaultfoldercontent,1) == 3);

%% A model that already has its .mat file is not parsed again
% the xml file is invalid: a new parse would fail, and the existing .mat file must stay as it is
existingModel = 'kept';
save([defaultname filesep 'Invalid.mat'], 'existingModel');
parsedOutput = evalc('sbmlTestModelToMat()');
assert(contains(parsedOutput, 'Invalid.xml :already parsed and compatible with readCbModel'));
savedContent = load([defaultname filesep 'Invalid.mat']);
assert(isequal(savedContent, struct('existingModel', 'kept')));

%% CBTDIR is filled in when the toolbox root is not known yet
savedCBTDIR = CBTDIR;
CBTDIR = [];
try
    sbmlTestModelToMat();
catch ME
    CBTDIR = savedCBTDIR;
    rethrow(ME);
end
assert(strcmp(CBTDIR, savedCBTDIR));

cd(fileDir);



%Clean up the folders. (In a try/catch for windows)
%Even if this does not work, those folders are just temporary folders.
try
   rmdir(MATFolder,'s');
   rmdir(SBMLFolder,'s');        
   rmdir([tempfolder filesep defaultname],'s');
   isdeleted = true;
catch
    
end

cd(currentDir)
