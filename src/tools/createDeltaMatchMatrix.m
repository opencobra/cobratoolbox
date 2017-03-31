function A = createDeltaMatchMatrix(set1, set2)
% Create a flux difference constraint matrix for MOMA
% type calculations
%
% USAGE:
%
%    A = createDeltaMatchMatrix(set1, set2)
%
% .. Authors: Markus Herrgard 1/4/07

nRxns1 = length(set1);
nRxns2 = length(set2);

[isInSet2, set2Match] = ismember(set1, set2);

ind1 = find(isInSet2);
ind2 = set2Match(isInSet2 == 1);

nCommon = length(ind1);

A = sparse(2 * nCommon, nRxns1 + nRxns2 + 2 * nCommon);
for i = 1:nCommon
    A(i, ind1(i)) = -1;
    A(i, nRxns1 + ind2(i)) = 1;
    A(i, nRxns1 + nRxns2 + i) = 1;
    A(nCommon + i, ind1(i)) = 1;
    A(nCommon + i, nRxns1 + ind2(i)) = -1;
    A(nCommon + i, nRxns1 + nRxns2 + nCommon + i) = 1;
end
