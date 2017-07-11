function [model2] = generateRules(model)
% If a model does not have a model.rules field but has a model.grRules
% field, can be regenerated using this script
%
% USAGE:
%
%    [model2] = generateRules(model)
%
% INPUT:
%    model:     with model.grRules
%
% OUTPUT:
%    model2:    same model but with model.rules added
%
% .. Author: -  Aarash Bordar 11/17/2010

grRules = model.grRules;
genes = model.genes;

[m,n] = size(model.S);

rules(1:n,1) = {''};

for i = 1:n
    if length(grRules{i}) > 0
        tmp = grRules{i};
        %The function assumes that there are no spaces between parenthesis
        %and formulas, or it creates "empty" gene associations. so we
        %replace all spaces trailing or preceding parenthesis.
        tmp = regexprep(tmp,'\( *','('); %replace all spaces after opening parenthesis
        tmp = regexprep(tmp,' *\)',')'); %replace all spaces before closing paranthesis.
        tmp = regexprep(tmp,' * (and|AND|or|OR|And|Or)  *',' $1 '); %replace all surplus spaces around logical operators

        tmp = splitString(tmp,' ');
        tmp = strrep(tmp,' ','');

        tmp2 = [];
        for j = 1:length(tmp)
            if strcmp(tmp{j},'or')
                tmp2 = [tmp2,'| '];
            elseif strcmp(tmp{j},'and')
                tmp2 = [tmp2,'& '];
            elseif strcmp(tmp{j}(1),'(') & strcmp(tmp{j}(end),')')
                tmp{j} = strrep(tmp{j},'(','');
                tmp{j} = strrep(tmp{j},')','');
                loc = strmatch(tmp{j},genes,'exact');
                tmp2 = [tmp2,'(x(',num2str(loc),')) '];
            elseif strcmp(tmp{j}(1),'(')
                tmp{j} = strrep(tmp{j},'(','');
                tmp{j} = strrep(tmp{j},')','');
                loc = strmatch(tmp{j},genes,'exact');
                tmp2 = [tmp2,'(x(',num2str(loc),') '];
            elseif strcmp(tmp{j}(end),')')
                tmp{j} = strrep(tmp{j},'(','');
                tmp{j} = strrep(tmp{j},')','');
                loc = strmatch(tmp{j},genes,'exact');
                tmp2 = [tmp2,'x(',num2str(loc),')) '];
            else
                loc = strmatch(tmp{j},genes,'exact');
                tmp2 = [tmp2,'x(',num2str(loc),') '];
            end
        end

        tmp2 = tmp2(1:end-1);
        rules{i} = tmp2;

    end
end


model2 = model;
model2.rules = rules;
