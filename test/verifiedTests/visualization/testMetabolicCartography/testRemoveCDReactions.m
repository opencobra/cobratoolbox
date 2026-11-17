% The COBRAToolbox: testRemoveCDReactions.m
%
% Purpose:
%     - removeCDReactions reads a CellDesigner map with transformXML2Map, removes the reactions
%       named in a list, removes the species and species aliases that take part (as reactant
%       or product) only in removed reactions, prints a message for each listed name that is
%       not in the map (unless printLevel is 0) and writes the reduced map to
%       '<input name>_subset.xml'.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the independent review (T027/T028) showed that it deletes a species that a
%       kept reaction still uses as modifier, leaving dangling references in the written map,
%       so this file makes no assertion about the function. The wave 13 version of this test
%       (git history) checked hand-derived reductions of a three-reaction map (R1: A -> B
%       catalysed by E, R2: B -> C, R3: C -> D) and is the starting point once the defects are
%       fixed; a fixed version should add a species that is a reactant or product of a removed
%       reaction and a modifier of a kept one.
%
% Function under test:
%     src/visualization/metabolicCartography/removeCDReactions.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-written CellDesigner file in a tempname folder.
%
% Coverage exemptions:
%     every line - removeCDReactions is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers, independent review T027/T028). Before the
%     quarantine the test exempted lines 27, 29, 31, 32, 33 (dead code inside 'if 0').
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A species still used as modifier by a kept reaction is removed, leaving dangling references
%       SEVERITY: wrong-result
%       TRIGGER: removeCDReactions(fileName, {'R5'}) on a map with species A-F (s1-s6, aliases
%         sa1-sa6), R1: A -> B catalysed by E (modifiers="s5" aliases="sa5"), R2: B -> C,
%         R3: C -> D, R5: E -> F (re4, base reactant s5/sa5, product s6/sa6)
%       OBSERVED: (R2025a, 2026-11-17) the written _subset.xml has the reactions R1, R2, R3, the
%         species s1-s4 and the aliases sa1-sa4: s5 and sa5 are deleted although R1 keeps its
%         modification modifiers="s5" aliases="sa5" and its modifierSpeciesReference to s5.
%         map.sID and map.sAlias (getMapMatrices) hold reactants and products only, so lines
%         62 and 65 see s5/sa5 used by R5 alone and lines 71 and 74-75 delete them
%       EXPECTED: "removing corresponding species and species aliases if necessary" (lines
%         2-3): a species or alias used by a remaining reaction (as modifier too) is kept
%       LINES: 62, 65, 71, 74-75
%     - DEFECT: A species that only modifies removed reactions is kept
%       SEVERITY: wrong-result
%       TRIGGER: removeCDReactions(fileName, {'R1'}) on the map above without R5 and F, where
%         species E (s5, alias sa5) is only the catalyst (modifier) of R1
%       OBSERVED: (R2025a, 2026-11-17) the written map has R2, R3, the species s2-s5 and the
%         aliases sa2-sa5: A (s1, sa1) is removed with R1, but E and sa5 stay although no
%         remaining reaction uses them (map.sID and map.sAlias hold reactants and products
%         only, not modifiers)
%       EXPECTED: E and sa5 removed with R1, as for reactants and products: the map structure
%         is used "to be able to delete isolated species and species aliases" (lines 37-38)
%       LINES: 62, 65
%     - DEFECT: A name listed twice is reported as not present in the map
%       SEVERITY: cosmetic
%       TRIGGER: removeCDReactions(fileName, {'R3', 'R3'}) on a map that contains R3
%       OBSERVED: MATLAB R2025a prints 'R3 not present in the map' (ismember returns only the
%         first position of R3 in the list, so the second position is counted as missing);
%         R3 is removed.
%       EXPECTED: no message, as R3 is in the map
%       LINES: 46, 51
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.
%     - Converted to the quarantine layout after the independent review (T027/T028), 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRemoveCDReactions'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
