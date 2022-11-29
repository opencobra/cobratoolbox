function [model] = addElementTracker(model,Element,rxnTags)
% 
%addElementTracker creates artificial metabolites and reactions that track
%the flux of a particular element through reactions with specified
%string tags.
%
%USAGE:
%
% [model] = addElementTracker(model,Element,rxnTags,trackString)
%
% INPUTS:
%    model:          COBRA model structure with minimal fields:
%                      * .S
%                      * .c
%                      * .ub
%                      * .lb
%                      * .mets  
%                      * .rxns  
%   Element:       element you are interested in (e.g., 'N')
%   rxnTags:       string or cell array containing the strings that mark 
%                  reactions of interest to keep track of 
%
%Outputs
%   model: Returns the input model with added tracking reactions and the
%   key "Track" reaction
%
%Authors: Bronson R. Weston 2022

%Identify rxnTag reactions
if isstr(rxnTags)
    rxnTags={rxnTags};
end

exretionRxnIDs=[];
for i=1:length(rxnTags)
    IDs=find(contains(model.rxns,rxnTags{i}));
    exretionRxnIDs=[exretionRxnIDs,IDs];
end

exMetIDs=[];
for i=1:length(exretionRxnIDs)
    x=find(model.S(:,exretionRxnIDs(i))~=0).';
    exMetIDs=[exMetIDs,x];
end
if length(exMetIDs)~= length(exretionRxnIDs)
    error('Model not compatible with addElementTracker function due to complex exretion reations')
end

%Add a metabolite to track the the element from each relevant
%reaction
model=addMetabolite(model, [Element,'[excretion]']);
elementCount=zeros(1,length(exretionRxnIDs));
for i=1:length(exretionRxnIDs)
    %for each reaction get the stoichiometry of the element exreted
    [~,stoich]=getMolFormula(model,model.mets(exMetIDs(i)));
    for e=1:length(stoich(:,1))
        if strcmp(stoich{e,1},Element)
            elementCount(i)=stoich{e,2};
            break
        end
    end
    
end

elementID=contains(model.mets,[Element,'[excretion]']);

model.S(elementID,exretionRxnIDs)=elementCount;
model=addReaction(model,[Element,'_Track'],'reactionFormula',[Element,'[excretion] ->'],'l',0,'u', 1e9);

end