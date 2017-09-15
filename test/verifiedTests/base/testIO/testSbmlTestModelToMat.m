% The COBRAToolbox: testSbmlTestModelToMat.m
%
% Purpose:
%     - tests the batch conversion of SBML models to .mat files.
%
% Authors:
%     - Original file: Jacek Wachowiak
%     - Updated to check models for similarity: Thomas Pfau - Sept 2017
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
modeldir = [CBTDIR filesep 'test' filesep 'models'];

modelfiles = dir(modeldir);

modelNames = cell(0);
models = cell(0);
%We will use up to 3 model files for the test.
for i = 1:size(modelfiles)    
    if ~isempty(regexp(modelfiles(i).name,'.*\.xml$'))
        copyfile([modeldir filesep, modelfiles(i).name],SBMLFolder);
        models{end+1} = readCbModel([modelfiles(i).folder filesep modelfiles(i).name]);
        modelNames{end+1} = modelfiles(i).name;
    end
    if numel(models) >= 3
        break;
    end
end
sbmlTestModelToMat(SBMLFolder,MATFolder)
matModels = cell(0);
for i = 1:size(modelfiles)
    if ~isempty(regexp(modelfiles(i).name,'.*\.xml$'))
        %We load them, as otherwise the ID would change to the mat file and
        %they would no longer be equivalent.
        load([MATFolder filesep strrep(modelNames{i},'.xml','.mat')]);
        matModels{end+1} = model;
end
end

%Test that the models are the same
assert(numel(matModels) == numel(models));
for i = 1:numel(matModels)
    assert(isSameCobraModel(matModels{i},models{i}));
end

%Clean up the folders.
isdeleted = false;
k = 0;

while ~isdeleted && k < 10 %we don'T try it more than ten times.
    try
        rmdir(MATFolder,'s');
        rmdir(SBMLFolder,'s');        
        isdeleted = true;
    catch
        k = k + 1; % increase counter for timeout
        pause(1); %wait a second before retry
        rehash;
    end
end

cd(currentDir)
