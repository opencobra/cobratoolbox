function [gdlsSolution, bilevelMILPProblem, gdlsSolutionStructs] = GDLS(model, targetRxns, varargin)
% GDLS (Genetic Design through Local Search) attempts to find genetic
% designs with greater in silico production of desired metabolites.
%
% USAGE:
%
%    [gdlsSolution, bilevelMILPProblem, gdlsSolutionStructs] = GDLS(model, varargin)
%
% INPUTS:
%    model:             Cobra model structure
%    targetRxn:         Reaction(s) to be maximized (Cell array of strings)
%
% OPTIONAL INPUTS:
%    varargin:          parameters entered using either a structure or list of
%                       parameter, parameter value. List of optional parameters:
%
%                         *  `nbhdsz` - Neighborhood size (default: 1)
%                         *  `M` - Number of search paths (default: 1)
%                         *  `maxKO` - Maximum number of knockouts (default: 50)
%                         *  `koCost` - Cost for knocking out a reaction, gene set, or gene. A different cost can be set for each knockout (default: 1 for each knockout)
%                         *  `selectedRxns` - List of reactions/geneSets that can be knocked out
%                         *  `koType` - What to knockout: reactions, gene sets, or genes {('rxns'), 'geneSets', 'genes'}
%                         *  `iterationLimit` - Maximum number of iterations (default: 70)
%                         *  `timeLimit` - Maximum run time in seconds (default: 252000)
%                         *  `minGrowth` - Minimum growth rate
%
% OUTPUTS:
%    gdlsSolution:          GDLS solution structure (similar to `OptKnock` `sol` struct)
%    bilevelMILPProblem:    Problem structure used in computation
%    gdlsSolutionStructs:
%
% .. Author: - Richard Que 1/28/2010 Adapted from Desmond S Lun's gdls scripts.

MAXFLUX = 1000;
MAXDUAL = 1000;
EPS = 1e-4;
gdlsSolutionStructs = [];

if nargin < 2
    error('Model and target reaction(s) must be specified')
elseif mod((nargin-2),2)==0 %manual entry
    options.targetRxns = targetRxns;
    for i=1:2:(nargin-2)
        if ismember(varargin{i},{'nbhdsz','M','maxKO','selectedRxns','koType','koCost','minGrowth', ...
                                 'timeLimit','iterationLimit'})
            options.(varargin{i}) = varargin{i+1};
        else
            display(['Unknown option ' varargin{i}]);
        end
    end
elseif isstruct(targetRxns) %options structure
    options = varargin{1};
else
    error('Invalid number of entries')
end

%Default Values
if ~isfield(options,'koType'), options.koType = 'rxns'; end
if ~isfield(options,'nbhdsz'), options.nbhdsz=1; end
if ~isfield(options,'M'), options.M=1; end
if ~isfield(options,'maxKO'), options.maxKO=50; end
if ~isfield(options,'iterationLimit'), options.iterationLimit=70; end
if ~isfield(options,'timeLimit'), options.timeLimit=252000 ; end
if isfield(options,'targetRxns')
    selTargetRxns = logical(ismember(model.rxns,options.targetRxns));
    if ~any(selTargetRxns)
        error([options.targetRxns ' not found. Double check spelling.']);
    end
else
    error('No target reaction specified')
end
if isfield(options,'selectedRxns')
    selSelectedRxns = logical(ismember(model.rxns,options.selectedRxns));
else
    selSelectedRxns = true(length(model.rxns),1);
end


switch lower(options.koType)
    case 'rxns'
        %% Generate selection reaction matrix
        model.selRxnMatrix = selMatrix(selSelectedRxns)';
        possibleKOList = model.rxns(selSelectedRxns);

    case 'genesets'
        %% Generate reaction gene set mapping matrix
        %remove biomass reaction from grRules and generate unique gene set list
        possibleKOList = unique(model.grRules(selSelectedRxns));
        if isempty(possibleKOList{1}), possibleKOList = possibleKOList(2:end); end
        for i = 1:length(possibleKOList)
            model.selRxnMatrix(:,i) =  double(strcmp(possibleKOList{i},model.grRules));
        end

    case 'genes'
        %% Use rxnGeneMat as selRxnMatrix
        model.selRxnMatrix = model.rxnGeneMat;
        possibleKOList = model.genes;
    otherwise
        error('Unrecognized KO type')
