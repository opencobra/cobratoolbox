function [reconstruction, AddedRxns] = swiftGapFill(consistMatricesSUX, tol, weights, weightsPerReaction)
% This function requires the swiftcore algorithm as well as the output from `prepareFastGapFill`.
%
% USAGE:
%
%    [reconstruction, AddedRxns] = swiftGapFill(consistMatricesSUX, tol, weights, weightsPerReaction)
%
% INPUT:
%    consistMatricesSUX:    To be obtained from `prepareFastGapFill`
% OPTIONAL INPUTS:
%    tol:                   Parameter for `swiftcore` (default: 1e-10).
%    weights:              	Weight structure that permits to add weights to non-core reactions
%                           It is recommended to use values other than 0 and 1, with lower weight
%                           corresponding to higher priority.
%                           Format:
%                             * weights.MetabolicRxns = 10; % Universal database metabolic reactions
%                             * weights.ExchangeRxns = 10; % Exchange reactions
%                             * weights.TransportRxns = 10; % Transport reactions
%                           Default: weigth of 10 for all non-core reactions.
%    weightsPerReaction:    Weights per reaction
%
% OUTPUT:
%    AddedRxns:             Reactions that have been added from `UX` matrix to `S`
%
% .. Authors: 
%   - Ines Thiele, June 2013, http://thielelab.eu.
%   - Mojtaba Tefagh, May 2019

if ~exist('epsilon','var') || isempty(tol)
    tol = 1e-10;
end

if ~exist('weights','var') || isempty(weights)
     % define weights for reactions to be added - the lower the weight the
    % higher the priority
    % default = equal weights
    weights.MetabolicRxns = 10; % Kegg metabolic reactions
    weights.ExchangeRxns = 10; % Exchange reactions
    weights.TransportRxns = 10; % Transport reactions
end

if ~exist('weightsPerReaction','var') || isempty(weightsPerReaction)
    weightsPerReaction.rxns = [];
    weightsPerReaction.weights = [];
end


% assign weights to the potentially to be added reactions to MatricesSUX
consistMatricesSUX = assignRxnWeights(consistMatricesSUX, weights, weightsPerReaction);

% solve problem by finding the most compact subnetwork containing all core
% reactions

[reconstruction, reconInd, LP] = swiftcore(consistMatricesSUX, consistMatricesSUX.C1, consistMatricesSUX.weights, tol, false);
fprintf('number of solved LPs: %d\n', LP);

% added reactions
AddedRxns.rxns = setdiff(consistMatricesSUX.rxns(reconInd), consistMatricesSUX.rxns(consistMatricesSUX.C1));
AddedRxns.rxnFormula = printRxnFormula(consistMatricesSUX, AddedRxns.rxns,false);
