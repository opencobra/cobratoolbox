function modelRev = convertToReversible(model)
% Converts a model structure from irreversible format to
% reversible format
%
% USAGE:
%
%    modelRev = convertToReversible(model)
%
% INPUT:
%    model:       COBRA model in irreversible format (forward/backward reactions separated)
%                 forward reactions have to be marked with an _f in the id,
%                 backward with an _b. reverse reactions (i.e. reactions
%                 which were originally only allowed to carry negative flux
%                 must have a _r tag at the end of the reaction id.
%                 It is further assumed, that there is an exact 1:1 match
%                 between _f and _b reactions. 
%
% OUTPUT:
%    modelRev:    Model in reversible format
%
% .. Author: - Greg Hannum 7/22/05
%
%
%

nRxns = length(model.rxns);
%indicator for reactions already handled
rxnProcessed = false(length(model.rxns),1);
%get the basic names of the reactions.
reactionbasenames = regexprep(model.rxns,'(_f|_r|_b)$','');
%Get the reaction positions which need to be reversed
reversePos = ~cellfun(@isempty ,regexp(model.rxns,'(_r|_b)$'));
%and those, which will be deleted (all backwards. Since backward only
%reactions are marked with an _r, we should always have a _f which is the
%other matching reaction.
reactionsToRemove = ~cellfun(@isempty ,regexp(model.rxns,'(_b)$'));

%and replace the names
model.rxns = reactionbasenames;


%We can directly update the lower bounds and stoichiometries of reverse reactions
%The assumption is, that all reverse reaction bounds and forward reaction
%bounds are consistent.
templbs = model.lb(reversePos);
model.lb(reversePos) = -model.ub(reversePos);
model.ub(reversePos) = -templbs;
model.S(:,reversePos) = -model.S(:,reversePos); 


%update all reactions

for i = 1:numel(reactionbasenames)
    if(rxnProcessed(i))
        continue;
    end    
    matches = ismember(reactionbasenames,reactionbasenames{i});
    rxnProcessed = rxnProcessed | matches;
    if(sum(matches) > 1)
        %We only need to do something if we have a forward/backward pair.
        %otherwise we don't do anything (since the input format is not
        %matched.
        revpos = reversePos & matches;
        fwpos = ~reversePos & matches;
        model.lb(fwpos) = min(model.lb(revpos), model.lb(fwpos));
        model.ub(fwpos) = max(model.ub(revpos), model.ub(fwpos));
    end
end

%Remove the surplus model fields (they should be the same anyways)
modelRev = removeFieldEntriesForType(model,reactionsToRemove,'rxns',nRxns);

%and remove a potential "match field
if isfield(modelRev, 'match')
    modelRev = rmfield(modelRev,'match');
end
modelRev.reversibleModel = true;
