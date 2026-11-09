% The COBRAToolbox: testConvertOldStyleModel.m
%
% Purpose:
%     - testConvertOldStyleModel tests, whether a model containing new style fields stays unchanged by the model conversion,
%       and whether an old style models FieldNames change and get replaced.
%       It also tests, whether an old style models fields get merged to
%       potentially existing new Style fields.
%
% Authors:
%     - Thomas Pfau
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which(mfilename));
cd(fileDir);

% prepare the test, i.e. require LP solver
solverPkgs = prepareTest('needsLP',true,'useMinimalNumberOfSolvers',true);

changeCobraSolver(solverPkgs.LP{1},'LP');
% Test with 
%s ... ', solverPkgs.LP{k}
fprintf('>> Testing Model conversion and field merging:%s ... \n', solverPkgs.LP{1});
%Explicitly load the model by load to ensure that its an old style model
%that we can convert.
% Core model structure
model = struct;
model.mets = {'m1'; 'm2'; 'm3'};
model.rxns = {'r1'; 'r2'};
model.S = [1 -1; -1 1; 0 0];
model.lb = [-1000; 0];
model.ub = [1000; 1000];
model.c = [1; 0];
model.b = [0; 0; 0];

% Old-style fields
model.metHMDB = {'HMDB00001'; 'HMDB00002'; 'HMDB00003'};
model.metSmile = {'C(C(=O)O)N'; 'CCO'; 'COC'};
model.metInchiString = {'InChI=1S/C2H5NO2'; 'InChI=1S/C2H6O'; 'InChI=1S/CH4O'};
model.confidenceScores = {'4'; '3'};  % Old format, as strings
model.ecNumbers = {'1.1.1.1'; '2.7.1.1'};
model.rxnKeggID = {'R00001'; 'R00002'};
model.metKeggID = {'C00001'; 'C00002'; 'C00003'};

convertedFields = {'metHMDB','metSmile','metInchiString','confidenceScores','ecNumbers','rxnKeggID','metKeggID'};
newFields = {'metHMDBID','metSmiles','metInChIString','rxnConfidenceScores','rxnECNumbers','rxnKEGGID','metKEGGID'};
%There are multiple old style fields.
for i = 1:numel(convertedFields)
    assert(isfield(model,convertedFields{i}));
end
modelnew = convertOldStyleModel(model);
%check that they are removed.
for i = 1:numel(convertedFields)
    assert(~isfield(modelnew,convertedFields{i}));
end
%and that the new ones are containing the old data
for i = 1:numel(convertedFields)
    if strcmp(convertedFields{i},'confidenceScores')
       %This field is different
       assert(isnumeric(modelnew.(newFields{i})));
    else
        assert(all(cellfun(@(x,y) isequal(x,y), model.(convertedFields{i}), modelnew.(newFields{i}))));
    end
end


model.metHMDBID = {'Lets','Test'};

modelnew = convertOldStyleModel(model);
convertedFields = {'metSmile','metInchiString','confidenceScores','ecNumbers','rxnKeggID','metKeggID'};
newFields = {'metSmiles','metInChIString','rxnConfidenceScores','rxnECNumbers','rxnKEGGID','metKEGGID'};
retainedFields = {'metHMDBID','metHMDB'};
for i = 1:numel(convertedFields)
    if strcmp(convertedFields{i},'confidenceScores')
       %This field is different
       assert(isnumeric(modelnew.(newFields{i})));
    else
        assert(all(cellfun(@(x,y) isequal(x,y), model.(convertedFields{i}), modelnew.(newFields{i}))));
    end
end
for i = 1:numel(retainedFields)
    assert(all(cellfun(@(x,y) isequal(x,y), model.(retainedFields{i}), modelnew.(retainedFields{i}))));
end
newHMDBIDs = cellfun(@num2str, num2cell(1:numel(model.mets)),'UniformOutput',0);
model.metHMDB = newHMDBIDs;

