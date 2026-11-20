% The COBRAToolbox: testGenerateInchiKeysSmilesFromInchiStrings.m
%
% Purpose:
%     - generateInchiKeysSmilesFromInchiStrings converts, for every metabolite with an InChI
%       string, a missing InChI key and a missing SMILES with Open Babel
%       (convertInchiString2format), logs each addition in IDsAdded and finally runs
%       cleanUpMetabolite_structure on the whole structure.
%     - Open Babel cannot run from MATLAB here, so the test stands in for it with an executable
%       named obabel that the test writes into a tempname folder put first on PATH (restored at
%       the end). For an InChI string containing 'garbage' it prints Open Babel's error text
%       ("*** Open Babel Error  in InChI code"); otherwise it prints the InChI key or the SMILES
%       of L-alanine (QNAYBMKLOCPYGJ-REOHCLBHSA-N, C[C@@H](C(=O)O)N followed by a tab, the form
%       Open Babel writes). The expected values are therefore the stand-in's outputs, which the
%       function must store unchanged; the SMILES is compared after strtrim because the
%       trailing tab comes from convertInchiString2format, not from the function under test.
%     - The paths without conversion are checked as well: a metabolite whose InChI key and
%       SMILES are both present, and metabolites without an InChI string (NaN or empty), with
%       and without a VMHId field. The structure comes back cleaned (spaces removed from the
%       KEGG id, text PubChem id and charge made numeric, as cleanUpMetabolite_structure
%       documents); expected values are derived by hand from that documentation.
%
% Function under test:
%     src/dataIntegration/metaboAnnotator/generateMetInfo/generateInchiKeysSmilesFromInchiStrings.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, a hand-built metabolite structure; Open Babel is replaced by
%     a test double (needs a Unix shell).
%
% Coverage exemptions:
%     None. Every executable line is reached below.
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
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15; conversion
%       paths added after independent review, 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGenerateInchiKeysSmilesFromInchiStrings'));
cd(fileDir);

% needs a POSIX shell for the stand-in obabel
prepareTest('needsUnix', true);

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

%% conversion with a stand-in Open Babel

% the stand-in obabel: Open Babel's error text for an InChI containing 'garbage', otherwise
% the InChI key or SMILES of L-alanine with the "1 molecule converted" line on stderr
origPath = getenv('PATH');
sandboxDir = tempname;
fakeBin = [sandboxDir, filesep, 'bin'];
mkdir(fakeBin);
fakeObabel = [fakeBin, filesep, 'obabel'];
stubLines = {'#!/bin/sh', ...
    'case "$*" in', ...
    '  *garbage*) printf ''==============================\n*** Open Babel Error  in InChI code\n  Reading InChI failed\n'' >&2', ...
    '    echo "0 molecules converted" >&2; exit 1 ;;', ...
    'esac', ...
    'case "$*" in', ...
    '  *"-o inchikey"*) echo "QNAYBMKLOCPYGJ-REOHCLBHSA-N" ;;', ...
    '  *"-o smiles"*) printf ''C[C@@H](C(=O)O)N\t\n'' ;;', ...
    'esac', ...
    'echo "1 molecule converted" >&2'};
fid = fopen(fakeObabel, 'w');
fprintf(fid, '%s\n', stubLines{:});
fclose(fid);
system(['chmod +x ', fakeObabel]);

alanineInchi = 'InChI=1S/C3H7NO2/c1-2(4)3(5)6/h2H,4H2,1H3,(H,5,6)/t2-/m0/s1';
alanineKey = 'QNAYBMKLOCPYGJ-REOHCLBHSA-N';
alanineSmiles = 'C[C@@H](C(=O)O)N';
sourcePrefix = 'InchiString (metabolite_structure, obabel):automatic:not verified:';

converting = struct();
% key and SMILES missing (NaN): both are converted and logged, key first
converting.VMH_ala__L = newMetabolite(alanineInchi, NaN, NaN, 'C00041', NaN, 0);
% key present, SMILES empty: only the SMILES is converted
converting.VMH_alaKey = newMetabolite(alanineInchi, alanineKey, '', NaN, NaN, 0);
% SMILES present, key empty: only the key is converted, the SMILES is kept
converting.VMH_alaSmiles = newMetabolite(alanineInchi, '', 'CC(N)C(O)=O', NaN, NaN, 0);
% Open Babel reports an error: nothing is stored or logged
converting.VMH_bad = newMetabolite('InChI=1S/garbage', '', NaN, NaN, NaN, 0);

try
    setenv('PATH', [fakeBin, pathsep, origPath]);
    % nothing below may reach the real Open Babel
    [~, obabelPath] = system('which obabel');
    assert(strcmp(strtrim(obabelPath), fakeObabel));

    [converted, IDsAdded] = generateInchiKeysSmilesFromInchiStrings(converting);
catch ME
    % restore the system path and remove the sandbox before reporting the failure
    setenv('PATH', origPath);
    rmdir(sandboxDir, 's');
    rethrow(ME);
end
setenv('PATH', origPath);
rmdir(sandboxDir, 's');

% the log: one row per added identifier, in metabolite order and key before SMILES
assert(iscell(IDsAdded) && isequal(size(IDsAdded), [4, 3]));
assert(isequal(IDsAdded(:, 1:2), {'VMH_ala__L', 'inchiKey'; 'VMH_ala__L', 'smiles'; ...
    'VMH_alaKey', 'smiles'; 'VMH_alaSmiles', 'inchiKey'}));
assert(isequal(IDsAdded([1, 4], 3), {alanineKey; alanineKey}));
assert(isequal(strtrim(IDsAdded([2, 3], 3)), {alanineSmiles; alanineSmiles}));

% the structure: converted identifiers stored with their source, present ones kept
assert(strcmp(converted.VMH_ala__L.inchiKey, alanineKey));
assert(strcmp(strtrim(converted.VMH_ala__L.smile), alanineSmiles));
assert(startsWith(converted.VMH_ala__L.inchiKey_source, sourcePrefix));
assert(startsWith(converted.VMH_ala__L.smile_source, sourcePrefix));
assert(strcmp(converted.VMH_alaKey.inchiKey, alanineKey) && ~isfield(converted.VMH_alaKey, 'inchiKey_source'));
assert(strcmp(strtrim(converted.VMH_alaKey.smile), alanineSmiles));
assert(startsWith(converted.VMH_alaKey.smile_source, sourcePrefix));
assert(strcmp(converted.VMH_alaSmiles.inchiKey, alanineKey));
assert(strcmp(converted.VMH_alaSmiles.smile, 'CC(N)C(O)=O') && ~isfield(converted.VMH_alaSmiles, 'smile_source'));
% the failed conversions leave the missing key and SMILES as they were
assert(isempty(converted.VMH_bad.inchiKey) && isnan(converted.VMH_bad.smile));
assert(~isfield(converted.VMH_bad, 'inchiKey_source') && ~isfield(converted.VMH_bad, 'smile_source'));
% cleanUpMetabolite_structure ran here too: the KEGG id is kept, no metabolite added or removed
assert(strcmp(converted.VMH_ala__L.keggId, 'C00041'));
assert(isequal(fieldnames(converted), fieldnames(converting)));

% change the directory
cd(currentDir)
