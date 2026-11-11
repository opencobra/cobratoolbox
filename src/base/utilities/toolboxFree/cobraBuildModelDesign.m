function design = cobraBuildModelDesign(tbl, parsed, referenceInfo)
% Builds the design matrix of a linear or generalized linear model from a
% table and a parsed formula, without the Statistics and Machine Learning
% Toolbox
%
% USAGE:
%
%    design = cobraBuildModelDesign(tbl, parsed)
%    design = cobraBuildModelDesign(tbl, parsed, referenceInfo)
%
% INPUTS:
%    tbl:      table with the response and predictor variables
%    parsed:   structure returned by cobraParseModelFormula (fields response and terms)
%
% OPTIONAL INPUT:
%    referenceInfo: the variableInfo of a design built before (for example on the data a
%                   model was fitted to): its levels are used, so that new data are coded
%                   like the fitted data (unknown levels give missing rows); the response
%                   need not be in tbl (y is then NaN)
%
% OUTPUT:
%    design:   structure with fields
%
%                * X - N x p design matrix of all N rows of tbl (first column the
%                  intercept); rows with a missing value hold NaN
%                * y - N x 1 response (double)
%                * isMissing - N x 1 logical, true where a formula variable is missing
%                  (NaN, '', "", <missing>, <undefined>)
%                * coefficientNames - 1 x p cell array: '(Intercept)', then for each term
%                  the names of its columns
%                * variableInfo - structure array with, per predictor, `name`,
%                  `isCategorical` and `levels` (cell array of level names; the first is
%                  the reference)
%
% EXAMPLE:
%
%    tbl = table([1; 2; 3; 4], {'a'; 'b'; 'a'; 'b'}, [2; 4; 6; 9], 'VariableNames', {'x', 'g', 'y'});
%    design = cobraBuildModelDesign(tbl, cobraParseModelFormula('y ~ x + g', tbl.Properties.VariableNames));
%    % design.coefficientNames = {'(Intercept)', 'x', 'g_b'}
%
% NOTE:
%    Helper of cobraFitglm and cobraFitlm (plain-MATLAB replacements of fitglm and fitlm);
%    semantics: specs/20261111-152503-toolbox-free-remaining/mathworks-semantics.md, G3
%    section 6. Numeric (non-logical) predictors are continuous; logical, categorical,
%    string, cell and char predictors are categorical, with reference (dummy) coding and the
%    first level as reference, levels ordered as cobraGrp2idx orders them (first appearance
%    for text, category order for categorical, sorted for logical) among the rows without
%    missing values. Column names: 'x' (continuous), 'x_level' (categorical), joined with
%    ':' for interactions, the first factor varying fastest (the MathWorks order of the
%    columns of a categorical-by-categorical interaction is UNCONFIRMED; the names of logical
%    levels are '0' and '1').
%
% .. Authors:
%     - Generated for feature 20261111-152503-toolbox-free-remaining, 2026-11-11.

if ~istable(tbl)
    error('COBRA:cobraBuildModelDesign:invalidInput', 'cobraBuildModelDesign: tbl must be a table.');
end
nRows = height(tbl);
givenInfo = exist('referenceInfo', 'var') && ~isempty(referenceInfo);
if givenInfo && ~any(strcmp(parsed.response, tbl.Properties.VariableNames))
    y = NaN(nRows, 1);
else
    y = tbl.(parsed.response);
end
if ~(isnumeric(y) || islogical(y)) || ~isvector(y) && nRows > 0
    error('COBRA:cobraBuildModelDesign:invalidInput', 'cobraBuildModelDesign: the response ''%s'' must be a numeric or logical vector.', parsed.response);
end
y = double(y(:));
isMissing = isnan(y) & ~givenInfo;

predictors = unique([parsed.terms{:}], 'stable');
variableInfo = struct('name', {}, 'isCategorical', {}, 'levels', {}, 'index', {}, 'values', {});
for k = 1:numel(predictors)
    values = tbl.(predictors{k});
    if isnumeric(values) && ~islogical(values)
        if ~isvector(values) && ~isempty(values)
            error('COBRA:cobraBuildModelDesign:invalidInput', 'cobraBuildModelDesign: variable ''%s'' must be a vector.', predictors{k});
        end
        values = double(values(:));
        variableInfo(k) = struct('name', predictors{k}, 'isCategorical', false, 'levels', {{}}, 'index', [], 'values', values);
        isMissing = isMissing | isnan(values);
    else
        [index, ~] = cobraGrp2idx(values);
        variableInfo(k) = struct('name', predictors{k}, 'isCategorical', true, 'levels', {{}}, 'index', index, 'values', []);
        isMissing = isMissing | isnan(index);
    end
end
% levels among the rows used in the fit, in the order of cobraGrp2idx, or the given levels
for k = find([variableInfo.isCategorical])
    values = tbl.(variableInfo(k).name);
    if ischar(values)
        values = cellstr(values);
    end
    if givenInfo
        levels = referenceInfo(strcmp({referenceInfo.name}, variableInfo(k).name)).levels;
        if islogical(values)
            values = double(values); % logical levels are named '0' and '1'
        end
        [~, fullIndex] = ismember(cellstr(string(values(:))), levels);
        fullIndex(fullIndex == 0) = NaN;
        isMissing = isMissing | isnan(fullIndex);
    else
        [index, levels] = cobraGrp2idx(values(~isMissing));
        fullIndex = NaN(nRows, 1);
        fullIndex(~isMissing) = index;
    end
    variableInfo(k).index = fullIndex;
    variableInfo(k).levels = levels(:)';
end

X = ones(nRows, 1);
coefficientNames = {'(Intercept)'};
for t = 1:numel(parsed.terms)
    termColumns = ones(nRows, 1);
    termNames = {''};
    for f = 1:numel(parsed.terms{t})
        info = variableInfo(strcmp({variableInfo.name}, parsed.terms{t}{f}));
        if info.isCategorical
            nLevels = numel(info.levels);
            factorColumns = double(info.index == (2:nLevels));
            factorNames = strcat(info.name, '_', info.levels(2:end));
        else
            factorColumns = info.values;
            factorNames = {info.name};
        end
        % product of the columns so far (fastest) with the columns of this factor
        newColumns = zeros(nRows, size(termColumns, 2) * size(factorColumns, 2));
        newNames = cell(1, size(newColumns, 2));
        column = 0;
        for b = 1:size(factorColumns, 2)
            for a = 1:size(termColumns, 2)
                column = column + 1;
                newColumns(:, column) = termColumns(:, a) .* factorColumns(:, b);
                if isempty(termNames{a})
                    newNames{column} = factorNames{b};
                else
                    newNames{column} = [termNames{a} ':' factorNames{b}];
                end
            end
        end
        termColumns = newColumns;
        termNames = newNames;
    end
    X = [X, termColumns]; %#ok<AGROW>
    coefficientNames = [coefficientNames, termNames]; %#ok<AGROW>
end
X(isMissing, :) = NaN;
variableInfo = rmfield(variableInfo, {'index', 'values'});
design = struct('X', X, 'y', y, 'isMissing', isMissing, 'coefficientNames', {coefficientNames}, ...
    'variableInfo', variableInfo);
end
