function [gene_id, gene_expr, gene_sig] = findUsedGenesLevels_efmviz(model, exprData, printLevel)
% Returns vectors of gene identifiers and corresponding gene expression
% levels for each gene present in the model ('model.genes').
%
% USAGE:
%    [gene_id, gene_expr] = findUsedGenesLevels(model, exprData)
%
% INPUTS:
%
%   model:               input model (COBRA model structure)
%
%   exprData:            mRNA expression data structure
%       .gene                cell array containing GeneIDs in the same
%                            format as model.genes
%       .value               Vector containing corresponding expression value (FPKM)
%       .sig                 Vector containing corresponding significance values
%
% OPTIONAL INPUTS:
%    printLevel:         Printlevel for output (default 0);
%
% OUTPUTS:
%
%   gene_id:             vector of gene identifiers present in the model
%                        that are associated with expression data
%
%   gene_expr:           vector of expression values associated to each
%                        'gened_id'
%   gene_sig:             vector of significance values associated to each
%                        'gened_id'
%
%   
% Original Authors: - S. Opdam & A. Richelle May 2017
% Adapted by Chaitra Sarathy to use significance levels along with
% expression value 
% Last modified: Chaitra Sarathy, 13 Aug 2019

if ~exist('printLevel','var')
    printLevel = 0;
end

gene_expr=[];
gene_sig=[];
gene_id = model.genes;

for i = 1:numel(gene_id)
        
    cur_ID = gene_id{i};
	dataID=find(ismember(exprData.gene,cur_ID));
	if isempty (dataID)
    	gene_expr(i)=0;        
    elseif length(dataID)==1
    	gene_expr(i)=exprData.value(dataID);
        gene_sig(i) = exprData.sig(dataID);
    elseif length(dataID)>1    	
        if printLevel > 0
            disp(['Double for ',num2str(cur_ID)])
        end
    	gene_expr(i) = mean(exprData.value(dataID));
        gene_sig(i) = mean(exprData.sig(dataID));
    end
end
           
end
