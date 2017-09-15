% The COBRAToolbox: testSbmlTestModelToMat.m
%
% Purpose:
%     - tests the batch conversion of SBML models to .mat files.
%
% Authors:
%     - Original file: Thomas Pfau - Sept 2017
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
copyfile([modeldir filesep '*.xml'], SBMLFolder);

modelfiles = dir(SBMLFolder);
models = cell(0);
%Now, individually read all models
for i = 1:size(modelfiles)
    if ~isempty(regexp(modelfiles(i).name,'.*\.xml$'))
        models{end+1} = readCbModel([modelfiles(i).folder filesep modelfiles(i).name]);
    end
end
sbmlTestModelToMat(SBMLFolder,MATFolder)
matModels = cell(0);
for i = 1:size(modelfiles)
    if ~isempty(regexp(modelfiles(i).name,'.*\.xml$'))
        %We load them, as otherwise the ID would change to the mat file and
        %they would no longer be equivalent.
        load([MATFolder filesep strrep(modelfiles(i).name,'.xml','.mat')]);
        matModels{end+1} = model;
    end
end

%Test that the models are the same
assert(numel(matModels) == numel(models));
for i = 1:numel(matModels)
    assert(isSameCobraModel(matModels{i},models{i}));
end

%Clean up the folders.
rmdir(MATFolder,'s');
rmdir(SBMLFolder,'s');

cd(currentDir)
