% The COBRAToolbox: testFastGapFill.m
%
% Purpose:
%     - testFastGapFill tests the fastGapFill function
%
% Author:
%     - CI: integration: Laurent Heirendt - March 2017

global path_ILOG_CPLEX

% define the path to The COBRAToolbox
pth = which('initCobraToolbox.m');
CBTDIR = pth(1:end - (length('initCobraToolbox.m') + 1));

initTest([CBTDIR filesep 'test' filesep 'verifiedTests' filesep 'testFastGapFill'])

% ILOG CPLEX libraray must be included
addpath(genpath(path_ILOG_CPLEX))

%Specify test files
modelFile = 'fgf_test_model.xml';
dbFile = 'fgf_test_rxn_db.lst';
dictFile = 'fgf_test_dict.tsv';
listCompartments = {'[c]'};

fprintf('Testing FastGapFill ...\n');

%Test DB import
U_model = createUniversalReactionModel2(dbFile, []);
rxnCount = length(U_model.rxns);
metCount = length(U_model.mets);
assert(rxnCount == 3 && metCount == 5);

%Test dict conversion
file_handle = fopen(dictFile);
u = textscan(file_handle,'%s\t%s');
dictionary = {};
for i = 1:length(u{1})
    dictionary{i,1} = u{1}{i};
    dictionary{i,2} = u{2}{i};
end
fclose(file_handle);

translated_model = transformKEGG2Model(U_model, dictionary);

assert(sum(cellfun(@(s) ~isempty(strfind('A[c]', s)), translated_model.mets)) == 1);

%Test SUX creation
modelFull = readCbModel(modelFile);
changeCobraSolver('glpk');
if ~exist('modelFull.subSystems') || length(modelFull.subSystems) ~= length(modelFull.rxnNames)
    modelFull.subSystems = repmat({''},length(modelFull.rxnNames));
end
if ~exist('modelFull.genes')
    modelFull.genes = repmat({'no_gene'},1);
end
if ~exist('modelFull.rxnGeneMat')
    modelFull.rxnGeneMat = zeros(length(modelFull.rxnNames),1);
end
if ~exist('modelFull.grRules')
    modelFull.grRules = repmat({''},length(modelFull.rxnNames));
end
[modelConsistent, ~] = identifyBlockedRxns(modelFull, 1e-4);

MatricesSUX = generateSUXComp(modelConsistent, dictionary, dbFile, [], listCompartments);

rxnCount = length(MatricesSUX.rxns);
metCount = length(MatricesSUX.mets);
assert(rxnCount == 23 && metCount == 14);

changeCobraSolver('glpk');

%Test full FastGapFill
[AddedRxns] = submitFastGapFill(modelFile, dbFile, dictFile, [], 'test_sampleWeights.tsv', true, [], [], listCompartments);

assert(sum(cellfun(@(s) ~isempty(strfind('RXN1013', s)), AddedRxns.rxns)) == 1)

delete KEGGMatrix.mat;

% change the directory
cd(CBTDIR)
