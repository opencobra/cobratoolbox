% The COBRAToolbox: testPrintMetRxnInfo.m
%
% Purpose:
%     - printMetRxnInfo prints one metabolite or reaction as a line of text: optional field names,
%     then the values (text, lists of text joined with |, numbers, or matrices of numbers).
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%
% Function under test:
%     src/analysis/exploration/surfNetSubfunctions/printMetRxnInfo.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Line 43 of printMetRxnInfo.m (a value that is not text, a list of text or a number, for
%     example a logical) is uncovered because of the second defect below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Matrix values are separated by a comma without a space
%       SEVERITY: cosmetic
%       TRIGGER: a numeric matrix value
%       OBSERVED: strcat drops the trailing space of the separator, so rows print as 1.5,2; 3,4
%       EXPECTED: 1.5, 2; 3, 4
%       LINES: 38
%     - DEFECT: Other value types print as an unreadable character or error
%       SEVERITY: limitation
%       TRIGGER: a value that is a logical, or a nested cell
%       OBSERVED: a logical is printed as a control character and a nested cell makes fprintf error
%       EXPECTED: a readable text for such values or a clear error
%       LINES: 42-45
%
% Authors:
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPrintMetRxnInfo'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the printed text is captured with evalc, which is the only way to read it (Constitution VII-A);
% the captured text uses the unique variable name printedText

%% field names and numbers

% firstFieldWtComma = 2: the second field starts with a comma; names are printed
printedText = evalc('printMetRxnInfo({''name'', ''val''; ''abc'', 3.14159}, 2, true, {}, -6, 8, 8)');
assert(strcmp(printedText, sprintf('name: abc, val: 3.14159\n')));

%% no field names, every field starts with a comma, lists of text are joined with |

printedText = evalc('printMetRxnInfo({''name'', ''tags''; ''abc'', {''x'', ''y''}}, 1, false, {}, -6, 8, 8)');
assert(strcmp(printedText, sprintf(', abc, x|y\n')));

%% text, list of text and number together

printedText = evalc('printMetRxnInfo({''a'', ''b'', ''c''; ''x'', {''p'', ''q''}, 7}, 2, true, {}, -6, 8, 8)');
assert(strcmp(printedText, sprintf('a: x, b: p|q, c: 7\n')));

%% strings are printed like text

printedText = evalc('printMetRxnInfo({''a'', ''b''; "str", "s2"}, 1, true, {}, -6, 8, 8)');
assert(strcmp(printedText, sprintf(', a: str, b: s2\n')));

%% fields excluded from the field-name printing

% 'name' is in the excluded list: its value is printed without the name; other fields keep theirs
printedText = evalc('printMetRxnInfo({''name'', ''size''; ''abc'', 3}, 1, true, {''name''}, -6, 8, 8)');
assert(strcmp(printedText, sprintf(', abc, size: 3\n')));

%% a numeric matrix: rows are joined with ;

printedText = evalc('printMetRxnInfo({''m''; [1.5 2; 3 4]}, 1, true, {}, -6, 8, 8)');
% (the exact separator inside a row is not checked, see the header)
assert(startsWith(printedText, ', m: 1.5') && contains(printedText, '; 3') && contains(printedText, '4'));

% change the directory
cd(currentDir)
