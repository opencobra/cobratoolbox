% The COBRAToolbox: testParseBoolean.m
%
% Purpose:
%     - testParseBoolean tests the functionality of boolean parsing
%       and checks solution against known solution.
%
% Authors:
%     - Lemmer El Assal February 2017
%

% tests the functionality of parseBoolean

%save original directory
oriDir = pwd;

%change to test folder
mFilePath = mfilename('fullpath');
cd(mFilePath(1:end-length(mfilename)));

str = '((A&B)|(B&C))&(~D)';
tokens = '&!()';

ref_elements = {'A','B','|','C','~D'};
ref_newRule = '((x(1)&x(2))|(x(2)&x(4)))&(x(5))';


[elements,newRule] = parseBoolean(str,tokens);

assert(isequal(ref_elements, elements))
assert(isequal(ref_newRule, newRule))

%return to original directory
cd(oriDir);