modelnew = convertOldStyleModel(model);
for i = 1:numel(convertedFields)
    if strcmp(convertedFields{i},'confidenceScores')
       %This field is different
       assert(isnumeric(modelnew.(newFields{i})));
    else
        assert(all(cellfun(@(x,y) isequal(x,y), model.(convertedFields{i}), modelnew.(newFields{i}))));
    end
end
assert(all(cellfun(@(x,y) isequal(x,y), modelnew.metHMDBID,model.metHMDBID)));
randpos = randi(numel(model.mets),20,1);
newHMDBIDs(randpos) = {''};
model.metHMDBID = newHMDBIDs;
modelnew = convertOldStyleModel(model);
for i = 1:numel(convertedFields)
    if strcmp(convertedFields{i},'confidenceScores')
       %This field is different
       assert(isnumeric(modelnew.(newFields{i})));
    else
        assert(all(cellfun(@(x,y) isequal(x,y), model.(convertedFields{i}), modelnew.(newFields{i}))));
    end
end

assert(all(cellfun(@(x,y) isequal(x,y), modelnew.metHMDBID(randpos),model.metHMDB(randpos))));
newpos = setdiff(1:numel(model.mets),randpos);
assert(all(cellfun(@(x,y) isequal(x,y), modelnew.metHMDBID(newpos),model.metHMDBID(newpos))));

