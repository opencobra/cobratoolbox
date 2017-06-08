function [modelIrrev, matchRev, rev2irrev, irrev2rev] = convertToIrreversible(model, sRxns, leaveInverse)
% Converts model to irreversible format, either for the entire model or for
% a defined list of reversible reactions.
%
% USAGE:
%
%    [modelIrrev, matchRev, rev2irrev, irrev2rev] = convertToIrreversible(model, sRxns)
%
% INPUT:
%    model:         COBRA model structure
%
% OPTIONAL INPUTS:
%    sRxns:         List of specific reversible reactions to convert to
%                   irreversible (Default = model.rxns)
%    leaveInverse:  Do not alter reactions that can only carry negative
%                   flux, normally, those are flipped and marked with '_r'
%                   (Default = false)
% OUTPUTS:
%    modelIrrev:    Model in irreversible format
%    matchRev:      Matching of forward and backward reactions of a reversible reaction
%    rev2irrev:     Matching from reversible to irreversible reactions
%    irrev2rev:     Matching from irreversible to reversible reactions
%
% NOTE:
%   Uses the reversible list to construct a new model with reversible
%   reactions separated into forward and backward reactions.  Separated
%   reactions are appended with '_f' and '_b' and the reversible list tracks
%   these changes with a '1' corresponding to separated forward reactions.
%   Reactions entirely in the negative direction will be reversed and
%   appended with '_r'.
%
% .. Authors:
%       - written by Gregory Hannum 7/9/05
%       - Modified by Markus Herrgard 7/25/05
%       - Modified by Jan Schellenberger 9/9/09 for speed.
%       - Modified by Diana El Assal & Fatima Monteiro 6/2/17 allow to
%         optionally only split a specific list of reversible reactions to
%         irreversible, without appending '_r'.
%       - Modified by Thomas Pfau June 2017 - Also include all fields
%         associated to reactions.

if ~exist('sRxns','var')
    sRxns = model.rxns;
end

if ~exist('leaveInverse','var')
    leaveInverse = 0;
end

%Flip all pure backward reactions and append a _r
backReacs = ismember(model.rxns,sRxns) & model.lb < 0 & model.ub <= 0;

if ~leaveInverse
    model.S(:,backReacs) = -model.S(:,backReacs);
    templbs = -model.ub(backReacs);
    model.ub(backReacs) = -model.lb(backReacs);
    model.lb(backReacs) = templbs;
    model.c(backReacs) = - model.c(backReacs); %Also flip the objective coefficient, as otherwise the target changes.
    model.rxns(backReacs) = strcat(model.rxns(backReacs),'_r');
end

%
% Note: reactions which can only carry negative flux, will have an inactive
% forward reaction.
revReacs = ismember(model.rxns,sRxns) & model.lb < 0 & model.ub > 0;
nRevRxns = sum(revReacs);
nRxns = numel(model.rxns);
rxnIDs = 1:nRxns;
irrevRxnIDs = nRxns + (1:nRevRxns);


%teat special fields: S, lb, ub, rxns
model.S(:,end+1:end+nRevRxns) = -model.S(:,revReacs);

%update the lower and upper bounds (first for the reversed reactions, as
%otherwise the information is lost
model.ub(end+1:end+nRevRxns) = max(0,-model.lb(revReacs));
model.lb(end+1:end+nRevRxns) = max(0,-model.ub(revReacs));
model.lb(revReacs) = max(0,model.lb(revReacs));
model.ub(revReacs) = max(0,model.ub(revReacs));

%Extend the c vector by the negative (otherwise the objective changes)
model.c(end+1:end+nRevRxns) = -model.c(revReacs);

%Alter the reaction ids (as defined)
RelReacNames = model.rxns(revReacs);
model.rxns(revReacs) = strcat(RelReacNames,'_f');
model.rxns(end+1:end+nRevRxns) = strcat(RelReacNames,'_b');

%And update all other relevant fields (which have not yet been altered)
fields = getRelevantModelFields(model,'rxns','fieldSize',nRxns);
for i = 1:length(fields)    
    cfield = fields{i};
    if size(model.(cfield),1) == nRxns
        model.(cfield)(end+1:end+nRevRxns,:) = model.(cfield)(revReacs,:);
    elseif size(model.(cfield),2) == nRxns
        model.(cfield)(:,end+1:end+nRevRxns) = model.(cfield)(:,revReacs);
    end
end


%Now, map the reactions
irrev2rev = [rxnIDs';rxnIDs(revReacs)'];
rev2irrev = num2cell(rxnIDs');
rev2irrev(revReacs) = num2cell([rxnIDs(revReacs)',irrevRxnIDs'],2);
matchRev = zeros(size(model.rxns));
matchRev(revReacs) = irrevRxnIDs;
matchRev(irrevRxnIDs) = rxnIDs(revReacs);

%Mark the model type.
modelIrrev = model;
modelIrrev.match = matchRev;
modelIrrev.reversibleModel = false;