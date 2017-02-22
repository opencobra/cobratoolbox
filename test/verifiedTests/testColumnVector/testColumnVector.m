% Tests functionality of columnVector.

%save original directory
oriDir = pwd;

%change to test folder
mFilePath = mfilename('fullpath');
cd(mFilePath(1:end-length(mfilename)));
cd(oriDir);

load ref.mat;

vecT = columnVector(vec);
assert(isequal(vecT,ref_vecT));

%return to original directory
cd(oriDir);