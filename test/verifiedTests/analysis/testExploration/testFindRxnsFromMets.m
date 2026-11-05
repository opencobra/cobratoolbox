% The COBRAToolbox: testFindRxnsFromMets.m
%
% Purpose:
%     - Tests the functionality of findRxnFromMets with all available
%     parameters
%
% Function under test:
%     src/analysis/exploration/findRxnsFromMets.m
%
% Tier (Constitution III-Coverage):
%     Tier 3 - optimisation (only for minimalReactionN, which needs an LP solver); ecoli_core_model
%     loaded through getDistributedModel. Assertions on minimalReactionN check that every requested
%     metabolite is covered, because the cardinality solution need not be unique.
%
% Coverage exemptions:
%     None. Every other executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The documented positional printFlag alone stops with an error
%       SEVERITY: error
%       TRIGGER: findRxnsFromMets(model, metList, printFlag) with no parameter/value pair after it
%       OBSERVED: varargin keeps its single element, so inputParser fails with "Expected a string
%         scalar or character vector for the parameter name"
%       EXPECTED: the reactions are returned and printed, as in the USAGE line
%       LINES: 50-52, 64
%     - DEFECT: The parameter verbFlag can never be used
%       SEVERITY: unusable-option
%       TRIGGER: findRxnsFromMets(model, metList, 'verbFlag', 1)
%       OBSERVED: the validator calls isnumeric without an argument, so parsing fails with "The value
%         of 'verbFlag' is invalid"; the branch behind it also reads the misspelt field verbFag
%       EXPECTED: verbFlag is accepted as the backward compatible name of printFlag
%       LINES: 60, 68-69, 71
%     - DEFECT: exclusive stops with an error together with the direction or minimal options
%       SEVERITY: error
%       TRIGGER: 'exclusive' true together with 'producersOnly', 'consumersOnly' or
%         'minimalReactionN', for example findRxnsFromMets(model, mets, 'exclusive', true,
%         'producersOnly', true)
%       OBSERVED: rels is a column in those branches and others a row, so implicit expansion gives
%         an n x n matrix and indexing model.rxns fails
%       EXPECTED: the reactions that meet both options are returned
%       LINES: 136, 145
%
% Authors:
%     - Original file: Thomas Pfau Jan 2018
%     - Coverage completed by feature 20261104-115314-test-coverage-100, 2026-11-04.
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testFindRxnsFromMets'));
cd(fileDir);

% an LP solver is needed for the option minimalReactionN
prepareTest('needsLP', true);

% load model
model = getDistributedModel('ecoli_core_model.mat');

% Initialize the test
fprintf(' -- Running testFindRxnsFromMets ... \n');

% First, find all reactions involved with 3pg
singleTestMet = model.mets{3};
involvedReacs = {'Biomass_Ecoli_core_w_GAM';'PGK';'PGM'};
consuming = involvedReacs;
producing = involvedReacs(2:3);
reacs = findRxnsFromMets(model,singleTestMet);
assert(isempty(setxor(involvedReacs,reacs)));
reacs = findRxnsFromMets(model,singleTestMet,'consumersOnly',true);
assert(isempty(setxor(consuming,reacs)));
reacs = findRxnsFromMets(model,singleTestMet,'producersOnly',true);
assert(isempty(setxor(producing,reacs)));

% now, we change the bounds of PGK to not function in the forward direction
modelChanged = changeRxnBounds(model,'PGK',0,'l');
modelChanged = changeRxnBounds(modelChanged,'PGM',0,'u');
reacs = findRxnsFromMets(modelChanged,singleTestMet,'producersOnly',true);
assert(isempty(reacs));

% now, test the same with consumers and the PGM reaction, only biomass is
% left.
modelChanged = changeRxnBounds(model,'PGM',0,'l');
modelChanged = changeRxnBounds(modelChanged,'PGK',0,'u');
reacs = findRxnsFromMets(modelChanged,singleTestMet,'consumersOnly',true);
assert(isempty(setxor(involvedReacs(1),reacs)));

