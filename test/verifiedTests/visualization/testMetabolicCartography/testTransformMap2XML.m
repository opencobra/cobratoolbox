% The COBRAToolbox: testTransformMap2XML.m
%
% Purpose:
%     - transformMap2XML copies the information of a CellDesigner map structure (molecule
%       aliases, species, reactions with their base and secondary reactants and products,
%       modifiers, colours, widths, notes, compartments) back into the XML structure read by
%       transformXML2Map, drops from each reaction's species references the aliases no longer
%       in the map, and writes the XML file with struct2xml.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the independent review (T027/T028) showed that documented map values are
%       not transferred to the file (a reaction set to reversible 'true' stays 'false';
%       emptied notes and compartment aliases stay) and that the check for a removed only
%       reactant or product is never reached, so a dangling reference is written; this file
%       makes no assertion about the function. The wave 11 version of this test (git history)
%       checked the round trip, edited values, removed aliases, the compartment forms, the
%       '~' path and the error paths on a hand-written three-reaction map and is the starting
%       point once the defects are fixed; a fixed version should add the edit of
%       rxnReversibility to 'true'.
%
% Function under test:
%     src/visualization/metabolicCartography/transformMap2XML.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-written CellDesigner file in a tempname folder.
%
% Coverage exemptions:
%     every line - transformMap2XML is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers, independent review T027/T028). Before the
%     quarantine the test exempted lines 109, 127 (skipped defective input), 212-215 and
%     246-249 (dead code after an unconditional error()) and 66-70 (Unix-like systems only).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A reaction set to reversible 'true' in the map stays reversible="false" in the file
%       SEVERITY: wrong-result
%       TRIGGER: [x, m] = transformXML2Map(f) on a map whose reaction has reversible="false";
%         m.rxnReversibility{1} = 'true' (a documented value, line 40, as transformToReversibleMap
%         writes it); transformMap2XML(x, m, out); [~, m2] = transformXML2Map(out)
%       OBSERVED: (R2025a, 2026-11-17) m2.rxnReversibility{1} is 'false': lines 162-164 write
%         the attribute only when the map value is 'false', so the old value of xmlStruct stays
%       EXPECTED: 'true' in the written file: the map information "is then transferred to the
%         xmlStruct" (lines 19-20)
%       LINES: 162-164
%     - DEFECT: Emptied notes and compartment aliases of the map are not removed from the file
%       SEVERITY: wrong-result
%       TRIGGER: the map above with species notes 'glucose', reaction notes 'hexokinase' and
%         molecule compartment alias 'ca1'; m.specNotes{1} = ''; m.rxnNotes{1} = '';
%         m.molCompartAlias{1} = ''; transformMap2XML(x, m, out); [~, m2] = transformXML2Map(out)
%       OBSERVED: (R2025a, 2026-11-17) m2.specNotes{1} is 'glucose', m2.rxnNotes{1}
%         'hexokinase' and m2.molCompartAlias{1} 'ca1': these values are written only when
%         non-empty, so the values of xmlStruct stay
%       EXPECTED: the file reflects the map (the INPUTS document these fields as "empty if no
%         info")
%       LINES: 79-81, 99-101, 281-283
%     - DEFECT: The check for a removed only reactant or product compares with the whole alias list
%       SEVERITY: wrong-result
%       TRIGGER: a reaction with one species reference of reactants (or products) whose alias
%         was removed from map.molAlias and from the alias list of xmlStruct, in a map of two
%         or more aliases; e.g. R3: C (sa3) -> D (sa4) with sa4 removed from a map of the
%         aliases sa1-sa4
%       OBSERVED: (R2025a, 2026-11-17) no error; the written file has the three remaining
%         aliases and R3 still references sa4 in its listOfProducts. strcmp(alias,
%         map.molAlias) returns one logical per map alias and 'if' needs all of them true, so
%         the handling code (error 'removing only substrate in reaction' or '... product ...')
%         is never reached for a map of two or more aliases; by reading, it is reached for a
%         one-alias map in which nothing was removed
%       EXPECTED: the error only when the single reference's alias is not in map.molAlias
%       LINES: 108-109, 126-127
%     - DEFECT: The error for a single secondary reactant or product link with several map aliases says 'should not be cell'
%       SEVERITY: cosmetic
%       TRIGGER: a map with two secondary reactants (or products) for a reaction whose XML has
%         one link (a struct, not a cell)
%       OBSERVED: error 'should not be cell' although the link is not a cell
%       EXPECTED: a message naming the inconsistent reactant (product) aliases
%       LINES: 211, 245
%     - DEFECT: Every '~' of the file name is replaced by the home folder
%       SEVERITY: limitation
%       TRIGGER: a file name starting with '~' that contains another '~', e.g. '~/maps/a~b.xml'
%       OBSERVED: strrep(fileName, '~', homePath) replaces each '~', not only the leading one
%       EXPECTED: only the leading '~' expanded
%       LINES: 69
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.
%     - Converted to the quarantine layout after the independent review (T027/T028), 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testTransformMap2XML'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
