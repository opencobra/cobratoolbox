function [S, rev, rxns] = mergeFullyCoupled(S, rev, rxns, i, j, c)
% mergeFullyCoupled merges the fully coupled pair of reactions (i, j)
% 
% USAGE:
%
%    [S_reduced, rev_reduced, rxns_reduced] = mergeFullyCoupled(S, rev, rxns, i, j, c)
% 
% INPUTS:
%    S:       the associated sparse stoichiometric matrix
%    rev:     the 0-1 vector with 1's corresponding to the reversible reactions
%    rxns:    the cell array of reaction abbreviations
%    i:       the reaction which the other one will merge with and is not removed
%    j:       the reaction which will be merged into the other reaction
%    c:       the full coupling coefficient
%
% OUTPUTS:
%    S_reduced:       the reduced sparse stoichiometric matrix
%    rev_reduced:     the reduced reversibility vector
%    rxns_reduced:    the reduced reaction abbreviations
%
% .. Authors:
%       - Mojtaba Tefagh, Stephen P. Boyd, 2019, Stanford University

    S(:, i) = S(:, i) + c*S(:, j);
    S(:, j) = [];
    % deleting the reaction from the rev and rxns vectors
    if rev(j) ~= 1
        if c > 0
            rev(i) = rev(j);
        else
            rev(i) = -1 - rev(j);
        end
    end
    rev(j) = [];
    rxns(i) = {strjoin([rxns(i), rxns(j)], ', ')};
    rxns(j) = [];
end