function [gene_id, gene_expr] = findUsedGenesLevels(model, exprData)
% Returns vectors of gene identifiers and corresponding gene expression
% levels for each gene present in the model (model.genes).
%
% INPUTS:
%
%   model:               input model (COBRA model structure)
%
%   exprData:            mRNA expression data structure
%       .gene                cell array containing GeneIDs in the same
%                            format as model.genes
%       .value               Vector containing corresponding expression value (FPKM)
%
% OUTPUTS:
%
%   gene_id:             vector of gene identifiers present in the model
%                        that are associated with expression data
%
%   gene_expr:           vector of expression values associated to each
%                        gened_id
%
% Authors: - S. Opdam & A. Richelle May 2017

gene_expr=[];
gene_id = model.genes;

for i = 1:numel(gene_id)
        
    cur_ID = gene_id{i};
	dataID=find(ismember(exprData.gene,cur_ID)==1);
	if isempty (dataID)
    	gene_expr(i)=-1;
    elseif length(dataID)==1
    	gene_expr(i)=exprData.value(dataID);
    elseif length(dataID)>1
    	disp(['Double for ',num2str(cur_ID)])
    	gene_expr(i)=mean(exprData.value(dataID));
    end
end
           
end
