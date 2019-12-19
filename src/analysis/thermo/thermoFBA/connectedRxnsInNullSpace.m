function conComp = connectedRxnsInNullSpace(N)
% Find connected components for reactions given a minimal feasible nullspace as defined in Chan et al., Bioinfo, 2017. 
% Two reactions in different connected components imply that no EFM connecting the reactions exists and therefore 
% EFMs can be calculated in a modular approach. If the nullspace matrix represents the nullspace for reactions 
% in internal loops, constraints for the loopless requirement are required only for the connected components 
% involving the reactions required to have no flux through cycles (the target set).
%
% USAGE:
%    conComp = connectedRxnsInNullSpace(N)
%
% INPUT:
%    N:       a minimal nullspace matrix spanning the feasible flux space, having the same number row as the number of reactions
%             Can be obtained from either `findMinNull.m` or `fastSNP.m`
%
% OUTPUT:
%    conComp: connected components for any reactions connected through the nullspace
%             E.g., conComp = [1; 0; 1; 2; 3; 2] means that the 1st and 3rd reactions are in the same 
%             connected component, 4th and 6th also in the same, 5th alone in a connected component and 
%             the 2nd reaction is not in any connected component, which means it is a blocked reaction 
%             under the condition where the nullspace is calculated.

conComp = zeros(size(N, 1), 1);
nCon = 0;
vCur = false(size(N, 1), 1);
while any(conComp == 0 & any(N, 2))
    vCur(:) = false;
    % find the first reaction not in any connected component yet
    vCur(find(conComp == 0 & any(N, 2), 1)) = true;
    nCon = nCon + 1;
    nCur = 0;
    % loop until no new reaction is added
    while nCur < sum(vCur)
        nCur = sum(vCur);
        % get any reactions sharing the same columns in the current component
        vCur(any(N(:, any(N(vCur, :), 1)), 2)) = true;
    end
    conComp(vCur) = nCon;
end
end
