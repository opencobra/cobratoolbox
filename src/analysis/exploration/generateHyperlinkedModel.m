function model = generateHyperlinkedModel(model, metNameFlag, hyperlinkCommand)
% Generate a copy of a COBRA model in which the gene-reaction rules,
% metabolites, reactions and genes are decorated with clickable MATLAB
% hyperlinks for interactive exploration at the command line
%
% USAGE:
%
%    model = generateHyperlinkedModel(model, metNameFlag, hyperlinkCommand)
%
% INPUT:
%    model:               COBRA model structure with fields:
%
%                           * .rules - `n x 1` evaluatable gene-reaction association rules
%                           * .grRules - `n x 1` readable gene-reaction association rules
%                           * .genes - gene identifiers
%                           * .mets - `m x 1` metabolite identifiers
%                           * .rxns - `n x 1` reaction identifiers
%                           * .metNames - `m x 1` metabolite names
%
% OPTIONAL INPUTS:
%    metNameFlag:         if true, hyperlink metabolite names rather than
%                         metabolite identifiers (default false)
%    hyperlinkCommand:    format string for the MATLAB command executed when a
%                         hyperlink is clicked (default 'fprintf(''%s\n'')')
%
% OUTPUT:
%    model:               COBRA model structure with the added hyperlinked fields:
%
%                           * .grRules - gene-reaction rules with gene identifiers substituted in
%                           * .grRulesLinked - gene-reaction rules with hyperlinked genes
%                           * .metsLinked - hyperlinked metabolites
%                           * .rxnsLinked - hyperlinked reactions
%                           * .genesLinked - hyperlinked genes
%

if nargin < 2 || isempty(metNameFlag)
    metNameFlag = false;
end
if nargin < 3
    hyperlinkCommand = 'fprintf(''%s\\n'')';
end

%% make sure *.rules, *.genes and *.grRules all exist and are consistent
if ~isfield(model, 'rules') && isfield(model, 'grRules')
    % if *.rules not exist and want to create hyperlinked grRules from *.grRules 
    model = generateRules(model);
elseif ~isfield(model, 'rules')
    model.rules = repmat({''}, numel(model.rules), 1);
end
genesFromRules = false;
if ~isfield(model, 'genes')
    genesFromRules = true;
    maxGeneId = 0;
end
% generate model.grRules from model.rules and model.genes
model.grRules = model.rules;
if addGrRulesLinked
    model.grRulesLinked = model.grRules;
end
for j = 1:numel(model.grRules)
    re = regexp(model.grRules{j}, 'x\((\d+)\)', 'tokens');
    if ~isempty(re)
        for k = 1:numel(re)
            id = str2double(re{k}{1});
            if genesFromRules
                gene = ['x(', re{k}{1}, ')'];
                maxGeneId = max([maxGeneId, id]);
            else
                gene = strtrim(regexprep(model.genes{id}, '\s', ''));
                model.grRules{j} = strrep(model.grRules{j}, ['x(', re{k}{1}, ')'], gene);
            end
            if addGrRulesLinked
                linkedGene = printHyperlink(sprintf(hyperlinkCommand, gene), gene, 0, 0);
                model.grRulesLinked{j} = strrep(model.grRulesLinked{j}, ['x(', re{k}{1}, ')'], linkedGene);
            end
        end
    end
end
if genesFromRules
    if maxGeneId > 0
        model.genes = strcat('x(', cellfun(@num2str, num2cell((1:maxGeneId)'), 'UniformOutput', false), ')');
    else
        model.genes = cell(0, 1);
    end
end

%% add hyperlined mets, rxns and genes
if metNameFlag
    if ~isfield(model, 'metNames')
        model.metNames = model.mets;
    end
    model.metsLinked = strcat('<a href="matlab:', cellfun(@(x) sprintf([' ' command], x), model.mets, 'UniformOutput', false), ...
    '">', model.metNames, '</a>');
else
    model.metsLinked = strcat('<a href="matlab:', cellfun(@(x) sprintf([' ' command], x), model.mets, 'UniformOutput', false), ...
    '">', model.mets, '</a>');
end
model.rxnsLinked = strcat('<a href="matlab:', cellfun(@(x) sprintf([' ' command], x), model.rxns, 'UniformOutput', false), ...
    '">', model.rxns, '</a>');
model.genesLinked = strcat('<a href="matlab:', cellfun(@(x) sprintf([' ' command], x), model.genes, 'UniformOutput', false), ...
    '">', model.genes, '</a>');
end