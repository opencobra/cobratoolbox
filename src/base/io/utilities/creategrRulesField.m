function model = creategrRulesField(model)
%CREATEGRRULESFIELD generates the grRules optional model field from the
%required rules and gene fields.

currentrules = model.rules;
currentrules = strrep(currentrules,'&','and');
currentrules = strrep(currentrules,'|','or');
for i = 1:numel(model.genes)
    currentrules = strrep(currentrules,['x(' num2str(i) ')'],['(' model.genes{i} ')']);
end
model.grRules = currentrules;


    