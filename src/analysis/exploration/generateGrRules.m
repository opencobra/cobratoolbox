function model = generateGrRules(model)
% generate model.grRules from model.rules and model.genes
model.grRules = model.rules;
for j = 1:numel(model.grRules)
    re = regexp(model.grRules{j}, 'x\((\d+)\)', 'tokens');
    if ~isempty(re)
        for k = 1:numel(re)
            id = str2double(re{k}{1});
            model.grRules{j} = strrep(model.grRules{j}, ['x(', re{k}{1}, ')'], strtrim(regexprep(model.genes{id}, '\s', '')));
        end
    end
end
end