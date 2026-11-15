% The COBRAToolbox: testTestRefinedReactions.m
%
% Purpose:
%     - testRefinedReactions(microbeID, BlockedRxns) is a DEMETER test-suite function (its
%       name starts with "test"; this file tests it). It reads gapfilledGenomeAnnotation.txt
%       from the current folder (tab-separated, no header; column 1 the microbe, column 2 a
%       reaction added by the refinement of the genome annotation) and splits the
%       reactions of microbeID into those in BlockedRxns (BlockedRefinedReactions) and the
%       others (RefinedReactionsCarryingFlux), both as sorted lists without repeats
%       (intersect and setdiff). Without the file, or for a microbe that is not in it, both
%       outputs are empty cell arrays.
%     - The test writes the annotation file by hand in a temporary folder and runs the
%       function from there; the expected lists follow from the file by hand.
%
% Function under test:
%     src/reconstruction/demeter/suite/tests/testRefinedReactions.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, a hand-written text file in a temporary folder.
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
fileDir = fileparts(which('testTestRefinedReactions'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

sandboxDir = tempname;
mkdir(sandboxDir);
cd(sandboxDir);

%% no annotation file in the current folder: both outputs are empty

assert(~isfile('gapfilledGenomeAnnotation.txt'));
[carryingFlux, blocked] = testRefinedReactions('Microbe_A', {'R1'});
assert(iscell(carryingFlux) && isempty(carryingFlux));
assert(iscell(blocked) && isempty(blocked));

% annotation file: Microbe_A has R3, R1, R2 and R3 again; Microbe_B has R4
annotationRows = {
    'Microbe_A', 'R3', 'gene1'
    'Microbe_B', 'R4', 'gene2'
    'Microbe_A', 'R1', 'gene3'
    'Microbe_A', 'R2', 'gene4'
    'Microbe_A', 'R3', 'gene5'};
fid = fopen('gapfilledGenomeAnnotation.txt', 'w');
for i = 1:size(annotationRows, 1)
    fprintf(fid, '%s\n', strjoin(annotationRows(i, :), sprintf('\t')));
end
fclose(fid);

%% the reactions of the microbe are split into blocked and flux-carrying reactions

% R1 and R4 are blocked: R4 belongs to another microbe, R5 is not an annotated reaction
[carryingFlux, blocked] = testRefinedReactions('Microbe_A', {'R4'; 'R1'; 'R5'});
assert(isequal(blocked, {'R1'}));
% sorted and without the repeated R3
assert(isequal(carryingFlux, {'R2'; 'R3'}));

% no blocked reaction: every refined reaction carries flux
[carryingFlux, blocked] = testRefinedReactions('Microbe_A', {});
assert(isequal(carryingFlux, {'R1'; 'R2'; 'R3'}));
assert(isempty(blocked));

% every refined reaction blocked
[carryingFlux, blocked] = testRefinedReactions('Microbe_B', {'R4'});
assert(isequal(blocked, {'R4'}));
assert(isempty(carryingFlux));

%% a microbe that is not in the file: both outputs are empty

[carryingFlux, blocked] = testRefinedReactions('Microbe_C', {'R1'});
assert(iscell(carryingFlux) && isempty(carryingFlux));
assert(iscell(blocked) && isempty(blocked));

%% clean up

cd(fileDir);
rmdir(sandboxDir, 's');

% change the directory
cd(currentDir)
