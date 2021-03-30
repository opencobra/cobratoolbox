function [RefinedReactionsCarryingFlux, BlockedRefinedReactions] = testRefinedReactions(microbeID, BlockedRxns)
% Tests if reactions that were added through the refinement of gene
% annotations in the reconstructed organism can carry flux.
%
% INPUT
% microbeID         Microbe ID in data file with refined genome annotations
% BlockedRxns       Reactions in the COBRA model that cannot carry flux:
%                   output of identifyBlockedRxns function
%
% OUTPUT
% RefinedReactionsCarryingFlux     Reactions that were added through
%                                  refinement of the genome annotations
%                                  and can carry flux
%
% BlockedRefinedReactions          Reactions that were added through
%                                  refinement of the genome annotations
%                                  and cannot carry flux
%
%
% Almut Heinken, Nov 2019

BlockedRefinedReactions = {};
RefinedReactionsCarryingFlux = {};

if isfile('gapfilledGenomeAnnotation.txt')
    
    genomeAnnotation = readtable('gapfilledGenomeAnnotation.txt', 'ReadVariableNames', false, 'Delimiter', 'tab','TreatAsEmpty',['UND. -60001','UND. -2011','UND. -62011']);
    genomeAnnotation = table2cell(genomeAnnotation);
    
    % get the reactions that were added for the reconstruction
    findRxns=find(strcmp(microbeID,genomeAnnotation(:,1)));
    if ~isempty(findRxns)
        annRxns(:,1)=genomeAnnotation(findRxns(:,1),2);
        
        % find the overlap with blocked reactions in the model
        BlockedRefinedReactions = intersect(annRxns(:,1),BlockedRxns);
        RefinedReactionsCarryingFlux = setdiff(annRxns(:,1),BlockedRxns);
    end
    
end

end