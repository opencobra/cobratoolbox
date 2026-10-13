% The COBRAToolbox: testGapfillRefinedGenomeReactions.m
%
% Purpose:
%     - gapfillRefinedGenomeReactions renames some transport reactions, adds (gap-fills) the
%     reactions needed to connect pathways that were added from genome annotations, removes
%     reactions that would always be blocked, and appends a fixed list of manually curated entries
%     to a table of genome annotations (organism, reaction, evidence).
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/reconstruction/demeter/src/integration/gapfillRefinedGenomeReactions.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None for the tested inputs; see the defect below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The first gap-filled row overwrites the last annotation row
%       SEVERITY: wrong-result
%       TRIGGER: a genome annotation to which at least one gap-filling rule applies
%       OBSERVED: the row counter starts at the number of rows instead of one more, so the first
%         added row replaces the last row of the input
%       EXPECTED: all input rows kept and the new rows appended after them
%       LINES: 127
%
% Authors:
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGapfillRefinedGenomeReactions'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% The expected rows are checked by membership, never by position or count: the first gap-filled row
% replaces the last input row (see the header), so the last input row is not checked.

% a helper that tells whether the annotation has a row (organism, reaction, evidence)
hasRow = @(annotation, organism, reaction, evidence) any(strcmp(annotation(:, 1), organism) & ...
    strcmp(annotation(:, 2), reaction) & strcmp(annotation(:, 3), evidence));

%% reactions with old names are renamed

result = gapfillRefinedGenomeReactions({'OrgA', '7BHGLZabc', 'E1'; 'OrgA', 'KEEP', 'E2'});
assert(hasRow(result, 'OrgA', '7BHGLZGLCabc', 'E1'));
assert(~any(strcmp(result(:, 2), '7BHGLZabc')));

%% a gap-filling rule: reaction present and the reaction it needs absent -> the needed one is added

result = gapfillRefinedGenomeReactions({'OrgA', 'PTVSTGLUC_GLCAASEe', 'E1'; 'OrgA', 'OTHER', 'E2'; 'OrgB', 'OTHER', 'E3'});
assert(hasRow(result, 'OrgA', 'EX_ptvst(e)', 'gap_filled'));
% the added reaction belongs to the organism that triggered the rule
assert(~hasRow(result, 'OrgB', 'EX_ptvst(e)', 'gap_filled'));
% the first rows are kept
assert(hasRow(result, 'OrgA', 'PTVSTGLUC_GLCAASEe', 'E1'));

%% the rule is not applied when the needed reaction is already there

result = gapfillRefinedGenomeReactions({'OrgA', 'PTVSTGLUC_GLCAASEe', 'E1'; 'OrgA', 'EX_ptvst(e)', 'E2'; 'OrgA', 'OTHER', 'E3'});
assert(~any(strcmp(result(:, 3), 'gap_filled') & strcmp(result(:, 1), 'OrgA') & strcmp(result(:, 2), 'EX_ptvst(e)')));

%% reactions that would always be blocked are removed

% '1HIBUPGLU_St' without '1HIBUP_S_GLCAASE' (or ...e): it and its exchange reaction are deleted
result = gapfillRefinedGenomeReactions({'OrgA', '1HIBUPGLU_St', 'E1'; 'OrgA', 'EX_1hibupglu_S(e)', 'E2'; 'OrgA', 'KEEP', 'E3'});
assert(~hasRow(result, 'OrgA', '1HIBUPGLU_St', 'E1') && ~hasRow(result, 'OrgA', 'EX_1hibupglu_S(e)', 'E2'));
% with the enzyme present nothing is deleted
result = gapfillRefinedGenomeReactions({'OrgA', '1HIBUPGLU_St', 'E1'; 'OrgA', '1HIBUP_S_GLCAASE', 'E2'; 'OrgA', 'KEEP', 'E3'});
assert(hasRow(result, 'OrgA', '1HIBUPGLU_St', 'E1'));

%% manually curated entries are always appended

result = gapfillRefinedGenomeReactions({'OrgZ', 'X', 'Y'});
assert(hasRow(result, 'Olsenella_uli_DSM_7084', 'IND3ACDC', 'E1QXZ2'));
assert(hasRow(result, 'OrgZ', 'X', 'Y'));

% change the directory
cd(currentDir)
