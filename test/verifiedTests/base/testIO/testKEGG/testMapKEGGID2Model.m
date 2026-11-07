% The COBRAToolbox: testMapKEGGID2Model.m
%
% Purpose:
%     - mapKEGGID2Model looks up every metabolite of the model, without its compartment, in a
%       dictionary of compound abbreviations and KEGG identifiers, and stores in metKEGGID the
%       KEGG identifier followed by the compartment ([c], [p] or [e]); a metabolite of any other
%       compartment, or without a dictionary entry or KEGG identifier, gets an empty entry.
%       Characterization test that PINS the current behaviour (feature
%       20261103-105830-tier2-safe-batch, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Recon2.v04 is used because it is the smallest distributed model with KEGG identifiers and
%       with metabolites outside the compartments c, p and e. The dictionary is built from the
%       model itself: one entry per metabolite abbreviation without compartment, with the KEGG
%       identifier of its first metabolite in model order.
%     - Reference values: the counts asserted below were recorded from the first run on
%       2026-11-03 with Recon2.v04 (no solver). They were not derived independently, so they
%       guard consistency, not independent correctness (Tier 5). The whole metKEGGID field is
%       also derived independently from model.mets and the dictionary.
%
% Function under test:
%     src/base/io/KEGG/mapKEGGID2Model.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; Recon2.v04 loaded through getDistributedModel.
%
% Coverage exemptions:
%     Lines 35-36, metabolites of compartment [p]: no distributed model with KEGG identifiers has
%     a periplasm, and the E. coli models write the compartment as a suffix _p.
%     Lines 51-52, a dictionary abbreviation with several entries: it stops with an error before
%     these lines (known defect).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A dictionary abbreviation with several entries stops with an error
%       SEVERITY: error
%       TRIGGER: a dictionary in which an abbreviation appears twice, for example the dictionary
%         of this test with its first row repeated, on Recon2.v04
%       OBSERVED: length(KEGGID{Match}) gets one argument per match and fails with 'Too many
%         input arguments.'
%       EXPECTED: an empty metKEGGID entry and the warning 'multiple matchings for ...'
%       LINES: 50-52
%     - DEFECT: A metabolite without compartment that is in the dictionary stops with an error
%       SEVERITY: error
%       TRIGGER: a model whose metabolite identifiers carry no compartment, for example
%         mapKEGGID2Model(model, {'g6p', 'C00092'}) on AntCore
%       OBSERVED: the compartment variable KEGGComp is only set for [c], [p] and [e]
%         metabolites, so the call fails with 'Unrecognized function or variable KEGGComp';
%         after an earlier [c], [p] or [e] metabolite the compartment of that metabolite would be
%         appended instead
%       EXPECTED: the KEGG identifier without a compartment, as the comment of the else branch
%         states
%       LINES: 40-41, 48
%
% Authors:
%     - Generated for feature 20261103-105830-tier2-safe-batch, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMapKEGGID2Model'));
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

% the compartment of every metabolite
metComp = regexp(model.mets, '(?<=\[)\w+(?=\]$)', 'match', 'once');

%% metabolites of c and e get the KEGG identifier with their compartment

keggModel = mapKEGGID2Model(model, Dictionary);

% the expected field, derived independently: the KEGG identifier of the abbreviation followed by
% the compartment for the metabolites of c and e with a non-empty identifier, empty otherwise
[~, dictIdx] = ismember(metAbbr, dictAbbr);
dictKegg = Dictionary(dictIdx, 2);
isMapped = ismember(metComp, {'c', 'e'}) & ~cellfun(@isempty, dictKegg);
expectedKegg = cell(numel(model.mets), 1);
expectedKegg(isMapped) = strcat(dictKegg(isMapped), '[', metComp(isMapped), ']');
assert(isequal(keggModel.metKEGGID, expectedKegg));

% metKEGGID has one entry per metabolite, and only metKEGGID is changed
assert(isequal(size(keggModel.metKEGGID), [numel(model.mets), 1]));
assert(isequal(rmfield(keggModel, 'metKEGGID'), rmfield(model, 'metKEGGID')));

% Tier-5 reference counts (first run, 2026-11-03): 1389 metabolites get an identifier, 993 in
% c and 396 in e
isFilled = ~cellfun(@isempty, keggModel.metKEGGID);
assert(nnz(isFilled) == 1389);
assert(nnz(endsWith(keggModel.metKEGGID(isFilled), '[c]')) == 993);
assert(nnz(endsWith(keggModel.metKEGGID(isFilled), '[e]')) == 396);

% an example: D-glucose in c and e has the KEGG compound C00031
assert(strcmp(keggModel.metKEGGID{strcmp(model.mets, 'glc_D[c]')}, 'C00031[c]'));
assert(strcmp(keggModel.metKEGGID{strcmp(model.mets, 'glc_D[e]')}, 'C00031[e]'));

%% metabolites of other compartments and metabolites without entry stay empty

keggModel = mapKEGGID2Model(model, Dictionary);

% a metabolite of another compartment is looked up with its compartment, which no abbreviation
% of the dictionary has, so it stays empty although its abbreviation has a KEGG identifier
isOtherComp = ~ismember(metComp, {'c', 'e'});
assert(all(cellfun(@isempty, keggModel.metKEGGID(isOtherComp))));
assert(isempty(keggModel.metKEGGID{strcmp(model.mets, 'glc_D[r]')}));

% a metabolite whose abbreviation is not in the dictionary (here glucose, removed from it) gets
% an empty entry, and so does a metabolite whose dictionary entry has no KEGG identifier
reducedDictionary = Dictionary(~strcmp(dictAbbr, 'glc_D'), :);
keggModel = mapKEGGID2Model(model, reducedDictionary);
assert(isempty(keggModel.metKEGGID{strcmp(model.mets, 'glc_D[c]')}));
noKeggIdx = find(cellfun(@isempty, Dictionary(:, 2)) & ismember(dictAbbr, metAbbr(strcmp(metComp, 'c'))), 1);
assert(isempty(keggModel.metKEGGID{strcmp(model.mets, [dictAbbr{noKeggIdx} '[c]'])}));

% Tier-5 reference count (first run, 2026-11-03): without glucose two identifiers fewer
assert(nnz(~cellfun(@isempty, keggModel.metKEGGID)) == 1387);

% change the directory
cd(currentDir)
