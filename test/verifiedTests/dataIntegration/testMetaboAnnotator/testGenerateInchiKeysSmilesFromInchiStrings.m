% The COBRAToolbox: testGenerateInchiKeysSmilesFromInchiStrings.m
%
% Purpose:
%     - generateInchiKeysSmilesFromInchiStrings converts, for every metabolite with an InChI
%       string, a missing InChI key and a missing SMILES with Open Babel
%       (convertInchiString2format), logs each addition in IDsAdded and finally runs
%       cleanUpMetabolite_structure on the whole structure.
%     - Open Babel cannot run here, so the test checks the paths that need no conversion: a
%       metabolite whose InChI key and SMILES are both present, and metabolites without an InChI
%       string (NaN or empty), with and without a VMHId field. Nothing is converted, IDsAdded
%       stays an empty text and the structure comes back cleaned (spaces removed from the KEGG
%       id, text PubChem id and charge made numeric, as cleanUpMetabolite_structure documents);
%       expected values are derived by hand from that documentation.
%
% Function under test:
%     src/dataIntegration/metaboAnnotator/generateMetInfo/generateInchiKeysSmilesFromInchiStrings.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, a hand-built metabolite structure.
%
% Coverage exemptions:
%     Lines 44-52, 56-64: the conversion of a missing InChI key or SMILES calls Open Babel
%     (obabel) through convertInchiString2format, which cannot run from MATLAB on the
%     reference machine (counted as not installed).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The metabolite counter is printed for every metabolite
%       SEVERITY: cosmetic
%       TRIGGER: any call with a non-empty metabolite structure
%       OBSERVED: (R2025a, 2026-11-15) "i =" and the index are printed once per metabolite
%         (line 40 has no semicolon)
%       EXPECTED: no console output, or output gated behind a printLevel
%       LINES: 40
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGenerateInchiKeysSmilesFromInchiStrings'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% a metabolite holds the fields that cleanUpMetabolite_structure reads (keggId, cheBIId,
% inchiString, pubChemId, charge) and the InChI key and SMILES fields
newMetabolite = @(inchiString, inchiKey, smile, keggId, pubChemId, charge) struct( ...
    'inchiString', inchiString, 'inchiKey', inchiKey, 'smile', smile, 'keggId', keggId, ...
    'cheBIId', NaN, 'pubChemId', pubChemId, 'charge', charge);

%% nothing to convert: complete metabolites and metabolites without an InChI string

metabolites = struct();
% InChI string, key and SMILES present (with a VMHId field): no conversion
metabolites.VMH_h2o = newMetabolite('InChI=1S/H2O/h1H2', 'XLYOFNOQVPJJNP-UHFFFAOYSA-N', 'O', ...
    'C 00001', '962', '0');
metabolites.VMH_h2o.VMHId = 'h2o';
% no InChI string (NaN), no VMHId field: skipped although key and SMILES are missing
metabolites.VMH_glc__D = newMetabolite(NaN, NaN, NaN, 'C00031', 5793, 0);
% empty InChI string: skipped
metabolites.VMH_atp = newMetabolite('', '', '', NaN, NaN, NaN);

[annotated, IDsAdded] = generateInchiKeysSmilesFromInchiStrings(metabolites);

% nothing was converted: the log stays an empty text
assert(ischar(IDsAdded) && isempty(IDsAdded));
% the identifiers present are kept (exact text) and no source is written
assert(strcmp(annotated.VMH_h2o.inchiKey, 'XLYOFNOQVPJJNP-UHFFFAOYSA-N'));
assert(strcmp(annotated.VMH_h2o.smile, 'O'));
assert(~isfield(annotated.VMH_h2o, 'inchiKey_source') && ~isfield(annotated.VMH_h2o, 'smile_source'));
% the metabolites without an InChI string keep their missing key and SMILES
assert(isnan(annotated.VMH_glc__D.inchiKey) && isnan(annotated.VMH_glc__D.smile));
assert(isempty(annotated.VMH_atp.inchiKey) && isempty(annotated.VMH_atp.smile));
assert(~isfield(annotated.VMH_glc__D, 'inchiKey_source') && ~isfield(annotated.VMH_atp, 'smile_source'));

% cleanUpMetabolite_structure ran on the result: spaces removed from the KEGG id and the
% PubChem id and charge given as text converted to numbers (exact values)
assert(strcmp(annotated.VMH_h2o.keggId, 'C00001'));
assert(isequal(annotated.VMH_h2o.pubChemId, 962) && isequal(annotated.VMH_h2o.charge, 0));
assert(strcmp(annotated.VMH_glc__D.keggId, 'C00031') && isequal(annotated.VMH_glc__D.pubChemId, 5793));
% no metabolite is added or removed
assert(isequal(fieldnames(annotated), fieldnames(metabolites)));

% change the directory
cd(currentDir)
