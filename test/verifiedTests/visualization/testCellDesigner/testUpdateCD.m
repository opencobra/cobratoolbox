% The COBRAToolbox: testUpdateCD.m
%
% Purpose:
%     - updateCD replaces species names in the lines of a CellDesigner XML file (a structure
%       array whose .str fields hold one line each, as stored by parseCD) by the names in column
%       2 of parsed.r_info.species. In a first round the name attribute of each "<species " line
%       is replaced by the name of the species row with the same position; in a second round the
%       text of each "<celldesigner:name>" line is replaced in the same way. With note 'true'
%       the old and new names are recorded in results.col. Without a species list in
%       parsed.r_info the text is returned unchanged with a warning.
%       Characterization test that PINS the current behaviour (feature
%       20261103-105830-tier2-safe-batch, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Expected values are derived by hand from the hand-built XML lines and species lists.
%       Names are chosen so that they occur only once in their line (see the strrep defect
%       below); results.changedStrLines, and results.number when a second round finds lines,
%       are not asserted because of the defects below. results.number is asserted only where
%       every listed line had its name replaced.
%
% Function under test:
%     src/visualization/cellDesigner/updateCD.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     - Line 113: the error for a line that is not a cell is unreachable, because the line was
%       converted with cellstr at line 95.
%     - Line 122: the catch of the replacement is only reached if strrep fails, which it does not
%       for character names.
%     - Lines 161-162: the catch and error of the subfunction position are unreachable, because
%       position is only called for a line in which strfind found the keyword (lines 106-107).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The documented default value of note stops with an error
%       SEVERITY: unusable-option
%       TRIGGER: updateCD(text, parsed, '0') (any note other than 'true')
%       OBSERVED: error "Unrecognized function or variable 'ConductCol'" at line 130 once a name
%         is replaced (and col is undefined at line 148 otherwise)
%       EXPECTED: no record of the replaced names, as without note
%       LINES: 38-45, 130, 148
%     - DEFECT: changedStrLines lists only the lines changed in the second round
%       SEVERITY: wrong-result
%       TRIGGER: a text whose "<species " lines are renamed, e.g. the text of the first section
%         below
%       OBSERVED: changedStrLines is reset before the second round, so it is empty although two
%         lines were changed
%       EXPECTED: every changed line, as the help text states
%       LINES: 87-88, 128
%     - DEFECT: number lists only the lines found in the second round
%       SEVERITY: wrong-result
%       TRIGGER: a text with both "<species " and "<celldesigner:name>" lines, e.g. the text of
%         the fourth section below
%       OBSERVED: number = [3; 6], the "<celldesigner:name>" lines overwrite the "<species "
%         lines found first
%       EXPECTED: [2; 3; 5; 6], every line where a replacement was found
%       LINES: 56, 76-77
%     - DEFECT: The second round pairs name lines with species rows by position and stops early
%       SEVERITY: wrong-result
%       TRIGGER: more "<celldesigner:name>" lines than "<species " lines, or name lines in another
%         order (e.g. glycolysisAndTCA.xml has 107 name lines and 67 species lines)
%       OBSERVED: only as many name lines as species lines are processed, and the d-th name line
%         receives the d-th species name whichever species it belongs to (a species line "a"
%         followed by name lines "b" and "a" renames "b" and leaves "a")
%       EXPECTED: each name line renamed with the name of its own species
%       LINES: 81-85, 90-92
%     - DEFECT: Every occurrence of the old name in the line is replaced
%       SEVERITY: wrong-result
%       TRIGGER: a name that also occurs elsewhere in its line, e.g. name="a" in
%         '<species metaid="s1" id="s1" name="a" compartment="c">'
%       OBSERVED: strrep replaces every "a" of the line: metAid, nAme, compArtment
%       EXPECTED: only the name value replaced
%       LINES: 117, 121
%     - DEFECT: A text without "<species " lines stops with an error
%       SEVERITY: error
%       TRIGGER: a text with "<celldesigner:name>" lines but no "<species " line
%       OBSERVED: error "Unrecognized function or variable 'number'" at line 82
%       EXPECTED: the text returned unchanged
%       LINES: 77, 82
%     - DEFECT: Debug output of internal variables
%       SEVERITY: cosmetic
%       TRIGGER: any call that finds a species line
%       OBSERVED: lines without a terminating semicolon and disp calls print the search pattern,
%         keyword, mark, line counts, sizes, loop index, column number, matched positions and
%         every changed line, and a warning "starting the second round of the program" is issued
%       EXPECTED: no debug output
%       LINES: 58, 61, 63, 65, 82, 95, 98-101, 106, 115, 121, 132, 160, 164
%
% Authors:
%     - Generated for feature 20261103-105830-tier2-safe-batch, 2026-11-03.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testUpdateCD'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% XML lines with two species; each line is stored as a 1 x 1 cell, as parseCD stores them
speciesLines = {'<sbml>'
                '<species metaid="s1" id="s1" name="glc_D[c]" compartment="c">'
                '</species>'
                '<species metaid="s2" id="s2" name="g6p[c]" compartment="c">'
                '</species>'
                '</sbml>'};
speciesText = struct('str', cellfun(@cellstr, speciesLines, 'UniformOutput', false));

% the reference names, one row per species in the order of the species lines (column 2)
parsed = struct();
parsed.r_info.species = {'s1', 'D-glucose[c]'; 's2', 'glucose 6-phosphate[c]'};

%% the name attribute of each species line is replaced by the reference name

results = updateCD(speciesText, parsed);

newLines = [results.text.str]';
assert(isequal(newLines, {'<sbml>'
                          '<species metaid="s1" id="s1" name="D-glucose[c]" compartment="c">'
                          '</species>'
                          '<species metaid="s2" id="s2" name="glucose 6-phosphate[c]" compartment="c">'
                          '</species>'
                          '</sbml>'}));
% the lines that hold a species, and no record of the names without note
assert(isequal(results.number, [2; 4]));
assert(isequal(results.col, {}));

%% with note 'true' the old and new names are recorded

results = updateCD(speciesText, parsed, 'true');

assert(isequal(results.col, {'glc_D[c]', 'D-glucose[c]'; 'g6p[c]', 'glucose 6-phosphate[c]'}));
assert(isequal(results.number, [2; 4]));
assert(isequal(results.text(2).str, {'<species metaid="s1" id="s1" name="D-glucose[c]" compartment="c">'}));

%% a species line without a name attribute is left unchanged

lines = {'<sbml>'
         '<species metaid="s1" id="s1" compartment="c">'
         '<species metaid="s2" id="s2" name="g6p[c]" compartment="c">'
         '</sbml>'};
text = struct('str', cellfun(@cellstr, lines, 'UniformOutput', false));

results = updateCD(text, parsed);

% the second species line takes the name of the second species row
assert(isequal([results.text.str]', {'<sbml>'
                                     '<species metaid="s1" id="s1" compartment="c">'
                                     '<species metaid="s2" id="s2" name="glucose 6-phosphate[c]" compartment="c">'
                                     '</sbml>'}));

