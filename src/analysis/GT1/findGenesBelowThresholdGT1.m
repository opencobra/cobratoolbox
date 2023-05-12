function genes = findGenesBelowThresholdGT1(threshold, geneNames, expressionValues)
% Filters transcriptomics dataset and returns lowly expressed gene cell array 
% (columns: geneId, expressionValue, expression classification - 'Low') containing genes 
% with expression value below the given global threshold value 
%
% USAGE:
%
%   genes = findGenesBelowThresholdGT1(threshold, geneNames, expressionValues)
%
% INPUTS:
%   threshold:              double
%   geneNames:              char cell array ix1 with all gene Ids
%   expressionValues:       double cell array ix1 with gene expression
%                           values
%
% OUTPUTS:
%	genes:                  cell array ix3 where columns include geneId, 
%                           expressionValue, expression classification - 'Low'
%
% .. Authors:
%       - Kristina Grausa 05/16/2022
%       - Kristina Grausa 08/23/2022 - standard header and formatting

    cnt = 1;
    for i=1:1:length(geneNames)
        if threshold >= expressionValues(i)
            genes{cnt,1} = geneNames{i};
            genes{cnt,2} = expressionValues(i);
            genes{cnt,3} = 'Low';
            cnt = cnt + 1;
        end
    end
end