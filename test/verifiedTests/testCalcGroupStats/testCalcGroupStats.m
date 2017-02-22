% Tests functionality of calcGroupStats.

%save original directory
oriDir = pwd;

%change to test folder
mFilePath = mfilename('fullpath');
cd(mFilePath(1:end-length(mfilename)));

load ref.mat;

data = ones(5)*6;
statname = {'mean','std','median','count'};
groups = {'test1','test2','test3','test4','test1'};

ref_groupCnt = [2;1;1;1];

for i = 1:4 
    [groupStat(:,:,i),groupList,groupCnt] = calcGroupStats(data,groups,statname{i},ref_groupList,1,10);
    assert(isequal(ref_groupList, groupList));
    assert(isequal(ref_groupCnt, groupCnt));
    %assert(isequal(groupStat,data));
end

assert(isequal(ref_groupStat,groupStat))

%return to original directory
cd(oriDir);
