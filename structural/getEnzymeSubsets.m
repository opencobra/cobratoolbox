function [ReactionSubsets] = getReactionSubsets(model,tol)
% getReactionSubsets Find the enzymatic subsets (i.e. perfectly correlated
% reaction sets)
%
% [ReactionSubsets] = getReactionSubsets(model,tol)
%
%INPUT
% model             COBRA model structure
%
%OPTIONAL INPUTS
% tol               The tolerance used for the Single Value decomposition
%                   used in the sparse nullspace determination and for correlations
%
%OUTPUTS
% ReactionSubsets     Cell Array of sets of reactions contained in each
%                   enzyme subset
%
% Reactionsubsets are the enzymesubsets as defined in Pfeiffer et al. 1999, Bioinformatics, 15(3) pp 251-257
% In essence, reactions in a reaction subset are perfectly correlated,
% which can be directly deduced from the nullspace of the stoichiometric
% matrix.
%
% 04/03/15 Thomas Pfau


ReactionSubsets = {};

% obtain nullspace 
NullSpace = sparseNull(model.S,tol);

%Detect all row vectors of The Nullspace which are 0 vectors:
%Nulls = find(sum(abs(NullSpace),2) < tol);
NonNulls = find(sum(abs(NullSpace),2) > tol);
Divisors = max(NullSpace(NonNulls,:),[],2);

CompVectors = NullSpace(NonNulls,:)./(diag(Divisors) * ones(numel(Divisors),size(NullSpace,2)));

[~,~,Ess] = unique(CompVectors,'rows');
EssIDs = unique(Ess);
for i = 1:numel(EssIDs)
    index = NonNulls(find(Ess == EssIDs(i)));
    if numel(index) > 1
        ReactionSubsets{end+1} = index;
    end
end