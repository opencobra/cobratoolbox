function [AddedRxns] = fastGapFill(consistMatricesSUX,epsilon,weights,weightsPerReaction)
%% function [AddedRxns] = fastGapFill(consistMatricesSUX,epsilon,weights,weightsPerReaction)
% 
% This function requires the fastCORE algorithm (Vlassis et al., 2013, http://arxiv.org/abs/1304.7992) as
% well as the output from prepareFastGapFill.
%
% Requires the openCOBRA toolbox
% http://opencobra.sourceforge.net/openCOBRA/Welcome.html
% 
% Getting the Latest Code From the Subversion Repository:
% Linux:
% svn co https://opencobra.svn.sourceforge.net/svnroot/opencobra/cobra-devel
%
%
% INPUT
% consistMatricesSUX    To be obtained from prepareFastGapFill
% epsilon               Parameter for fastCore (optional input, default:
%                       1e-4). Please refer to Vlassis et al. to get more
%                       details on this parameter.
% weights           	Weight structure that permits to add weights to
%                       non-core reactions (it is recommended to use values other than 0 and 1, with lower weight
%                       corresponding to higher priority.
%                       Format:
%                           weights.MetabolicRxns = 10; % Universal database metabolic reactions  
%                           weights.ExchangeRxns = 10; % Exchange reactions  
%                           weights.TransportRxns = 10; % Transport reactions  
%                       Optional input. Default: weigth of 10 for all non-core
%                       reactions.
% weightsPerReaction
% OUTPUT
% AddedRxns             Reactions that have been added from UX matrix to S 
%
% June 2013
% Ines Thiele, http://thielelab.eu. 

%%
if ~exist('epsilon','var') || isempty(epsilon)
    epsilon = 1e-4;
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
consistMatricesSUX = assignRxnWeights(consistMatricesSUX,weights,weightsPerReaction);

% solve problem by finding the most compact subnetwork containing all core
% reactions

A2 = fastCoreWeighted(consistMatricesSUX.C1, consistMatricesSUX, epsilon);

% added reactions
AddedRxns.rxns=setdiff(consistMatricesSUX.rxns(A2),consistMatricesSUX.rxns(consistMatricesSUX.C1));
AddedRxns.rxnFormula = printRxnFormula(consistMatricesSUX,AddedRxns.rxns,false);
