function [gene_id, gene_expr] = findUsedGenesLevels(model,expressionData)
%Returns vectors of gene identifiers and corresponding gene expression
%levels for each gene present in the model (model.gene).
%
%INPUTS
%
%   model               input model (COBRA model structure)
%
%   expressionData      mRNA expression data structure
%       gene                cell array containing GeneIDs
%       value               Vector containing corresponding expression value (FPKM)
%
%OUTPUTS
%
%   gene_id             vector of gene identifiers present in the model
%                       that are associated with expression data
%
%   gene_expr           vector of expression values associated to each
%                       gened_id
%
% S. Opdam & A. Richelle May 2017


gene_id = {};
gene_expr=[];
for i = 1:numel(model.genes)
	gene_id{i} = model.genes{i};
end

for i = 1:numel(gene_id)
        
    cur_ID = gene_id{i};
	dataID=find(ismember(expressionData.gene,cur_ID )==1);
	if isempty (dataID)
    	gene_expr(i)=-1;
    elseif length(dataID)==1
    	gene_expr(i)=expressionData.value(dataID);
    elseif length(dataID)>1
    	disp(['Double for ',num2str(cur_ID)])
    	gene_expr(i)=mean(expressionData.value(dataID));
    end
end
           
end
