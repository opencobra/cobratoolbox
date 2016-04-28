function MatricesSUX = assignRxnWeights(MatricesSUX,weights,WeightsPerRxn, NoWeight)
% function MatricesSUX = assignRxnWeights(MatricesSUX,weights)
%
% INPUT
% MatricesSUX       Input model structure
% weights           Weight structure that permits to add weights to
%                   non-core reactions (it is recommended to use values other than 0 and 1, with lower weight
%                   corresponding to higher priority.
%                   Format:
%                         weights.MetabolicRxns = 10; % Universal database metabolic reactions
%                         weights.ExchangeRxns = 10; % Exchange reactions
%                         weights.TransportRxns = 10; % Transport reactions
%                   Optional input. Default: weigth of 10 for all non-core
%                   reactions.
% WeightsPerRxn     Structure containing a list of reactions that should be assined with
%                   individual weights (WeightsPerRxn.rxns) AND a list of Reaction weights (WeightsPerRxn.weights) in the same order.
% NoWeight          Weight that should be assigned to those reactions NOT
%                   in core reaction set and NOT in WeightsPerRxn
%                   (default:1000)
%
% OUTPUT
% MatricesSUX   Output model structure
%
%
% Dec 2013
% Ines Thiele, http://thielelab.eu

if ~exist('weights','var') || isempty(weights)
    % define weights for reactions to be added - the lower the weight the
    % higher the priority
    % default = equal weights
    weights.MetabolicRxns = 10; % Kegg metabolic reactions
    weights.ExchangeRxns = 10; % Exchange reactions
    weights.TransportRxns = 10; % Transport reactions
end

% assign default weight to all reactions
if ~exist('NoWeight','var')
    NoWeight = 1000;
end
MatricesSUX.weights = NoWeight*ones(length(MatricesSUX.rxns),1);
% get exchange and transport reactions in SUX
ExTr = MatricesSUX.rxns(MatricesSUX.MatrixPart==3);
% identify Exchange reactions of those
ExR = ExTr(strncmp('Ex_',ExTr,3));
TrR = ExTr(~strncmp('Ex_',ExTr,3));
% get metabolic Kegg reactions in SUX
MetR = MatricesSUX.rxns(MatricesSUX.MatrixPart==2);

%MatricesSUX.weights = zeros(length(MatricesSUX.rxns),1);
MatricesSUX.weights(ismember(MatricesSUX.rxns,MetR)) = weights.MetabolicRxns;
MatricesSUX.weights(ismember(MatricesSUX.rxns,ExR)) = weights.ExchangeRxns;
MatricesSUX.weights(ismember(MatricesSUX.rxns,TrR)) = weights.TransportRxns;

if exist('WeightsPerRxn','var') && isfield(WeightsPerRxn,'rxns')
    if ~isempty(WeightsPerRxn.rxns)
        % assign weights to individual reactions
        % set all core reactions to 0
        %MatricesSUX.weights(ismember(MatricesSUX.rxns,MatricesSUX.C1)) = 0;
        %MatricesSUX.weights(ismember(MatricesSUX.rxns,MatricesSUX.rxns(MatricesSUX.C1))) = 0;
        for k = 1 : length(WeightsPerRxn.rxns)
            clear R;
            R =find(ismember(MatricesSUX.rxns,WeightsPerRxn.rxns{k}));
            if ~isempty(R)
                MatricesSUX.weights(R) = WeightsPerRxn.weights{k};
            end
        end
    end
end