function [gene_id, gene_expr, gene_sig] = findUsedGenesLevels(model, exprData, printLevel)
% Returns vectors of gene identifiers and corresponding gene expression
% levels for each gene present in the model ('model.genes').
%
% USAGE:
%
%    [gene_id, gene_expr] = findUsedGenesLevels(model, exprData)
%    [gene_id, gene_expr, gene_sig] = findUsedGenesLevels(model, exprData)
%
% INPUTS:
%
%   model:               input model (COBRA model structure)
%
%   exprData:            mRNA expression data structure
%       .gene                cell array containing GeneIDs in the same
%                            format as model.genes
%       .value               Vector containing corresponding expression value (FPKM)
%       .sig:                [optional field] Vector containing significance values of
%                            expression corresponding to expression values in exprData.value (ex. p-values)
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
%                        'gene_id'
%
% OPTIONAL OUTPUTS:
%   gene_sig:             vector of significance values associated to each
%                        'gene_id'
%
%   

% Authors:  - S. Opdam & A. Richelle May 2017
%           - Chaitra Sarathy, Oct 2019, add significance value as optional input
%           - Ronan Fleming, NaN replaces -1 for no data

if ~exist('printLevel','var')
    printLevel = 0;
end

if isfield(exprData, 'sig') 
    exprSigFlag = 1; 
else
    exprSigFlag = 0;
end 

gene_expr=[];
gene_sig=[];
gene_id = model.genes;

for i = 1:numel(gene_id)
        
    cur_ID = gene_id{i};
	dataID=find(ismember(exprData.gene,cur_ID));
    
    if isempty (dataID)
        gene_expr(i)=NaN;        
    elseif length(dataID)==1
        gene_expr(i)=exprData.value(dataID);
        if exprSigFlag == 1 
            gene_sig(i) = exprData.sig(dataID);
        end 
    elseif length(dataID)>1    	
        if printLevel > 0
            disp(['Double for ',num2str(cur_ID)])
        end
        gene_expr(i) = mean(exprData.value(dataID));
        if exprSigFlag == 1 
            gene_sig(i) = mean(exprData.sig(dataID));
        end 
    end    
end
           
end
