function model = changeRxnBounds(model,rxnNameList,value,boundType)
%changeRxnBounds Change upper or lower bounds of a reaction or a set of
%reactions
%
% model = changeRxnBounds(model,rxnNameList,value,boundType)
%
%INPUTS
% model         COBRA model structure
% rxnNameList   List of reactions (cell array or string)
% value         Bound values
%               Can either be a vector or a single scalar value if the same
%               bound value is to be assinged to all reactions
%
%OPTIONAL INPUT
% boundType     'u' - upper, 'l' - lower, 'b' - both (Default = 'b')
%               Bound type can either be a cell array of strings or a 
%               string with as many letters as there are reactions in 
%               rxnNameList
%
%OUTPUT
% model         COBRA model structure with modified reaction bounds
%
% Markus Herrgard 4/21/06

if (nargin < 4)
    boundType = 'b';
end

if ((length(value) ~= length(rxnNameList) & length(value) > 1) | (length(boundType) ~= length(rxnNameList) & length(boundType) > 1))
   error('Inconsistent lenghts of arguments: rxnNameList, value & boundType'); 
end

rxnID = findRxnIDs(model,rxnNameList);

% Remove reactions that are not in the model
if (iscell(rxnNameList))
    missingRxns = rxnNameList(rxnID == 0);
    for i = 1:length(missingRxns)
        fprintf('Reaction %s not in model\n',missingRxns{i});    
    end
    if (length(boundType) > 1)
        boundType = boundType(rxnID ~= 0);
    end
    if (length(value) > 1)
        value = value(rxnID ~= 0);
    end
    rxnID = rxnID(rxnID ~= 0);    
end

if (isempty(rxnID) | sum(rxnID) == 0)
    warning('No such reaction in model');
else
    nRxns = length(rxnID);
    if (length(boundType) > 1)
        if (length(value) == 1)
            value = repmat(value,nRxns,1);
        end
        for i = 1:nRxns
            switch lower(boundType{i})
                case 'u'
                    model.ub(rxnID(i)) = value(i);
                case 'l'
                    model.lb(rxnID) = value(i);
                case 'b'
                    model.lb(rxnID) = value(i);
                    model.ub(rxnID) = value(i);
            end
        end
    else
        switch lower(boundType)
            case 'u'
                model.ub(rxnID) = value;
            case 'l'
                model.lb(rxnID) = value;
            case 'b'
                model.lb(rxnID) = value;
                model.ub(rxnID) = value;
        end
    end
end