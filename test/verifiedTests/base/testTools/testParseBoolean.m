% The COBRAToolbox: testParseBoolean.m
%
% Purpose:
%     - testParseBoolean tests the functionality of boolean parsing
%       and checks solution against known solution.
%
% Authors:
%     - Lemmer El Assal February 2017
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testParseBoolean'));
cd(fileDir);

str = '((A&B)|(B&C))&(~D)';
tokens = '&!()';

ref_elements = {'A', 'B', '|', 'C', '~D'};
ref_newRule = '((x(1)&x(2))|(x(2)&x(4)))&(x(5))';

[elements, newRule] = parseBoolean(str, tokens);

assert(isequal(ref_elements, elements))
assert(isequal(ref_newRule, newRule))

%
cellArr = {str};

ref_elements1 = {'A', 'B', 'C', 'D'};
ref_newRule1 = '((A & x(2)) | (B & x(3))) & (~x(4))';

[elements1, newRule1, rxnGeneMat] = parseBoolean(cellArr);

for i = 1:length(elements1)
    assert(isequal(elements1{i}, ref_elements1{i}))
end

assert(strcmp(ref_newRule1, newRule1) == 1)

assert(rxnGeneMat(1,2) == 1)
assert(rxnGeneMat(1,3) == 1)
assert(rxnGeneMat(1,4) == 1)

% test parseBoolean with str and 3 output arguments - throws a warning message
warning('off', 'all')
[elements, newRule, rxnGeneMat] = parseBoolean(str, tokens);
assert(length(lastwarn()) > 0)
warning('on', 'all')

% test parseBoolean with a random input argument
try
    [elements, newRule] = parseBoolean(0);
catch ME
    assert(length(ME.message) > 0)
end

% change the directory
cd(currentDir)
