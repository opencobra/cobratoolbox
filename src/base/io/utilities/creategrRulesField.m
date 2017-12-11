function model = creategrRulesField(model, positions)
% Generates the grRules optional model field from the required rules and gene fields.
%
% USAGE:
%
%    modelWithField = creategrRulesField(model, positions)
%    
% INPUT:
%    model:             The COBRA Model structure to generate the grRules Field for
%                       an existing grRules field will be overwritten
%
% OPTIONAL INPUT:
%
%    positions:         The positions to update. Can be supplied either as 
%                       logical array, double indices, or reaction names (Default: model.rxns)
%
% OUTPUT:
%    model:    The Output model with a grRules field
%
% .. Authors: - Thomas Pfau May 2017

if ~exist('positions','var')
    pos = true(size(model.rxns));
else
    if islogical(positions)
        pos = positions;
    else
        if isnumeric(positions)
            pos = false(size(model.rxns));
            pos(positions) = true;
        elseif iscell(positions)
            pos = ismember(model.rxns,positions);
            if ~sum(pos) == numel(unique(positions))
                error('The following reactions are not part of this model:\n%s\n',positions(~ismember(postions, model.rxns)));
            end
        end
        
    end
end

currentrules = model.rules(pos);
currentrules = strrep(currentrules,'&','and');
currentrules = strrep(currentrules,'|','or');
currentrules = regexprep(currentrules,'x\(([0-9]+)\)','${model.genes{str2num($1)}}');
model.grRules(pos,1) = currentrules;
