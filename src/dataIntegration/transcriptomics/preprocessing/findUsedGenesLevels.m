function [gene_id, gene_expr, gene_sig] = findUsedGenesLevels(model, exprData, exprSig, printLevel)
% Returns vectors of gene identifiers and corresponding gene expression
% levels for each gene present in the model ('model.genes').
%
% USAGE:
%
%    [gene_id, gene_expr] = findUsedGenesLevels(model, exprData)
%    [gene_id, gene_expr, gene_sig] = findUsedGenesLevels(model, exprData, exprSig, printLevel)
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
% OPTIONAL INPUTS:
%    exprSig:            Vector containing significance values of
%                        expression corresponding to expression values in exprData.value (ex. p-values)
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
% Authors: - S. Opdam & A. Richelle May 2017
%       - Chaitra Sarathy, Oct 2019, add significance value as optional input

if ~exist('printLevel','var')
    printLevel = 0;
end

if ~exist('exprSig','var') 
    exprSigFlag = 0; 
else
    exprSigFlag = 1;
end 

gene_expr=[];
gene_sig=[];
gene_id = model.genes;

for i = 1:numel(gene_id)
        
    cur_ID = gene_id{i};
	dataID=find(ismember(exprData.gene,cur_ID));
    
    if isempty (dataID)
        gene_expr(i)=-1;        
    elseif length(dataID)==1
        gene_expr(i)=exprData.value(dataID);
        if exprSigFlag ~= 0 
            gene_sig(i) = exprSig(dataID);
        end 
    elseif length(dataID)>1    	
        if printLevel > 0
            disp(['Double for ',num2str(cur_ID)])
        end
        gene_expr(i) = mean(exprData.value(dataID));
        if exprSigFlag ~= 0 
            gene_sig(i) = mean(exprSig(dataID));
        end 
    end    
end
           
end
