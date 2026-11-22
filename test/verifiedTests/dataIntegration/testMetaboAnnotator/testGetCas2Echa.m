% The COBRAToolbox: testGetCas2Echa.m
%
% Purpose:
%     - getCas2Echa reads the ECHA (European Chemicals Agency) EC inventory ec_inventory_en.xlsx
%       (three header rows, then the ECHA identifier in column 1 and the CAS registry number in
%       column 4), gives every metabolite of a metabolite structure that has a CAS number and no
%       ECHA identifier the identifier listed for that CAS number, logs the additions and
%       passes the structure through cleanUpMetabolite_structure. This test writes a small
%       inventory with the layout of the shipped file into a temporary folder (the real file
%       has 106,213 entries and is not needed) and checks a metabolite that receives an
%       identifier, one whose identifier exists already, one with an empty identifier, ones
%       without a CAS number (NaN or empty), one whose CAS number is not listed and one whose
%       CAS number is listed twice. Expected values are the hand-written inventory entries.
%
% Function under test:
%     src/dataIntegration/metaboAnnotator/connect2resources/getCas2Echa.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built inputs (a six-entry inventory written with
%     writecell into a tempname folder, removed at the end).
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetCas2Echa'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the function reads ec_inventory_en.xlsx by name; a file in the current folder is found before
% any copy on the MATLAB path, so the test writes its own inventory into a temporary folder and
% calls the function from there. Rows 1 to 3 are headers as in the shipped file; CAS 8001-20-5
% is listed for two substances, as in the shipped file
tempDir = tempname;
mkdir(tempDir);
inventory = {'EC Inventory', '', '', ''; 'test copy', '', '', ''; ...
    'ID', 'EC Name', 'EC No.', 'CAS No.'; ...
    '100.000.002', 'Formaldehyde', '200-001-8', '50-00-0'; ...
    '100.000.003', 'Guanidinium chloride', '200-002-3', '50-01-1'; ...
    '100.000.004', 'Dexamethasone', '200-003-9', '50-02-2'; ...
    '100.029.548', 'Tung oil', '232-272-9', '8001-20-5'; ...
    '100.099.999', 'Tung oil, second entry', '300-000-1', '8001-20-5'; ...
    '100.199.999', 'No CAS number', '300-000-2', '-'};
writecell(inventory, fullfile(tempDir, 'ec_inventory_en.xlsx'));

% metabolite entries with the fields that the function and cleanUpMetabolite_structure read
emptyEntry = struct('casRegistry', NaN, 'echa_id', NaN, 'keggId', NaN, 'cheBIId', NaN, ...
    'inchiString', NaN, 'pubChemId', NaN, 'charge', NaN);
metaboliteStructure = struct();
% CAS listed, no ECHA identifier yet; the KEGG identifier has a trailing blank that
% cleanUpMetabolite_structure removes
metaboliteStructure.VMH_fald = emptyEntry;
metaboliteStructure.VMH_fald.casRegistry = '50-00-0';
metaboliteStructure.VMH_fald.keggId = 'C00067 ';
% CAS listed, ECHA identifier already present: kept
metaboliteStructure.VMH_gua = emptyEntry;
metaboliteStructure.VMH_gua.casRegistry = '50-01-1';
metaboliteStructure.VMH_gua.echa_id = '100.000.999';
% no CAS number (NaN) and an empty CAS number: nothing to look up
metaboliteStructure.VMH_nocas = emptyEntry;
metaboliteStructure.VMH_emptycas = emptyEntry;
metaboliteStructure.VMH_emptycas.casRegistry = '';
% CAS listed, empty ECHA identifier: filled
metaboliteStructure.VMH_dexa = emptyEntry;
metaboliteStructure.VMH_dexa.casRegistry = '50-02-2';
metaboliteStructure.VMH_dexa.echa_id = '';
% CAS not in the inventory
metaboliteStructure.VMH_unlisted = emptyEntry;
metaboliteStructure.VMH_unlisted.casRegistry = '999-99-9';
% CAS listed for two substances
metaboliteStructure.VMH_tung = emptyEntry;
metaboliteStructure.VMH_tung.casRegistry = '8001-20-5';

%% ECHA identifiers are added by CAS number and logged

cd(tempDir);
[updatedStructure, IDsAdded] = getCas2Echa(metaboliteStructure);
cd(fileDir);

% one log row per added identifier, in the order of the structure (exact text); for a CAS
% number listed twice the first listed substance is taken
assert(isequal(IDsAdded, {'VMH_fald', 'echa_id', '100.000.002'; ...
    'VMH_dexa', 'echa_id', '100.000.004'; 'VMH_tung', 'echa_id', '100.029.548'}));
assert(isequal(updatedStructure.VMH_fald.echa_id, '100.000.002'));
assert(isequal(updatedStructure.VMH_dexa.echa_id, '100.000.004'));
assert(isequal(updatedStructure.VMH_tung.echa_id, '100.029.548'));
% the source records the mapping, the annotation type and the date
assert(startsWith(updatedStructure.VMH_fald.echa_id_source, ...
    'Echa_id mapping from CasRegistry:automatic:'));

% the existing identifier is kept; the entries without CAS number or with an unlisted one
% keep their NaN identifier and get no source field
assert(isequal(updatedStructure.VMH_gua.echa_id, '100.000.999'));
assert(~isfield(updatedStructure.VMH_gua, 'echa_id_source'));
assert(isnan(updatedStructure.VMH_nocas.echa_id) && isnan(updatedStructure.VMH_emptycas.echa_id));
assert(isnan(updatedStructure.VMH_unlisted.echa_id));
assert(~isfield(updatedStructure.VMH_unlisted, 'echa_id_source'));

% the structure was passed through cleanUpMetabolite_structure (blank removed from keggId)
assert(isequal(updatedStructure.VMH_fald.keggId, 'C00067'));

%% nothing to add gives an empty log

metaboliteStructure = struct('VMH_gua', metaboliteStructure.VMH_gua);
cd(tempDir);
[updatedStructure, IDsAdded] = getCas2Echa(metaboliteStructure);
cd(fileDir);
assert(isempty(IDsAdded) && ischar(IDsAdded));
assert(isequal(updatedStructure.VMH_gua.echa_id, '100.000.999'));

% remove the temporary inventory
rmdir(tempDir, 's');

% change the directory
cd(currentDir)
