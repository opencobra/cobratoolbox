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

Transcript = model.genes;

cnt = 1;
for i = 1 : length(Transcript);
        a=regexp(Transcript{i,1},'\.','split');
    if ~isempty(char(a));
       if ~isempty(find(dataGenes== str2num(char(a(1)))));
        j = find(dataGenes == str2num(char(a(1))));
        Genes2Transcripts(j,cnt) = 1;
       ExpressionData.Transcript{cnt,1} = Transcript{i,1};
        ExpressionData.Locus(cnt,1) = dataGenes(j(1));
        cnt = cnt +1;
    end
    end
end


DeleteGenes_Metabol_Transcriptome = [];
[modelGE, hasEffect,constrRxnNames,deletedGenes] = deleteModelGenes(model,ExpressionData.Transcript); 
end
