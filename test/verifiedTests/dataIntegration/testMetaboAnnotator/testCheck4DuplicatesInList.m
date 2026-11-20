% The COBRAToolbox: testCheck4DuplicatesInList.m
%
% Purpose:
%     - check4DuplicatesInList finds the entries of a list (for example metabolite abbreviations)
%       that repeat an earlier entry, prints one line per repetition and returns, for each
%       repetition, the entry and its position in the list (as text). This test checks a column
%       list with entries repeated two and three times and a list without duplicates. Expected
%       values are the hand-listed later occurrences of each repeated entry. The entries contain
%       no '%' or '\', so the cosmetic defect below (the entry is used as a print format) is
%       skipped.
%
% Function under test:
%     src/dataIntegration/metaboAnnotator/analyseMetStruct/check4DuplicatesInList.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A repeated entry is used as the format of its message
%       SEVERITY: cosmetic
%       TRIGGER: check4DuplicatesInList({'a%d'; 'b'; 'a%d'}) or check4DuplicatesInList({'a\nb'; 'a\nb'})
%       OBSERVED: the first prints only "a" (printing stops at the conversion %d, no newline);
%         the second prints "a", a line break and "b appears more than once."; the returned
%         list is right ({'a%d', '3'} and {'a\nb', '2'}) (R2025a, 2026-11-15)
%       EXPECTED: the entry printed verbatim, e.g. fprintf('%s appears more than once.\n', entry)
%       LINES: 25
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCheck4DuplicatesInList'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

%% a list with repeated entries: every later occurrence is listed with its position

% the list is a column, as the caller list2MetaboliteStructure passes it (one column of the
% input table); 'glc_D' occurs at 1, 3 and 6, 'atp' at 2 and 5, 'h2o' once
metaboliteList = {'glc_D'; 'atp'; 'glc_D'; 'h2o'; 'atp'; 'glc_D'};
listDuplicates = check4DuplicatesInList(metaboliteList);
% text and positions are exact; the rows follow the order of the positions in the list
assert(isequal(listDuplicates, {'glc_D', '3'; 'atp', '5'; 'glc_D', '6'}));

%% a list without duplicates gives an empty result

listDuplicates = check4DuplicatesInList({'glc_D'; 'atp'; 'h2o'});
assert(isempty(listDuplicates) && isnumeric(listDuplicates));

% change the directory
cd(currentDir)