%% CellDesigner name lines are replaced in the second round

lines = {'<sbml>'
         '<species metaid="s1" id="s1" name="glc_D[c]" compartment="c">'
         '<celldesigner:name>glc_D[c]</celldesigner:name>'
         '</species>'
         '<species metaid="s2" id="s2" name="g6p[c]" compartment="c">'
         '<celldesigner:name>g6p[c]</celldesigner:name>'
         '</species>'
         '</sbml>'};
text = struct('str', cellfun(@cellstr, lines, 'UniformOutput', false));

results = updateCD(text, parsed);

% both the name attributes and the CellDesigner names are replaced
assert(isequal([results.text.str]', {'<sbml>'
                                     '<species metaid="s1" id="s1" name="D-glucose[c]" compartment="c">'
                                     '<celldesigner:name>D-glucose[c]</celldesigner:name>'
                                     '</species>'
                                     '<species metaid="s2" id="s2" name="glucose 6-phosphate[c]" compartment="c">'
                                     '<celldesigner:name>glucose 6-phosphate[c]</celldesigner:name>'
                                     '</species>'
                                     '</sbml>'}));

%% without a species list the text is returned unchanged with a warning

noSpecies = struct();
noSpecies.r_info.ID = {};
lastwarn('');
results = updateCD(speciesText, noSpecies);

assert(strcmp(lastwarn(), 'cannot find the field name ''species'''));
assert(isequal(results.text, speciesText));
assert(isequal(results.col, {}));

% change the directory
cd(currentDir)
