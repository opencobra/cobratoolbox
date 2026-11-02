% The COBRAToolbox: testCoreMetRxnAnalysis.m
%
% Purpose:
%     - coreMetRxnAnalysis compares a model before and after a deletion step, reports which core
%     metabolites and reactions were deleted, and returns the core sets without the deleted or
%     missing entries.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch4, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Defect(s) fixed by feature 20261102-140321-tier1-safe-defect-fixes: The deleted reactions
%       are not computed when the old model is empty and no deletion lists are given.
%
% Function under test:
%     src/dataIntegration/XomicsToModel/analysis/coreMetRxnAnalysis.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A given list of deleted metabolites is discarded when the old model is empty and no
%         deleted reactions are given
%       SEVERITY: wrong-result
%       TRIGGER: an empty old model, a non-empty deletedMets and an empty deletedRxns, for example
%         coreMetRxnAnalysis([], model, coreMets, coreRxns, {'c'}, [])
%       OBSERVED: the branch that fills the missing deletedRxns also sets deletedMets to empty, so
%         the given deleted metabolites are not counted as deleted and core metabolites among them
%         are reported as missing from the old model instead
%       EXPECTED: the given deletedMets is kept
%       LINES: 52
%
% Authors:
%     - Generated for feature tier1-test-batch4, 2026-10-13.
%     - Updated for feature 20261102-140321-tier1-safe-defect-fixes, 2026-11-02.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCoreMetRxnAnalysis'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% old model: metabolites a-d, reactions r1-r3; new model keeps a, b and r1
oldModel.mets = {'a'; 'b'; 'c'; 'd'};
oldModel.metNames = {'A'; 'B'; 'C'; 'D'};
oldModel.rxns = {'r1'; 'r2'; 'r3'};
oldModel.lb = [0; 0; 0];
oldModel.ub = [1; 1; 1];
oldModel.S = eye(4, 3);
oldModel.c = zeros(3, 1);
newModel = oldModel;
newModel.mets = {'a'; 'b'};
newModel.rxns = {'r1'};

%% core sets without the deleted entries

[coreMets, coreRxns] = coreMetRxnAnalysis(oldModel, newModel, {'a', 'c'}, {'r1', 'r2'});
% c and r2 were deleted
assert(isequal(coreMets, {'a'}));
assert(isequal(coreRxns, {'r1'}));

%% messages at print level 1

text = evalc("coreMetRxnAnalysis(oldModel, newModel, {'a', 'c'}, {'r1', 'r2'}, [], [], struct('printLevel', 1));");
assert(contains(text, '1 deleted non-core metabolites,  corresponding to deletion.'));
assert(contains(text, '1 deleted core metabolites,  corresponding to deletion.'));
assert(contains(text, '1 deleted non-core reactions,  corresponding to deletion.'));
assert(contains(text, '1 deleted core reactions,  corresponding to deletion.'));
% the deleted core metabolite is shown with its name
assert(contains(text, 'metNames') && contains(text, 'C'));

%% print level above 2 lists the deleted non-core entries and uses the given message

param = struct('printLevel', 3, 'message', 'filtering');
text = evalc("coreMetRxnAnalysis(oldModel, newModel, {'a', 'c'}, {'r1', 'r2'}, [], [], param);");
assert(contains(text, 'corresponding to filtering.'));
% the deleted non-core metabolite d and the deleted non-core reaction r3 are shown
assert(contains(text, 'd') && contains(text, 'r3'));

%% core entries that the old model does not contain are removed

text = evalc("[coreMets, coreRxns] = coreMetRxnAnalysis(oldModel, newModel, {'a', 'zz'}, {'r1', 'zz'});");
assert(contains(text, 'Old model does not contain these core metabolites'));
assert(contains(text, 'Old model does not contain these core reactions'));
assert(isequal(coreMets, {'a'}) && isequal(coreRxns, {'r1'}));

%% core entries that are not deleted but missing from the current model produce warnings

% deletion lists are given, but the current model lacks the metabolite b and the reaction r2 as well
smallModel = oldModel;
smallModel.mets = {'a'};
smallModel.rxns = {'r1'};
lastwarn('');
text = evalc("[coreMets, coreRxns] = coreMetRxnAnalysis(oldModel, smallModel, {'a', 'b'}, {'r1', 'r2'}, {'d'}, {'r3'});");
assert(contains(lastwarn, 'Current model does not contain these reactions from the core reaction set'));
assert(isequal(coreMets, {'a'}) && isequal(coreRxns, {'r1'}));

%% no old model: the deletion lists are used

% row cell arrays are needed because the lists are concatenated horizontally
rowModel.mets = {'a', 'b'};
rowModel.rxns = {'r1'};
[coreMets, coreRxns] = coreMetRxnAnalysis([], rowModel, {'a'}, {'r1'}, {'c'}, {'r2'});
assert(isequal(coreMets, {'a'}) && isequal(coreRxns, {'r1'}));

% only the deleted reactions are given
[coreMets, coreRxns] = coreMetRxnAnalysis([], rowModel, {'a'}, {'r1'}, [], {'r2'});
assert(isequal(coreMets, {'a'}) && isequal(coreRxns, {'r1'}));

% with printing, the deleted entries are listed
text = evalc("coreMetRxnAnalysis([], rowModel, {'a'}, {'r1'}, {'c'}, {'r2'}, struct('printLevel', 3));");
assert(contains(text, '1 deleted non-core reactions'));
assert(contains(text, '0 deleted core metabolites') && contains(text, '0 deleted core reactions'));

% no old model and no deletion lists: nothing is deleted, the core sets are kept
[coreMets, coreRxns] = coreMetRxnAnalysis([], rowModel, {'a'}, {'r1'});
assert(isequal(coreMets, {'a'}) && isequal(coreRxns, {'r1'}));
% with the empty lists passed explicitly (needed to give a print level) the printed counts show
% that the list of deleted reactions is empty
text =evalc("coreMetRxnAnalysis([], rowModel, {'a'}, {'r1'}, [], [], struct('printLevel', 1));");
assert(contains(text, '0 deleted non-core reactions') && contains(text, '0 deleted core reactions'));

%% no metabolites deleted

sameMets = oldModel;
sameMets.rxns = {'r1'};
[coreMets, ~] = coreMetRxnAnalysis(oldModel, sameMets, {'a'}, {'r1'});
assert(isequal(coreMets, {'a'}));
text = evalc("coreMetRxnAnalysis(oldModel, sameMets, {'a'}, {'r1'}, [], [], struct('printLevel', 1));");
assert(contains(text, '0 deleted non-core metabolites') && contains(text, '0 deleted core metabolites'));

%% an empty core metabolite set

[coreMets, ~] = coreMetRxnAnalysis(oldModel, newModel, [], {'r1'});
assert(isempty(coreMets));

% change the directory
cd(currentDir)
