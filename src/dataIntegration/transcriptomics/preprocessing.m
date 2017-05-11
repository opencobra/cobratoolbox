function [model, gene_id, gene_expr, parsedGPR, corrRxn, expressionRxns]=preprocessing(modelIN, expressionData) 
% Preprocessing of the data and the model for the extraction process
%
%INPUTS
%
%   modelIN             input model (COBRA model structure)   
%   expressionData      mRNA expression data structure
%       firstColumn     Vector containing GeneIDs
%       scondColumn     Vector containing corresponding expression value
%       (FPKM)
%
%OUTPUTS
%
%   model               model structure ready for extraction
%   gene_id             vector of gene identifiers present in the model
%                       that are associated with expression data
%   gene_expr           vector of expression values associated to each
%                       gened_id
%   parsedGPR           cell array describing the possible combination of 
%                       gene needed for each reactions in the model without
%                       using "AND" and "OR" logical rule
%   corrRxn             cell array containg the reaction names associated
%                       to parsedGPR
%   expressionRxns      expression data, corresponding to model.rxns, that
%                       will be used by the extraction method algorithm
%
% S. Opdam & A. Richelle May 2017

  
    %model preprocessing - remove blocked reactions 
    blockedRxns = findBlockedReaction(modelIN); %% TO DO - need to provide a way to modulate the tolerance of this function (set at 10e-10)
    model = removeRxns(modelIN,blockedRxns);
    
    %check the existence of a solution for the setup
    sol=optimizeCbModel(model); %% TO DO - write a warning if no solution, if no objective function etc..
    
    model= formatGenes(model); %% TO DO - to update depending on the last format of gene introduction in models of cobratoolbox v3

    [gene_id, gene_expr] = findUsedGenesLevels(model,expressionData);

    [parsedGPR, corrRxn] = extractGPRs(model);
    
    expressionRxns = mapGeneToRxn(model, gene_id, gene_expr, parsedGPR, corrRxn);


end




