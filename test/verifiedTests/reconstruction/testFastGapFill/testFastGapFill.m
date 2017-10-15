% The COBRAToolbox: testFastGapFill.m
%
% Purpose:
%     - testFastGapFill tests the fastGapFill function
%
% Author:
%     - CI: integration: Laurent Heirendt - March 2017

% FASTCORE functions must have the CPLEX library included in order to run
global ILOG_CPLEX_PATH

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFastGapFill'));
cd(fileDir);

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
solverOK = changeCobraSolver('glpk');
if solverOK
    if ~exist('modelFull.subSystems') || length(modelFull.subSystems) ~= length(modelFull.rxnNames)
        modelFull.subSystems = repmat({''},size(modelFull.rxns));
    end
    if ~exist('modelFull.genes')
        modelFull.genes = {};
    end
    if ~exist('modelFull.rxnGeneMat')
        modelFull.rxnGeneMat = false(0,length(modelFull.rxnNames));
    end
    if ~exist('modelFull.grRules')
        modelFull.grRules = repmat({''},size(modelFull.rxns));
    end
    [modelConsistent, ~] = identifyBlockedRxns(modelFull, 1e-4);

    MatricesSUX = generateSUXComp(modelConsistent, dictionary, dbFile, [], listCompartments);

    rxnCount = length(MatricesSUX.rxns);
    metCount = length(MatricesSUX.mets);
    assert(rxnCount == 23 && metCount == 14);
end

%test solver packages
solverPkgs = {'ibm_cplex'};

for k = 1:length(solverPkgs)

    fprintf('   Running testFastGapFill using %s ... ', solverPkgs{k});

    solverOK  = changeCobraSolver(solverPkgs{k}, 'LP', 0);

    if solverOK
        %Test full FastGapFill
        [AddedRxns] = submitFastGapFill(modelFile, dbFile, dictFile, [], 'test_sampleWeights.tsv', true, [], [], listCompartments);

        assert(sum(cellfun(@(s) ~isempty(strfind('RXN1013', s)), AddedRxns.rxns)) == 1)

        delete KEGGMatrix.mat;
    end

    % print a success message
    fprintf('Done.\n')
end

% change the directory
cd(currentDir)
