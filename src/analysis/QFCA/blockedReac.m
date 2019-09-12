function [S, rev, rxns, blocked] = blockedReac(S, rev, rxns, solver)
% blockedReac finds the blocked reactions and removes them from the network
%
% USAGE:
%
%    [S_reduced, rev_reduced, rxns_reduced, blocked] = blockedReac(S, rev, rxns, solver)
%   
% INPUTS:
%    S:         the associated sparse stoichiometric matrix
%    rev:       the 0-1 vector with 1's corresponding to the reversible reactions
%    rxns:      the cell array of reaction abbreviations
%    solver:    the LP solver to be used; the currently available options are
%               'gurobi', 'linprog', and otherwise the default COBRA LP solver
%
% OUTPUTS:
%    S_reduced:       the reduced sparse stoichiometric matrix
%    rev_reduced:     the reduced reversibility vector
%    rxns_reduced:    the reduced reaction abbreviations
%    blocked:         the 0-1 vector with 1's corresponding to the blocked reactions
%
% .. Authors:
%       - Mojtaba Tefagh, Stephen P. Boyd, 2019, Stanford University

    [~, result] = directionallyCoupled(S, rev, 0, solver);
    % identifying the blocked irreversible reactions
    blocked = 1*(result < -0.5);
    % setting up the zero-tolerance parameter
    tol = norm(S(:, blocked == 0), 'fro')*eps(class(S));
    % identifying the blocked reversible reactions
    [Q, R, ~] = qr(transpose(S(:, blocked == 0)));
    Z = Q(rev(blocked == 0) == 1, sum(abs(diag(R)) > tol)+1:end);
    blocked(blocked == 0 & rev == 1) = diag(Z*Z.') < tol^2;
    % removing the blocked reactions from the metabolic network
    S(:, blocked == 1) = [];
    rev(blocked == 1) = [];
    rxns(blocked == 1) = [];
end