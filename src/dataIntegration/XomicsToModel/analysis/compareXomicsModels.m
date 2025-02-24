function [overlapResults,statistic] = compareXomicsModels(multiModels, printFlag)
%Compare generated models in mets, rxns, genes
%
%USAGE:
%
%    [overlapResults,statistic] = compareXomicsModels(multiModels, printFlag)
%
%INPUT:
%    multiModels:     struct format with models that need to compare
%                      e.g.multimodels.model1
%                          multimodels.model2 ...
%    printFlag:       1 if information should be printed to a table.
%                     Default = 0
%
%OUTPUT:
%    overlapResults:  the overlapped met/rxn/gene numbers of each pair of models
%    statistic:       the overlapped porportion matrix of each pair of models
%
%EXAMPLE:
%
%    [overlapResults,statistic] = compareXomicsModels(multiModels)
%
%NOTE:
%
%    This function is used to compare generated models from xomicsToModel
%    pipeline
%
%Author(s): - Xi Luo, update at 2024/10
%           - Hanneke Leegwater (2022)

%% Check input params

if ~exist('printFlag', 'var') || isempty(printFlag)
    printFlag = 0;
elseif (~isnumeric(printFlag) & ~islogical(printFlag))
    error('printFlag should be a number or a bool')
end

%% Initialize
models = multiModels;

if isstruct(models) && length(fieldnames(models))>1
    fields = fieldnames(models);
    numModels = length(fields);

    % Initialize matrices for statistics and results
    statMets = cell(numModels);
    statRxns = cell(numModels);
    statGenes = cell(numModels);
    overlap_mets = struct();
    overlap_rxns = struct();
    overlap_genes = struct();

    % Loop over all model pairs to compute overlaps
    for i = 1:numModels
        for j = 1:numModels
            % Mets overlap
            overlap_mets.(fields{i}).(fields{j}) = models.(fields{i}).mets(ismember(models.(fields{i}).mets, models.(fields{j}).mets));
            statMets{i,j} = length(overlap_mets.(fields{i}).(fields{j}));

            % Rxns overlap
            overlap_rxns.(fields{i}).(fields{j}) = models.(fields{i}).rxns(ismember(models.(fields{i}).rxns, models.(fields{j}).rxns));
            statRxns{i,j} = length(overlap_rxns.(fields{i}).(fields{j}));

            % Genes overlap
            overlap_genes.(fields{i}).(fields{j}) = models.(fields{i}).genes(ismember(models.(fields{i}).genes, models.(fields{j}).genes));
            statGenes{i,j} = length(overlap_genes.(fields{i}).(fields{j}));
        end
    end
    % Convert statistics to tables
    statMets = cell2table(statMets, 'VariableNames', fields, 'RowNames', fields);
    statRxns = cell2table(statRxns, 'VariableNames', fields, 'RowNames', fields);
    statGenes = cell2table(statGenes, 'VariableNames', fields, 'RowNames', fields);

    % Store results in output structure
    overlapResults.mets = overlap_mets;
    overlapResults.rxns = overlap_rxns;
    overlapResults.genes = overlap_genes;
    % Calculate all overlap across all models
    overlapResults.mets.alloverlap = intersectMultipleModels(models, fields, 'mets');
    overlapResults.rxns.alloverlap = intersectMultipleModels(models, fields, 'rxns');
    overlapResults.genes.alloverlap = intersectMultipleModels(models, fields, 'genes');

    statistic.overlapnumber_mets=statMets;
    statistic.overlapnumber_rxns=statRxns;
    statistic.overlapnumber_genes=statGenes;

    % Calculate symmetric proportion matrix (A ∩ B) / (A ∪ B)
    statistic.overlapproportion_mets = calculateProportionMatrix(models, fields, 'mets', statMets);
    statistic.overlapproportion_rxns = calculateProportionMatrix(models, fields, 'rxns', statRxns);
    statistic.overlapproportion_genes = calculateProportionMatrix(models, fields, 'genes', statGenes);

else
    disp('please check the input variable')
end


% Print tables with output if printFlag = 1
if printFlag ==1
    disp('Number of overlapping mets between models is:')
    statistic.overlapnumber_mets

    disp('Number of overlapping rxns between models is:')
    statistic.overlapnumber_rxns

    disp('Number of overlapping genes between models is:')
    statistic.overlapnumber_genes
end

end

% Function to calculate the intersection across multiple models
function allOverlap = intersectMultipleModels(models, fields, featureType)
    allOverlap = models.(fields{1}).(featureType);
    for i = 2:length(fields)
        allOverlap = intersect(allOverlap, models.(fields{i}).(featureType));
    end
end

% Function to calculate proportion matrix (A ∩ B) / (A ∪ B)
function proportionTable = calculateProportionMatrix(models, fields, featureType, statTable)
    numModels = length(fields);
    proportionMatrix = cell(numModels);
    
    for i = 1:numModels
        for j = 1:numModels
            % Calculate the union (A ∪ B) for proportion
            unionCount = length(union(models.(fields{i}).(featureType), models.(fields{j}).(featureType)));
            if unionCount > 0
                proportionMatrix{i,j} = round(100 * statTable{i,j} / unionCount, 2);  % (A ∩ B) / (A ∪ B)
            else
                proportionMatrix{i,j} = NaN;  % Avoid division by zero
            end
        end
    end
    
    % Convert to table for easy reading
    proportionMatrix = cell2table(proportionMatrix, 'VariableNames', fields, 'RowNames', fields);
    proportionTable = proportionMatrix;
end
