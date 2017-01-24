function [isSame,nDiff,commonFields] = isSameCobraModel(model1,model2)
%isSameCobraModel Checks if two COBRA models are the same
%
% [isSame,nDiff,commonFields] = isSameCobraModel(model1,model2)
%
%INPUTS
% model1        COBRA model structure 1
% model2        COBRA model structure 2
%
%OUTPUTS
% isSame        True if all common fields are identical, else false
% nDiff         Number of differences between the two models for each field
% commonFields  List of common fields
%
% Authors:
%     - Markus Herrgard 9/14/07
%     - CI integration: Laurent Heirendt

isSame = true;

fields1 = fieldnames(model1);
fields2 = fieldnames(model2);
onlyIn1 = setdiff(fields1, fields2);
onlyIn2 = setdiff(fields2, fields1);
commonFields = intersect(fields1, fields2);
commonFields = commonFields(~strcmpi('description', commonFields));

if (~isempty(onlyIn1) & ~isempty(onlyIn2))
    isSame = false;
end

% initialize variables
nFields = length(commonFields);
nDiff = zeros(nFields,1);

% loop through all fields
for i = 1:nFields
    fieldName = commonFields{i};
    value1 = getfield(model1, fieldName);
    value2 = getfield(model2, fieldName);

    % replace all whitespaces
    if iscellstr(value1)
        value1 = regexprep(value1, '[^\w'']', '');
        value2 = regexprep(value2, '[^\w'']', '');
    end

    if isnumeric(value1)
        nDiff(i) = sum(sum(value1 ~= value2));

    elseif iscellstr(value1)
        nDiff(i) = sum(~strcmp(value1, value2));

    elseif ischar(value1)
        nDiff(i) = ~strcmp(value1, value2);
    end

    if (nDiff(i) > 0)
        isSame = false;
    end
end
