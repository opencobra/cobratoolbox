% The COBRAToolbox: testCreateNewMetaboliteStructure.m
%
% Purpose:
%     - createNewMetaboliteStructure builds a metabolite structure from a table whose first row
%       holds the headers (a VMH ID column, a metabolite name column and identifier columns):
%       one entry VMH_<abbreviation> per row, each header mapped to a field of
%       metaboliteStructureFieldNames, every other field added as NaN (addField2MetStructure),
%       then cleanUpMetabolite_structure and sanityCheckMetIds. The function is QUARANTINED
%       (Constitution III-Defects, quarantine in back-fill campaigns): the formula columns of
%       the documented input format are dropped, so no assertion about the function is made.
%       With the documented example, the entries VMH_cot and VMH_coto get metNames, hmdb and
%       charge (0, numeric) from the table (R2025a, 2026-11-15).
%
% Function under test:
%     src/dataIntegration/metaboAnnotator/buildMetStruct/createNewMetaboliteStructure.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use the hand-built table of the documentation.
%     Lines 70-71 and 86-88 (input without VMH ID column) call generateVMHMetAbbr, which needs
%     the VMH web API, and would stay exempt.
%
% Coverage exemptions:
%     every line - createNewMetaboliteStructure is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The formula columns of the documented input format are dropped
%       SEVERITY: wrong-result
%       TRIGGER: createNewMetaboliteStructure({'VMH ID' 'metabolite_name' 'HMDB' 'inchistring'
%         'neutral_formula' 'charged_formula' 'charge'; 'cot' 'Cotinine' 'HMDB0001046' ''
%         'C10H12N2O' 'C10H12N2O' '0'; 'coto' 'Cotinine n-oxide' 'HMDB0001411' '' '' '' ''},
%         'test source'), the example of the function's documentation
%       OBSERVED: s.VMH_cot.neutralFormula = NaN and s.VMH_cot.chargedFormula = NaN although
%         the table gives C10H12N2O; a header is used only when a field name of
%         metaboliteStructureFieldNames contains it after blanks are replaced by '_' or removed,
%         so 'neutral_formula' and 'charged_formula' match no field and their columns are
%         ignored without notice; likewise the header 'smiles' that createrBioNetStructure
%         passes does not match the field 'smile' (R2025a, 2026-11-15)
%       EXPECTED: the documented columns stored in neutralFormula and chargedFormula
%       LINES: 108-110
%     - DEFECT: A table without a name column stops on an undefined variable
%       SEVERITY: limitation
%       TRIGGER: createNewMetaboliteStructure({'VMH ID' 'HMDB'; 'cot' 'HMDB0001046'}, 'src')
%       OBSERVED: "Unrecognized function or variable 'metList'." (MATLAB:UndefinedFunction, line
%         64), in the branch written for a table without name column; the documentation
%         requires the name column (R2025a, 2026-11-15)
%       EXPECTED: the branch adds the column metNames or reports the missing column
%       LINES: 62-64
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCreateNewMetaboliteStructure'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
