% The COBRAToolbox: testPopulateModelwithRxnIDs.m
%
% Purpose:
%     - populateModelwithRxnIDs fills the reaction cross-reference fields rxnECNumbers,
%       rxnKEGGID, rxnMetaNetXID, rxnSEEDID and rxnRheaID of a model from the VMH reaction list
%       (src/reconstruction/metaboRePort/VMH_reactionList.xlsx, matched on the abbreviation
%       column) and then overwrites rxnSEEDID with the DEMETER seed translation
%       (ReactionTranslationTable.txt) where the reaction is listed there. The test builds a
%       five-reaction model whose identifiers reach every branch: a reaction with text and
%       missing (NaN, '\N') entries (PFK), a numeric Rhea identifier (HEX1, which also has two
%       seed translations), an exchange whose entries are all '\N' (EX_glc_D(e)), a reaction
%       only in the seed table (10DMMCNFDOR) and one in neither (r1). The expected identifiers
%       were read from the two files with a separate reader (Python pandas), not with the
%       function's own code.
%
% Function under test:
%     src/reconstruction/metaboRePort/populateModelwithRxnIDs.m
%     (a second file of this name, src/reconstruction/metaboRePort/other/populateModelwithRxnIDs.m,
%     is shadowed by this one on the MATLAB path and is not tested)
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model annotation of a five-reaction model built with createModel; no solver.
%     The seed translation table is read from the papers submodule
%     (papers/2021_demeter/input); the test is skipped when it is not on the path.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

global CBT_MISSING_REQUIREMENTS_ERROR_ID

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPopulateModelwithRxnIDs'));
cd(fileDir);

% declare the requirements of this test. This test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the function reads ReactionTranslationTable.txt from the MATLAB path (papers submodule)
if isempty(which('ReactionTranslationTable.txt'))
    cd(currentDir);
    error(CBT_MISSING_REQUIREMENTS_ERROR_ID, 'ReactionTranslationTable.txt (papers submodule) is not on the path.');
end

% a five-reaction model; the identifiers select the branches described in the header
rxnIDs = {'PFK'; 'HEX1'; 'EX_glc_D(e)'; '10DMMCNFDOR'; 'r1'};
formulas = {'A[c] -> B[c]'; 'B[c] -> C[c]'; 'A[c] <=> '; 'C[c] -> D[c]'; 'D[c] -> '};
model = createModel(rxnIDs, rxnIDs, formulas);

% existing values that the function must overwrite (PFK is in the VMH list, r1 is not)
model.rxnECNumbers = {'old'; ''; ''; ''; 'old r1'};
model.rxnSEEDID = {'old'; ''; ''; ''; 'old r1'};

%% identifiers from the VMH list and the seed translation table

modelUpdated = populateModelwithRxnIDs(model);

% PFK: text entries are copied, NaN (keggId) and '\N' (rhea) give '', seed from both files
% HEX1: the numeric Rhea identifier 17828 becomes the text '17828'; of its two seed
%       translations (rxn00216 and rxn15249) the first one in the table is kept
% EX_glc_D(e): every entry is '\N', so all are ''; the seed table translates it to EX_cpd00027
% 10DMMCNFDOR: not in the VMH list, so all are ''; the seed table gives rxn04324
% r1: in neither file, so every field is '' (existing values are overwritten)
expected.rxnECNumbers = {'2.7.1.11'; '2.7.1.1, 2.7.1.2'; ''; ''; ''};
expected.rxnKEGGID = {''; 'R00299'; ''; ''; ''};
expected.rxnMetaNetXID = {'MNXR102507'; 'MNXR100612'; ''; ''; ''};
expected.rxnSEEDID = {'rxn00545'; 'rxn00216'; 'EX_cpd00027'; 'rxn04324'; ''};
expected.rxnRheaID = {''; '17828'; ''; ''; ''};
fieldsSet = fieldnames(expected);
for k = 1:numel(fieldsSet)
    assert(isequal(modelUpdated.(fieldsSet{k}), expected.(fieldsSet{k})), fieldsSet{k});
end

%% structural consistency: only the five identifier fields change

% every new field has one entry per reaction; S, rxns, mets and the bounds are unchanged
for k = 1:numel(fieldsSet)
    assert(isequal(size(modelUpdated.(fieldsSet{k})), [numel(model.rxns), 1]));
end
assert(isequal(setdiff(fieldnames(modelUpdated), fieldnames(model)), ...
    {'rxnKEGGID'; 'rxnMetaNetXID'; 'rxnRheaID'}));
otherFields = setdiff(fieldnames(model), fieldsSet);
for k = 1:numel(otherFields)
    assert(isequal(modelUpdated.(otherFields{k}), model.(otherFields{k})), otherFields{k});
end

% change the directory
cd(currentDir)
