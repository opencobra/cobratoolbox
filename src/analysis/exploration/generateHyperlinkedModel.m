function model = generateHyperlinkedModel(model, metNameFlag, hyperlinkCommand)
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