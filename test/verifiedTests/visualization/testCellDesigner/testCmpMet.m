% The COBRAToolbox: testCmpMet.m
%
% Purpose:
%     - cmpMet compares the metabolites of a parsed CellDesigner model
%       (parsed.r_info.species, one row per species, one column per identifier form) with the
%       metabolites of a COBRA model: parsed species present and not present in the model, and
%       model metabolites not present in the parsed model.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the independent review (T021) showed that a parsed species is reported
%       present when one of its entries is only a substring of a model metabolite ID, and
%       that the model metabolites it reports are not the model's IDs (they are lowered), so
%       this file makes no assertion about the function. The wave 24 version of this test (git
%       history) pinned the substring rule and avoided upper-case model IDs; a test of the fixed
%       function must include a substring collision (parsed 'atp', model 'datp[c]') and an
%       upper-case model ID.
%
% Function under test:
%     src/visualization/cellDesigner/cmpMet.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model comparison on a hand-built model structure (mets, metNames) and parsed
%     structure; no solver.
%
% Coverage exemptions:
%     every line - cmpMet is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers, independent review T021). Before the quarantine the
%     test exempted lines 56-57 (unreachable: strtrim at line 52 raises an error for any entry
%     that is not text).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A parsed species is reported present when one of its entries is a substring of a model metabolite ID
%       SEVERITY: wrong-result
%       TRIGGER: parsed.r_info.species = {'h'; 'atp'}; model.mets = {'h2o[c]'; 'datp[c]'};
%         model.metNames = {'Water'; 'dATP'}; results = cmpMet(parsed, model)
%       OBSERVED: (R2025a, 2026-11-17) results.listOfFound holds both rows ({'h', [],
%         'Present in the Reference mode'; 'atp', [], 'Present in the Reference mode'}) and
%         results has no field listOfNotFound: line 63 tests strfind(model IDs, entry), so 'h'
%         matches h2o[c] and 'atp' matches datp[c], although neither species is in the model
%       EXPECTED: both rows in listOfNotFound ("A list of reactions in the test model that are
%         NOT present in the reference COBRA model"); an exact, case-insensitive match as in
%         the second pass of line 99
%       LINES: 63
%     - DEFECT: Model metabolites absent from the parsed model are returned in lower case
%       SEVERITY: wrong-result
%       TRIGGER: parsed.r_info.species = {'x'}; model.mets = {'A[c]'}; model.metNames = {'A'};
%         results = cmpMet(parsed, model)
%       OBSERVED: (R2025a, 2026-11-17) results.list_of_mets_not_present_in_ReferenceModel is
%         {'a[c]'}: the IDs are lowered at line 42 for the search and returned lowered at line
%         101, so they no longer equal (or ismember) the IDs of model.mets
%       EXPECTED: the model's own IDs ({'A[c]'})
%       LINES: 42, 101
%     - DEFECT: The help text names the third output field and its content wrongly
%       SEVERITY: cosmetic
%       TRIGGER: reading the OUTPUT section of cmpMet
%       OBSERVED: the field is list_of_mets_not_present_in_ReferenceModel (line 101) and holds
%         metabolites; the help text calls it list_of_rxns_not_present_in_ReferenceModel and
%         speaks of reactions in all three fields
%       EXPECTED: the field name of line 101 and "metabolites"
%       LINES: 21-26
%     - DEFECT: Every comparison prints the searched name
%       SEVERITY: cosmetic
%       TRIGGER: any call
%       OBSERVED: line 53 has no semicolon, so 'met = 1x1 cell array {...}' is printed for
%         every parsed entry compared
%       EXPECTED: no output, or output gated by a print level
%       LINES: 53
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.
%     - Converted to the quarantine layout after the independent review (T021), 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCmpMet'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
