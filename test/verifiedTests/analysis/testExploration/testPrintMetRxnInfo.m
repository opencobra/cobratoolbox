% The COBRAToolbox: testPrintMetRxnInfo.m
%
% Purpose:
%     - printMetRxnInfo prints one metabolite or reaction as a line of text: optional field names,
%     then the values (text, lists of text joined with |, numbers, or matrices of numbers).
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test.
%     - Defect(s) fixed by feature 20261102-140321-tier1-safe-defect-fixes: Matrix values are
%       separated by a comma without a space; Other value types print as an unreadable character
%       or error.
%
% Function under test:
%     src/analysis/exploration/surfNetSubfunctions/printMetRxnInfo.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch3, 2026-10-12.
%     - Updated for feature 20261102-140321-tier1-safe-defect-fixes, 2026-11-02.

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
% (the exact separator inside a row is checked in the next section)
assert(startsWith(printedText, ', m: 1.5') && contains(printedText, '; 3') && contains(printedText, '4'));

%% a numeric matrix: values in a row are separated by a comma and a space

printedText = evalc('printMetRxnInfo({''m''; [1.5 2; 3 4]}, 1, true, {}, -6, 8, 8)');
assert(strcmp(printedText, sprintf(', m: 1.5, 2; 3, 4\n')));

%% logical values are printed as 1 or 0

printedText = evalc('printMetRxnInfo({''flag''; true}, 1, true, {}, -6, 8, 8)');
assert(strcmp(printedText, sprintf(', flag: 1\n')));
printedText = evalc('printMetRxnInfo({''flags''; [true false]}, 1, true, {}, -6, 8, 8)');
assert(strcmp(printedText, sprintf(', flags: 1, 0\n')));

%% values of other classes that convert to text are printed as before (else branch)

printedText = evalc('printMetRxnInfo({''c''; categorical({''x''})}, 1, true, {}, -6, 8, 8)');
assert(strcmp(printedText, sprintf(', c: x\n')));

%% a nested cell array or a structure stops with a clear error

% firstFieldWtComma = 2 and no field names, so nothing is printed before the error
assert(verifyCobraFunctionError('printMetRxnInfo', 'inputs', {{'nested'; {'a', 1}}, 2, false, {}, -6, 8, 8}, ...
    'testMessage', 'printMetRxnInfo: the value of field 1 is of class cell and cannot be printed. Use text, a cell array of text, a number or a logical.'));
assert(verifyCobraFunctionError('printMetRxnInfo', 'inputs', {{'s'; struct('a', 1)}, 2, false, {}, -6, 8, 8}, ...
    'testMessage', 'printMetRxnInfo: the value of field 1 is of class struct and cannot be printed. Use text, a cell array of text, a number or a logical.'));

% change the directory
cd(currentDir)
