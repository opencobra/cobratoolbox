function [modelGE] = integrateGeneExpressionData(model,dataGenes)
% This function sets constrains based on sets of absent genes. It does not test for the functionality of the model, to maintain full control over
% the model generation process. Alternatively, the COBRA function `createTissueSpecificModel` can be used, and which can produce a functional model.
% See the supplemental tutorial of *DOI:10.1371/journal.pone.0049978 (Aurich and Thiele, PloS One, 2012)* for description on potentially necessary curation when using this crude method of data integration.
%
% USAGE:
%
%    [modelGE] = integrateGeneExpressionData(model, dataGenes)
%
% INPUTS:
%    model:           Metabolic model (e.g., Recon)
%    dataGenes:       Vector of absent genes. Follow the supplemental tutorial of *DOI: 10.1371/journal.pone.0049978 (Aurich and Thiele, PloS One, 2012)* for the generation of P/A calls, e.g., `Absent_genes` = [535;1548];
%
% OUTPUT:
%    modelGE:         Model, where all genes in `DataGenes` have been constrained to zero. Follow the supplemental tutorial of
%                     *DOI:10.1371/journal.pone.0049978 (Aurich and Thiele, PloS One, 2012)* for description of potentially necessary curation.
%
% .. Author: - Maike K. Aurich 13/02/15 (Depends on deleteModelGene)


if all(~cellfun(@isempty ,regexp(model.genes,'\.[0-9]+$'))) && isnumeric(dataGenes)
    %For backward compatability, we will check if this is recon 1 by testing,
    %whether all absentgenes lack a transcript and all model genes have it.
    
   geneNumbers = cellfun(@str2num, regexprep(model.genes, '\.[0-9]+$',''));
   presence = ismember(geneNumbers,dataGenes);
   dataGenes = model.genes(presence);
end

[modelGE, hasEffect,constrRxnNames,deletedGenes] = deleteModelGenes(model,dataGenes); 
end
