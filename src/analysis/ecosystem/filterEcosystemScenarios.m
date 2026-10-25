function scenarios = filterEcosystemScenarios(simulations, params)
% Selects simulated scenarios from a table of simulations (e.g. the file
% `simulations_pareto4.csv` of the bioleaching case study) according to
% the values of their parameters. Scenarios must satisfy all the non-empty
% filters; scenarios containing any of the flagged substrings are discarded.
% Scenarios are sorted by input Fe and name.
%
% USAGE:
%
%    scenarios = filterEcosystemScenarios(simulations, params)
%
% INPUTS:
%    simulations:   (table) table of simulations with the variables (text):
%                   'Alpha', 'Substrate combination', 'input constraint',
%                   'Input Fe', 'Energy level', 'Filename' and 'Objective'
%    params:        (structure) filters, with the optional fields:
%
%                     * .alpha - (double) values of alpha, e.g. [0.2 0.4 0.6]
%                     * .obj - (cell) objectives; if empty, scenarios with an
%                       objective are discarded
%                     * .cons - (cell) input constraints, e.g. {'biocons'}
%                     * .energy - (cell) energy levels, e.g. {'Medium'}
%                     * .subCombs - (double) n x 2 matrix with Fe and S
%                       fractions, e.g. [0.5 0.5]
%                     * .flag - (cell) substrings of scenarios to discard
%
% OUTPUT:
%    scenarios:     (cell array) names of the selected scenarios
%
% EXAMPLE:
%
%    simulations = readtable('simulations_pareto4.csv', 'Delimiter', ';', ...
%                            'TextType', 'char', 'VariableNamingRule', 'preserve');
%    params = struct('alpha', [0.2 0.4 0.6], 'obj', {{}}, 'cons', {{'biocons'}}, ...
%                    'energy', {{'Medium'}}, 'subCombs', [0.5 0.5], 'flag', {{}});
%    scenarios = filterEcosystemScenarios(simulations, params);
%
% NOTE:
%
%    Equivalent to the function `filter_cases` defined in the notebook
%    `sup_mat_multiple_bioleaching.ipynb`, including its conventions: a filter
%    that does not match any scenario is ignored, and alpha values are
%    compared as text with a decimal comma (e.g. '0,2').
%
% .. Author: - Sebastián N. Mendoza, 13/10/2026, MATLAB implementation based on the Python code of N.E. Jiménez et al.

if nargin < 2
    error('simulations and params must be provided.');
end
if ~istable(simulations)
    error('simulations must be a table.');
end
required = {'Alpha', 'Substrate combination', 'input constraint', 'Input Fe', 'Energy level', 'Filename', 'Objective'};
missing = setdiff(required, simulations.Properties.VariableNames);
if ~isempty(missing)
    error('simulations does not have the variables: %s', strjoin(missing, ', '));
end
if ~isstruct(params)
    error('params must be a structure.');
end
defaults = struct('alpha', [], 'obj', {{}}, 'cons', {{}}, 'energy', {{}}, 'subCombs', zeros(0, 2), 'flag', {{}});
fields = fieldnames(defaults);
for i = 1:numel(fields)
    if ~isfield(params, fields{i})
        params.(fields{i}) = defaults.(fields{i});
    end
end

% text columns
asText = @(x) cellfun(@(v) strtrim(num2str(v)), num2cell(x), 'UniformOutput', false);
cols = struct();
for i = 1:numel(required)
    values = simulations.(required{i});
    if ~iscell(values)
        values = asText(values);
    end
    values(cellfun(@(v) isempty(v) || (isnumeric(v) && any(isnan(v))), values)) = {''};
    values(strcmpi(values, 'NaN')) = {''};
    cols.(matlab.lang.makeValidName(required{i})) = values;
end
filenames = cols.Filename;

flag = cellstr(params.flag);
flag = flag(:)';
obj = cellstr(params.obj);
if isempty(obj) || (numel(obj) == 1 && isempty(obj{1}))
    obj = {};
    availableObj = unique(cols.Objective(~cellfun(@isempty, cols.Objective)));
    flag = [flag, strcat('_', availableObj(:)')];
end

energyLevels = {'high', 'medium', 'low'};
subcomLevels = [1 0; 0.9 0.1; 0.75 0.25; 0.6 0.4; 0.5 0.5; 0.4 0.6; 0.25 0.75; 0.1 0.9; 0 1];
energy = cellstr(params.energy);
energy = energy(~cellfun(@isempty, energy));
if isempty(energy)
    energyLoop = energyLevels;
else
    energyLoop = lower(energy);
end
subCombs = params.subCombs;
if isempty(subCombs)
    subCombs = subcomLevels;
end
subComb = {};
for e = 1:numel(energyLoop)
    for s = 1:size(subCombs, 1)
        subComb{end + 1} = [num2str(subCombs(s, 1)) '_Fe_' energyLoop{e} '_' num2str(subCombs(s, 2)) '_S_' energyLoop{e}]; %#ok<AGROW>
    end
end

filterSets = {};
if ~isempty(params.alpha)
    alphaText = arrayfun(@(a) strrep(num2str(a), '.', ','), params.alpha, 'UniformOutput', false);
    filterSets{end + 1} = unique(filenames(ismember(cols.Alpha, alphaText)));
end
cons = cellstr(params.cons);
cons = cons(~cellfun(@isempty, cons));
if ~isempty(cons)
    filterSets{end + 1} = unique(filenames(ismember(cols.inputConstraint, cons)));
end
if ~isempty(energy)
    filterSets{end + 1} = unique(filenames(ismember(cols.EnergyLevel, energy)));
end
if ~isempty(subComb)
    filterSets{end + 1} = unique(filenames(ismember(cols.SubstrateCombination, subComb)));
end
if ~isempty(obj)
    filterSets{end + 1} = unique(filenames(ismember(cols.Objective, obj)));
end
filterSets = filterSets(~cellfun(@isempty, filterSets));
if isempty(filterSets)
    scenarios = {};
    return
end
scenarios = filterSets{1};
for i = 2:numel(filterSets)
    scenarios = intersect(scenarios, filterSets{i});
end
for f = 1:numel(flag)
    scenarios = scenarios(~contains(scenarios, flag{f}));
end
% input Fe of each scenario (looked up with the names of the table)
inputFe = zeros(numel(scenarios), 1);
for i = 1:numel(scenarios)
    row = find(strcmp(filenames, scenarios{i}), 1);
    inputFe(i) = str2double(strrep(cols.InputFe{row}, ',', '.'));
end
% names of the result files
scenarios = strrep(scenarios, '_a0_', '_a00_');
scenarios = strrep(scenarios, '_a0.', '_a0');
scenarios = strrep(scenarios, '_a0,', '_a0');
scenarios = strrep(scenarios, '_a1_', '_a10_');

% sort by input Fe and name
[~, order] = sortrows(table(inputFe, scenarios(:)));
scenarios = scenarios(order);
scenarios = scenarios(:);
end
