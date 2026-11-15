% The COBRAToolbox: testTransformFullXML2Map.m
%
% Purpose:
%     - transformFullXML2Map reads a CellDesigner file with xml2struct and builds the map
%       structure of a protein-protein-interaction map: molecule aliases, species, complexes,
%       included species, reactions with their base and secondary reactants and products and
%       their line types, colours and widths, modifiers, notes and compartments. The function
%       is QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): a map with
%       exactly one complex (or one entry in another list) and reaction notes written inside
%       XHTML elements cannot be read; no assertion about the function is made.
%
% Function under test:
%     src/visualization/metabolicCartography/transformFullXML2Map.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would write a small CellDesigner file into a
%     tempname folder.
%
% Coverage exemptions:
%     every line - transformFullXML2Map is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A map with exactly one complex species alias cannot be read
%       SEVERITY: error
%       TRIGGER: a CellDesigner file whose celldesigner:listOfComplexSpeciesAliases holds one
%         celldesigner:complexSpeciesAlias (every other list with two or more entries), then
%         [xmlStruct, map] = transformFullXML2Map(fileName)
%       OBSERVED: (R2025a, 2026-11-15) error MATLAB:cellRefFromNonCell 'Brace indexing is not
%         supported for variables of this type.' at line 140: xml2struct returns a struct, not
%         a cell, for a single element and the loop indexes it with {k}. A file with one
%         species alias fails the same way at line 99 (observed); one species, included
%         species or reaction meets the same indexing at lines 118, 171 and 194
%       EXPECTED: map.complexAlias = {'csa1'} and the other fields, as lines 344-346 do for a
%         single compartment
%       LINES: 98-99, 117-118, 139-140, 170-171, 192-194
%     - DEFECT: Reaction notes written inside XHTML elements cannot be read
%       SEVERITY: error
%       TRIGGER: a reaction with the notes
%         '<notes><html xmlns="http://www.w3.org/1999/xhtml"><body><p>hexokinase</p></body></html></notes>'
%       OBSERVED: (R2025a, 2026-11-15) error 'Unrecognized field name "Text".' at line 334;
%         species notes of the same form are read as '' (lines 124-127)
%       EXPECTED: no error; rxnNotes read as the species notes are
%       LINES: 334
%     - DEFECT: The run time is printed on every call
%       SEVERITY: cosmetic
%       TRIGGER: any call
%       OBSERVED: (R2025a, 2026-11-15) 'Elapsed time is 0.732667 seconds.' printed by tic/toc
%       EXPECTED: no console output, or output gated behind a printLevel
%       LINES: 91, 360
%     - DEFECT: The field compartName is missing for a map without compartments
%       SEVERITY: limitation
%       TRIGGER: a file with an empty celldesigner:listOfCompartmentAliases
%       OBSERVED: (R2025a, 2026-11-15) map.compartAlias = '' and map has no field compartName
%       EXPECTED: map.compartName = '' (documented as empty if no info)
%       LINES: 356-357
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testTransformFullXML2Map'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
