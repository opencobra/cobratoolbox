% Tests functionality of selMatrix.

%save original directory
oriDir = pwd;

%change to test folder
mFilePath = mfilename('fullpath');
cd(mFilePath(1:end-length(mfilename)));

load ref.mat;

selMat1 = selMatrix(selVec1);
selMat2 = selMatrix(selVec2);
assert(isequal(selMat1,ref_selMat1))
assert(isequal(selMat2,ref_selMat2))


%return to original directory
cd(oriDir);