% test microbiota Models
testModel = getDistributedModel('ecoli_core_model.mat');
% add an A Matrix
o2Ex = double(ismember(testModel.rxns,'EX_o2(e)'));
acEx = double(ismember(testModel.rxns,'EX_ac(e)'));
co2Ex = double(ismember(testModel.rxns,'EX_co2(e)'));
ConstraintMatrix = sparse([o2Ex';acEx';co2Ex']);
addMets = {'O2Lim';'acLim';'co2Lim'};
addb = [-10;3;5];
addcsense = ['G';'E';'L']; % Uptake of less than 10 o2, export of less than 5 co2 and exactly 3 ac
modelWithConstraints = addCOBRAConstraints(testModel,testModel.rxns,addb,'dsense',addcsense,'c',ConstraintMatrix,'ConstraintID',addMets);
% now build the same model with a:
modelWithA = testModel;
modelWithA.A = [modelWithA.S;ConstraintMatrix];
modelWithA.b = [modelWithA.b;addb];
modelWithA.csense = [modelWithA.csense;addcsense];
modelWithA.mets = [modelWithA.mets;addMets];
modelWithA.osense = -1;
% the solutions should be the same.
sol = optimizeCbModel(modelWithConstraints);
solWithA = solveCobraLP(modelWithA);
modelWithA = rmfield(modelWithA,'osense');
optTol = getCobraSolverParams('LP','optTol');
assert(abs(solWithA.obj-sol.f) < optTol)
warning on
modelConverted = convertOldStyleModel(modelWithA);
% assert that the proper warning was shown
warnmessage = 'The inserted Model contains an old style coupling matrix (A). The Matrix will be converted into a Coupling Matrix (C) and fields will be adapted.';
assert(isequal(warnmessage,lastwarn));
% the two models with added constraints and converted A should be the same.
assert(isSameCobraModel(modelConverted,modelWithConstraints));

[nMets,nRxns] = size(testModel.S);
% now, test partially invalid old style fields
testModel.confidenceScores = arrayfun(@num2str, randi(4,nRxns,1),'Uniform',0);
testModel.confidenceScores(3) = {[]};
testModel.subSystems(10) = {[]};
res = verifyModel(testModel,'simpleCheck',true);
assert(res == 1);
fixedModel = convertOldStyleModel(testModel);
% confidenceScores got converted.
assert(fixedModel.rxnConfidenceScores(3) == 0);
% this should again be valid, subSystems Field is fixed and confidence Scores properly converted..
assert(verifyModel(fixedModel,'simpleCheck',true));

% if the old style A is the same as S (no additional constraint), test that convertOldStyleModel returns the correct empty vectors
modelWithA = fixedModel;
modelWithA.A = fixedModel.S;
modelConverted = convertOldStyleModel(modelWithA);
assert(verifyModel(modelConverted,'simpleCheck',true));

% The sections below perturb one small model, one legacy shape per section.
toyModel = struct;
toyModel.mets = {'m1'; 'm2'; 'm3'};
toyModel.rxns = {'r1'; 'r2'};
toyModel.S = [1 -1; -1 1; 0 0];
toyModel.lb = [-1000; 0];
toyModel.ub = [1000; 1000];
toyModel.c = [1; 0];
toyModel.b = [0; 0; 0];
toyModel.genes = {'g1'; 'g2'};

%% Old and new numeric fields: both exist, and one of them is a cell array
% old field as a cell of strings and empties: the larger score of old and new is kept
testCase = toyModel;
testCase.confidenceScores = {'4'; []};
testCase.rxnConfidenceScores = [1; 2];
converted = convertOldStyleModel(testCase);
assert(isequal(converted.rxnConfidenceScores, [4; 2]));
assert(~isfield(converted, 'confidenceScores'));

% new field as a cell with empties: an empty entry counts as missing
testCase = toyModel;
testCase.confidenceScores = [1; 3];
testCase.rxnConfidenceScores = {2; []};
converted = convertOldStyleModel(testCase);
assert(isequal(converted.rxnConfidenceScores, [2; 3]));

% charges: the old value only fills what the new field does not have
testCase = toyModel;
testCase.metCharge = [1; 2; 3];
testCase.metCharges = {[]; -1; []};
converted = convertOldStyleModel(testCase);
assert(isequal(converted.metCharges, [1; -1; 3]));
assert(~isfield(converted, 'metCharge'));

%% An old field of the wrong size is left alone, with a warning
testCase = toyModel;
testCase.metCharge = [1; 2];
lastwarn('');
converted = convertOldStyleModel(testCase);
assert(strcmp(lastwarn, 'Old field metCharge exists, but does not fit to size of mets, not converting it'));
assert(isequal(converted.metCharge, [1; 2]));
assert(~isfield(converted, 'metCharges'));

%% The numeric objective sense is translated, unless osenseStr is already there
testCase = toyModel;
testCase.osense = -1;
converted = convertOldStyleModel(testCase);
assert(strcmp(converted.osenseStr, 'max') && ~isfield(converted, 'osense'));
testCase.osense = 1;
converted = convertOldStyleModel(testCase);
assert(strcmp(converted.osenseStr, 'min') && ~isfield(converted, 'osense'));
testCase.osenseStr = 'max';
converted = convertOldStyleModel(testCase);
assert(strcmp(converted.osenseStr, 'max') && ~isfield(converted, 'osense'));

%% An invalid constraint sense becomes an equality, with a warning
testCase = toyModel;
testCase.csense = 'EXL';
lastwarn('');
converted = convertOldStyleModel(testCase);
assert(strcmp(lastwarn, 'Assuming 1 missing csense are equality constraints.'));
assert(isequal(converted.csense, ['E'; 'E'; 'L']));

%% Missing fields are created: objective, right hand side, rules from grRules
testCase = rmfield(toyModel, {'c', 'b'});
testCase.grRules = {'g1 and g2'; ''};
converted = convertOldStyleModel(testCase);
assert(isequal(converted.c, zeros(size(toyModel.rxns))));
assert(isequal(converted.b, zeros(size(toyModel.mets))));
assert(contains(converted.rules{1}, 'x(1) & x(2)') && isempty(converted.rules{2}));

%% Confidence scores that cannot be converted are set to 0, with a warning
testCase = toyModel;
testCase.rxnConfidenceScores = {1; 'not a number'};
lastwarn('');
converted = convertOldStyleModel(testCase);
assert(strcmp(lastwarn, 'Cannot Convert Reaction Confidence Scores, setting to 0'));
assert(isequal(converted.rxnConfidenceScores, zeros(size(toyModel.rxns))));

%% subSystems: numbers become text, and one subsystem per reaction becomes a plain char
testCase = toyModel;
testCase.subSystems = {1; 2};
converted = convertOldStyleModel(testCase);
assert(isequal(converted.subSystems, {'1'; '2'}));
testCase.subSystems = {{'first'}; {'second'}};
converted = convertOldStyleModel(testCase);
assert(isequal(converted.subSystems, {'first'; 'second'}));

%% A model without genes gets a rxnGeneMat of the right size, and an empty genes field 0 x 1
testCase = toyModel;
testCase.genes = {};
testCase.rxnGeneMat = zeros(2, 3);
converted = convertOldStyleModel(testCase);
assert(isequal(size(converted.rxnGeneMat), [2, 0]));
assert(isequal(size(converted.genes), [0, 1]));

%% Compartments and identifiers that were stored as chars and numbers become cell arrays of text
testCase = toyModel;
testCase.comps = 'ce';
testCase.metChEBIID = [15377; 16236; 17234];
testCase.metPubChemID = [962; NaN; 5793];
converted = convertOldStyleModel(testCase);
assert(isequal(converted.comps, {'c'; 'e'}));
assert(isequal(converted.metChEBIID, {'15377'; '16236'; '17234'}));
assert(isequal(converted.metPubChemID, {'962'; ''; '5793'}));

% a cell array that mixes numbers and text
testCase = toyModel;
testCase.metChEBIID = {15377; '16236'; 17234};
converted = convertOldStyleModel(testCase);
assert(isequal(converted.metChEBIID, {'15377'; '16236'; '17234'}));

%% Reaction names and rules stored as several entries are joined
testCase = toyModel;
testCase.rxnNames = {{'name one', 'name two'}; 'name three'};
testCase.grRules = {{'g1', 'g2'}; ''};
testCase.rules = {'x(1) | x(2)'; ''};
converted = convertOldStyleModel(testCase);
assert(isequal(converted.rxnNames, {sprintf('name one\nname two'); 'name three'}));
assert(isequal(converted.grRules, {'g1 or g2'; ''}));

%% Rules left empty next to existing grRules are generated
testCase = toyModel;
testCase.grRules = {'g1'; 'g2'};
testCase.rules = {''; ''};
converted = convertOldStyleModel(testCase);
assert(contains(converted.rules{1}, 'x(1)') && contains(converted.rules{2}, 'x(2)'));

%% The invalid rule of Recon2, at its reaction 2173, is corrected in rules and grRules
reconRule = ['(x(1039)) | (x(1040)) | (x(1041)) | (x(1042)) | (x(1043)) | (x(1044)) | (x(1045)) | ', ...
    '(x(1046)) | (x(1047)) | (x(1048)) | (x(1049)) | (x(1050)) | ()'];
nReconRxns = 2173;
reconSized = struct;
reconSized.mets = {'m1'};
reconSized.rxns = arrayfun(@(k) sprintf('r%d', k), (1:nReconRxns)', 'UniformOutput', false);
reconSized.S = sparse(1, nReconRxns);
reconSized.lb = zeros(nReconRxns, 1);
reconSized.ub = ones(nReconRxns, 1);
reconSized.c = zeros(nReconRxns, 1);
reconSized.b = 0;
reconSized.genes = arrayfun(@(k) sprintf('g%d', k), (1:1050)', 'UniformOutput', false);
reconSized.rules = repmat({''}, nReconRxns, 1);
reconSized.rules{nReconRxns} = reconRule;
converted = convertOldStyleModel(reconSized);
assert(strcmp(converted.rules{nReconRxns}, strrep(reconRule, ' | ()', '')));
assert(contains(converted.grRules{nReconRxns}, 'g1050') && ~contains(converted.grRules{nReconRxns}, '()'));

% output a success message
fprintf('Done.\n');

% change the directory
cd(currentDir)
