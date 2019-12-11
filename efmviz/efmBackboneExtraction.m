function [selectedRxns,  rxnDistribution] = efmBackboneExtraction(EFMRxns, percentage)
% This function extracts all the reactions present in a certain percentage of EFMs
%
% USAGE:
%    [selectedRxns,  rxnDistribution] = efmBackboneExtraction(EFMRxns, percentage)
%
% INPUTS:
%    efmData:       matlab array containing reactions in EFMs (each row is an EFM and every entry indicates the reaction IDs in the EFM) 
%    percentage:    a number indicating the cut off percentage. The reactions which are present in >= 'percentage' number of EFMs will be returned as output. ex. '80'
% 
% OUTPUTS:
%    selectedRxns:       table of reactions which are present in >= 'percentage' number of EFMs. 
%                        The columns in the table are:
%                            rxnID - reaction ID
%                            numEFMOccurrence - the number of EFMs the reaction occurs in 
%                            efmOccPercentage - percentage of EFMs the reaction occurs in. Calculated as: efmOccPercentage = numEFMOccurrence/<totalNumberOfEFMs> * 100
%    rxnDistribution:    table of all reactions which are present in the input set of EFMs. 
%                        The columns in the table are:
%                  `         rxnID - reaction ID
%                            numEFMOccurrence - the number of EFMs the reaction occurs in 
%                            efmOccPercentage - percentage of EFMs the reaction occurs in. Calculated as: efmOccPercentage = numEFMOccurrence/<totalNumberOfEFMs> * 100
%
% .. Author: Last modified: Chaitra Sarathy, 1 Oct 2019


% total number of EFMs
numEFMs = size(EFMRxns, 1);

% find the number of EFMs each reaction occurs in and sort by occurrence
allRxns = reshape(EFMRxns, [], 1); 
rxnDistribution = sortrows(array2table(tabulate(allRxns(allRxns ~= 0))), 2, 'descend');
rxnDistribution(rxnDistribution.Var2 == 0,:) = [];
rxnDistribution(:, 3) = [];
rxnDistribution.Properties.VariableNames = {'rxnID' 'numEFMOccurrence'};

% compute the percentage of EFMs the reaction occurs in
rxnDistribution.efmOccPercentage = rxnDistribution.numEFMOccurrence/numEFMs * 100;

% identify the reactions present in >= 'percentage' number of EFMs 
selectedRxns = rxnDistribution(rxnDistribution.efmOccPercentage >= percentage, :);

end

