function [rxnList, rxnFormulaList] = findRxnsFromMets(model, metList, varargin)
%findRxnsFromMets returns a list of reactions in which at least one
%metabolite listed in metList participates.
%
% [rxnList, rxnFormulaList] = findRxnsFromMets(model, metList, verbFlag)
%
%INPUTS
% model             COBRA model structure
% metList           Metabolite list
%
%OPTIONAL INPUT
% verbFlag          Print reaction formulas to screen (Default = false)
% Property/Value    Allowed Properties are: 
%                   containsAll (True/False) - If true only reactions
%                   containing all metabolites in metList are returned
%                   verbFlag (True/False) as Above, will overwrite a
%                   verbFlag set individually
%
%OUTPUTS
% rxnList           List of reactions
% rxnFormulaList    Reaction formulas coresponding to rxnList
%
%Richard Que (08/12/2010)
%Almut Heinken (09/25/2015)- made change so formulas are not printed if reaction list 
%                             is empty.
%Thomas Pfau (21/1/2016) - Additional Options, and minimal speedup of the indexing, 
%                           also updated behaviour of verbFlag to accurately reflect the description.
% 

verbFlag = false;
containsAll = false;
if isa(metList,'char')
    metList = {metList};
end
    

if mod(numel(varargin), 2) == 1 % the first argument has to be verbFlag, the remaining are property/value pairs
    verbFlag = varargin{1};
    if numel(varargin) > 1
        varargin = varargin(2:end);
    end
end

if numel(varargin) > 1 % we have already checked whether we have a verbFlag, now we can go for property/value pairs
    for i=1:2:numel(varargin)
        key = varargin{i};
        value = varargin{i+1};
        switch key
            case 'containsAll'
                containsAll = value;
            case 'verbFlag' 
                verbFlag = value;
            otherwise
                msg = sprintf('Unexpected key %s',key)
                error(msg);
        end
                
    end
end

%Find met indicies
index = ismember(model.mets,metList);
if containsAll
   rxnList = model.rxns(sum(model.S(index,:) ~= 0,1) == numel(metList));   
else
    %rxns = repmat(model.rxns,1,length(index));
    %find reactions i.e. all columns with at least one non zero value
    rxnList = model.rxns(sum(model.S(index,:)~=0,1) > 0);
end

if (nargout > 1) | verbFlag
    if ~isempty(rxnList)
        rxnFormulaList = printRxnFormula(model,rxnList,verbFlag);
    else
        rxnFormulaList={};
    end
end
