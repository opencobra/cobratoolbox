function printFluxBounds(model, rxns,rxnNameFlag)
% Prints the reactionID and upper/lower flux bounds.
%
% USAGE:
%
%   printFluxBounds(model, rxns)
%
% INPUTS:
%    model:    The model to print
%
% OPTIONAL INPUTS:
%    rxns:     a string array of reaction ids for which flux bounds need to
%              be printed
%
% .. Author:
%       - Thomas Pfau           May 2017
%       - Chintan Joshi         Feb 2019  optional input 'rxns'; prints
%                               flux bounds for the desired reactions only

if nargin < 2 || isempty(rxns)
    rxns = model.rxns;
end

rxnlength = cellfun(@length,rxns);
maxlength = max([rxnlength;11]);
fprintf(['%' num2str(maxlength) 's\t%14s\t%14s\n'],'Reaction ID','Lower Bound','Upper Bound');

bool = ismember(model.rxns,rxns);

if rxnNameFlag
    if min(abs(model.lb(bool)))>1e-2 & 0
        for i = 1: numel(rxns)
            fprintf(['%' num2str(maxlength) 's\t%14.3f\t%14.3f\t%s\n'],rxns{i}, ...
                model.lb(strcmp(model.rxns,rxns{i})),model.ub(strcmp(model.rxns,rxns{i})),model.rxnNames{strcmp(model.rxns,rxns{i})});
        end
    else
        for i = 1: numel(rxns)
            fprintf(['%' num2str(maxlength) 's\t%14.3e\t%14.3e\t%s\n'],rxns{i},...
                model.lb(strcmp(model.rxns,rxns{i})),model.ub(strcmp(model.rxns,rxns{i})),model.rxnNames{strcmp(model.rxns,rxns{i})});
        end
    end
else
    if min(abs(model.lb(bool)))>1e-2 
        for i = 1: numel(rxns)
            fprintf(['%' num2str(maxlength) 's\t%14.3f\t%14.3f\n'],rxns{i},...
                model.lb(strcmp(model.rxns,rxns{i})),model.ub(strcmp(model.rxns,rxns{i})));
        end
    else
        for i = 1: numel(rxns)
            fprintf(['%' num2str(maxlength) 's\t%14.3e\t%14.3e\n'],rxns{i},...
                model.lb(strcmp(model.rxns,rxns{i})),model.ub(strcmp(model.rxns,rxns{i})));
        end
    end
end
