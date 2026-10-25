function [metIDs, valuesMmol, duplicates] = convertNutrientsToMmol(values, units, vmhIDs, molecularWeights)
% Convert nutrient values of food items (g/mg/ug per 100 g of food) to mmol
% per 100 g of food for each VMH metabolite. If multiple nutrients of the
% food database map onto the same VMH metabolite, the highest value of
% those nutrients is used for each food item.
%
% USAGE:
%
%    [metIDs, valuesMmol, duplicates] = convertNutrientsToMmol(values, units, vmhIDs, molecularWeights)
%
% INPUTS:
%    values:             Numeric n x m matrix with the values of n nutrients
%                        for m food items (per 100 g of food item)
%    units:              Cell array (n x 1) with the unit of each nutrient:
%                        'g', 'mg' or 'ug' (case insensitive, the micro sign
%                        is also accepted)
%    vmhIDs:             Cell array (n x 1) with the VMH metabolite ID of each
%                        nutrient
%    molecularWeights:   Numeric vector (n x 1) with the molecular weight of
%                        each nutrient in g/mmol. Only one non-NaN weight is
%                        needed per VMH metabolite
%
% OUTPUTS:
%    metIDs:             Cell array (k x 1) with the unique VMH metabolite IDs
%    valuesMmol:         Numeric k x m matrix with the mmol per 100 g of food
%                        item for each VMH metabolite
%    duplicates:         Cell array listing the VMH metabolites that are
%                        mapped by more than one nutrient (column 1) and the
%                        number of nutrients combined (column 2)
%
% .. Author: - Bram Nap, 10-2026

units = cellstr(units);
vmhIDs = cellstr(vmhIDs);
molecularWeights = molecularWeights(:);

% Conversion factors to grams
unitFactor = nan(numel(units), 1);
unitFactor(strcmpi(units, 'g')) = 1;
unitFactor(strcmpi(units, 'mg')) = 1e-3;
% Microgram written as ug, with the micro sign (char 181) or the Greek mu
% (char 956)
unitFactor(strcmpi(units, 'ug') | strcmp(units, [char(181) 'g']) | strcmp(units, [char(956) 'g'])) = 1e-6;
if any(isnan(unitFactor))
    error('Unknown units found: %s. Only g, mg and ug are supported.', strjoin(unique(units(isnan(unitFactor))), ', '))
end

% Convert all measured values to grams
valuesGrams = values .* unitFactor;

% Combine nutrients that map on the same VMH metabolite
[metIDs, ~, grp] = unique(vmhIDs, 'stable');
valuesMmol = nan(numel(metIDs), size(values, 2));
duplicates = cell(0, 2);
missingWeight = {};
for i = 1:numel(metIDs)
    rows = grp == i;

    % Molecular weight of the metabolite
    mw = molecularWeights(rows);
    mw = mw(~isnan(mw));
    if isempty(mw)
        missingWeight{end+1, 1} = metIDs{i}; %#ok<AGROW>
        continue
    elseif any(abs(mw - mw(1)) > 0.01 * mw(1))
        warning('Different molecular weights are given for %s. Using %g g/mmol.', metIDs{i}, mw(1))
    end

    if sum(rows) > 1
        % Multiple nutrients map to this metabolite, take for each food
        % item the highest measured value. If no nutrient is measured for a
        % food item the value stays NaN.
        duplicates(end+1, :) = {metIDs{i}, sum(rows)}; %#ok<AGROW>
    end
    valuesMmol(i, :) = max(valuesGrams(rows, :), [], 1, 'omitnan') / mw(1);
end

if ~isempty(missingWeight)
    error('No molecular weight is available for the following VMH metabolites: %s. Please add them to the info file.', strjoin(missingWeight, ', '))
end
end
