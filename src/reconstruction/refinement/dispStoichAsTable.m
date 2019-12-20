function T = dispStoichAsTable(model,printLevel)
%display stoichiometric matrix as a table
%
%INPUT
% model 
%
%OUTPUT
% Table

if ~exist('printLevel','var')
    printLevel=1;
end

T=array2table(model.S);
T.Properties.VariableNames=model.rxns;
T.Properties.RowNames=model.mets;

if printLevel>0
    display(T)
end

