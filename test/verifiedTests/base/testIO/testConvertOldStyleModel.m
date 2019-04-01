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

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testConvertOldStyleModel'));
cd(fileDir);
% prepare the test, i.e. require LP solver
solverPkgs = prepareTest('needsLP',true,'useMinimalNumberOfSolvers',true);

changeCobraSolver(solverPkgs.LP{1},'LP');
% Test with 
fprintf('>> Testing Model conversion and field merging:\n');
%Explicitly load the model by load to ensure that its an old style model
%that we can convert.
load('Abiotrophia_defectiva_ATCC_49176','model')

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


model.metHMDBID = {'Lets','Test','Something'};

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
assert(isequal(solWithA.obj,sol.f))
warning on
modelConverted = convertOldStyleModel(modelWithA);
% assert that the proper warning was shown
warnmessage = 'The inserted Model contains an old style coupling matrix (A). The MAtrix will be converted into a Coupling Matrix (C) and fields will be adapted.';
assert(isequal(warnmessage,lastwarn));
% the two models with added constraints and converted A should be the same.
assert(isSameCobraModel(modelConverted,modelWithConstraints));

[nMets,nRxns] = size(testModel.S);
% now, test partially invalid old style fields
testModel.confidenceScores = arrayfun(@num2str, randi(4,nRxns,1),'Uniform',0);
testModel.confidenceScores(3) = {[]};
testModel.subSystems(10) = {[]};
assert(~verifyModel(testModel,'simpleCheck',true));
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

% change the directory
cd(currentDir)
