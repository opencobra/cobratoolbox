function [EnzymeSubsets] = getEnzymeSubsets(model,tol)

EnzymeSubsets = {};

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
        EnzymeSubsets{end+1} = index;
    end
end