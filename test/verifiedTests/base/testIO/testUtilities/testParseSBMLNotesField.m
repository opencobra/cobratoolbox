% The COBRAToolbox: testParseSBMLNotesField.m
%
% Purpose:
%     - parseSBMLNotesField reads reaction notes (gene rule, subsystem, EC number, formula, charge, citations, confidence, comments) from the <p> entries of an SBML notes text.
%       Characterization test that PINS the current behaviour (feature
%       026-tier1-test-batch2, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/base/io/utilities/parseSBMLNotesField.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects / quirks pinned (NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 026-tier1-test-batch2, 2026-10-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testParseSBMLNotesField'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

newLine = newline;

%% every recognised entry, with the <p> tag

notes = ['<p>GENE_ASSOCIATION: (g1 and g2)</p><p>SUBSYSTEM: S_Glycolysis_Gluco;Other</p>' ...
         '<p>EC Number: 1.1.1.1</p><p>FORMULA: C6H12O6</p><p>CHARGE: -2</p>' ...
         '<p>AUTHORS: Smith</p><p>AUTHORS: Jones</p><p>Confidence Level: 3</p>' ...
         '<p>NOTES: first note</p><p>NOTES: second:part</p><p>Custom: hello</p><p>Other2: world</p>'];
[subSystem, grRule, formula, confidenceScore, citation, comment, ecNumber, charge] = parseSBMLNotesField(notes);
% "S_" is removed from the subsystem, underscores become spaces and ";" separates subsystems
assert(isequal(subSystem, {'Glycolysis Gluco', 'Other'}));
assert(strcmp(grRule, '(g1 and g2)'));
assert(strcmp(formula, 'C6H12O6'));
assert(confidenceScore == 3);
% several AUTHORS entries are joined with ";"
assert(strcmp(citation, 'Smith;Jones'));
assert(strcmp(ecNumber, '1.1.1.1'));
assert(charge == -2);
% notes come first ("NOTES: ..." then further notes joined by ";"), then the other
% entries one per line
assert(strcmp(comment, ['NOTES: first note;second:part' newLine 'Custom: hello' newLine 'Other2: world']));

%% the other spellings, with the html:p tag

notes = ['<html:p>GPR_ASSOCIATION: g3</html:p><html:p>GENE ASSOCIATION: g4</html:p>' ...
         '<html:p>EC_Number: 2.2.2.2</html:p><html:p>Confidence_Level: 1</html:p>' ...
         '<html:p>Plain comment</html:p><html:p>NOTES: only note</html:p>'];
[subSystem, grRule, formula, confidenceScore, citation, comment, ecNumber, charge] = parseSBMLNotesField(notes);
% the last gene association wins
assert(strcmp(grRule, 'g4'));
assert(confidenceScore == 1);
assert(strcmp(ecNumber, '2.2.2.2'));
assert(strcmp(comment, ['NOTES: only note' newLine 'Plain comment']));
% entries that are not present keep their defaults
assert(isequal(subSystem, {''}));
assert(isempty(formula) && isempty(citation));
assert(isnan(charge));

%% notes and comments: ordering, and an empty NOTES entry is ignored

[~, ~, ~, ~, ~, comment] = parseSBMLNotesField('<p>NOTES: n1</p><p>Custom: c1</p><p>NOTES: n2</p>');
assert(strcmp(comment, ['NOTES: n1;n2' newLine 'Custom: c1']));

% only notes (no other comment): the notes are the comment
[~, ~, ~, ~, ~, comment] = parseSBMLNotesField('<p>NOTES: n1</p><p>NOTES:</p>');
assert(strcmp(comment, 'NOTES: n1'));

%% empty notes give the defaults

[subSystem, grRule, formula, confidenceScore, citation, comment, ecNumber, charge] = parseSBMLNotesField('');
assert(isequal(subSystem, {''}));
assert(isempty(grRule) && isempty(formula) && isempty(citation) && isempty(comment) && isempty(ecNumber));
assert(isnan(confidenceScore) && isnan(charge));

% change the directory
cd(currentDir)
