function T = dispStoichAsTable(model, printLevel)
% Display the stoichiometric matrix as a table
%
% USAGE:
%
%    T = dispStoichAsTable(model, printLevel)
%
% INPUTS:
%    model:         COBRA model structure with fields:
%
%                     * .S - `m x n` stoichiometric matrix
%                     * .rxns - `n x 1` cell array of reaction identifiers
%                     * .mets - `m x 1` cell array of metabolite identifiers
%
% OPTIONAL INPUTS:
%    printLevel:    Verbose level (0 = silent, 1 = display the table (default))
%
% OUTPUT:
%    T:             Table representation of the stoichiometric matrix, with
%                   reactions as variables and metabolites as row names

if ~exist('printLevel','var')
    printLevel=1;
end

T=array2table(model.S);
T.Properties.VariableNames=model.rxns;
T.Properties.RowNames=model.mets;

if printLevel>0
    display(T)
end

