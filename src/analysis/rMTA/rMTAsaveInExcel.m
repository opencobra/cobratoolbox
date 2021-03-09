function rMTAsaveInExcel(xls_filename, TSscore, deletedGenes, alpha_values, varargin)
% Save in Excel all the results calculated using rMTA.
%
% USAGE:
%
%    rMTAsaveInExcel(output_file, TSscore, deletedGenes, alpha_values, varargin)
%
% INPUTS:
%    xls_filename:       name of the resulting excel file
%    TSscore:            Transformation score by each transformation
%    deletedGenes:       The list of genes/reactions removed in each knock-out
%    alpha_values:       Numeric value or array. Parameter of the quadratic
%                        problem (default = alpha_1, alpha_2,...)
%
% OPTIONAL INPUTS:
%    gene_info:          Table with the gene names and additional
%                        information. It needs a column called 'gene',
%                        which contains the same information as the
%                        deletedGenes variable.
%    differ_genes:       Table with the gene differential expression 
%                        information. It needs a column called 'gene',
%                        which contains the same information as the
%                        deletedGenes variable.
%    RankingGeneID:      Caracter array with the ID of the gene which score
%                        is desired to know.
%
% .. Authors:
%       - Luis V. Valcarcel, 08/03/2021, University of Navarra, CIMA & TECNUN School of Engineering.

p = inputParser;
% check required arguments
addRequired(p, 'xls_filename', @(x)ischar(x));
addRequired(p, 'TSscore');
addRequired(p, 'deletedGenes');
% Check optional arguments
addOptional(p, 'alpha_values', -1, @isnumeric);
% Add optional name-value pair argument
addParameter(p, 'gene_info', []);
addParameter(p, 'differ_genes', []);
addParameter(p, 'RankingGeneID', [], @(x)ischar(x));
% extract variables from parser
parse(p, xls_filename, TSscore, deletedGenes, alpha_values, varargin{:});
gene_info = p.Results.gene_info;
differ_genes = p.Results.differ_genes;
RankingGeneID = p.Results.RankingGeneID;
num_alphas = numel(alpha_values);
if alpha_values == -1
    alpha_values = 1:size(TSscore.bTS,2);
end

% In order to store the results of all the cases, a cell array is going to
% store a table with the results for each alpha
results = cell(size(alpha_values));

% threshold for viable results
th = -1e20; % not (-INF) == infeasible

for i = 1:num_alphas
    fprintf('\tProcess results for alpha = %1.2f \n',alpha_values(i));
    T = table(deletedGenes, TSscore.bTS(:,i), TSscore.mTS, TSscore.wTS(:,i),TSscore.rTS(:,i));
    T.Properties.VariableNames = {'gene','bTS','mTS','wTS','rTS'};
    
    if ~isempty(gene_info)
        % join to extra information of genes
        T = join(gene_info,T,'Keys','gene');
    end
    
    %sort by MOMA results
    T = sortrows(T,'rTS','descend');
    
    % store only viable genes
    T = T(T.bTS>th,:);
    results{i} = T;
end

fprintf('\tSelected the "%u" best solutions\n',sum(T.mTS>(th)));

%export to excel
LETTERS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
% Export results for the different alphas
for i = 1:num_alphas
    T = results{i};
    fprintf('\tWrite xls for alpha = %1.2f \n',alpha_values(i));
    sheet_name = ['alpha = ',num2str(alpha_values(i))];
    
    % write results
    writetable(T,xls_filename,'FileType','spreadsheet','Sheet',sheet_name,'WriteVariableNames',true);
    
    LETTER = LETTERS(size(T,2)+3);
    
    if exist('RankingGeneID','var') && ~isempty(RankingGeneID)
        % ranking of gene
        xlswrite(xls_filename,{['position ' RankingGeneID]},sheet_name,[LETTER '2']);
        xlswrite(xls_filename,{['=MATCH(' RankingGeneID ',A:A,0)-1']},sheet_name,[LETTER '3']);
        xlswrite(xls_filename,{'ranking genes with KO'},sheet_name,[LETTER '4']);
        xlswrite(xls_filename,{['=' LETTER '3/' num2str(size(T,1))]},sheet_name,[LETTER '5']);
        xlswrite(xls_filename,{'ranking genes model'},sheet_name, [LETTER '6']);
        xlswrite(xls_filename,{['=' LETTER '3/' num2str(numel(deletedGenes))]}, sheet_name,[LETTER '7']);
    end
end

fprintf('\tWrite selection of best genes\n');
num = numel(results{i}.gene);
TopGenes_ID = cell(num,num_alphas);
titles = cell(1,num_alphas);
for i = 1:num_alphas
    num = sum(results{i}.rTS > 0);
    TopGenes_ID(1:num,i) = results{i}.gene(1:num);
    titles{i} = ['alpha = ',num2str(alpha_values(i))];
end
xlswrite(xls_filename,titles,'TOP_GENES_ID','A1');
xlswrite(xls_filename,TopGenes_ID,'TOP_GENES_ID','A2');


