% The COBRAToolbox: testParseBoolean.m
%
% Purpose:
%     - testParseBoolean tests the functionality of boolean parsing
%       and checks solution against known solution.
%
% Authors:
%     - Lemmer El Assal February 2017
%

% define the path to The COBRAToolbox
pth = which('initCobraToolbox.m');
CBTDIR = pth(1:end-(length('initCobraToolbox.m') + 1));

initTest([CBTDIR, filesep, 'test', filesep, 'verifiedTests', filesep, 'testTools']);

str = '((A&B)|(B&C))&(~D)';
tokens = '&!()';

ref_elements = {'A', 'B', '|', 'C', '~D'};
ref_newRule = '((x(1)&x(2))|(x(2)&x(4)))&(x(5))';

[elements, newRule] = parseBoolean(str, tokens);

assert(isequal(ref_elements, elements))
assert(isequal(ref_newRule, newRule))

% change the directory
cd(CBTDIR)
