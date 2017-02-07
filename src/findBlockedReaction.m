function blockedReactions = findBlockedReaction(model, method)
%findBlockedReaction determines those reactions which cannot carry any 
%flux in the given simulation conditions.
%
% BlockedReaction = findBlockedReaction(model)
%
%INPUT
% model              COBRA model structure
% method(optional)   'FVA' for flux variability analysis (default)
%                    'L2'  for 2-norm minimization
%OUTPUT
% blockedReactions   List of blocked reactions
%
%
% Ines Thiele 02/09
% Srikiran C 07/14 - fixed error - assigning cells to blockedReactions
% which is a double
% Marouen BEN GUEBILA - used 2-norm min as a heuristic for non-sparsity

blockedReactions = cellstr('');
if (nargin < 2 || isequal(method, 'FVA'))
    tol = 1e-10;
    [minMax(:, 1), minMax(:, 2)] = fluxVariability(model, 0);
    cnt = 1;
    for i = 1:length(minMax)
        if (minMax(i, 2) < tol && minMax(i, 2) > -tol && minMax(i, 1) < tol && minMax(i, 1) > -tol)
            blockedReactions(cnt) = model.rxns(i);
            cnt = cnt + 1;
        end
    end
else
    solution = solveCobraLPCPLEX(model, 0, 0, 0, [], 1e-6);
    blockedReactions = model.rxns(find(~solution.full))';
end

end
