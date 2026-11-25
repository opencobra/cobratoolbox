% The COBRAToolbox: testRemoveMapSpeciesOnly.m
%
% Purpose:
%     - removeMapSpeciesOnly(xmlStruct, map, specRemoveList, specRemoveType, printLevel)
%       removes the species named in specRemoveList (and, when given, every species of type
%       specRemoveType) and their aliases from a CellDesigner map (the map structure and the
%       xml2struct structure returned by transformXML2Map) without removing reactions; a
%       species or alias that is the base reactant or base product of a reaction is kept, and
%       the reactant and product lists of the reactions are updated. Quarantined: no behaviour
%       of removeMapSpeciesOnly is asserted until the defect below is fixed.
%
% Function under test:
%     src/visualization/metabolicCartography/removeMapSpeciesOnly.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver; the input map is read from the CellDesigner
%     file shipped with the test suite (testCD/glycolysisAndTCA.xml).
%
% Coverage exemptions:
%     every line - removeMapSpeciesOnly is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Reactions that keep all their species get their reactant/product IDs and aliases sorted apart, so IDs and aliases no longer match
%       SEVERITY: wrong-result
%       TRIGGER: [xmlStruct, map] = transformXML2Map('testCD/glycolysisAndTCA.xml');
%         [x3, m3] = removeMapSpeciesOnly(xmlStruct, map, {'itp[c]'}, [], 0) (itp[c] takes part
%         in r0354 only)
%       OBSERVED: (R2025a, 2026-11-25) in 12 reactions without itp[c] (ACYP, GAPD, HEX1, PYK,
%         r0153, r0165, r0413, AKGDm, CSm, MDHm, PCm, SUCOASm) the i-th secondary reactant
%         or product ID no longer belongs to the i-th alias (32 pairs): GAPD has reactants
%         {s4410 (nad[c]), s5962 (pi[c])} with aliases {sa31, sa30} in the input (sa31 is an
%         alias of s4410) and aliases {sa30, sa31} in the output, so nad[c] is paired with an
%         alias of pi[c]. Lines 155, 190, 235 and 275 rebuild every list with setdiff, which
%         sorts the IDs and the aliases independently. transformMap2XML writes
%         rxnReactantID{r}{x} and rxnReactantAlias{r}{x} into the same reactantLink, so the
%         written map links species to the wrong aliases.
%       EXPECTED: reactions whose species are all kept are unchanged, and in every reaction the
%         i-th ID still belongs to the i-th alias (the help: only the entries of the removed
%         species and aliases are stripped)
%       LINES: 155, 190, 235, 275
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-25.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testRemoveMapSpeciesOnly'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