% lets test 2 metabolites (2pg and 3pg)
dualTestMet = model.mets(2:3);
involvedReacs = {'Biomass_Ecoli_core_w_GAM';'ENO';'PGM';'PGK'};
consuming = involvedReacs;
producing = involvedReacs(2:4);
reacs = findRxnsFromMets(model,dualTestMet);
assert(isempty(setxor(involvedReacs,reacs)));
reacs = findRxnsFromMets(model,dualTestMet,'consumersOnly',true);
assert(isempty(setxor(consuming,reacs)));
reacs = findRxnsFromMets(model,dualTestMet,'producersOnly',true);
assert(isempty(setxor(producing,reacs)));

% test printout.
% build comparison text
res = printRxnFormula(model,'PGM');
compText = res{1}; % this is sufficient;

% create diary
diaryFile = 'RxnsFromMetTest';
diary(diaryFile)
reacs = findRxnsFromMets(model,dualTestMet,'containsAll',true,'printFlag',1);
assert(isempty(setxor({'PGM'},reacs)));
diary off
text = importdata(diaryFile);
assert(~isempty(strfind(strrep(text,'\n',''),compText)));
%cleanup
delete(diaryFile);


% test implicit printOut is silent, if no output is created
diary(diaryFile)
[reacs,forms] = findRxnsFromMets(model,dualTestMet,'containsAll',true);
diary off;
text = importdata(diaryFile);
% ITs not found in the output
assert(isempty(strfind(text,compText)));
% but is equal to printRxnFormula
assert(isequal(forms,res))
%cleanup
delete(diaryFile);

%% a positional printFlag followed by parameter/value pairs prints the formulas
printed = evalc('reacs = findRxnsFromMets(model, dualTestMet, 1, ''containsAll'', true);');
assert(isempty(setxor({'PGM'}, reacs)));
% the printed formula has tabs around the arrow
assert(contains(printed, sprintf('PGM\t2pg[c] \t<=>\t3pg[c]')));

%% producersOnly and consumersOnly together keep every reaction that can do either
reacs = findRxnsFromMets(model, singleTestMet, 'producersOnly', true, 'consumersOnly', true);
assert(isempty(setxor({'Biomass_Ecoli_core_w_GAM'; 'PGK'; 'PGM'}, reacs)));
% a closed reaction can do neither and is dropped
modelChanged = changeRxnBounds(model, 'PGK', 0, 'b');
reacs = findRxnsFromMets(modelChanged, singleTestMet, 'producersOnly', true, 'consumersOnly', true);
assert(isempty(setxor({'Biomass_Ecoli_core_w_GAM'; 'PGM'}, reacs)));

%% exclusive keeps only the reactions without any other metabolite
reacs = findRxnsFromMets(model, dualTestMet, 'exclusive', true);
assert(isempty(setxor({'PGM'}, reacs)));

%% a metabolite that is not in the model gives empty lists, also for the formulas
[reacs, forms] = findRxnsFromMets(model, 'notAMetabolite');
assert(isempty(reacs));
assert(isempty(forms));

%% minimalReactionN covers every metabolite with few reactions
% PGM alone holds both metabolites (the cardinality solution is unique here)
reacs = findRxnsFromMets(model, dualTestMet, 'minimalReactionN', true);
assert(isempty(setxor({'PGM'}, reacs)));

% without PGM among the consistent reactions, two other reactions must cover the metabolites
modelChanged = model;
modelChanged.SConsistentRxnBool = ~strcmp(model.rxns, 'PGM');
reacs = findRxnsFromMets(modelChanged, dualTestMet, 'minimalReactionN', true);
assert(~ismember('PGM', reacs));
assert(all(any(model.S(ismember(model.mets, dualTestMet), ismember(model.rxns, reacs)) ~= 0, 2)));

% the same restriction through SIntRxnBool
modelChanged = rmfield(modelChanged, 'SConsistentRxnBool');
modelChanged.SIntRxnBool = ~strcmp(model.rxns, 'PGM');
reacs = findRxnsFromMets(modelChanged, dualTestMet, 'minimalReactionN', true);
assert(~ismember('PGM', reacs));
assert(all(any(model.S(ismember(model.mets, dualTestMet), ismember(model.rxns, reacs)) ~= 0, 2)));

% Print a success message
fprintf('Done.\n');

% change the directory
cd(currentDir)
