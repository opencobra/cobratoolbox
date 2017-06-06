%testPrintMatrix tests the functionality of printMatrix.

%save original directory
oriDir = pwd;

%change to test folder
mFilePath = mfilename('fullpath');
cd(mFilePath(1:end-length(mfilename)));

A = ones(6)*6;
A = A + (A / 10) + (A / 100);
format = '%6.2f\t';
file = 'test.txt';


retStatus = printMatrix(A);
assert(retStatus == 1);

retStatus = printMatrix(A, format, file);
assert(retStatus == 1);

text1 = fileread('test.txt');
text2 = fileread('ref_test.txt');
assert(strcmp(text1, text2))

%return to original directory
cd(oriDir);