TopGenes_join = TopGenes_ID(~cellfun(@isempty,TopGenes_ID(:,1)),1);
for i = 1:num_alphas
    TopGenes_join = intersect(TopGenes_join,TopGenes_ID(~cellfun(@isempty,TopGenes_ID(:,i)),i));
end

if ~isempty(differ_genes)
    differ_genes = differ_genes(~strcmp(differ_genes.gene,''),:);
    [~, idx, ~] = unique(differ_genes.gene);
    differ_genes = differ_genes(idx,:);
    differ_genes.Properties.RowNames = differ_genes.gene;
    
    idx = intersect(deletedGenes,differ_genes.gene);
    
    xlswrite(xls_filename,differ_genes.Properties.VariableNames,'TOP_GENES_diff_expr','A1');
    xlswrite(xls_filename,table2cell(differ_genes(idx,:)),'TOP_GENES_diff_expr','A2');
end


if ~isempty(differ_genes) &&  ~isempty(RankingGeneID)
    
    fprintf('\tSUMMARY\n');
    
    differ_genes_aux = differ_genes(differ_genes.logFC>0,:);
    genes_FC_pos = differ_genes_aux.Properties.RowNames;
    
    SUMMARY = cell(7,2+5*num_alphas);
    table_aux_ranking = array2table(zeros(4,num_alphas));
    table_aux_ranking.Properties.RowNames = {'bTS','mTS','wTS','rTS'};
    table_aux_ranking.Properties.VariableNames = regexprep(strcat('alpha_',cellfun(@num2str,num2cell(alpha_values'),'UniformOutput',0)),'0.','0_');
    table_aux_ranking_FC_pos = table_aux_ranking;
    table_aux_sign = array2table(char(zeros(4,num_alphas)));
    table_aux_sign.Properties.RowNames = {'bTS','mTS','wTS','rTS'};
    table_aux_sign.Properties.VariableNames = regexprep(strcat('alpha_',cellfun(@num2str,num2cell(alpha_values'),'UniformOutput',0)),'0.','0_');
    num_KO = zeros(1,num_alphas);
    num_KO_FC_pos = zeros(1,num_alphas);
    for i = 1:num_alphas
        T = results{i};
        T.Properties.RowNames=T.gene;
        T2 = T(intersect(T.Properties.RowNames, genes_FC_pos),:);
        for j=1:size(table_aux_ranking,1)
            k = table_aux_ranking.Properties.RowNames{j};
            T = sortrows(T,k,'descend');
            T2 = sortrows(T2,k,'descend');
            try RankingGeneID = num2str(RankingGeneID); end
            table_aux_ranking{k,i} = find(strcmp(T.gene,RankingGeneID));
            try table_aux_ranking_FC_pos{k,i} = find(strcmp(T2.gene,RankingGeneID)); end
        end
        T = sortrows(T,'wTS','ascend');
        T2 = sortrows(T2,'wTS','ascend');
        table_aux_ranking{'wTS',i} = find(strcmp(T.gene,RankingGeneID));
        try table_aux_ranking_FC_pos{'wTS',i} = find(strcmp(T2.gene,RankingGeneID)); end
        aux = sign(T{RankingGeneID,table_aux_sign.Properties.RowNames})';
        aux2 = char(aux);
        aux2(:) = '+';
        aux2(aux<0) = '-';
        table_aux_sign{:,i} = aux2;
        num_KO(i) = size(T,1);
        num_KO_FC_pos(i) = size(T2,1);
    end
    
    table_aux_ranking_numKO = table2array(table_aux_ranking) ./ num_KO;
    table_aux_ranking_numDE = table2array(table_aux_ranking_FC_pos) ./ num_KO_FC_pos;
    table_aux_ranking_numgenes = table2array(table_aux_ranking) ./ length(deletedGenes);
    
    SUMMARY{1,2+0*num_alphas+1} = 'ranking';
    SUMMARY{1,2+1*num_alphas+1} = 'sign';
    SUMMARY{1,2+2*num_alphas+1} = 'ranking genes with KO';
    SUMMARY{1,2+3*num_alphas+1} = 'ranking genes with DE FC>0';
    SUMMARY{1,2+4*num_alphas+1} = 'ranking genes Recon1';
    
    SUMMARY(2,:) = [{'Case'} {'Score'} repmat(table_aux_ranking.Properties.VariableNames,1,5)];
    SUMMARY(3:6,2) = table_aux_ranking.Properties.RowNames;
    SUMMARY(3:6,3:end) = [table2cell(table_aux_ranking), table2cell(table_aux_sign), num2cell(table_aux_ranking_numKO), num2cell(table_aux_ranking_numDE), num2cell(table_aux_ranking_numgenes)];
    SUMMARY(end,2+2*num_alphas+(1:num_alphas)) = num2cell(num_KO);
    SUMMARY(end,2+3*num_alphas+(1:num_alphas)) = num2cell(num_KO_FC_pos);
    SUMMARY(end,2+4*num_alphas+(1:num_alphas)) = num2cell(length(deletedGenes));
    SUMMARY{1,1} = date();
    SUMMARY{end,1} = xls_filename;
    
    xlswrite(xls_filename,SUMMARY,'SUMMARY');
end

fprintf('DONE\n');

end

