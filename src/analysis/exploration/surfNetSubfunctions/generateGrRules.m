function model = generateGrRules(model, hyperlinkCommand)
% Generate model.grRules consistent with model.rules and model.genes, with
% an additional function of adding a field *.grRulesLinked in which the
% genes in the rules are hyperlinked with the provided command when
% displayed in the Matlab command window (used by `surfNet.m`).
%
% USAGE:
%    model = generateGrRules(model, hyperlinkCommand)
%
% INPUT:
%    model:            COBRA model
%
% OPTIONAL INPUT:
%    hyperlinkCommand: a string of Matlab command for the genes in the model
%                      e.g., 'fprintf(''%s'')' where %s will be replaced by the gene
%                      (default [], not adding the field for hyperlinked grRules)
%
% OUTPUT:
%    model:            COBRA model updated with *.grRules, and
%                      *.grRulesLinked if `hyperlinkCommand` is a non-empty string

if nargin < 2
    hyperlinkCommand = [];
end
% add *.grRulesLinked or not
addGrRulesLinked = ~isempty(hyperlinkCommand);
% add empty rules if nothing is there
if ~isfield(model, 'rules') && ~isfield(model, 'grRules')
    model.rules = repmat({''}, numel(model.rxns), 1);
end
if ~isfield(model, 'rules') && isfield(model, 'grRules')
    % if *.rules not exist, get from *.grRules
    model = generateRules(model);
end
% if *.genes is not present, just use x(1), ..., x(N) in *.rules as genes
genesFromRules = false;
if ~isfield(model, 'genes') && isfield(model, 'rules')
    genesFromRules = true;
    maxGeneId = 0;
end
% generate model.grRules from model.rules and model.genes
model.grRules = strrep(model.rules, '|', 'or');
model.grRules = strrep(model.grRules, '&', 'and');
model.grRules = strrep(model.grRules, '~', 'not');

if addGrRulesLinked
    model.grRulesLinked = model.grRules;
end
for j = 1:numel(model.grRules)
    % identify the gene ID
    re = regexp(model.grRules{j}, 'x\((\d+)\)', 'tokens');
    if ~isempty(re)
        for k = 1:numel(re)
            id = str2double(re{k}{1});
            if genesFromRules
                % if *.genes not exist, name the gene as x(n) and get the max number of genes
                gene = ['x(', re{k}{1}, ')'];
                maxGeneId = max([maxGeneId, id]);
            else
                % replace x(n) with the corresponding gene in *.genes
                gene = strtrim(regexprep(model.genes{id}, '\s', ''));
                model.grRules{j} = strrep(model.grRules{j}, ['x(', re{k}{1}, ')'], gene);
            end
            if addGrRulesLinked
                % add hyperlinks for the genes in *.grRulesLinked
                linkedGene = printHyperlink(sprintf(hyperlinkCommand, gene), gene, 0, 0);
                model.grRulesLinked{j} = strrep(model.grRulesLinked{j}, ['x(', re{k}{1}, ')'], linkedGene);
            end
        end
    end
end
if genesFromRules
    % assign *.genes if not exist
    if maxGeneId > 0
        model.genes = strcat('x(', cellfun(@num2str, num2cell((1:maxGeneId)'), 'UniformOutput', false), ')');
    else
        model.genes = cell(0, 1);
    end
end
end