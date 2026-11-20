% The COBRAToolbox: testGetCas2CTD.m
%
% Purpose:
%     - getCas2CTD reads CTD_chemicals.xlsx from the MATLAB search path (listing from row 28 on,
%       column 2 the CTD chemical id, column 3 the CAS registry number) and writes the CTD id
%       into the ctd field of every metabolite whose casRegistry matches exactly and whose ctd
%       is empty or NaN; numeric CAS numbers are compared as text (num2str). Each assignment is
%       logged in IDsAdded (metabolite, 'ctd', id) and dated in ctd_source; the structure is
%       then passed through cleanUpMetabolite_structure.
%     - The test writes a small CTD_chemicals.xlsx by hand (27 comment rows, the field row, a
%       '#' row and three chemicals, as in the shipped file) into a temporary folder and runs the
%       function from that folder, where xlsread finds it before the file of the tutorials
%       submodule; the test therefore does not need the submodule. Expected values are the
%       values written (hand derivation).
%
% Function under test:
%     src/dataIntegration/metaboAnnotator/connect2resources/getCas2CTD.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, a hand-built metabolite structure and spreadsheet.
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
fileDir = fileparts(which('testGetCas2CTD'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the hand-built CTD listing, written into a temporary folder that becomes the current folder
sandboxDir = tempname;
mkdir(sandboxDir);
ctdRows = cell(32, 3);
for i = 1:27
    ctdRows{i, 1} = sprintf('# comment line %d', i);
end
ctdRows(28, :) = {'# ChemicalName', 'ChemicalID', 'CasRN'};
ctdRows(29, 1) = {'#'};
ctdRows(30, :) = {'Formaldehyde', 'MESH:D005557', '50-00-0'};
ctdRows(31, :) = {'Water', 'MESH:D014867', '7732-18-5'};
ctdRows(32, :) = {'Numbered', 'MESH:C000001', 1234};
writecell(ctdRows, fullfile(sandboxDir, 'CTD_chemicals.xlsx'));
cd(sandboxDir);

% a metabolite with the fields read by getCas2CTD and cleanUpMetabolite_structure
newMetabolite = @(cas, ctd) struct('keggId', NaN, 'cheBIId', NaN, 'inchiString', NaN, ...
    'pubChemId', NaN, 'charge', NaN, 'casRegistry', cas, 'ctd', ctd);

%% CTD ids are added for matching CAS numbers without a CTD id

metabolites = struct();
metabolites.form = newMetabolite('50-00-0', NaN);       % text CAS, no CTD id: added
metabolites.num = newMetabolite(1234, NaN);             % numeric CAS, compared as text: added
metabolites.kept = newMetabolite('7732-18-5', 'MESH:old'); % CTD id present: kept
metabolites.noCas = newMetabolite('', NaN);             % empty CAS: skipped
metabolites.nanCas = newMetabolite(NaN, NaN);           % NaN CAS: skipped
metabolites.unknown = newMetabolite('1-1-1', NaN);      % CAS not listed: nothing added
metabolites.water = newMetabolite('7732-18-5', '');     % empty CTD id: added
% a KEGG id with a blank shows that cleanUpMetabolite_structure is applied at the end
metabolites.form.keggId = 'C 00067';

[annotated, IDsAdded] = getCas2CTD(metabolites);

% the log lists the three assignments in field order (exact text)
assert(isequal(IDsAdded, {'form', 'ctd', 'MESH:D005557'; 'num', 'ctd', 'MESH:C000001'; ...
    'water', 'ctd', 'MESH:D014867'}));
assert(strcmp(annotated.form.ctd, 'MESH:D005557'));
assert(strcmp(annotated.num.ctd, 'MESH:C000001'));
assert(strcmp(annotated.water.ctd, 'MESH:D014867'));
% the source names the mapping, the annotation type and a date
assert(startsWith(annotated.form.ctd_source, 'CTD_id mapping from CasRegistry:automatic:'));
assert(isfield(annotated.water, 'ctd_source'));
% unchanged metabolites: no CTD id and no source added
assert(strcmp(annotated.kept.ctd, 'MESH:old') && ~isfield(annotated.kept, 'ctd_source'));
assert(isnan(annotated.noCas.ctd) && isnan(annotated.nanCas.ctd) && isnan(annotated.unknown.ctd));
% the structure went through cleanUpMetabolite_structure (blank removed from the KEGG id)
assert(strcmp(annotated.form.keggId, 'C00067'));

%% nothing to add: the log stays an empty text

[annotated, IDsAdded] = getCas2CTD(struct('none', newMetabolite('1-1-1', NaN)));
assert(ischar(IDsAdded) && isempty(IDsAdded));
assert(isnan(annotated.none.ctd));

% remove the temporary folder and change the directory
cd(currentDir)
rmdir(sandboxDir, 's');
