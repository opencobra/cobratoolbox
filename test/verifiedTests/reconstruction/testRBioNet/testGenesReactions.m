% The COBRAToolbox: testGenesReactions.m
%
% Purpose:
%     - GenesReactions lists, for every gene of a gene list (a column), the rBioNet reactions
%       (rows of rxns: abbreviation in column 2, gene rule in column 6) whose rule names the
%       gene (genes read with GPR2Genes), joined with ', ' in the order of the reactions; a
%       gene without reaction gets []. A gene of a rule that is not in the gene list is
%       reported in a message box and skipped. Expected lists are read off the hand-written
%       rules; the message box is closed after reading its text.
%
% Function under test:
%     src/reconstruction/rBioNet/GenesReactions.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-built gene list and reactions. One case opens a
%     message box, which the test closes.
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
fileDir = fileparts(which('testGenesReactions'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% gene list (a column) and reactions in the rBioNet layout: abbreviation in column 2, rule in
% column 6; the other columns are not read
geneList = {'g1'; 'g2'; 'g3'; 'g5'};
reactions = {
    '', 'R1', '', '', '', 'g1 or g2'
    '', 'R2', '', '', '', '(g1 and g3)'
    '', 'R3', '', '', '', ''
    '', 'R4', '', '', '', 'g3'};

%% each gene lists the reactions of its rules; a gene without reaction gets []

% g1 is in R1 and R2, g2 in R1, g3 in R2 and R4, g5 in none; R3 has no rule
expected = {'g1', 'R1, R2'; 'g2', 'R1'; 'g3', 'R2, R4'; 'g5', []};
assert(isequal(GenesReactions(geneList, reactions), expected));

%% no reaction: every gene gets []

assert(isequal(GenesReactions(geneList, cell(0, 6)), [geneList, cell(4, 1)]));

%% a gene of a rule that is not in the gene list is reported and skipped

% R5 names g4 (not listed) and g2: g4 is reported in a message box, g2 gets R5
withUnknownGene = [reactions; {'', 'R5', '', '', '', 'g4 or g2'}];
expected = {'g1', 'R1, R2'; 'g2', 'R1, R5'; 'g3', 'R2, R4'; 'g5', []};
assert(isequal(GenesReactions(geneList, withUnknownGene), expected));
assert(contains(closeMessageBoxes(), 'Gene g4 is not in genelist....R5'));

% change the directory
cd(currentDir)

function boxText = closeMessageBoxes()
% Returns the text of the open message boxes and closes them, so that no window stays open.
boxes = findall(0, 'Type', 'figure', '-regexp', 'Tag', '^Msgbox_');
boxText = '';
for iBox = 1:numel(boxes)
    boxLines = cellstr(get(findall(boxes(iBox), 'Type', 'text'), 'String'));
    boxText = [boxText, ' ', strjoin(strtrim(boxLines), ' ')];
end
delete(boxes);
end
