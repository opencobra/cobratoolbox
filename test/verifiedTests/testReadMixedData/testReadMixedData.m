%testReadMixedData tests the functionality of readMixedData.

%save original directory
oriDir = pwd;

%change to test folder
mFilePath = mfilename('fullpath');
cd(mFilePath(1:end-length(mfilename)));


file = 'test.txt';
n_header = 1;
n_labels = 3;
delimiter = ',';
verbose = 1;

[id,data,header] = readMixedData(file,n_header,n_labels,delimiter,verbose);

load ref.mat
assert(isequal(ref_data, data))
assert(isequal(ref_header, header))
assert(isequal(ref_id, id))


%return to original directory
cd(oriDir);
