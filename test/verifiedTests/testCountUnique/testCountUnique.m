% Tests functionality of calcGroupStats.

%save original directory
oriDir = pwd;

%change to test folder
mFilePath = mfilename('fullpath');
cd(mFilePath(1:end-length(mfilename)));

load ref.mat;

vec = [1,2,4,5,6,1,2,4];
[sortedList, sortedCount] = countUnique(vec);

assert(isequal(ref_sortedList,sortedList));
assert(isequal(ref_sortedCount,sortedCount));

%return to original directory
cd(oriDir);
