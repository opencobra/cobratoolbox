%testReporterMets tests the functionality of reporterMets.

%save original directory
oriDir = pwd;

%change to test folder
mFilePath = mfilename('fullpath');
cd(mFilePath(1:end-length(mfilename)));

load e_coli_core.mat % model
data = [];
nRand = 10;
pValFlag = 0;
nLayers = 2;
metric = {'default','mean','median','std','count'};
dataRxns = [];


for i=1:5
    [normScore,nRxnsMet,nRxnsMetUni,rawScore] = reporterMets(model,data,nRand,pValFlag,nLayers,metric{i},dataRxns);
end


%return to original directory
cd(oriDir);
