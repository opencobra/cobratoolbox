% The COBRAToolbox: testModel2data.m
%
% Purpose:
%     - testModel2data tests the functionality of the rBioNet functions
%     model2data and data2model
%
% Function under test:
%     src/reconstruction/rBioNet/model2data.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; ecoli_core_model loaded through getDistributedModel.
%     Message boxes are opened and closed by the test.
%
% Coverage exemptions:
%     None besides the defective inputs listed below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A model without grRules is reported as incomplete although the field is created
%       SEVERITY: wrong-result
%       TRIGGER: model2data(rmfield(model, 'grRules'))
%       OBSERVED: the field is created in model, but the mandatory fields are then checked against
%         the names read before and later read from handles.model, so the message Group grRules is
%         missing from structure of model is shown and nothing is returned
%       EXPECTED: the output is built with the created grRules field
%       LINES: 49
%     - DEFECT: A model whose description is missing or is not a text or a structure of seven fields stops
%       SEVERITY: error
%       TRIGGER: model2data(rmfield(model, 'description')); model.description = {'text'};
%         model.description = struct('name', 'text')
%       OBSERVED: the variable description is only set for the two supported forms, so the call
%         stops with Unrecognized function or variable 'description'
%       EXPECTED: an output with an empty description, or an error that names the problem
%       LINES: 179
%     - DEFECT: The two exits with a message box leave the output unassigned
%       SEVERITY: error
%       TRIGGER: data = model2data(rmfield(model, 'rxnNames'))
%       OBSERVED: after the message box the call stops with Output argument "data_out" (and
%         possibly others) not assigned a value; the test calls these exits without an output
%       EXPECTED: an empty output after the message box, as in rBioNetSaveLoad
%       LINES: 44, 82
%
% Authors:
%     - Stefania Magnusdottir April 2017
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%

global CBTDIR

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testModel2data'));
cd(fileDir);

% this test needs no solver, MATLAB toolbox or particular operating system
prepareTest();

% set paths to rBioNet database
comp_path = [fileDir, filesep 'compartments.mat'];
met_path = [fileDir, filesep 'metab.mat'];
rxn_path = [fileDir, filesep 'rxn.mat'];
save([fileDir, filesep 'rBioNetSettingsDB.mat'], 'comp_path', 'met_path', 'rxn_path')

% load E. coli model
model = getDistributedModel('ecoli_core_model.mat');
modelEcore = model;

% model to data
modelData = model2data(modelEcore, 1);

% data to model
modelTest = data2model(modelData{1, 1}, modelData{1, 2});

% test that the models have the same reactions
[cR, tR, eR] = intersect(modelTest.rxns, modelEcore.rxns);
assert(length(cR) == length(modelTest.rxns))
assert(length(cR) == length(modelEcore.rxns))

% test that the models have the same metabolites
[cM, tM, eM] = intersect(modelTest.mets, modelEcore.mets);
assert(length(cM) == length(modelTest.mets))
assert(length(cM) == length(modelEcore.mets))

% test that the S matrices are identical
assert(isequal(modelTest.S(tM, tR), modelEcore.S(eM, eR)))

% delete the file
delete('rBioNetSettingsDB.mat');

nRxns = numel(modelEcore.rxns);
nMets = numel(modelEcore.mets);

%% one input gives the same reaction table, without the metabolite table

modelDataDefault = model2data(modelEcore);
assert(numel(modelDataDefault) == 4);
assert(isequal(modelDataDefault{1}, modelData{1}));
assert(isequal(modelDataDefault{3}, modelEcore.genes));

%% any other value of fordb is rejected

assert(verifyCobraFunctionError('model2data', 'inputs', {modelEcore, 2}, ...
    'testMessage', 'fordb is supposed to be 0 or 1.'));

%% the alternative field names of Recon fill the same columns of the reaction table

