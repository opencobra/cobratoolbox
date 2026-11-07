% The COBRAToolbox: testMapMetName2KEGGID.m
%
% Purpose:
%     - mapMetName2KEGGID maps the metabolites of a KEGG model (identifiers made of a KEGG
%       compound identifier and a compartment, as written by transformModel2KEGG) back to the
%       compound abbreviations of a dictionary: metsAbr gets the abbreviation followed by the
%       compartment ([c], [p] or [e]); a metabolite of any other compartment, whose identifier is
%       not a KEGG identifier of the dictionary, or whose KEGG identifier belongs to several
%       abbreviations gets an empty entry. metKEGGID is set to the metabolite identifiers. Every
%       KEGG identifier that appears more than once in the dictionary is reported once with
%       'multiple matches'; this output is not suppressed.
%       Characterization test that PINS the current behaviour (feature
%       20261103-105830-tier2-safe-batch, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Recon2.v04 is used because it is the smallest distributed model with KEGG identifiers and
%       with metabolites outside the compartments c, p and e. The dictionary is built from the
%       model itself (one entry per metabolite abbreviation without compartment, with the KEGG
%       identifier of its first metabolite in model order) and the KEGG model is built from the
%       model and this dictionary with transformModel2KEGG, without its metsAbr field, so that
%       the field is created by the function under test.
%     - Reference values: the counts asserted below were recorded from the first run on
%       2026-11-03 with Recon2.v04 (no solver). They were not derived independently, so they
%       guard consistency, not independent correctness (Tier 5). The whole metsAbr field is also
%       derived independently from the metabolite identifiers and the dictionary.
%
% Function under test:
%     src/base/io/KEGG/mapMetName2KEGGID.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; Recon2.v04 loaded through getDistributedModel.
%
% Coverage exemptions:
%     Lines 47-48, metabolites of compartment [p]: no distributed model with KEGG identifiers has
%     a periplasm, and the E. coli models write the compartment as a suffix _p.
%     Lines 67-68 and 71, the report of a metabolite with several matches: the condition
%     length(Match) < 0 is never true (known defect).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The message for a metabolite with several matches is never printed
%       SEVERITY: cosmetic
%       TRIGGER: a KEGG identifier that belongs to several abbreviations of the dictionary, for
%         example C00376 (retinal, retinal_cis_13 and retinal_cis_9) in the dictionary of this test
%       OBSERVED: the branch tests length(Match) < 0, which is never true, so the metabolite
%         silently gets an empty entry through the last branch
%       EXPECTED: an empty entry and the message 'multiple matches' with the identifier
%       LINES: 66-71
%     - DEFECT: A metabolite without compartment that is in the dictionary stops with an error
%       SEVERITY: error
%       TRIGGER: a KEGG model whose metabolite identifiers carry no compartment, for example
%         mapMetName2KEGGID(struct('mets', {{'C00092'}}), {'g6p', 'C00092'})
%       OBSERVED: the compartment variable KEGGComp is only set for [c], [p] and [e]
%         metabolites, so the call fails with 'Unrecognized function or variable KEGGComp';
%         after an earlier [c], [p] or [e] metabolite the compartment of that metabolite would be
%         appended instead
%       EXPECTED: the abbreviation without a compartment, as the comment of the else branch
%         states
%       LINES: 52-53, 64
%
% Authors:
%     - Generated for feature 20261103-105830-tier2-safe-batch, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMapMetName2KEGGID'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox or
% particular operating system, so none is listed
prepareTest();

% load the model once (5063 metabolites in the compartments c, e, g, l, m, n, r and x, with a
% metKEGGID field)
model = getDistributedModel('Recon2.v04.mat');

% the dictionary built from the model: each abbreviation without compartment once, with the KEGG
% identifier of its first metabolite
metAbbr = regexprep(model.mets, '\[\w+\]$', '');
[dictAbbr, firstIdx] = unique(metAbbr, 'stable');
Dictionary = [dictAbbr, model.metKEGGID(firstIdx)];

% the KEGG model: the metabolites of c and e with a KEGG identifier are renamed to it (for
% example C00031[c]), all others keep their identifier; only the original identifiers are kept
% from the model, which is not needed any more
keggModel = rmfield(transformModel2KEGG(model, Dictionary), 'metsAbr');
originalMets = model.mets;
clear model

% the KEGG identifiers that belong to exactly one abbreviation of the dictionary
dictKegg = Dictionary(:, 2);
[uniqueKegg, ~, keggGroup] = unique(dictKegg(~cellfun(@isempty, dictKegg)));
keggCount = accumarray(keggGroup, 1);
singleKegg = uniqueKegg(keggCount == 1);

%% KEGG identifiers of c and e get the abbreviation with their compartment

newModel = mapMetName2KEGGID(keggModel, Dictionary);

% the expected field, derived independently: for an identifier made of a KEGG identifier of a
% single abbreviation and the compartment c or e, the abbreviation followed by the compartment;
% empty otherwise
keggParts = regexp(keggModel.mets, '^(.*)\[(c|e)\]$', 'tokens', 'once');
expectedAbbr = cell(numel(keggModel.mets), 1);
for i = 1:numel(keggModel.mets)
    if ~isempty(keggParts{i}) && ismember(keggParts{i}{1}, singleKegg)
        expectedAbbr{i} = [Dictionary{strcmp(dictKegg, keggParts{i}{1}), 1} '[' keggParts{i}{2} ']'];
    end
end
assert(isequal(newModel.metsAbr, expectedAbbr));

% the mapping inverts transformModel2KEGG: every filled entry is the original metabolite
isFilled = ~cellfun(@isempty, newModel.metsAbr);
assert(isequal(newModel.metsAbr(isFilled), originalMets(isFilled)));

% metsAbr has one entry per metabolite, metKEGGID is set to the metabolite identifiers and
% nothing else changes
assert(isequal(size(newModel.metsAbr), [numel(keggModel.mets), 1]));
assert(isequal(newModel.metKEGGID, keggModel.mets));
assert(isequal(rmfield(newModel, {'metsAbr', 'metKEGGID'}), rmfield(keggModel, 'metKEGGID')));

% Tier-5 reference counts (first run, 2026-11-03): 1281 metabolites get an abbreviation; 58 KEGG
% identifiers belong to several abbreviations
assert(nnz(isFilled) == 1281);
assert(nnz(keggCount > 1) == 58);

% an example: C00031[c] is D-glucose in c
assert(strcmp(newModel.metsAbr{strcmp(keggModel.mets, 'C00031[c]')}, 'glc_D[c]'));

%% identifiers without a single dictionary match stay empty

newModel = mapMetName2KEGGID(keggModel, Dictionary);

% a metabolite of another compartment keeps its abbreviation as identifier in the KEGG model,
% which is not a KEGG identifier, so it stays empty
isOtherComp = cellfun(@isempty, regexp(keggModel.mets, '\[(c|e)\]$', 'once'));
assert(all(cellfun(@isempty, newModel.metsAbr(isOtherComp))));
assert(isempty(newModel.metsAbr{strcmp(keggModel.mets, 'glc_D[r]')}));

% a metabolite of c without KEGG identifier keeps its abbreviation, which is not in the KEGG
% identifiers of the dictionary, so it stays empty
noKeggIdx = find(strcmp(originalMets, keggModel.mets) & endsWith(keggModel.mets, '[c]'), 1);
assert(isempty(newModel.metsAbr{noKeggIdx}));

% a KEGG identifier of several abbreviations stays empty: C00376 (retinal) belongs to retinal,
% retinal_cis_13 and retinal_cis_9 in Recon2.v04
assert(nnz(strcmp(dictKegg, 'C00376')) == 3);
isRetinal = strcmp(keggModel.mets, 'C00376[c]');
assert(any(isRetinal) && all(cellfun(@isempty, newModel.metsAbr(isRetinal))));

% change the directory
cd(currentDir)
