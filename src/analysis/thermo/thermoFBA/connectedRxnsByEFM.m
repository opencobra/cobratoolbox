function rxnLink = connectedRxnsByEFM(model, conComp, rxnInLoops, printLevel)
% Find reactions lying in internal cycles that are connected by any EFMs.
% Used for minimizing the number of constraints for the loopless requirement 
% when running loopless FVA using localized loopless constraints. This
% function requires EFMtool (`CalculateFluxModes.m`) to work.
%
% USAGE:
%    rxnLink = connectedRxnsByEFM(model, conComp, rxnInLoops)
%
% INPUTS:
%    model:      COBRA model
%    conComp:    reactions connected in the minimal nullspace for internal cycles, computed by `connectedRxnsInNullSpace`
%    rxnInLoops: n-by-2 logical matrix where n = # of rxns in the model
%                rxnInLoops(k, 1) = true => forward direction of the k-th reaction in internal cycles
%                rxnInLoops(k, 2) = true => reverse direction of the k-th reaction in internal cycles
%                Returned by `findMinNull.m`
%
% OPTIONAL INPUT:
%    printLevel: true to show messages when the linkage matrix cannot be computed
%
% OUTPUT:
%    rxnLink:    n-by-n matrix. rxnLink(i, j) = 1 => reactions i and j are connected 
%                by an EFM representing an elementary internal cycle.

if nargin < 4
    printLevel = 0;
end
% the path to EFMtool
efmToolpath = which('CalculateFluxModes.m');
if isempty(efmToolpath)
    rxnLink = [];
    if printLevel
        fprintf('EFMtool not in Matlab path. Unable to calculate EFMs.\n')
    end
    return
end
efmToolpath = strsplit(efmToolpath, filesep);
efmToolpath = strjoin(efmToolpath(1: end - 1), filesep);
p = pwd;
cd(efmToolpath)
% EFMtool call options
options = CreateFluxModeOpts('sign-only', true, 'level', 'WARNING');

rxnLink = sparse(size(model.S, 2), size(model.S, 2));
for jC = 1:max(conComp)
    % for each connected component, find the EFM matrix
    try
        S = model.S(:, conComp == jC);
        S = S(any(S, 2), :);
        % revert the stoichiometries for reactions that are in cycles only in the reverse direction
        S(:, rxnInLoops(conComp == jC, 1) & ~rxnInLoops(conComp == jC, 2)) = -S(:, rxnInLoops(conComp == jC, 1) & ~rxnInLoops(conComp == jC, 2));
        rev = all(rxnInLoops(conComp == jC, :), 2);
        efms = CalculateFluxModes(full(S), double(rev), options);
        % calling Java too rapidly may have problems in tests
        pause(1e-4)
        efms = efms.efms;
        rxnJC = find(conComp == jC);
        for j = 1:numel(rxnJC)
            rxnLink(rxnJC(j), rxnJC) = any(efms(:, efms(j, :) ~= 0), 2)';
        end
    catch msg
        if printLevel
            fprintf('Error encountered during calculation of EFMs:\n%s', getReport(msg))
        end
        rxnLink = [];
        return
    end
end
cd(p)

end