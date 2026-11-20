% The COBRAToolbox: testDisplayReactingMoieties.m
%
% Purpose:
%     - displayReactingMoieties(reacting) prints a summary table (reaction, number of formed
%       and broken bonds, total) of reacting.reactMoietyTables and then each per-reaction table
%       under a "=== Reacting moiety k (reaction name) ===" heading. The output is not
%       suppressed: the command window text is also recorded with diary in a temporary file
%       and the summary rows and headings are checked against counts derived by hand from
%       hand-built tables, including a reaction without bonds and a string array of reaction
%       names.
%
% Function under test:
%     src/analysis/topology/reactingMoieties/displayReactingMoieties.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built tables.
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
fileDir = fileparts(which('testDisplayReactingMoieties'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% per-reaction tables as buildReactingMoietyTables makes them: rxnA has 2 formed and 1 broken
% bond, rxnB 1 broken bond, rxnC none (zero-row table with the same columns)
makeMoietyTable = @(bondChange, bond) table(bondChange, bond, ...
    'VariableNames', {'BondChange', 'Bond'});
reacting.selectedReactionNames = {'rxnA'; 'rxnB'; 'rxnC'};
reacting.reactMoietyTables = { ...
    makeMoietyTable(["formed"; "formed"; "broken"], ["bondA1"; "bondA2"; "bondA3"]); ...
    makeMoietyTable("broken", "bondB1"); ...
    makeMoietyTable(strings(0, 1), strings(0, 1))};

% record the command window in a temporary file; the previous diary state is restored below
workDir = tempname;
mkdir(workDir);
diaryWasOn = strcmp(get(0, 'Diary'), 'on');
previousDiaryFile = get(0, 'DiaryFile');
if diaryWasOn
    diary('off');
end

%% summary counts and one heading per reaction (cell array of names)

diaryFile = fullfile(workDir, 'cellNames.txt');
diary(diaryFile);
displayReactingMoieties(reacting);
diary('off');
printedText = fileread(diaryFile);
assert(contains(printedText, 'Reacting moieties summary:'));
% summary rows: name, formed, broken, total (counted by hand from the tables above)
assert(~isempty(regexp(printedText, '"rxnA"\s+2\s+1\s+3', 'once')));
assert(~isempty(regexp(printedText, '"rxnB"\s+0\s+1\s+1', 'once')));
assert(~isempty(regexp(printedText, '"rxnC"\s+0\s+0\s+0', 'once')));
% one heading per reaction, followed by its table (bond names of rxnA and rxnB appear)
assert(contains(printedText, '=== Reacting moiety 1 (reaction rxnA) ==='));
assert(contains(printedText, '=== Reacting moiety 2 (reaction rxnB) ==='));
assert(contains(printedText, '=== Reacting moiety 3 (reaction rxnC) ==='));
assert(contains(printedText, 'bondA3') && contains(printedText, 'bondB1'));
% headings in reaction order
assert(strfind(printedText, 'reaction rxnA') < strfind(printedText, 'reaction rxnB'));

%% a string array of reaction names prints the same summary

reactingFromStrings = reacting;
reactingFromStrings.selectedReactionNames = ["rxnA"; "rxnB"; "rxnC"];
diaryFile = fullfile(workDir, 'stringNames.txt');
diary(diaryFile);
displayReactingMoieties(reactingFromStrings);
diary('off');
printedText = fileread(diaryFile);
assert(~isempty(regexp(printedText, '"rxnA"\s+2\s+1\s+3', 'once')));
assert(contains(printedText, '=== Reacting moiety 3 (reaction rxnC) ==='));

%% restore the diary state and remove the files

set(0, 'DiaryFile', previousDiaryFile);
if diaryWasOn
    diary('on');
end
rmdir(workDir, 's');

% change the directory
cd(currentDir)
