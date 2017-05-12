function [transportRxnBool]=transportReactionBool(model)
%Return a boolean vector indicating which reactions transport between compartments.
%
% INPUT
% model.S       
% model.mets
%
% OPTIONAL INPUT
% numChar           number of characters in compartment identifier (default = 1)
%
% OUTPUT
% transportRxnBool  boolean vector indicating transport reactions
% 
%Ronan M.T. Fleming


[nMet,nRxn]=size(model.S);

transportRxnBool=false(nRxn,1);

[compartments,uniqueCompartments]=getCompartment(model.mets);  

for n=1:nRxn
    rxnCompartments=compartments(model.S(:,n)~=0);
    %should also omit exchange reactions
    if length(unique(rxnCompartments))>1
        transportRxnBool(n,1)=1;
    end
end
