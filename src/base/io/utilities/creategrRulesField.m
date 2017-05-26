function modelWithField = creategrRulesField(model)
% Generates the grRules optional model field from the
% required rules and gene fields.
%
% USAGE:
%
%    modelWithField = creategrRulesField(model)
%
% INPUT:
%    model:             The COBRA Model structure to generate the grRules Field for
%                       an existing grRules field will be overwritten
%
% OUTPUT:
%    modelWithField:    The Output model with a grRules field
%
% .. Authors: - Thomas Pfau May 2017



currentrules = model.rules;
currentrules = strrep(currentrules,'&','and');
currentrules = strrep(currentrules,'|','or');
for i = 1:numel(model.genes)
    currentrules = strrep(currentrules,['x(' num2str(i) ')'],['(' model.genes{i} ')']);
end
modelWithField.grRules = currentrules;