end

%% Generate koCost if not present
if ~isfield(options,'koCost')
    if isfield(model,'koCost')
        if length(model.koCost) == 1
            options.koCost = ones(length(possibleKOList,1)) * model.koCost;
        else
            options.koCost = model.koCost;
        end
    else
        options.koCost = ones(length(possibleKOList),1);
    end
elseif length(model.koCost) == 1
    options.koCost = ones(length(possibleKOList,1)) * model.koCost;
else
    options.koCost = model.koCost;
end

%index exchange reactions
[selExc] = findExcRxns(model,true,true);

%% Setup model
model.ub(isinf(model.ub)) = MAXFLUX;
model.ub(model.ub>MAXFLUX) = MAXFLUX;
model.lb(isinf(model.lb)) = -MAXFLUX;
model.lb(model.lb<-MAXFLUX) = -MAXFLUX;
model.rxnsPresent = ones(length(model.rxns),1);

%% Create Baseline
solution0 = fluxBalance(model,selTargetRxns);

%% Create bi-level MILP problem

[nMets nRxns] = size(model.S);
nInt = size(model.selRxnMatrix,2);

jMu = find(~isinf(model.lb));
nMu = length(jMu);
jNu = find(~isinf(model.ub));
nNu = length(jNu);

y0 = (model.selRxnMatrix' * ~model.rxnsPresent) ~= 0;
y0 = repmat(y0,1,options.M);
y0p = y0;
iiter = 1;
change = true;
t1 = clock;
while change
    change = false;

    y = false(nInt, 0);
    fmax = zeros(1, 0);
    for istart = 1:size(y0, 2)
        for irun = 1:options.M

            c = [selTargetRxns;
                zeros(nMets, 1);
                zeros(nMu, 1);
                zeros(nNu, 1);
                zeros(nRxns, 1);
                zeros(nInt, 1)];
            %x= [ v                             lambda                      mu                                              nu                                              xi                              y                                           ]
            A = [ model.S                       sparse(nMets, nMets)        sparse(nMets, nMu)                              sparse(nMets, nNu)                              sparse(nMets, nRxns)            sparse(nMets, nInt);
                sparse(nRxns, nRxns)            model.S'                    -sparse(jMu, 1:nMu, ones(nMu, 1), nRxns, nMu)   sparse(jNu, 1:nNu, ones(nNu, 1), nRxns, nNu)    speye(nRxns)                    sparse(nRxns, nInt);
                speye(nRxns)                    sparse(nRxns, nMets)        sparse(nRxns, nMu)                              sparse(nRxns, nNu)                              sparse(nRxns, nRxns)            model.selRxnMatrix .* repmat(model.lb, 1, nInt);
                speye(nRxns)                    sparse(nRxns, nMets)        sparse(nRxns, nMu)                              sparse(nRxns, nNu)                              sparse(nRxns, nRxns)            model.selRxnMatrix .* repmat(model.ub, 1, nInt);
                sparse(nRxns, nRxns)            sparse(nRxns, nMets)        sparse(nRxns, nMu)                              sparse(nRxns, nNu)                              speye(nRxns)                    model.selRxnMatrix * MAXDUAL;
                sparse(nRxns, nRxns)            sparse(nRxns, nMets)        sparse(nRxns, nMu)                              sparse(nRxns, nNu)                              speye(nRxns)                    -model.selRxnMatrix * MAXDUAL;
                model.c'                        sparse(1, nMets)            model.lb(jMu)'                                  -model.ub(jNu)'                                 sparse(1, nRxns)                sparse(1, nInt);
                sparse(1, nRxns)                sparse(1, nMets)            sparse(1, nMu)                                  sparse(1, nNu)                                  sparse(1, nRxns)                ((y0(:, istart) == 0) - (y0(:, istart) == 1))';
                sparse(size(y, 2), nRxns)       sparse(size(y, 2), nMets)   sparse(size(y, 2), nMu)                         sparse(size(y, 2), nNu)                         sparse(size(y, 2), nRxns)       ((y == 0) - (y == 1))';
                sparse(1, nRxns)                sparse(1, nMets)            sparse(1, nMu)                                  sparse(1, nNu)                                  sparse(1, nRxns)                options.koCost'; ];
            b = [ zeros(nMets, 1);
                model.c;
                model.lb;
                model.ub;
                zeros(nRxns, 1);
                zeros(nRxns, 1);
                0;
                options.nbhdsz - nnz(y0(:, istart));
                ones(size(y, 2), 1) - sum((y ~= 0), 1)';
                options.maxKO; ];
       csense = char(['E' * ones(nMets, 1);
                'E' * ones(nRxns, 1);
                'G' * ones(nRxns, 1);
                'L' * ones(nRxns, 1);
                'G' * ones(nRxns, 1);
                'L' * ones(nRxns, 1);
                'E';
                'L';
                'G' * ones(size(y, 2), 1);
                'L'; ]);
           lb = [ model.lb;
                -Inf * ones(nMets, 1);
                zeros(nMu, 1);
                zeros(nNu, 1);
                -Inf * ones(nRxns, 1);
                zeros(nInt, 1) ];
           ub = [ model.ub;
                Inf * ones(nMets, 1);
                Inf * ones(nMu, 1);
                Inf * ones(nNu, 1);
                Inf * ones(nRxns, 1);
                ones(nInt, 1) ];
      vartype = char(['C' * ones(nRxns, 1);
                'C' * ones(nMets, 1);
                'C' * ones(nMu, 1);
                'C' * ones(nNu, 1);
                'C' * ones(nRxns, 1);
                'B' * ones(nInt, 1); ]);
       osense = -1; %maximize

            if isfield(options,'minGrowth')
                A = [A; model.c' sparse(1, nMets + nMu + nNu + nRxns + nInt)];
                b = [b; options.minGrowth];
                csense = [csense; 'G'];
            end

            [bilevelMILPProblem.c, bilevelMILPProblem.A,...
                bilevelMILPProblem.b, bilevelMILPProblem.lb,...
                bilevelMILPProblem.ub, bilevelMILPProblem.csense,...
                bilevelMILPProblem.vartype, bilevelMILPProblem.osense,...
                bilevelMILPProblem.x0] = ...
                deal(c, A, b, lb, ub, csense, vartype, osense, []);

            %solve
            solution1 = solveCobraMILP(bilevelMILPProblem);

            %check solver status
            if solution1.stat~=1
                continue; %non optimal solution
            end
            yt = solution1.full((end - nInt + 1):end) > EPS;

            model.rxnsPresent = ~(model.selRxnMatrix * yt);
            solution2 = fluxBalance(model,selTargetRxns,false);
            if abs(solution2.obj - solution1.obj) > EPS
                continue; %inconsistent
            end

            fmax(:, end + 1) = solution1.obj;
            y(:, end + 1) = yt;
        end
    end

    if size(y, 2) == 0
        continue;
    end

    [fmaxsort, ifmaxsort] = sort(fmax);
    y = y(:, ifmaxsort);
    y = y(:, max([1 size(y, 2) - options.M + 1]):end);
    y = shrinkKnockouts(y, model, selTargetRxns);
    if size(y, 2) ~= size(y0, 2) || any(any(y~=y0))&&any(any(y~=y0p))
        y0p=y0;
        y0 = y;
        change = true;
    end

    fprintf('Iteration %d\n', iiter);
    fprintf('----------%s\n', char('-' * ones(1, floor(log10(iiter)) + 1)));
    for iend = 1:size(y0, 2)
        model.rxnsPresent = ~(model.selRxnMatrix * y0(:, iend));
        [solSynMax solSynMin solBiomass] = fluxBalance(model,selTargetRxns);
        fprintf('Knockout cost:   %d\n', options.koCost' * y0(:, iend));
        if nnz(y0) > 0
            fprintf('Knockouts:\n%s', sprintf('\t%s\n', possibleKOList{y0(:, iend)}));
        end
        printLabeledData(model.rxns(selExc),solSynMax.full(selExc),true);
        fprintf('\n');

        %Save Solutions
        gdlsSolutionStructs.(sprintf('Iteration_%d',iiter)).(sprintf('solution_%2',i)).solBiomass = solBiomass;
        gdlsSolutionStructs.(sprintf('Iteration_%d',iiter)).(sprintf('solution_%2',i)).solSynMin = solSynMin;
        gdlsSolutionStructs.(sprintf('Iteration_%d',iiter)).(sprintf('solution_%2',i)).solSynMax = solSynMax;
    end
    elapsed_time = etime(clock,t1)
    iiter = iiter + 1;
    if (elapsed_time >= options.timeLimit) || (iiter >= options.iterationLimit)
        break;
    end
end

%Generate Solution Structure
fprintf('\nGenerating Output\n');
gdlsSolution.int = y0;
gdlsSolutions.KOs = cell(max(sum(y0,2)),size(y0,2));
for i = 1:size(y0,2)
gdlsSolution.KOs(1:nnz(y0(:,i)),i) = possibleKOList(y0(:,i));
[solSynMax solSynMin solBiomass] = fluxBalance(model,selTargetRxns,false);
gdlsSolution.biomass(1,i) = solBiomass.obj;
gdlsSolution.minTargetProd(1,i) = solSynMin.obj;
gdlsSolution.maxTargetProd(1,i) = solSynMax.obj;
end

end
function y = shrinkKnockouts(y, model, selTargetRxns)

for iycol = 1:size(y, 2)
    model.rxnsPresent = ~(model.selRxnMatrix * y(:, iycol));
    solution1 = fluxBalance(model, selTargetRxns, false);
    for i = find(y(:, iycol))'
        yt = y(:, iycol);
        yt(i) = 0;

        model.rxnsPresent = ~(model.selRxnMatrix * yt);
        solution2 = fluxBalance(model, selTargetRxns, false);

        if solution2.obj >= solution1.obj
            y(:, iycol) = yt;

            y(:, iycol) = shrinkKnockouts(y(:, iycol), model, selTargetRxns);
        end
    end
end

y = unique(y', 'rows')';
end

function [solSynMax solSynMin solBiomass]  = fluxBalance(model,selTargetRxns,verbFlag)
if nargin < 3
    verbFlag = true;
end
model.x0 = [];
modelb = model;
model_syn = model;

[nMets nRxns] = size(model.S);

yt = model.rxnsPresent;

modelb.A = [ model.S;
      sparse(1:nnz(~yt), find(~yt), ones(nnz(~yt), 1), nnz(~yt), nRxns) ];
modelb.b = [ zeros(nMets, 1);
      zeros(nnz(~yt), 1) ];
modelb.csense = char('E' * ones(1, nMets + nnz(~yt)));
modelb.vartype = char('C' * ones(1, nRxns));
modelb.osense = -1;
solBiomass = solveCobraMILP(modelb);


model_syn.A = [ model.S;
      sparse(1:nnz(~yt), find(~yt), ones(nnz(~yt), 1), nnz(~yt), nRxns);
      model.c' ];
model_syn.b = [ zeros(nMets, 1);
      zeros(nnz(~yt), 1);
      solBiomass.obj ];
model_syn.c = selTargetRxns;
model_syn.csense = char('E' * ones(1, nMets + nnz(~yt) + 1));
model_syn.vartype = char('C' * ones(1, nRxns));
model_syn.osense = -1;
solSynMax = solveCobraMILP(model_syn);
model_syn.osense = 1;
solSynMin = solveCobraMILP(model_syn);

if verbFlag
fprintf('Biomass flux:    %f\n', solBiomass.obj);
fprintf('Synthetic flux:  [%f, %f]\n', solSynMin.obj, solSynMax.obj);
end
end
