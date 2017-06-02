function [MetsAndRxns, pVal_up, pVal_down, Dir_1, Dir_2] = compareConditions(MetConnectivity1, ConnectedMet1, MetConnectivity2, ConnectedMet2)
% This function compare reaction score of both sampling condition
% and identify metabolites that change significantly
%
% USAGE:
%
%    [MetsAndRxns, pVal_up, pVal_down, Dir_1, Dir_2] = compareConditions(MetConnectivity1, ConnectedMet1, MetConnectivity2, ConnectedMet2)
%
% INPUTS:
%    MetConnectivity1:    A structure that present, for each
%                         metabolite present in the model sampled under first
%                         condition the following sets of fields:
%
%                           * ConnRxns - the reactions that are connected
%                             to the metabolite
%                           * Sij - The stoichiometric coefficient for the
%                             metabolite in each reaction in `ConnRxns`
%                           * RxnScore - Score for each reaction in `ConnRxns`
%                           * Direction - The direction of reaction flux
%                             for each sample point
%                           * MetNotUsed - Whether or not the metabolite is
%                             used in the condition
%    ConnectedMet1:       List of metabolites described in `MetConnectivity1`
%    MetConnectivity2:    Same as `MetConnectivity1` but for `model`
%                         sampled under the second condition
%    ConnectedMet2:       List of metabolites described in `MetConnectivity2`
%
% OUTPUTS:
%    MetsAndRxns:         Cell arrays containing in the first column
%                         the list of metabolites that significantly change
%                         under both sampling conditions and in the second
%                         column the reactions that are connected to
%                         these metabolites
%    pVal_up:             p-value associated to upregulated
%                         `MetsAndRxns`
%    pVal_down:           p-value associated to downregulated
%                         `MetsAndRxns`
%    Dir_1:               reaction directionality for model sampled under first
%                         condition (1 producing metabolite, -1
%                         consuming the metabolite)
%    Dir_2:               Same as `Dir_1` but for model
%                         sampled under the second condition
%
% .. Authors:
%       - Nathan E. Lewis, May 2010-May 2011
%       - Anne Richelle, May 2017

Met1=MetConnectivity1.(ConnectedMet1{1});
Met2=MetConnectivity2.(ConnectedMet2{1});
% Get the minimum number of points used to score reactions in the two
% conditions
MinNumPts = min([length(Met1.RxnScore(1,:)) length(Met2.RxnScore(1,:))]);

% only look at nodes shared between the sampled models
ConnectedMet = intersect(ConnectedMet1,ConnectedMet2);
MetsAndRxns={};
pVal_up=[];
pVal_down=[];
Dir_1 = [];
Dir_2 = [];

for i = 1:length(ConnectedMet)

    Met1=MetConnectivity1.(ConnectedMet{i});
    Met2=MetConnectivity2.(ConnectedMet{i});

    FracNotUsed1 = sum(Met1.MetNotUsed(1:MinNumPts))/(MinNumPts); % fraction of the sample points not using this node in model1
    FracNotUsed2 = sum(Met2.MetNotUsed(1:MinNumPts))/(MinNumPts); % fraction of the sample points not using this node in model2

    % ignore nodes that are used in less than 10% of the sample points in one
    % condition
    if and(FracNotUsed1<.9,FracNotUsed2<.9)

        % subtract scores of 2nd condition from the 1st condition
        tmp = Met1.RxnScore(:,1:MinNumPts) - Met2.RxnScore(:,1:MinNumPts);

        % p of increasing flux is obtained by subtracting 2nd from 1st and
        % finding how many are > or < 0 for the pvalue for up and down,
        % respectively. (many >= 0 means 2nd condition was lower, so high
        % p-value for up and low for down, suggesting that the flux dropped
        % in the 2nd condition
        p_up = sum(tmp>=0,2)/length(tmp(1,:));
        p_down = sum(tmp<=0,2)/length(tmp(1,:));

        % This computes the median direction, just to give an idea which
        % direction the reaction tends to go in the conditions
        tmp_Dir1 = median(Met1.Direction(:,1:MinNumPts),2);
        tmp_Dir2 = median(Met2.Direction(:,1:MinNumPts),2);

        % Go through each reaction and build arrays with the reactions, the
        % branch-point metabolites, and p-values, and reaction directionality
        % (i.e., in or out of the central metabolite)
        for j = 1:length(tmp(:,1))
            if ~all(tmp(j,:)==0) % skip reactions that carry no flux or don't change at all
                MetsAndRxns{end+1,1} =ConnectedMet{i};
                MetsAndRxns{end,2}=Met1.ConnRxns{j};
                pVal_up(end+1,1)=p_up(j);
                pVal_down(end+1,1)=p_down(j);
                Dir_1(end+1,1)= tmp_Dir1(j);
                Dir_2(end+1,1)= tmp_Dir2(j);
            end
        end

    end
end

end
