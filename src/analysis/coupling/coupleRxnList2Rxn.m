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

rxnCPos = find(ismember(model.rxns,rxnC));

if ~any(rxnCPos)
    error('Reaction not in model!');    
elseif any(~ismember(rxnList,model.rxns))
    notpres = ~ismember(rxnList,model.rxns);
    error('The following reactions are missing from the model:\n%s\nNot adding Constraints.',strjoin(rxnList(notpres),'; '));
else
    %Remove duplicate rxns from rxnList
    targetInList = false;
    rxnList = unique(rxnList);
    rxnPosList = columnVector(cellfun(@(x) find(ismember(model.rxns,x)),rxnList));
    [pres,pos] = ismember(rxnCPos,rxnPosList);
    if any(pres)
        targetRxnList = rxnCPos(pres);
        rxnPosList(pos) = [];
        targetInList = true;
    end
    revReacs = find(model.lb(rxnPosList) < 0);
    nRxns = length(rxnPosList);
    %We will initially create a List with forward and backward for all:
    dsense = repmat(['L';'G'],nRxns,1);
    constraintC = repmat([1, -c * ones(1,numel(rxnCPos)); 1, c * ones(1,numel(rxnCPos))],nRxns,1);
    d = repmat([u;-u],nRxns,1);    
    IDs = strcat('slack_', model.rxns(rxnPosList));
    BIDs = strcat('slack_', model.rxns(rxnPosList), '_B');
    rxnPosList = reshape([rxnPosList,rxnPosList]',nRxns*2,1); %(1; 1; 2;2; ...);    
    constraintRxns = [rxnPosList, repmat(rxnCPos,2*nRxns,1)];    
    ConstraintIDs = reshape([IDs,BIDs]',2*nRxns,1);
    %And now remove all the non reversible reaction positions.
    constraintRxns(2*revReacs,:) = [];
    dsense(2*revReacs,:) = [];
    constraintC(2*revReacs,:) = [];
    d(2*revReacs,:) = [];
    ConstraintIDs(2*revReacs,:) = [];
    
    modelCoupled = model;        
    modelCoupled = addCOBRAConstraint(modelCoupled,constraintRxns,d,'dsense',dsense,'c', constraintC,'ConstraintID', ConstraintIDs);
    if targetInList         
        % This is odd, but it could be. 
        % according to the old code: modelCoupled.C(i,rxnCPos) = c(i) for
        % each reaction in rxnCPos. with u  as rhs and 'L' as sense. 
        % If any of those reactions is reversible, then also add the
        % opposite one. This was potentially duplicating quite some
        % constraints..
        % 
        modelCoupled = addCOBRAConstraint(modelCoupled,rxnCPos,u,'c',[1, -c * ones(1,numel(rxnCPos))],...
            'dsense','L','ConstraintID', strcat('slack_', model.rxns(rxnCPos(1))));
        if any(model.lb(rxnCPos) < 0)
            modelCoupled = addCOBRAConstraint(modelCoupled,rxnCPos, -u,'c',[1, c * numel(1,sum(rxnCPos))],...
                'dsense','G','ConstraintID', strcat('slack_', model.rxns(rxnCPos(1))));
        end                
    end    
        
end


