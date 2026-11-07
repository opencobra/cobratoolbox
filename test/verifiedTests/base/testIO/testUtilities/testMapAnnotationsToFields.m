% The COBRAToolbox: testMapAnnotationsToFields.m
%
% Purpose:
%     - mapAnnotationsToFields turns the MIRIAM annotations of the entities of one type (as
%       parsed from SBML by parseCVTerms: per entity a list of databases, identifiers and
%       bio-qualifiers) into model fields: a database and qualifier with a known field (for
%       example kegg.compound with is -> metKEGGID) fill that field, any other one fills a field
%       <type><qualifier><database>ID; several identifiers of one field are joined with '; '. A
%       qualifier selection restricts the qualifiers used: by default to all qualifiers except
%       the selected ones, and inverted to the selected ones only.
%       Characterization test that PINS the current behaviour (feature
%       20261103-105830-tier2-safe-batch, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Abiotrophia_defectiva_ATCC_49176 (AGORA) is used because it is the smallest distributed
%       model with metabolite annotation fields. The annotations are built from the model: per
%       metabolite its KEGG and HMDB identifiers, as parseCVTerms would return them, and a
%       MetaCyc annotation that holds the metabolite identifier. The qualifier cases are built
%       for three entities with KEGG identifiers of the model and an empty structure as model,
%       as readSBML does for the protein annotations.
%     - Reference values: the counts asserted below were recorded from the first run on
%       2026-11-03 with Abiotrophia_defectiva_ATCC_49176 (no solver). They were not derived
%       independently, so they guard consistency, not independent correctness (Tier 5). The
%       fields are also compared with the annotation fields of the model they were built from.
%
% Function under test:
%     src/base/io/utilities/SBML/mapAnnotationsToFields.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; Abiotrophia_defectiva_ATCC_49176 loaded through
%     getDistributedModel.
%
% Coverage exemptions:
%     Line 74, the local function getID: it is never called.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261103-105830-tier2-safe-batch, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMapAnnotationsToFields'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system, so none is listed
prepareTest();

% load the model once (955 metabolites with the annotation fields metKEGGID and metHMDBID, among
% others)
model = getDistributedModel('Abiotrophia_defectiva_ATCC_49176.mat');
nMets = numel(model.mets);

% the annotations of every metabolite as parseCVTerms returns them: column lists of databases,
% identifiers and qualifiers, and empty lists for a metabolite without annotation
databases = cell(1, nMets);
identifiers = cell(1, nMets);
qualifiers = cell(1, nMets);
for i = 1:nMets
    hasId = ~cellfun(@isempty, {model.metKEGGID{i}; model.metHMDBID{i}});
    if any(hasId)
        dbNames = {'kegg.compound'; 'hmdb'};
        ids = {model.metKEGGID{i}; model.metHMDBID{i}};
        databases{i} = dbNames(hasId);
        identifiers{i} = ids(hasId);
        qualifiers{i} = repmat({'is'}, nnz(hasId), 1);
    else
        databases{i} = {};
        identifiers{i} = {};
        qualifiers{i} = {};
    end
end

% the model without the two annotation fields
baseModel = rmfield(model, {'metKEGGID', 'metHMDBID'});

% three entities with KEGG identifiers of the model: the first with two identifiers under the
% two database names of KEGG compounds, the second with the qualifier isRelatedTo, the third
% without annotation
keggId1 = model.metKEGGID{1};
keggId2 = model.metKEGGID{find(~cellfun(@isempty, model.metKEGGID) & ~strcmp(model.metKEGGID, keggId1), 1)};
smallDatabases = {{'kegg.compound'; 'kegg'}, {'kegg.compound'}, {}};
smallIdentifiers = {{keggId1; keggId2}, {keggId2}, {}};
smallQualifiers = {{'is'; 'is'}, {'isRelatedTo'}, {}};

%% known databases fill their model fields

mappedModel = mapAnnotationsToFields(baseModel, databases, identifiers, qualifiers, 'met');

% the two fields are rebuilt exactly as in the model, one entry per metabolite, and nothing else
% changes
assert(isequal(mappedModel.metKEGGID, model.metKEGGID));
assert(isequal(mappedModel.metHMDBID, model.metHMDBID));
assert(isequal(size(mappedModel.metKEGGID), [nMets, 1]));
assert(isequal(rmfield(mappedModel, {'metKEGGID', 'metHMDBID'}), baseModel));

% Tier-5 reference counts (first run, 2026-11-03): 427 metabolites have a KEGG identifier and
% 408 an HMDB identifier
assert(nnz(~cellfun(@isempty, mappedModel.metKEGGID)) == 427);
assert(nnz(~cellfun(@isempty, mappedModel.metHMDBID)) == 408);

%% a database without known field fills a field named after the type, qualifier and database

% every metabolite annotated with its own identifier in MetaCyc, under is and isRelatedTo
metacycIds = cellfun(@(x) {x}, model.mets', 'UniformOutput', false);
metacycDatabases = repmat({{'metacyc.compound'}}, 1, nMets);
mappedModel = mapAnnotationsToFields(baseModel, metacycDatabases, metacycIds, ...
    repmat({{'is'}}, 1, nMets), 'met');
assert(isequal(mappedModel.metismetacyc__46__compoundID, model.mets));
assert(isequal(setdiff(fieldnames(mappedModel), fieldnames(baseModel)), {'metismetacyc__46__compoundID'}));

mappedModel = mapAnnotationsToFields(baseModel, metacycDatabases, metacycIds, ...
    repmat({{'isRelatedTo'}}, 1, nMets), 'met');
assert(isequal(mappedModel.metisRelatedTometacyc__46__compoundID, model.mets));
assert(isequal(setdiff(fieldnames(mappedModel), fieldnames(baseModel)), {'metisRelatedTometacyc__46__compoundID'}));

%% identifiers of one field are joined and every qualifier has its own field

mappedFields = mapAnnotationsToFields(struct(), smallDatabases, smallIdentifiers, smallQualifiers, 'met');

% kegg.compound and kegg both map to metKEGGID with the qualifier is, so the first entity gets
% both identifiers; isRelatedTo has no known field, so the second entity gets a field of its
% own; an entity without annotation gets empty entries
assert(isequal(sort(fieldnames(mappedFields)), {'metKEGGID'; 'metisRelatedTokegg__46__compoundID'}));
assert(isequal(mappedFields.metKEGGID, {[keggId1 '; ' keggId2]; ''; ''}));
assert(isequal(mappedFields.metisRelatedTokegg__46__compoundID, {''; keggId2; ''}));

%% a qualifier selection excludes the selected qualifiers, or keeps only them when inverted

% by default the selected qualifier is is left out
mappedFields = mapAnnotationsToFields(struct(), smallDatabases, smallIdentifiers, smallQualifiers, ...
    'met', {'is'});
assert(isequal(fieldnames(mappedFields), {'metisRelatedTokegg__46__compoundID'}));
assert(isequal(mappedFields.metisRelatedTokegg__46__compoundID, {''; keggId2; ''}));
assert(isequal(mapAnnotationsToFields(struct(), smallDatabases, smallIdentifiers, smallQualifiers, ...
    'met', {'is'}, true), mappedFields));

% with inverseRelationSelection false only the selected qualifier is is used
mappedFields = mapAnnotationsToFields(struct(), smallDatabases, smallIdentifiers, smallQualifiers, ...
    'met', {'is'}, false);
assert(isequal(fieldnames(mappedFields), {'metKEGGID'}));
assert(isequal(mappedFields.metKEGGID, {[keggId1 '; ' keggId2]; ''; ''}));

% no selection uses every qualifier, as in the previous section
assert(isequal(mapAnnotationsToFields(struct(), smallDatabases, smallIdentifiers, smallQualifiers, ...
    'met', {}), mapAnnotationsToFields(struct(), smallDatabases, smallIdentifiers, smallQualifiers, 'met')));

% change the directory
cd(currentDir)
