function [C, order] = cobraConfusionmat(group, grouphat, varargin)
% Confusion matrix without the Statistics and Machine Learning Toolbox
%
% USAGE:
%
%    [C, order] = cobraConfusionmat(group, grouphat)
%    [C, order] = cobraConfusionmat(group, grouphat, 'Order', order)
%
% INPUTS:
%    group:      known groups: numeric or logical vector, categorical
%                vector, cell array of character vectors or string array
%    grouphat:   predicted groups, the same type and length as `group`
%
% OPTIONAL INPUT:
%    'Order':    the order of the groups in `C` (name case-insensitive); must
%                contain every group present in `group` and `grouphat`;
%                listed groups that do not occur give zero rows and columns
%
% OUTPUTS:
%    C:          K x K double matrix; C(i, j) counts the observations known to
%                be in group i and predicted in group j
%    order:      K x 1 group order (numeric column for numeric and logical
%                input, cell column of character vectors for text input,
%                categorical column for categorical input)
%
% EXAMPLE:
%
%    C = cobraConfusionmat([3 2 2 3 1 1]', [4 2 3 NaN 1 1]')
%    % C = [2 0 0 0; 0 1 1 0; 0 0 0 1; 0 0 0 0]
%
% NOTE:
%    Plain-MATLAB replacement for confusionmat (Statistics and Machine
%    Learning Toolbox); supported syntaxes are those listed under USAGE; any
%    other option raises an error naming it; semantics:
%    specs/20261111-152503-toolbox-free-remaining/mathworks-semantics.md,
%    G1 section 14. Missing values (NaN, '', "", <missing>, <undefined>) in
%    either input drop the observation. Default order: sorted for numeric
%    and logical input, the order of the categories for categorical input
%    (categories that occur), first appearance in [group; grouphat] for
%    text. A group that occurs but is not listed in 'Order' raises an error
%    naming it (the MathWorks behaviour is UNCONFIRMED).
%
% .. Authors:
%     - Generated for feature 20261111-152503-toolbox-free-remaining, 2026-11-11.

givenOrder = [];
if ~isempty(varargin)
    if numel(varargin) ~= 2 || ~(ischar(varargin{1}) || isstring(varargin{1})) || ~strcmpi(char(varargin{1}), 'order')
        if ischar(varargin{1}) || isstring(varargin{1})
            optionName = char(varargin{1});
        else
            optionName = class(varargin{1});
        end
        error('COBRA:cobraConfusionmat:unsupportedOption', ...
            'cobraConfusionmat: unsupported option ''%s'' (only ''Order'' is supported).', optionName);
    end
    givenOrder = varargin{2};
end
if numel(group) ~= numel(grouphat) || ~strcmp(class(group), class(grouphat)) && ...
        ~((isnumeric(group) || islogical(group)) && (isnumeric(grouphat) || islogical(grouphat)))
    error('COBRA:cobraConfusionmat:invalidInput', 'cobraConfusionmat: group and grouphat must have the same type and length.');
end

[keys, keysHat, isMissing, isTextKey] = toKeys(group, grouphat);
keys = keys(~isMissing);
keysHat = keysHat(~isMissing);
pooled = [keys; keysHat];

if isempty(givenOrder)
    if isTextKey
        if iscategorical(group)
            levels = categories(group);
            levels = levels(ismember(levels, pooled));
        else
            levels = unique(pooled, 'stable');
        end
    else
        levels = unique(pooled);
    end
else
    [levels, ~, ~, isTextOrder] = toKeys(givenOrder(:), givenOrder(:));
    if isTextOrder ~= isTextKey
        error('COBRA:cobraConfusionmat:invalidInput', 'cobraConfusionmat: ''Order'' must have the same type as group.');
    end
    unlisted = setdiff(pooled, levels);
    if ~isempty(unlisted)
        if isTextKey
            unlistedName = unlisted{1};
        else
            unlistedName = num2str(unlisted(1));
        end
        error('COBRA:cobraConfusionmat:invalidOrder', ...
            'cobraConfusionmat: ''Order'' does not list the group ''%s''.', unlistedName);
    end
end

[~, rowIndex] = ismember(keys, levels);
[~, columnIndex] = ismember(keysHat, levels);
K = numel(levels);
C = accumarray([rowIndex, columnIndex], 1, [K K]);

if ~isempty(givenOrder)
    order = givenOrder(:);
    if iscellstr(order) || isstring(order)
        order = cellstr(order);
    end
elseif iscategorical(group)
    order = categorical(levels, categories(group));
elseif isTextKey
    order = levels;
else
    order = levels;
    if islogical(group)
        order = logical(order);
    end
end
end

function [keys, keysHat, isMissing, isTextKey] = toKeys(group, grouphat)
% Converts both inputs to column keys (double or cellstr) and marks missing pairs
isTextKey = ~(isnumeric(group) || islogical(group));
if isTextKey
    textKeys = string(group(:));
    textKeysHat = string(grouphat(:));
    missingKey = ismissing(textKeys) | textKeys == "";
    missingHat = ismissing(textKeysHat) | textKeysHat == "";
    textKeys(missingKey) = "";
    textKeysHat(missingHat) = "";
    keys = cellstr(textKeys);
    keysHat = cellstr(textKeysHat);
else
    keys = double(group(:));
    keysHat = double(grouphat(:));
    missingKey = isnan(keys);
    missingHat = isnan(keysHat);
end
isMissing = missingKey | missingHat;
end
