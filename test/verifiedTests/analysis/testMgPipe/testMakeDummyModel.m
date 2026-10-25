% The COBRAToolbox: testMakeDummyModel.m
%
% Purpose:
%     - makeDummyModel creates an empty COBRA model structure with the requested number of
%     metabolites and reactions.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/makeDummyModel.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMakeDummyModel'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

dummy = makeDummyModel(3, 2);

%% sizes of the numeric fields

assert(isequal(size(dummy.S), [3 2]) && all(dummy.S(:) == 0));
assert(isequal(size(dummy.c), [2 1]) && isequal(size(dummy.lb), [2 1]) && isequal(size(dummy.ub), [2 1]));
assert(isequal(size(dummy.b), [3 1]) && isequal(size(dummy.metCharge), [3 1]));

%% metabolite and reaction annotation fields are empty cells of the right size

metFields = {'mets', 'metNames', 'metFormulas', 'metCHEBIID', 'metHMDB', 'metInchiString', 'metKeggID', 'metSmile', 'metPubChemID'};
for i = 1:numel(metFields)
    assert(iscell(dummy.(metFields{i})) && isequal(size(dummy.(metFields{i})), [3 1]), metFields{i});
end
rxnFields = {'rxns', 'rxnNames', 'subSystems', 'rules', 'grRules', 'comments', 'citations', ...
             'confidenceScores', 'ecNumbers', 'rxnKeggID'};
for i = 1:numel(rxnFields)
    assert(iscell(dummy.(rxnFields{i})) && isequal(size(dummy.(rxnFields{i})), [2 1]), rxnFields{i});
end

%% genes, gene matrix, description and disabled list

assert(isempty(dummy.genes));
assert(issparse(dummy.rxnGeneMat) && isequal(size(dummy.rxnGeneMat), [2 0]));
assert(isequal(fieldnames(dummy.description), {'organism'; 'author'; 'name'; 'geneindex'; 'genedate'; 'genesource'; 'notes'}));
assert(isempty(dummy.disabled));

%% a model without metabolites or reactions

empty = makeDummyModel(0, 0);
assert(isempty(empty.S) && isempty(empty.mets) && isempty(empty.rxns));

% change the directory
cd(currentDir)
