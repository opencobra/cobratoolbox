function model = generateGrRules(model, hyperlinkCommand)
if nargin < 2
    hyperlinkCommand = [];
end
addGrRulesLinked = ~isempty(hyperlinkCommand);
if addGrRulesLinked && ~isfield(model, 'rules') && isfield(model, 'grRules')
    % if *.rules not exist and want to create hyperlinked grRules from *.grRules 
    model = generateRules(model);
end
genesFromRules = false;
if ~isfield(model, 'genes') && isfield(model, 'rules')
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
    model.genes = strcat('x(', cellfun(@num2str, num2cell((1:maxGeneId)'), 'UniformOutput', false), ')');
end
end