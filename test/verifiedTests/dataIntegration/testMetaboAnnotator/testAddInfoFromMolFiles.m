% The COBRAToolbox: testAddInfoFromMolFiles.m
%
% Purpose:
%     - addInfoFromMolFiles fills, for the metabolites startSearch to endSearch of a metabolite
%       structure, a missing InChI string from the mol file <VMHId>.mol of folderName (Open
%       Babel, obabel), and then a missing InChI key and SMILES from the InChI string
%       (convertInchiString2format, Open Babel); each addition is logged in IDAdded.
%     - Once the defect below is fixed, the test should check the paths that need no Open
%       Babel: the default folder 'ctf-main/mets/molFiles' (absent: nothing changes), an empty
%       folder, metabolites whose InChI string, key and SMILES are all present, a metabolite
%       without InChI string and without mol file, and the startSearch/endSearch range, with
%       IDAdded empty. Lines 56-69, 75-85 and 89-98 need Open Babel, which cannot run from
%       MATLAB on the reference machine, and stay exempt.
%       Quarantined: no behaviour of addInfoFromMolFiles is asserted until the error defect
%       below is fixed; this file only opens the test.
%
% Function under test:
%     src/dataIntegration/metaboAnnotator/analyseMetStruct/addInfoFromMolFiles.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, a hand-built metabolite structure.
%
% Coverage exemptions:
%     every line - addInfoFromMolFiles is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The documented output IDAdded is not assigned when nothing is added, so a
%         call requesting it stops
%       SEVERITY: error
%       TRIGGER: [ms, IDAdded] = addInfoFromMolFiles(struct('VMH_h2o', struct('VMHId', 'h2o',
%         'inchiString', 'InChI=1S/H2O/h1H2', 'inchiKey', 'XLYOFNOQVPJJNP-UHFFFAOYSA-N',
%         'smile', 'O')), tempname)
%       OBSERVED: (R2025a, 2026-11-15) 'Output argument "IDAdded" (and possibly others) not
%         assigned a value in the execution with "addInfoFromMolFiles" function.': IDAdded is
%         assigned only inside the branches that add an identifier (lines 64-66, 82-84, 96-98)
%         and is never initialised (line 46 initialises only the counter)
%       EXPECTED: IDAdded returned empty when nothing is added
%       LINES: 1, 46
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAddInfoFromMolFiles'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
