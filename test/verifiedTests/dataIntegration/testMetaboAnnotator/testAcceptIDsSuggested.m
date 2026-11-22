% The COBRAToolbox: testAcceptIDsSuggested.m
%
% Purpose:
%     - acceptIDsSuggested adds curated identifiers to a metabolite structure: every row of the
%       suggestion list whose 6th column is 'accepted' gives, for the metabolite of column 1,
%       the identifier 'database:identifier' of column 3, with a source 'annotationSource:
%       manual:verified:<date>', and is logged in IDsAdded. The function is QUARANTINED
%       (Constitution III-Defects, quarantine in back-fill campaigns): IDsAdded keeps only the
%       last accepted suggestion, and a list with fewer rows than columns stops with an index
%       error, so no assertion about the function is made. With seven rows of which two are
%       accepted, both identifiers are written to the structure with the documented source
%       (R2025a, 2026-11-15).
%
% Function under test:
%     src/dataIntegration/metaboAnnotator/analyseMetStruct/acceptIDsSuggested.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use a hand-built metabolite structure and
%     suggestion list.
%
% Coverage exemptions:
%     every line - acceptIDsSuggested is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: IDsAdded keeps only the last accepted suggestion
%       SEVERITY: wrong-result
%       TRIGGER: ms.VMH_glc_D = struct('keggId', NaN, 'hmdb', NaN); ms.VMH_atp = ms.VMH_glc_D;
%         S = [{'VMH_glc_D', 'x', 'keggId:C00031', '', '', 'accepted'; 'VMH_atp', 'x',
%         'hmdb:HMDB0000538', '', '', 'accepted'}; repmat({'VMH_atp', 'x', 'keggId:C00002', '',
%         '', 'rejected'}, 5, 1)]; [o, IDsAdded] = acceptIDsSuggested(ms, S, 'curator (test)')
%       OBSERVED: o.VMH_glc_D.keggId = 'C00031' and o.VMH_atp.hmdb = 'HMDB0000538' are both
%         added, but IDsAdded = {'VMH_atp', 'hmdb', 'HMDB0000538', 'added based on accepted
%         suggestion'} (1 x 4): the row counter a is set to 1 and never incremented, so each
%         accepted suggestion overwrites row 1 (R2025a, 2026-11-15)
%       EXPECTED: one row of IDsAdded per accepted suggestion (two rows here)
%       LINES: 35, 42-45
%     - DEFECT: A suggestion list with fewer rows than columns stops with an index error
%       SEVERITY: error
%       TRIGGER: acceptIDsSuggested(ms, S(1:2, :)) with ms and S as above (2 rows, 6 columns)
%       OBSERVED: "Index in position 1 exceeds array bounds. Index must not exceed 2."
%         (MATLAB:badsubscript, line 38): the loop runs to length(IDsSuggested), which is the
%         number of columns (6) when the list has fewer rows than columns (R2025a, 2026-11-15)
%       EXPECTED: the two suggestions accepted, the loop running over the rows (size(IDsSuggested, 1))
%       LINES: 37-38
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAcceptIDsSuggested'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
