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
modelRev = removeRelevantModelFields(model,reactionsToRemove,'rxns',nRxns);

%and remove a potential "match field
if isfield(modelRev, 'match')
    modelRev = rmfield(modelRev,'match');
end
modelRev.reversibleModel = true;
    
%         
%     
%     
%     
% modelRev.rxns = {}; % Initialize
% modelRev.S = [];
% modelRev.lb = [];
% modelRev.ub = [];
% modelRev.c = [];
% 
% % Has this rxn been processed
% 
% cnt = 0;
% for i = 1:length(model.rxns)
%   if (model.match(i) == 0)
%     % Non-reversible reaction
%     cnt = cnt + 1;
%     if (strcmp(model.rxns{i}(end-1:end),'_r') | strcmp(model.rxns{i}(end-1:end),'_b'))
%       modelRev.rxns{end+1} = model.rxns{i}(1:end-2);
%       modelRev.S(:,end+1) = -model.S(:,i);
%       modelRev.ub(end+1) = -model.lb(i);
%       modelRev.lb(end+1) = -model.ub(i);
%       modelRev.c(end+1) = -model.c(i);
%     else
%       if (strcmp(model.rxns{i}(end-1:end),'_f'))
%         modelRev.rxns{end+1} = model.rxns{i}(1:end-2);
%       else
%         modelRev.rxns{end+1} = model.rxns{i};
%       end
%       modelRev.S(:,end+1) = model.S(:,i);
%       modelRev.lb(end+1) = model.lb(i);
%       modelRev.ub(end+1) = model.ub(i);
%       modelRev.c(end+1) = model.c(i);
%     end    
%     map(cnt) = i;
%   else
%     % Reversible reaction
%     if (~rxnProcessed(i)) % Don't bother if this has already been processed
%       cnt = cnt + 1;
%       map(cnt) = i;
%       modelRev.rxns{end+1} = model.rxns{i}(1:end-2);
%       modelRev.S(:,end+1) = model.S(:,i);
%       modelRev.ub(end+1) = model.ub(i);      
%       revRxnID = model.match(i);
%       rxnProcessed(revRxnID) = true;
%       % Get the correct ub for the reverse reaction
%       modelRev.lb(end+1) = -model.ub(revRxnID);
%       % Get correct objective coefficient
%       if (model.c(i) ~= 0)
%         modelRev.c(end+1) = model.c(i);
%       elseif (model.c(revRxnID) ~= 0)
%         modelRev.c(end+1) = -modelRev.c(revRxnID);
%       else
%         modelRev.c(end+1) = 0;
%       end
%     end
%   end
% end
% 
% modelRev.ub = columnVector(modelRev.ub);
% modelRev.lb = columnVector(modelRev.lb);
% modelRev.rxns = columnVector(modelRev.rxns);
% modelRev.c = columnVector(modelRev.c);
% modelRev.mets = columnVector(model.mets);
% if (isfield(model,'b'))
%     modelRev.b = model.b;
% end
% if isfield(model,'description')
%     modelRev.description = [model.description ' reversible'];
% end
% if isfield(model,'subSystems')
%     modelRev.subSystems = model.subSystems(map);
% end
% if isfield(model,'genes')
%     modelRev.genes = model.genes;
%     modelRev.rxnGeneMat = model.rxnGeneMat(map,:);
%     modelRev.rules = model.rules(map);
% end
% modelRev.reversibleModel = true;
