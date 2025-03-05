function geneWeight = calculateGeneWeight(model,Transcriptomic, Threshold)
% Inputs:
%   model              - A COBRA model with mandatory fields: grRules and SConsistentRxnBool.
%   Transcriptomic     - A table with entrezID and geneExpression values.
%   Threshold          - Threshold for transcriptomic data.


% Note: geneWeight is a value that can be used in entropicFBA to assign a weight
% that corresponds to the gene expression value to internal reactions. If you
% want to use this value for this purpose, use the following formula: 
% cr = cf = -log(geneWeight + 1e-8) + 1 - ci/g
% Default values: g = 2 , ci = 0

% Author : Samira Ranjbar 2024
% (The algoithm is explained here:
% https://doi.org/10.1016/j.isci.2023.106201)
%-------------------------------------------------
if isfield(model,'grRules')
    rule = model.grRules(model.SConsistentRxnBool);
else
    error('grRules is missiming')
end
if ~isfield(model,'SConsistentRxnBool')
    error('grRules is missiming')
end

orList =[];
% Divide the rule by "or" and iterate over each resulting subrule
for i = 1:length(rule)
    % if ~isempty(rule(i))
    subrules = strsplit(strjoin(rule(i)), ' or ');

    for subruleIndex = 1:length(subrules)
        % Split each subrule by "and" to get a list of genes
        genes = strsplit(subrules{subruleIndex}, ' and ');

        g_vector = {};

        % Process each gene
        for geneIndex = 1:length(genes)
            gene = strrep(genes{geneIndex}, '(', '');  % Remove "("
            gene = strrep(gene, ')', '');  % Remove ")"
            gene = strrep(gene, ' ', '');  % Remove spaces
            g_vector{geneIndex} = [gene];
        end
        % g_table = cell2table(g_vector', 'VariableNames', {'GeneID'});

        % Evaluate the minimum expression value
        if contains(g_vector,'rec1_')
            fpkmTable1 = Transcriptomic(:,[1,2]);
            values = fpkmTable1{ismember(strrep(cellstr(num2str(fpkmTable1.entrezID)),' ',''), strrep(cellstr(g_vector),'rec1_','')), 2};
        elseif contains(g_vector,'rec2_')
            fpkmTable2 = Transcriptomic(:,[1,3]);
            values = fpkmTable2{ismember(strrep(cellstr(num2str(fpkmTable2.entrezID)),' ',''), strrep(cellstr(g_vector),'rec2_','')), 2};
        else
            values = Transcriptomic{ismember(strrep(cellstr((Transcriptomic.entrezID)),' ',''), cellstr(g_vector)), 2};

        end
        value = min(values);

        % Apply the threshold
        if value < Threshold
            value = 0;
        end

        % Add the minimum to the list
        orList = vertcat(orList, value);
        
    % end
    end
        expList{i,1} = orList';
        orList = [];
        expList{i,2} = sum(expList{i,1});
        % Return the sum of the list
        % result = sum(orList);
end


 % Access the first and second columns and convert them to numeric arrays
firstColumn = expList(:, 1);
secondColumn = cell2mat(expList(:, 2));
medianValue = median(secondColumn);
% Find empty cells in the first column
isEmptyFirstColumn = cellfun('isempty', firstColumn);

% Replace empty cells in the first column with the corresponding row median from the second column
for i = 1:numel(firstColumn)
    if isEmptyFirstColumn(i) & model.SConsistentRxnBool
        secondColumn(i) = medianValue;
    end
end
geneWeight = secondColumn;