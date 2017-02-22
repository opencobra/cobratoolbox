% test function for unioncell

% save original directory
oriDir = pwd;

%change to test folder
mFilePath = mfilename('fullpath');
cd(mFilePath(1:end-length(mfilename)));

load ref.mat;

A = {'String1','String2'};
B = {'String2','String1'};

AB{1} = unioncell(A,1,B,1);
AB{2} = unioncell(A,1,B,2);
AB{3} = unioncell(A,2,B,1);
AB{4} = unioncell(A,2,B,2);

assert(isequal(ref_AB,AB))

%return to original directory
cd(oriDir);
