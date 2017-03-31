% Tests functionality of createDeltaMatchMatrix.

%save original directory
oriDir = pwd;

%change to test folder
mFilePath = mfilename('fullpath');
cd(mFilePath(1:end-length(mfilename)));

load ref.mat;

set1 = ones(5);
set2 = ones(5);

vec = createDeltaMatchMatrix(set1,set2);
assert(isequal(ref_vec,vec))


%return to original directory
cd(oriDir);
