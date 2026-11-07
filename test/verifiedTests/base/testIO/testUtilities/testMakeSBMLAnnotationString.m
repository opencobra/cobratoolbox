% The COBRAToolbox: testMakeSBMLAnnotationString.m
%
% Purpose:
%     - makeSBMLAnnotationString builds the MIRIAM annotation of one model entity for SBML: every
%       identifier of a known annotation field (for example metKEGGID) that matches the pattern
%       of its database becomes an identifiers.org resource in the bag of its bio-qualifier;
%       identifiers of fields named <field><qualifier><database>ID (written by readSBML for
%       databases without a known field) are used as they are; a known field with an identifier
%       that does not match the pattern is returned in the notes. With mergeAnnotations the
%       resources of several field types are merged into one bag per qualifier.
%       Characterization test that PINS the current behaviour (feature
%       20261103-105830-tier2-safe-batch, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Abiotrophia_defectiva_ATCC_49176 (AGORA) is used because it is the smallest distributed
%       model with metabolite annotation fields. Metabolite 1, 10fthf[c], has valid HMDB, KEGG
%       and PubChem identifiers, and ChEBI and InChI entries that do not match their patterns;
%       metabolite 2 has no annotation. Two inputs are built from the model: a copy with two
%       identifiers in one field, and a copy with a field metismetacyc__46__compoundID that
%       holds the metabolite identifiers (empty for metabolite 2), as readSBML would name a
%       MetaCyc annotation.
%     - Reference values: the string lengths asserted below were recorded from the first run on
%       2026-11-03 with Abiotrophia_defectiva_ATCC_49176 (no solver). They were not derived
%       independently, so they guard consistency (the layout of the string), not independent
%       correctness (Tier 5). The resources and notes are also derived independently from the
%       annotation fields of the model.
%
% Function under test:
%     src/base/io/utilities/SBML/makeSBMLAnnotationString.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; Abiotrophia_defectiva_ATCC_49176 loaded through
%     getDistributedModel.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A field of another is-qualifier is also annotated under the qualifier is
%       SEVERITY: wrong-result
%       TRIGGER: a field named for a qualifier that starts with is, for example
%         metisRelatedTometacyc__46__compoundID holding 10fthf[c] for metabolite 1, with
%         makeSBMLAnnotationString(model, 'M_x', 'met', 1)
%       OBSERVED: the field is selected by prefix, so besides the correct resource
%         http://identifiers.org/metacyc.compound/10fthf[c] in the bag isRelatedTo it also gives
%         http://identifiers.org/RelatedTometacyc.compound/10fthf[c] in the bag is
%       EXPECTED: the field only in the bag of its own qualifier isRelatedTo
%       LINES: 62, 74
%
% Authors:
%     - Generated for feature 20261103-105830-tier2-safe-batch, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMakeSBMLAnnotationString'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system, so none is listed
prepareTest();

% load the model once (1073 reactions, 955 metabolites with the annotation fields metHMDBID,
% metKEGGID, metPubChemID, metChEBIID and metInChIString)
model = getDistributedModel('Abiotrophia_defectiva_ATCC_49176.mat');

% the resources of a string and the start and end of every annotation
getResources = @(s) regexp(s, '(?<=rdf:resource=")[^"]+', 'match')';
annotationStart = sprintf('<annotation xmlns:sbml="http://www.sbml.org/sbml/level3/version1/core">\n  <rdf:RDF ');
annotationEnd = sprintf('    </rdf:Description>\n  </rdf:RDF>\n</annotation>');

% the resources of the valid identifiers of metabolite 1, in the order of their field names
% (metHMDBID, metKEGGID, metPubChemID)
expectedResources = {['http://identifiers.org/hmdb/' model.metHMDBID{1}]; ...
    ['http://identifiers.org/kegg.compound/' model.metKEGGID{1}]; ...
    ['http://identifiers.org/pubchem.compound/' model.metPubChemID{1}]};

%% the annotation of a metabolite: valid identifiers as resources, invalid ones as notes

[annotationString, notes] = makeSBMLAnnotationString(model, 'M_10fthf_c', 'met', 1);

% the valid identifiers of metabolite 1 are the resources
assert(isequal(getResources(annotationString), expectedResources));
assert(isequal(expectedResources{2}, 'http://identifiers.org/kegg.compound/C00234'));

% the ChEBI entry has no CHEBI: prefix and the InChI does not match its pattern, so both are
% returned as notes with their field
assert(isequal(notes, {'metChEBIID', model.metChEBIID{1}; 'metInChIString', model.metInChIString{1}}));

% the string is one annotation for the entity with one bag of the qualifier is
assert(startsWith(annotationString, annotationStart));
assert(endsWith(annotationString, annotationEnd));
assert(contains(annotationString, '<rdf:Description rdf:about="#M_10fthf_c">'));
assert(numel(strfind(annotationString, '<bqbiol:is>')) == 1);
assert(numel(strfind(annotationString, '<rdf:Bag>')) == 1);

% Tier-5 reference length (first run, 2026-11-03)
assert(numel(annotationString) == 906);

% the defaults: no qualifier list means all qualifiers, and mergeAnnotations is false
assert(isequal(makeSBMLAnnotationString(model, 'M_10fthf_c', {'met', {}}, 1), annotationString));
assert(isequal(makeSBMLAnnotationString(model, 'M_10fthf_c', 'met', 1, false), annotationString));

%% an entity without annotation gives an empty string and no notes

[annotationString, notes] = makeSBMLAnnotationString(model, 'M_x', 'met', 2);
assert(isempty(annotationString) && ischar(annotationString));
assert(iscell(notes) && isequal(size(notes), [0, 2]));

%% only the given qualifiers are annotated

% the known metabolite fields all use the qualifier is, so selecting is gives the same string,
% and selecting isDescribedBy gives nothing
annotationString = makeSBMLAnnotationString(model, 'M_10fthf_c', {'met', {'is'}}, 1);
assert(isequal(annotationString, makeSBMLAnnotationString(model, 'M_10fthf_c', 'met', 1)));
[annotationString, notes] = makeSBMLAnnotationString(model, 'M_10fthf_c', {'met', {'isDescribedBy'}}, 1);
assert(isempty(annotationString));
assert(isequal(size(notes), [0, 2]));

%% several identifiers in one field: each valid one is a resource, the field is noted once

% metabolite 1 with a second valid KEGG identifier (C02917, that of 12ppd_S[c], the first
% metabolite with another KEGG identifier) and an invalid one
twoIdModel = model;
otherKegg = model.metKEGGID{find(~cellfun(@isempty, model.metKEGGID) & ~strcmp(model.metKEGGID, model.metKEGGID{1}), 1)};
twoIdModel.metKEGGID{1} = [model.metKEGGID{1} '; ' otherKegg '; notAKeggId'];
[annotationString, notes] = makeSBMLAnnotationString(twoIdModel, 'M_10fthf_c', 'met', 1);

% both valid KEGG identifiers are resources, after the HMDB identifier and before the PubChem
% identifier; the whole KEGG entry is added to the notes
assert(isequal(getResources(annotationString), {expectedResources{1}; expectedResources{2}; ...
    ['http://identifiers.org/kegg.compound/' otherKegg]; expectedResources{3}}));
assert(isequal(notes(:, 1), {'metChEBIID'; 'metInChIString'; 'metKEGGID'}));
assert(isequal(notes{3, 2}, twoIdModel.metKEGGID{1}));

%% a field of a database without known field is annotated under its qualifier

% the field holds the metabolite identifiers, except for metabolite 2
metacycModel = model;
metacycModel.metismetacyc__46__compoundID = model.mets;
metacycModel.metismetacyc__46__compoundID{2} = '';
annotationString = makeSBMLAnnotationString(metacycModel, 'M_10fthf_c', 'met', 1);

% the identifier is used without pattern check, with the database name decoded from the field
% name, before the resources of the known fields
assert(isequal(getResources(annotationString), ...
    [{['http://identifiers.org/metacyc.compound/' model.mets{1}]}; expectedResources]));
assert(numel(strfind(annotationString, '<bqbiol:is>')) == 1);

% Tier-5 reference length (first run, 2026-11-03)
assert(numel(annotationString) == 990);

% an empty entry of the field is skipped
assert(isempty(makeSBMLAnnotationString(metacycModel, 'M_x', 'met', 2)));

%% merged annotations: one bag per qualifier over all field types

% the metabolite fields listed twice, the second time also with isDescribedBy, which has no
% identifier; the resources of the two rows are merged into one bag is without duplicates
[annotationString, notes] = makeSBMLAnnotationString(model, 'M_10fthf_c', ...
    {'met', {'is'}; 'met', {'is', 'isDescribedBy'}}, 1, true);
assert(isequal(sort(getResources(annotationString)), sort(expectedResources)));
assert(numel(strfind(annotationString, '<bqbiol:is>')) == 1);
assert(~contains(annotationString, 'isDescribedBy'));
assert(startsWith(annotationString, annotationStart) && endsWith(annotationString, annotationEnd));

% the notes are collected for each row
assert(isequal(notes, repmat({'metChEBIID', model.metChEBIID{1}; 'metInChIString', model.metInChIString{1}}, 2, 1)));

% Tier-5 reference length (first run, 2026-11-03)
assert(numel(annotationString) == 906);

% change the directory
cd(currentDir)
