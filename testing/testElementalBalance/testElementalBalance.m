function statusOK = testElementalBalance()
% Tests computeMW functionality

statusOK = 1;
%load Model and Data
load('testElementalBalanceData.mat');

%run elmental Balance no optional functions
[MW Ematrix] = computeMW(model);

%check Solution
if ~isequal(MW, stdMW)
    display('Error calculating molecular weights');
    statusOK = 0;
end
if ~isequal(Ematrix, stdEmatrix)
    display('Error computing Ematrix');
    statusOK = 0;
end

%run computeMW specifying met list
[MW Ematrix] = computeMW(model,model.mets(25:35),false);
%check Solution
if ~isequal(MW, stdMW2)
    display('Error calculating molecular weights');
    statusOK = 0;
end
if ~isequal(Ematrix, stdEmatrix2)
    display('Error computing Ematrix');
    statusOK = 0;
end



