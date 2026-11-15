% The COBRAToolbox: testBuildReactingMoietyTables.m
%
% Purpose:
%     - buildReactingMoietyTables(reacting, formedBondsTable, brokenBondsTable) makes, for each
%       reaction in reacting.selectedReactionNames, one table of its formed and then broken
%       bond transitions (rows of the dBTM.Edges schema of buildAtomAndBondTransitionMultigraph)
%       with a leading BondChange column ("formed"/"broken"), then BondEndNodes, BondElmts and
%       Bond taken from the side whose bond elements are not the reaction placeholder "E-E"
%       (the tail side when neither or both are "E-E"), and the transition-specific columns
%       removed. The test uses hand-built bond tables with every column of that schema and
%       derives each expected table by hand; it covers the three side choices, a reaction
%       without reacting bonds (typed zero-row table) and a string array of reaction names.
%
% Function under test:
%     src/analysis/topology/reactingMoieties/buildReactingMoietyTables.m
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
fileDir = fileparts(which('testBuildReactingMoietyTables'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% bond tables with the column names and order of dBTM.Edges (one row per bond transition).
% formed bonds: r1 with only the head side "E-E", r1 with only the tail side "E-E", r2 with
% neither; broken bonds: r1 with both sides "E-E"
makeBondTable = @(endNodes, rxns, headBond, tailBond, headElmts, tailElmts) table( ...
    endNodes, (1:size(endNodes, 1))', (1:size(endNodes, 1))', (1:size(endNodes, 1))', ...
    {'C'}, {'O'}, {'C'}, {'O'}, 1, 2, 3, 4, rxns, (1:size(endNodes, 1))', (1:size(endNodes, 1))', ...
    headBond, tailBond, headElmts, tailElmts, {'m1'}, {'m2'}, {'single'}, {'single'}, ...
    'VariableNames', {'EndNodes', 'Trans', 'TransInstIndex', 'dirTransInstIndex', ...
    'HeadBondHeadAtom', 'HeadBondTailAtom', 'TailBondHeadAtom', 'TailBondTailAtom', ...
    'HeadBondHeadAtomIndex', 'HeadBondTailAtomIndex', 'TailBondHeadAtomIndex', ...
    'TailBondTailAtomIndex', 'rxns', 'HeadBondIndex', 'TailBondIndex', 'HeadBond', 'TailBond', ...
    'HeadBondElmts', 'TailBondElmts', 'HeadMet', 'TailMet', 'HeadMetBondTypes', ...
    'TailMetBondTypes'});
formedBondsTable = [ ...
    makeBondTable([1 2], {'r1'}, {'hb1'}, {'tb1'}, {'E-E'}, {'C-O'}); ...
    makeBondTable([3 4], {'r1'}, {'hb2'}, {'tb2'}, {'C-H'}, {'E-E'}); ...
    makeBondTable([5 6], {'r2'}, {'hb3'}, {'tb3'}, {'C-C'}, {'C-N'})];
brokenBondsTable = makeBondTable([7 8], {'r1'}, {'hb4'}, {'tb4'}, {'E-E'}, {'E-E'});

% the columns kept from the schema, after the four new leading ones
keptColumns = {'HeadBondHeadAtom', 'HeadBondTailAtom', 'TailBondHeadAtom', ...
    'TailBondTailAtom', 'HeadBondHeadAtomIndex', 'HeadBondTailAtomIndex', ...
    'TailBondHeadAtomIndex', 'TailBondTailAtomIndex', 'rxns'};
expectedColumns = [{'BondChange', 'BondEndNodes', 'BondElmts', 'Bond'}, keptColumns];

%% one table per reaction, rows formed then broken, bond taken from the non-placeholder side

reacting = struct('selectedReactionNames', {{'r1'; 'r2'; 'r3'}});
reacting = buildReactingMoietyTables(reacting, formedBondsTable, brokenBondsTable);
assert(iscell(reacting.reactMoietyTables) && isequal(size(reacting.reactMoietyTables), [3 1]));

r1Table = reacting.reactMoietyTables{1};
assert(isequal(r1Table.Properties.VariableNames, expectedColumns));
% formed rows first (in table order), then the broken row
assert(isequal(r1Table.BondChange, ["formed"; "formed"; "broken"]));
assert(isequal(r1Table.BondEndNodes, [1 2; 3 4; 7 8]));
% row 1: head is "E-E" -> tail side; row 2: tail is "E-E" -> head side; row 3: both -> tail
assert(isequal(r1Table.BondElmts, ["C-O"; "C-H"; "E-E"]));
assert(isequal(r1Table.Bond, ["tb1"; "hb2"; "tb4"]));
assert(isequal(r1Table.rxns, {'r1'; 'r1'; 'r1'}));

r2Table = reacting.reactMoietyTables{2};
% neither side is "E-E": the tail side is used
assert(isequal(r2Table.Properties.VariableNames, expectedColumns));
assert(isequal(r2Table.BondChange, "formed") && isequal(r2Table.BondEndNodes, [5 6]));
assert(isequal(r2Table.BondElmts, "C-N") && isequal(r2Table.Bond, "tb3"));

%% a reaction without reacting bonds gives a zero-row table with the same columns

r3Table = reacting.reactMoietyTables{3};
% NOTE of the help text: a typed table, never a bare table()
assert(istable(r3Table) && height(r3Table) == 0);
assert(isequal(r3Table.Properties.VariableNames, expectedColumns));
assert(isstring(r3Table.BondChange) && isstring(r3Table.Bond) && isequal(size(r3Table.BondEndNodes), [0 2]));

%% a string array of reaction names gives the same tables

reactingFromStrings = struct('selectedReactionNames', ["r1"; "r2"; "r3"]);
reactingFromStrings = buildReactingMoietyTables(reactingFromStrings, formedBondsTable, brokenBondsTable);
assert(isequal(reactingFromStrings.reactMoietyTables, reacting.reactMoietyTables));

% change the directory
cd(currentDir)
