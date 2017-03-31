%testFvaJaccardIndex tests the functionality of fvaJaccardIndex.

%save original directory
oriDir = pwd;

%change to test folder
mFilePath = mfilename('fullpath');
cd(mFilePath(1:end-length(mfilename)));

minFlux = ones(6)*0.1;
maxFlux = ones(6)*1;

J = fvaJaccardIndex(minFlux, maxFlux);

assert(isequal(ones(6,1),J));

%return to original directory
cd(oriDir);