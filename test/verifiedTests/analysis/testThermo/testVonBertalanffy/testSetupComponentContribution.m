% The COBRAToolbox: testSetupComponentContribution.m
%
% Purpose:
%     - test the setupComponentContribution function
%
% Authors:
%     - Jacek Wachowiak

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSetupComponentContribution'));
cd(fileDir);

% this test is using babel library - if it is not installed, no computation will be made
[status,result] = system('babel'); %if run without initVonBertalanffy it is needed to fix the path
if status ~= 0
    setenv('LD_LIBRARY_PATH',['/usr/lib/x86_64-linux-gnu:' getenv('LD_LIBRARY_PATH')]);
end

[status,result] = system('babel'); %if after path change no babel detected - finish test - needs to be installed
if status ~= 0
  disp('No babel installed, test cannot proceed - for babel installation see docs/source/installation/vonBertalanffy.md')
  return
end

% test variables
model = getDistributedModel('Recon3DModel_Dec2017.mat');
model.csense(1:size(model.S,1),1)='E';
model.metFormulas{strcmp(model.mets,'h[i]')}='H';
model.metFormulas(cellfun('isempty',model.metFormulas)) = {'R'};
if isfield(model,'metCharge')
  model.metCharges = double(model.metCharge);
  model=rmfield(model,'metCharge');
end
basePath='~/work/sbgCloud';
molfileDir = [basePath '/data/molFilesDatabases/explicitHMol'];

% function outputs
model = setupComponentContribution(model, molfileDir);

% tests
assert(isstruct(model.inchi))
assert(isequal(size(model.pseudoisomers), [5835, 1]))
assert(isequal(model.pseudoisomers(1).success, 0))
assert(isempty(model.pseudoisomers(1).pKas))
assert(isequal(size(model.inchi.standard), [5835, 1]))

% change to old directory
cd(currentDir);
