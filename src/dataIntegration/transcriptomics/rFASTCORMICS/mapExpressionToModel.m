function [mapping] = mapExpressionToModel(model, data, dico, rownames, processTranscripts)
% The mapExpressionToModel function map the expression to a model following
% the GPR rules (Pacheco et al,2019)
%
% USAGE:
%
%   [mapping] = mapExpressionToModel(model, data, dico, rownames, processTranscripts)
%
% INPUTS:
%   model:                 (the following fields are required - others can be supplied)
%                          * S  - `m x 1` Stoichiometric matrix
%                          * lb - `n x 1` Lower bounds
%                          * ub - `n x 1` Upper bounds
%                          * rxns   - `n x 1` cell array of reaction abbreviations
%
%   data:                  expression or dicretized values for the samples, size(expression,1) =
%                          lenghth(gene IDs size(expression,2) = number of
%                          samples
%   dico:                  table which contains corresponding gene identifier information. Needed
%                          to map the rownames to the genes in the model. Can
%                          contain multiple columns, with different identifiers.
%   rownames:              cell array with the gene IDs
% 
% OPTIONAL INPUTS:
%   processTranscripts:    0 for inactive (default), 1 for active - if active, 
%                          consider gene names of the model without any numbers after a "."
% OUTPUTS:
%   mapping                matrix containing the expression values that were mapped to the reactions acoording to the GPR rules
%                          size(mapping,1) is equal to the number of reactions and size(mapping,2) is equal to size(data,2)
%
% .. Authors:
%       - Maria Pires Pacheco, Thomas Sauter, 2016, University of Luxembourg, modified by Tamara Bintener
%       - Maria Pires Pacheco, Thomas Sauter, 2022, University of Luxembourg, adaptation of the code to the Cobra toolbox
%       - Leonie Thomas, 2024, University of Luxembourg, upgrade of the mapping loop to make it faster
%       - Vanille Lejal, 2024, University of Luxembourg, addition of an optional parameter for handling transcripts
                         
%% 
if nargin < 5
    processTranscripts = 0; % default value
end

% search the dataIds in the dictionnary
if istable(dico)
    dico = table2array(dico);
else
    disp('dico must be a table');
    return
end

if any(cellfun(@isempty, rownames))
    disp('rownames contains empty entries, please check')
    return
end

% find the dico column with the highest number of matches in rownames
col = (sum(ismember(dico, rownames)) == max(sum(ismember(dico, rownames))));
[~, idico, irownames] = intersect(dico(:, col), rownames); % get indices in dico of the gene identifiers that match with rownames

if isempty(irownames)
    'rownames does not match the dataIds in the dico';
    return
end

mapped = data(irownames, :); % get discretized data for rownames matching in the dico

% create a new variable with only the genes in rownames that have a match in dico
mapped2(:, 1) = rownames(irownames); % same order than input

% as many columns as in dico
for i = 1:size(dico, 2)
    try        
        mapped2(:, i+1) = dico(idico, i); %completing mapped2
    catch
        try        
            mapped2(:, i+1) = cellstr(dico(idico, i)); % might need conversion to cell
        catch
            warning('Could not assign column %d from dico.', i); 
        end
    end
end

% deal with transcripts
if (processTranscripts == 1) && any(contains(model.genes, '.'))
    disp('Transcripts will temporarily be removed to allow matching with the discretized data.')
    model.genes = regexprep(model.genes, '\.[0-9]*', '');
end % corrected model genes (nothing after the dot)

% initialise the variable that will contain discretized expression data for genes of the model that have a discretized value
mappedToGenes = zeros(numel(model.genes), size(mapped, 2)); 

genesMatched = 0;

% maps the discretized expression data to the genes
for i = 1:numel(model.genes)
    [match, ~] = find(ismember(mapped2, model.genes(i))); %find row of match
    if numel(match) == 1
        mappedToGenes(i, :) = mapped(match, :); % discretized value is assigned
    elseif numel(match) > 1
        mappedToGenes(i, :) = max(mapped(match, :), [], 1); % take the highest value if more probeIDs correspond to one modelID
    end
    if ~isempty(match)
        genesMatched =  genesMatched + 1;
    end
end

fprintf('%i of %i genes of the model matched\n', genesMatched, numel(model.genes))

mapping = zeros(numel(model.rxns), size(mapped, 2)); % map the expression data to the reactions

% rewrite the rules
rules = regexprep(model.rules, 'x\(([0-9]*)\)','x($1,:)');
% find rules that are not empty
match = find(~strcmp(rules, ''));
% loop over all rules
for k = 1:numel(rules(match))       
    mapping(match(k),:) = GPRrulesMapper(cell2mat(rules(match(k))), mappedToGenes);
end