modelRecon = modelEcore;
modelRecon.rxnConfidenceScores = (1:nRxns)';
modelRecon.rxnReferences = strcat('reference_', modelEcore.rxns);
modelRecon.rxnNotes = strcat('note_', modelEcore.rxns);
modelRecon.rxnECNumbers = strcat('ec_', modelEcore.rxns);
modelRecon.rxnKEGGID = strcat('kegg_', modelEcore.rxns);
reactionTable = model2data(modelRecon);
reactionTable = reactionTable{1};
assert(isequal(reactionTable(:, 9), num2cell((1:nRxns)')));
assert(isequal(reactionTable(:, 11), modelRecon.rxnReferences));
assert(isequal(reactionTable(:, 12), modelRecon.rxnNotes));
assert(isequal(reactionTable(:, 13), modelRecon.rxnECNumbers));
assert(isequal(reactionTable(:, 14), modelRecon.rxnKEGGID));

modelRecon = rmfield(modelEcore, 'subSystems');
modelRecon.rxnSubSystems = modelEcore.subSystems;
reactionTable = model2data(modelRecon);
reactionTable = reactionTable{1};
assert(isequal(reactionTable(:, 10), modelEcore.subSystems));

%% subsystems held in nested cells are joined into one text

modelNested = modelEcore;
modelNested.subSystems = cellfun(@(x) {x, 'second'}, modelEcore.subSystems, 'UniformOutput', false);
reactionTable = model2data(modelNested);
reactionTable = reactionTable{1};
assert(isequal(reactionTable(:, 10), strcat(modelEcore.subSystems, ';second')));

%% a description structure of seven fields is listed in the order of the database

modelDescribed = modelEcore;
modelDescribed.description = struct('notes', 'n7', 'name', 'n1', 'organism', 'n2', 'author', 'n3', ...
    'geneindex', 'n4', 'genedate', 'n5', 'genesource', 'n6');
describedData = model2data(modelDescribed);
assert(isequal(describedData{2}, {'n1', 'n2', 'n3', 'n4', 'n5', 'n6', 'n7'}));

%% disabled reactions are added to the reaction table

modelDisabled = modelEcore;
modelDisabled.disabled = {true, 'off', 'name', 'a[c] -> b[c]', 0, '', 0, 1000, [], '', '', '', '', ''};
disabledData = model2data(modelDisabled);
assert(size(disabledData{1}, 1) == nRxns + 1);
assert(isequal(disabledData{1}(end, :), modelDisabled.disabled));
assert(isequal(disabledData{4}.disabled, modelDisabled.disabled));

%% the metabolite table holds numeric charges, and fields that are empty or wrongly capitalised

modelMets = modelEcore;
modelMets.metCharges = (1:nMets)';
modelMets.metKEGGID = {};
modelMets.metchebiid = modelEcore.mets;
metaboliteTable = model2data(modelMets, 1);
metaboliteTable = metaboliteTable{5};
assert(isequal(size(metaboliteTable), [nMets, 12]));
assert(isequal(metaboliteTable(:, 1), modelEcore.mets));
assert(isequal(metaboliteTable(:, 4), num2cell((1:nMets)')));
assert(all(cellfun(@isempty, metaboliteTable(:, 5))));
assert(isequal(metaboliteTable(:, 7), modelEcore.mets));
assert(all(cellfun(@isempty, metaboliteTable(:, 8))));

%% a file that is not a complete reconstruction is reported in a message box

model2data(struct('genes', {{}}, 'data', 1, 'description', 'text'));
assert(contains(closeMessageBoxes(), 'not an complete reconstruction'));

%% a missing mandatory field is reported in a message box

model2data(rmfield(modelEcore, 'rxnNames'));
assert(contains(closeMessageBoxes(), 'Group rxnNames is missing from structure of model.'));

% change the directory
cd(currentDir)

function boxText = closeMessageBoxes()
% Returns the text of the open message boxes and closes them, so that no window stays open.
boxes = findall(0, 'Type', 'figure', '-regexp', 'Tag', '^Msgbox_');
boxText = '';
for iBox = 1:numel(boxes)
    boxLines = cellstr(get(findall(boxes(iBox), 'Type', 'text'), 'String'));
    boxText = [boxText, ' ', strjoin(strtrim(boxLines), ' ')];
end
delete(boxes);
end
