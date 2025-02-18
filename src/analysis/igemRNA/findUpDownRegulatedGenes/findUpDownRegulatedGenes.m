function result = findUpDownRegulatedGenes(source, target, trDataPath)
% Compares two transcriptomics datasets and returns comparison result cell
% array, where each row corresponds the gene which expression being compared 
%
% USAGE:
%
%   result = findUpDownRegulatedGenes(source, target, trDataPath)
%
% INPUTS:
%   source:                 source transcriptomics sheet name 1×1 char cell array
%   target:                 target transcriptomics sheet name 1×1 char cell array
%   trDataPath:             transcriptomics data file full name and location
%
% OUTPUTS:
%	result:                 cell array ix4, where i = gene count, and columns include 
%                           geneId, source dataset expression value, target dataset 
%                           expression value and comparison result ('Up', 'Down', 'Equal')
% .. Authors:
%       - Kristina Grausa 05/16/2022
%       - Kristina Grausa 08/23/2022 - standard header and formatting

    try
        cnt = 1;
        sourceDataSetName = char(source);
        targetDataSetName = char(target);
        trSource=readtable(trDataPath,'Sheet',sourceDataSetName); 
        trTarget=readtable(trDataPath,'Sheet',targetDataSetName);
        
        for i=1:1:height(trSource)
            result{cnt,1} = trSource.Geneid{i};
            result{cnt,2} = trSource.Data(i);
            result{cnt,3} = trTarget.Data(i);
            if trSource.Data(i) > trTarget.Data(i)
                result{cnt,4} = 'Down';
            elseif trSource.Data(i) < trTarget.Data(i)
                result{cnt,4} = 'Up';
            else
                result{cnt,4} = 'Equal';
            end
            cnt = cnt + 1;
        end
    catch e
        disp(e);
    end
end
