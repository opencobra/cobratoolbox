% Tests functionality of translateList.

%save original directory
oriDir = pwd;

%change to test folder
mFilePath = mfilename('fullpath');
cd(mFilePath(1:end-length(mfilename)));

list = {'a','b','c'};
trList1 = {'b','c'};
trList2 = {'B','C'};
newList = translateList(list,trList1,trList2);
assert(isequal(newList,{'a','B','C'}))


%return to original directory
cd(oriDir);
