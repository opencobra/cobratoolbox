% The COBRAToolbox: testTransformFullMap2XML.m
%
% Purpose:
%     - transformFullMap2XML copies the information of a protein-protein-interaction map
%       structure (molecule aliases, species, complexes, included species, reactions with
%       their links, modifiers, colours, widths and notes, compartments) back into the XML
%       structure read by transformFullXML2Map and writes the file with struct2xml. The
%       function is QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns):
%       edited complex aliases are not written, and a map with exactly one complex (or one
%       entry in another list) cannot be written; no assertion about the function is made.
%
% Function under test:
%     src/visualization/metabolicCartography/transformFullMap2XML.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would write a small CellDesigner file into a
%     tempname folder.
%
% Coverage exemptions:
%     every line - transformFullMap2XML is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The complex aliases and complex species of the map are not written
%       SEVERITY: wrong-result
%       TRIGGER: [xmlStruct, map] = transformFullXML2Map(fileName) for a file with two
%         complexSpeciesAlias elements csa1 and csa2; map.complexAlias{2} = 'csaX';
%         map.complexColor{2} = 'ff123456'; transformFullMap2XML(xmlStruct, map, outFile);
%         [~, mapBack] = transformFullXML2Map(outFile)
%       OBSERVED: (R2025a, 2026-11-15) mapBack.complexAlias = {'csa1', 'csa2'} while
%         mapBack.complexColor = {'fff7f7f7', 'ff123456'}: lines 123-124 copy the values of
%         xmlStruct into the local map instead of the map values into xmlStruct
%       EXPECTED: mapBack.complexAlias = {'csa1'; 'csaX'} (the map information is transferred)
%       LINES: 123-124
%     - DEFECT: A map with exactly one complex or one included species cannot be written
%       SEVERITY: error
%       TRIGGER: an xmlStruct whose listOfComplexSpeciesAliases holds one complexSpeciesAlias
%         (a struct, as xml2struct returns a single element) and map.complexAlias = {'csa1'};
%         or one included species in both
%       OBSERVED: (R2025a, 2026-11-15) error MATLAB:cellRefFromNonCell 'Brace indexing is not
%         supported for variables of this type.' at line 123; with one included species
%         'Unable to perform assignment because brace indexing is not supported for variables
%         of this type.' A single species alias, species or reaction meets the same {k}
%         indexing at lines 89, 106 and 159
%       EXPECTED: the file is written, as lines 272-274 do for a single compartment
%       LINES: 89, 106, 123, 143, 159
%     - DEFECT: Included species without notes are written with empty notes
%       SEVERITY: cosmetic
%       TRIGGER: a map with two included species, one with notes and one with
%         specIncNotes{2} = ''
%       OBSERVED: (R2025a, 2026-11-15) line 148 tests the whole list, not the entry, so an
%         empty notes element is written for the second species, read back as a 1x0 char
%         instead of the 0x0 char read from the original file
%       EXPECTED: no notes element for an included species without notes (as lines 112-114
%         do for species)
%       LINES: 148-149
%     - DEFECT: The run time is printed on every call
%       SEVERITY: cosmetic
%       TRIGGER: any call
%       OBSERVED: (R2025a, 2026-11-15) 'Elapsed time is 0.185330 seconds.' printed by tic/toc
%       EXPECTED: no console output, or output gated behind a printLevel
%       LINES: 84, 287
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testTransformFullMap2XML'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
