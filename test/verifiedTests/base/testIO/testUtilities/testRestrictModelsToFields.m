% The COBRAToolbox: testRestrictModelsToFields.m
%
% Purpose:
%     - test the restrictModelsToFields function
%
% Authors:
%     - Jacek Wachowiak
global CBTDIR
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRestrictModelsToFields'));
cd(fileDir);

% test variables
models{1} = getDistributedModel('ecoli_core_model.mat');
models{2} = getDistributedModel('Abiotrophia_defectiva_ATCC_49176.xml');

fieldNames = fieldnames(models{1});
fieldNames2 = fieldnames(models{2});

%test whether fields are removed:
commonfields = intersect(fieldNames,fieldNames2);
restrictedModels = restrictModelsToFields(models, commonfields);

for i = 1:numel(models)
    assert(isempty(setxor(commonfields,fieldnames(restrictedModels{i}))));
end

%Test whether random fields are retained.

fieldsKept = commonfields([1,2,3]);
restrictedModels = restrictModelsToFields(models, fieldsKept);
for i = 1:numel(models)
    assert(isempty(setxor(fieldsKept,fieldnames(restrictedModels{i}))));
end

%leave all fields in
allFields = union(fieldNames,fieldNames2);
restrictedModels = restrictModelsToFields(models, allFields);

% test
assert(isSameCobraModel(restrictedModels{1}, models{1}));
assert(isSameCobraModel(restrictedModels{2}, models{2}));

% change to old directory
cd(currentDir);
