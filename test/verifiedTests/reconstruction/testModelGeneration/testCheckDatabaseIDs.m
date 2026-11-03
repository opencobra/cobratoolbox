% The COBRAToolbox: testCheckDatabaseIDs.m
%
% Purpose:
%     - checkDatabaseIDs checks every database identifier field of a model (as defined by the
%       toolbox field definitions) against the identifier pattern of its database; an entry with
%       several identifiers separated by ; is valid only if each one matches, and an empty entry
%       is valid. For every field with at least one invalid entry it stores, in
%       results.checkDatabaseIDs.invalidIDs.<field>, a copy of the field in which the valid
%       entries are replaced by the text valid. Other content of results is kept.
%       Characterization test that PINS the current behaviour (feature
%       20261103-105830-tier2-safe-batch, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Reference values: the fields and invalid counts asserted below were recorded from the
%       first run on 2026-11-03 with Abiotrophia_defectiva_ATCC_49176 (no solver). They were not
%       derived independently, so they guard consistency, not independent correctness (Tier 5).
%       The invalid entries are also characterized independently: the ChEBI identifiers lack the
%       CHEBI: prefix, most InChI strings are stored cut short (they end with the text
%       "... <Preview truncated at 128 characters>"), three lack the InChI= prefix, and the one
%       invalid PubChem identifier is a KEGG compound identifier.
%     - Four complete InChI strings with an undefined stereo centre (?) are also reported
%       invalid (defect below); the test asserts neither that they are reported nor that they are
%       not, and the InChI count is therefore not asserted as a whole.
%     - The AGORA model Abiotrophia_defectiva_ATCC_49176 is used because ecoli_core_model has no
%       database identifier fields. The model without database fields and the identifiers with
%       a separator are built in the test from the loaded model.
%
% Function under test:
%     src/reconstruction/modelGeneration/modelVerification/checkDatabaseIDs.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model verification, no solver; Abiotrophia_defectiva_ATCC_49176 loaded through
%     getDistributedModel.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Standard InChI strings with an undefined stereo centre are reported invalid
%       SEVERITY: wrong-result
%       TRIGGER: checkDatabaseIDs(model, struct()) on Abiotrophia_defectiva_ATCC_49176, whose
%         metabolites 100, 241, 509 and 510 have complete InChI strings with ? in the /t layer
%       OBSERVED: the metInChIString pattern of the field definitions
%         (src/base/io/definitions/COBRA_structure_fields.tab, line 24) does not allow ?, so the
%         four strings are listed in invalidIDs.metInChIString
%       EXPECTED: valid InChI strings accepted; the InChI pattern of generateMetaboScore allows ?
%       LINES: 26
%
% Authors:
%     - Generated for feature 20261103-105830-tier2-safe-batch, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCheckDatabaseIDs'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system, so none is listed
prepareTest();

% load the model once (1073 reactions, 955 metabolites)
model = getDistributedModel('Abiotrophia_defectiva_ATCC_49176.mat');

%% the invalid identifiers of the model are reported per field

results = checkDatabaseIDs(model, struct('otherCheck', 5));

% other content of results is kept
assert(isequal(results.otherCheck, 5));

% Tier-5 reference (first run, 2026-11-03): three of the seven database fields of the model
% have invalid entries; metHMDBID and metKEGGID are valid and rxnECNumbers and rxnKEGGID are
% empty
invalidIDs = results.checkDatabaseIDs.invalidIDs;
assert(isequal(fieldnames(invalidIDs), {'metInChIString'; 'metChEBIID'; 'metPubChemID'}));
assert(all(isfield(model, {'metHMDBID', 'metKEGGID', 'rxnECNumbers', 'rxnKEGGID'})));
fields = fieldnames(invalidIDs);
isInvalid = cellfun(@(f) ~strcmp(invalidIDs.(f), 'valid'), fields, 'UniformOutput', false);
assert(nnz(isInvalid{2}) == 429 && nnz(isInvalid{3}) == 1);

% every reported field has the size of the model field; the invalid entries are copied from the
% model and the others are the text valid; no empty entry is reported as invalid
for i = 1:numel(fields)
    reported = invalidIDs.(fields{i});
    assert(isequal(size(reported), size(model.(fields{i}))));
    assert(isequal(reported(isInvalid{i}), model.(fields{i})(isInvalid{i})));
    assert(all(~cellfun(@isempty, reported(isInvalid{i}))));
end

% the invalid ChEBI identifiers are exactly the non-empty ones, all digits without the CHEBI:
% prefix
assert(isequal(isInvalid{2}, ~cellfun(@isempty, model.metChEBIID)));
assert(all(~cellfun(@isempty, regexp(model.metChEBIID(isInvalid{2}), '^\d+$'))));

% every InChI string that is stored cut short or lacks the InChI= prefix is reported (Tier-5
% counts, first run 2026-11-03), and every other reported one has an undefined stereo centre
% (the defect in the header; those four are not asserted either way)
inchi = model.metInChIString;
isCut = contains(inchi, '<Preview truncated');
isUnprefixed = ~cellfun(@isempty, inchi) & ~strncmp(inchi, 'InChI=', 6);
assert(nnz(isCut) == 145 && nnz(isUnprefixed & ~isCut) == 3);
assert(all(isInvalid{1}(isCut | isUnprefixed)));
assert(all(contains(inchi(isInvalid{1} & ~isCut & ~isUnprefixed), '?')));

% the invalid PubChem identifier is a KEGG compound identifier
assert(isequal(model.metPubChemID(isInvalid{3}), {'C02737'}));

%% a second call with the results of the first gives the same results

firstResults = checkDatabaseIDs(model, struct());
assert(isequal(checkDatabaseIDs(model, firstResults), firstResults));

%% identifiers separated by ; are valid only if each one is valid

% the first two metabolites with a KEGG identifier get two identifiers each, one pair valid and
% one pair with an invalid identifier
keggModel = model;
withKegg = find(~cellfun(@isempty, keggModel.metKEGGID), 2);
keggModel.metKEGGID{withKegg(1)} = 'C00031;C00221';
keggModel.metKEGGID{withKegg(2)} = 'C00031;glucose';
results = checkDatabaseIDs(keggModel, struct());
expectedKegg = repmat({'valid'}, size(keggModel.metKEGGID));
expectedKegg(withKegg(2)) = {'C00031;glucose'};
assert(isequal(results.checkDatabaseIDs.invalidIDs.metKEGGID, expectedKegg));

%% a model without database identifier fields leaves results unchanged

dbFields = getDefinedFieldProperties('Database', true);
plainModel = rmfield(model, intersect(fieldnames(model), dbFields(:, 3)));
assert(isequal(checkDatabaseIDs(plainModel, struct('otherCheck', 5)), struct('otherCheck', 5)));
assert(isequal(checkDatabaseIDs(plainModel, struct()), struct()));

% change the directory
cd(currentDir)
