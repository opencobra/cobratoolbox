function EMV = findElementaryMoietyVectors(model, varargin)
% Enumerate all possible elementary conserved moiety vectors based on the
% left null space of the stoichiometric matrix S.
%
% USAGE:
%    EMV = findElementaryMoietyVectors(model, method)
%
% INPUT:
%    model:                  COBRA model
%
% OPTIONAL INPUTS (in name-value pair):
%    'method':           method for finding all conserved moiety vectors
%                          * 'efmtool':  use EFMtool, 'CalculateFluxModes.m' must be in matlab path (default)
%                          * 'null':     use matlab rational null basis. 
%    'deadCMs':           include dead end metabolites or not (default true)
%                        (will have more conserved moieties found for dead end metabolites if true)
%    'printLevel':       print messages or not (default 0).
%
%    Other COBRA LP solver parameters, see solveCobraLP.m
%
% OUTPUT:
%    EMV:                all minimal conserved moiety vectors

if mod(numel(varargin), 2) ~= 0
    error('Incorrect number of name-value pair arguments')
end
k = 1;
while k <= numel(varargin) - 1
    if ischar(varargin{k}) && strcmp(varargin{k}, 'method') && k < numel(varargin)
        method = varargin{k + 1};
        varargin = varargin([1:(k - 1), (k + 2):numel(varargin)]);
    elseif ischar(varargin{k}) && strcmp(varargin{k}, 'deadCMs') && k < numel(varargin)
        deadCM = logical(varargin{k + 1});
        varargin = varargin([1:(k - 1), (k + 2):numel(varargin)]);
    else
        if ischar(varargin{k}) && strcmp(varargin{k}, 'printLevel')
            printLevel = varargin{k + 1};
        end
        k = k + 1;
    end
end
if ~exist('method', 'var')
    method = 'efmtool';
end
if ~exist('deadCM', 'var')
    deadCM = true;
end
if ~exist('printLevel', 'var')
    printLevel = 0;
end

metActive = true(numel(model.mets), 1);
if ~deadCM
    [~,removedMets] = removeDeadEnds(model);
    metActive(findMetIDs(model,removedMets)) = false;
end

% first solve an LP to find all metabolites that contain conserved moieties
bigM = 1000;
minMass = 1;
[nM, nR] = size(model.S);
LP.A = [model.S',           sparse(nR, nM); ...   S' * m        = 0
        -speye(nM),  -bigM * speye(nM)];  %           -m - M z <= -minMass (% z = 0 ==> m can be positive)
LP.b = [zeros(nR, 1); -minMass * ones(nM, 1)];
LP.c = [zeros(nM, 1); ones(nM, 1)];  %           min (sum(z))
LP.lb = zeros(nM * 2, 1);
LP.ub = [bigM * metActive; ones(nM, 1)];
LP.osense = 1;
LP.csense = char(['E' * ones(1, nR), 'L' * ones(1, nM)]);
sol = solveCobraLP(LP, varargin{:});
metCM = sol.full(1:nM) >= 1 - 1e-6;

if ~any(metCM)
    % no conserved moiety at all
    EMV = sparse(nM, 0);
    return
end
% the reduced stoichiometric matrix containing all rxns and mets involving conserved moieties
S = full(model.S(metCM, any(model.S(metCM, :), 1)));

% find extreme rays using EFMtool
if strcmpi(method, 'efmtool')
    pathEFM = which('CalculateFluxModes.m');
    if isempty(pathEFM)
        if printLevel
            warning('EFMtool not in Matlab path. Use Matlab rational basis.');
        end
        method = 'null';
    else
        dirEFM = strsplit(pathEFM,filesep);
        dirEFM = strjoin(dirEFM(1:end-1),filesep);
        dirCur = pwd;
        cd(dirEFM);
        % may fail due to lack of memory if there are a huge number of dead end
        % metabolites, set deadCM = false to exclude them
        if ~printLevel
            opts = CreateFluxModeOpts('level', 'WARNING');
        else
            opts = CreateFluxModeOpts('level', 'INFO');
        end
        N = CalculateFluxModes(S',zeros(size(S, 1), 1), opts);
        N = N.efms;
        cd(dirCur);
    end
end

% find rational null space basis. May not include all extreme rays as using EFMtool
if strcmpi(method, 'null')
    N = null(S', 'r');  % should usually be fast for most networks since the number of metabolites having conserved moieties should be low
    N(abs(N) < 1e-10) = 0;
    N = N(:, all(N >= 0, 1));
end

% Elementary moiety vectors
EMV = sparse(nM, size(N, 2));
EMV(metCM, :) = N;