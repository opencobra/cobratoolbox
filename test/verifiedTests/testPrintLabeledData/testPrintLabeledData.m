%tests the functionality of printLabeledData.

%save original directory
oriDir = pwd;

labels = {'row1', 'row2', 'row3'};
data = ones(3);
nonzeroFlag = 1;
sortCol = -1;
fileName = 'test.txt';
headerRow = {'col1', 'col2', 'col3'};
sortMode = 'descend';


printLabeledData(labels,data);
printLabeledData(labels,data,nonzeroFlag,sortCol,fileName,headerRow,sortMode);

text1 = fileread('ref_test.txt');
text2 = fileread('test.txt');
assert(strcmp(text1, text2));


%change to test folder
mFilePath = mfilename('fullpath');
cd(mFilePath(1:end-length(mfilename)));