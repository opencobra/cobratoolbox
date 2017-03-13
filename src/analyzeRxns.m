function [allRxns,rxnCount] = analyzeRxns(product,listProducts,listRxns)
%analyzeRxns       determines which knockout reactions occur most often
%                  when a specified product is produced
%
% [allRxns, rxnCount] = analyzeRxns(product,listProducts,listRxns)
%
%INPUTS
% product          the product to investigate
% listProducts     the list of all products produced in a RandKnock
% listRxns         the list of all rxns knocked out in a RandKnock
%
%OUTPUTS
% allRxns          all of the rxns knocked out in strains producing the
%                  product
% rxnCount         the number of times each rxn was knocked out
%
% Jeff Orth (6/20/07)

%find all product producers
makesProd = [];
showprogress(0,['finding ',product,' producing strains']);
for i = 1:length(listProducts)
    showprogress(i/length(listProducts));
    pos = strmatch(product,listProducts{i});
    if pos ~= 0
        makesProd = [makesProd,i];
    end
end

%determine which reactions are knocked out in each strain, return the
%frequency of each knockout reactions
allRxns = [];
rxnCount = [];
for i = 1:length(makesProd)
    rxns = listRxns(makesProd(i));
    rxns = rxns{1};
    for j = 1:length(rxns)
        rxn = rxns(j);
        %if reaction has not been added to list yet, add it
        match = strcmp(rxn,allRxns);
        if length(find(match)) == 0
            allRxns = [allRxns,rxn];
            rxnCount = [rxnCount,1];
        else
            rxnCount(find(match)) = rxnCount(find(match))+1;
        end
    end
end
