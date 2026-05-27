function blockedReactions = findBlockedReaction(model, method)
% Determines those reactions which cannot carry any
% flux in the given simulation conditions.
%
% USAGE:
%
%    blockedReactions = findBlockedReaction(model)
%    blockedReactions = findBlockedReaction(model, method)
%
% INPUT:
%    model:               COBRA model structure
%
% OPTIONAL INPUT:
%    method:              'FVA'  for flux variability analysis (default)
%                         'L2'   for 2-norm minimization via CPLEX followed
%                                by targeted FVA to remove false positives.
%                                The L2 min-norm solution identifies a superset
%                                of blocked reactions (zero false negatives at
%                                tol = 1e-10), then FVA is run only on those
%                                candidates to prune false positives.
%
% OUTPUT:
%    blockedReactions:    List of blocked reactions
%
% .. Authors:
%       - Ines Thiele 02/09
%       - Srikiran C 07/14 - fixed error - assigning cells to blockedReactions which is a double
%       - Marouen BEN GUEBILA - used 2-norm min as a preprocessing step for FVA

blockedReactions = cellstr('');
[m, n] = size(model.S);
if nargin < 2 || isequal(method, 'FVA')
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
    % Stage 1: L2 min-norm via solveCobraLPCPLEX to get candidate blocked reactions
    tol = 1e-10;
    % Preserve original objective for fallback
    modelOrig = model;
    model.c = zeros(n, 1);
    solution = solveCobraLPCPLEX(model, 0, 0, 0, [], 1e-6);

    if solution.stat ~= 1
        warning('L2 solve failed (status %d), falling back to full FVA', solution.stat);
        blockedReactions = findBlockedReaction(modelOrig, 'FVA');
        return;
    end

    candidateIdx = abs(solution.full) < tol;
    candidateRxns = model.rxns(candidateIdx);

    if isempty(candidateRxns)
        blockedReactions = cell(0, 1);
        return;
    end

    % Stage 2: targeted FVA only on L2 candidates to prune false positives
    [minFlux, maxFlux] = fluxVariability(model, 0, 'max', candidateRxns);
    cnt = 1;
    for i = 1:length(candidateRxns)
        if abs(minFlux(i)) < tol && abs(maxFlux(i)) < tol
            blockedReactions(cnt) = candidateRxns(i);
            cnt = cnt + 1;
        end
    end
end

end
