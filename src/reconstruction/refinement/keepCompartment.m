function model = keepCompartment(model, compartments)
% This function removes reactions in all compartments except those
% specified by the cell array "compartments"
%
% USAGE:
%
%    model = keepCompartment(model, compartments)
%
% INPUTS:
%    model:           COBRA model structure with fields:
%
%                       * .S - `m x n` stoichiometric matrix
%                       * .mets - `m x 1` metabolite identifiers
%                       * .rxns - `n x 1` reaction identifiers
%    compartments:    cell array of strings (e.g., to discard all
%                     reactions except those in the mitochondria and
%                     cytosol, compartments = {'[m]', '[c]'};
%
% OUTPUT:
%    model:           COBRA model with reactions in the specified compartments
%
% .. Author: - Nathan Lewis, June 8, 2008

compartments = regexprep(compartments, '\[','\\\['); % compartments is a cell array list of compartments to keep (e.g. {'[e]','[c]','[m]'})
compartments = regexprep(compartments, '\]','\\\]');
% make a list of metabolites which are in the desired compartment
mets2keep = zeros(size(model.mets));
for i=1:max(size(compartments))
    a(:,i)=regexpi(model.mets,compartments{i});
    for j=1:max(size(a(:,i)))
        if not(isempty(a{j,i}))
            mets2keep(j,1)=1;
        end
    end
end
% make a list of rxns to remove
k=1;rxns2remove={};
for j=max(size(model.rxns)):-1:1
    for i=max(size(mets2keep)):-1:1
        if model.S(i,j) ~= 0 && mets2keep(i) == 0
            rxns2remove{k}=model.rxns{j};k=k+1;
            ID = findRxnIDs(model,model.rxns{j});
            printRxnFormula(model,model.rxns{j});
            hi=1;
        end
    end
end
% remove rxns
hi = 1;
if ~isempty(rxns2remove)
    model = removeRxns(model,rxns2remove);    
else display('No Compartments Removed')
end
end
