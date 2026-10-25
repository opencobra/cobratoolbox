function eco = loadEcosystemScenario(resultDir, scenarioName, varargin)
% Loads the results of an ecosystem scenario computed and stored in batches
% by the Python implementation of the abundance-growth framework
% (https://github.com/mathomics/ecosystem, folder `result_files`). The
% following files are read (`<name>` is the scenario name):
%
%    * `<name>.p` - pickle with the grid points, member prefixes, member
%      objectives, member reactions and reactions analyzed (`rxn2cluster`)
%    * `<name>.json` - community model in cobrapy JSON format (optional)
%    * `<name>_fpoints_<first>_<last>.npy` - feasibility of the grid points
%    * `<name>_qFVA_feasibleOnly_<first>_<last>.npy` - qualitative FVA vectors
%    * `<name>_full_FVA_feasibleOnly_<first>_<last>.npy` - FVA results (optional)
%
% USAGE:
%
%    eco = loadEcosystemScenario(resultDir, scenarioName, varargin)
%
% INPUTS:
%    resultDir:              (string) folder containing the result files
%    scenarioName:           (string) scenario name, e.g.
%                            'biomin_newgrid_sce_a02_biocons_75Fe_5S'
%
% OPTIONAL INPUTS:
%    batchSize:              (double) number of grid points per batch file
%                            (Default = 250)
%    loadModel:              (logical) read the community model from the
%                            JSON file (Default = true)
%    recomputeFeasibility:   (logical) if the feasibility batch files are
%                            missing, recompute the feasibility of the grid
%                            points with the community model (requires
%                            `loadModel` = true) (Default = true)
%    printLevel:             (double) verbosity level (Default = 1)
%
% OUTPUT:
%    eco:                    (structure) ecosystem structure (see
%                            `createEcosystemModel`) with fields `.model`
%                            (if loaded), `.name`, `.prefixes`, `.objectives`,
%                            `.memberRxns`, `.rxn2cluster`, `.points`,
%                            `.pfractions`, `.maxCommunityGrowth`,
%                            `.feasiblePoints`, `.qualVectors`,
%                            `.qualPointIndex`, `.fvaResults` (empty if not
%                            available) and `.feasibilitySource`
%                            ('pickle', 'files' or 'recomputed')
%
% EXAMPLE:
%
%    eco = loadEcosystemScenario('ecosystem/result_files', 'biomin_newgrid_sce_a04_biocons_75Fe_5S');
%
% NOTE:
%
%    When the feasibility is recomputed, the number of feasible points of
%    each batch is compared with the number of rows of the corresponding
%    qualitative FVA file, which validates the recomputation.
%    Equivalent to the constructor of `Ecosystem` in `multiple_ecosystem.py`
%    and the functions `get_feasible_points_from_batch_files`,
%    `get_qual_fva_from_batch_files` and `get_fva_from_batch_files` of
%    `eco_utils.py`.
%
% .. Author: - Sebastián N. Mendoza, 13/10/2026, MATLAB implementation based on the Python code of N.E. Jiménez et al.

parser = inputParser();
parser.addRequired('resultDir', @(x) ischar(x) || isstring(x));
parser.addRequired('scenarioName', @(x) ischar(x) || isstring(x));
parser.addParameter('batchSize', 250, @(x) isnumeric(x) && isscalar(x) && x >= 1);
parser.addParameter('loadModel', true, @(x) islogical(x) || isnumeric(x));
parser.addParameter('recomputeFeasibility', true, @(x) islogical(x) || isnumeric(x));
parser.addParameter('printLevel', 1, @(x) isnumeric(x) || islogical(x));
parser.parse(resultDir, scenarioName, varargin{:});
resultDir = char(parser.Results.resultDir);
scenarioName = char(parser.Results.scenarioName);
batchSize = parser.Results.batchSize;
loadModel = parser.Results.loadModel;
recomputeFeasibility = parser.Results.recomputeFeasibility;
printLevel = parser.Results.printLevel;

pickleFile = fullfile(resultDir, [scenarioName '.p']);
if ~exist(pickleFile, 'file')
    error('File %s not found.', pickleFile);
end
if printLevel > 0
    fprintf('%s\n', scenarioName);
end
data = readPythonPickle(pickleFile);

eco = struct();
eco.name = scenarioName;
eco.id = scenarioName;
eco.prefixes = data('prefixes');
eco.prefixes = eco.prefixes(:);
eco.size = numel(eco.prefixes);
objectives = data('objectives');
eco.objectives = cell(eco.size, 1);
for k = 1:eco.size
    objKeys = keys(objectives{k});
    eco.objectives{k} = objKeys{1};
end
memberRxns = data('member_rxns');
eco.memberRxns = cell(eco.size, 1);
for k = 1:eco.size
    eco.memberRxns{k} = memberRxns(eco.prefixes{k});
end
eco.rxn2cluster = data('rxn2cluster');
eco.rxn2cluster = eco.rxn2cluster(:);
eco.points = double(data('points'));
eco.pfractions = [eco.points(:, 1), 1 - eco.points(:, 1)];
eco.maxCommunityGrowth = max(eco.points(:, 2));
eco.limits = [min(eco.points, [], 1); max(eco.points, [], 1)];
eco.model = [];
eco.feasiblePoints = [];
eco.qualVectors = [];
eco.qualPointIndex = [];
eco.fvaResults = [];
eco.clusters = [];
eco.k = [];
eco.feasibilitySource = '';

if loadModel
    jsonFile = fullfile(resultDir, [scenarioName '.json']);
    if exist(jsonFile, 'file')
        eco.model = readCobrapyJSONModel(jsonFile);
    elseif printLevel > 0
        fprintf('Community model %s not found.\n', jsonFile);
    end
end

% batches
nPoints = size(eco.points, 1);
batchFirst = 0:batchSize:nPoints - 1;
batchLast = min(batchFirst + batchSize, nPoints);
nBatches = numel(batchFirst);

% feasible points
if ~isempty(data('feasible_points'))
    eco.feasiblePoints = logical(cell2mat(data('feasible_points')));
    eco.feasibilitySource = 'pickle';
else
    files = arrayfun(@(f, l) fullfile(resultDir, sprintf('%s_fpoints_%d_%d.npy', scenarioName, f, l)), ...
        batchFirst, batchLast, 'UniformOutput', false);
    if all(cellfun(@(f) exist(f, 'file') == 2, files))
        feasible = cellfun(@(f) readNumpyArray(f), files, 'UniformOutput', false);
        eco.feasiblePoints = logical(vertcat(feasible{:}));
        eco.feasibilitySource = 'files';
    elseif recomputeFeasibility && ~isempty(eco.model)
        if printLevel > 0
            fprintf('Feasibility files not found. Recomputing the feasibility of %d grid points...\n', nPoints);
        end
        eco = checkEcosystemGridFeasibility(eco, 'updateBounds', true, 'printLevel', printLevel);
        eco.feasibilitySource = 'recomputed';
    else
        error('Feasibility files of scenario %s not found.', scenarioName);
    end
end
if numel(eco.feasiblePoints) ~= nPoints
    error('The number of feasibility values differs from the number of grid points.');
end

% qualitative FVA vectors (feasible points only)
validBatches = arrayfun(@(f, l) any(eco.feasiblePoints(f + 1:l)), batchFirst, batchLast);
qualParts = {};
fvaParts = {};
fvaAvailable = true;
for b = find(validBatches)
    qualFile = fullfile(resultDir, sprintf('%s_qFVA_feasibleOnly_%d_%d.npy', scenarioName, batchFirst(b), batchLast(b)));
    if ~exist(qualFile, 'file')
        error('Qualitative FVA file %s not found.', qualFile);
    end
    qual = double(readNumpyArray(qualFile));
    nFeasibleBatch = sum(eco.feasiblePoints(batchFirst(b) + 1:batchLast(b)));
    if size(qual, 1) ~= nFeasibleBatch
        warning(['Batch %d-%d: %d qualitative vectors but %d feasible points. Feasibility (%s) and ' ...
            'stored results are not consistent.'], batchFirst(b), batchLast(b), size(qual, 1), ...
            nFeasibleBatch, eco.feasibilitySource);
    end
    qualParts{end + 1, 1} = qual; %#ok<AGROW>
    fvaFile = fullfile(resultDir, sprintf('%s_full_FVA_feasibleOnly_%d_%d.npy', scenarioName, batchFirst(b), batchLast(b)));
    if fvaAvailable && exist(fvaFile, 'file')
        fvaParts{end + 1, 1} = double(readNumpyArray(fvaFile)); %#ok<AGROW>
    else
        fvaAvailable = false;
    end
end
eco.qualVectors = vertcat(qualParts{:});
eco.qualPointIndex = find(eco.feasiblePoints);
if size(eco.qualVectors, 1) ~= numel(eco.qualPointIndex)
    error('The number of qualitative vectors (%d) differs from the number of feasible points (%d).', ...
        size(eco.qualVectors, 1), numel(eco.qualPointIndex));
end
if size(eco.qualVectors, 2) ~= numel(eco.rxn2cluster)
    error('The number of columns of the qualitative vectors differs from the number of reactions.');
end
if fvaAvailable && ~isempty(fvaParts)
    eco.fvaResults = cat(1, fvaParts{:});
end
if printLevel > 0
    fprintf('  grid points: %d, feasible: %d (%s), reactions: %d, FVA results: %s\n', nPoints, ...
        sum(eco.feasiblePoints), eco.feasibilitySource, numel(eco.rxn2cluster), mat2str(fvaAvailable && ~isempty(fvaParts)));
end
end
