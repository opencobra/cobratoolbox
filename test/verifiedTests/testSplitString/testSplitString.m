% Tests functionality of splitString.

%save original directory
oriDir = pwd;

%change to test folder
mFilePath = mfilename('fullpath');
cd(mFilePath(1:end-length(mfilename)));

load ref.mat;


testString1 = 'Some Strings Delimited';
testString2 = 'Some|Strings|Delimited';
fields1 = splitString(testString1);
fields2 = splitString(testString2,'\|');

assert(isequal(ref_fields,fields1))
assert(isequal(ref_fields,fields2))

%return to original directory
cd(oriDir);
