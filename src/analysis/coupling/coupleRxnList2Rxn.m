function [modelCoupled] = coupleRxnList2Rxn(model, rxnList, rxnC, c, u)
% This function adds coupling constraints to the fluxes `vi` of a given list of reactions
% (`RxnList`).The constraints are proportional to the flux `v` of a specified
% reaction `rxnC`, so that for all reactions in `RxnList` `vi ~ vrxnC`.
% For all reactions, a threshold `u` on flux is set (default value: 0.01).
%
% To add a coupling constraint to a reaction, a coupling vector `c` is
% determined (default value 1000). `c` is multiplied by `vrxnC`, so that for
% all irreversible reactions in `RxnList vi - c * vrxnC <= u`.
%
% For all reversible reactions, the following equation holds true for the
% reverse direction: `vi + c * vrxnC >= u`.
%
% The output is a coupled model (`modelCoupled`), in which for every new
% entry in `modelCoupled.b` a "slack" variable has been added
% to `modelCoupled.mets`.
%
% USAGE:
%
%    [modelCoupled] = coupleRxnList2Rxn(model, rxnList, rxnC, c, u)
%
% INPUTS:
%    model:           model structure
%    rxnList:         array of reaction names
%    rxnC:            reaction that should be coupled with each reaction in the
%                     reaction list
%    c:               vector of coupling factors for each rxn in rxnList (default c = 1000)
%    u:               vector of lower bounds one reaction couples (default u = 0.01)
%
% OUTPUT:
%    modelCoupled:    coupled model
%
% .. Authors:
%    - Sept 2011 AH/IT
%    - May 2012: Added a warning if the coupled reaction is not in model. AH
%    - Nov 2017 TP, Updated to use C * v = d.

if ~exist('rxnList', 'var') || isempty(rxnList)
    rxnList = model.rxns;
end

if ~exist('c', 'var') || isempty(c)
    c = 1000;
end

if ~exist('u', 'var') || isempty(u)
    u = 0.01;
end

rxnCPos = ismember(model.rxns,rxnC);

if ~any(rxnCPos)
    error('Reaction not in model!');    
elseif any(~ismember(rxnList,model.rxns))
    notpres = ~ismember(rxnList,model.rxns);
    error('The following reactions are missing from the model:\n%s\nNot adding Constraints.',strjoin(rxnList(notpres),'; '));
else
    modelCoupled = model;        
    for i = 1:length(rxnList)                
        RPos = ismember(model.rxns,rxnList(i));
        %Add vi - c * vrxnC <= u
        modelCoupled = addCOBRAConstraint(modelCoupled,[rxnList(i);model.rxns(rxnCPos)],u,'dsense', 'L','c', [1, -c * ones(1,sum(rxnCPos))],'ConstraintID',strcat('slack_', rxnList{i}));
        % for reversible reactions we add a "mirror" constraint
        if modelCoupled.lb(RPos) < 0
            % Add `vi + c * vrxnC >= u`.
            modelCoupled = addCOBRAConstraint(modelCoupled,[rxnList(i);model.rxns(rxnCPos)],-u,'dsense', 'G', 'c', [1, c * ones(1,sum(rxnCPos))],'ConstraintID',strcat('slack_', rxnList{i}, '_R'));            
        end
    end
end


