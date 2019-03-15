function [minFlux, maxFlux, Vmin, Vmax] = fluxVariability(model, optPercentage, osenseStr, rxnNameList, printLevel, allowLoops, method, cpxControl, advind)
% Performs flux variablity analysis
%
% USAGE:
%
%    [minFlux, maxFlux] = fluxVariability(model, optPercentage, osenseStr, rxnNameList, printLevel, allowLoops, method)
%
% INPUT:
%    model:            COBRA model structure
%
% OPTIONAL INPUTS:
%    optPercentage:    Only consider solutions that give you at least a certain
%                      percentage of the optimal solution (Default = 100
%                      or optimal solutions only)
%    osenseStr:        Objective sense ('min' or 'max') (Default = 'max')
%    rxnNameList:      List of reactions for which FVA is performed
%                      (Default = all reactions in the model)
%    printLevel:       Verbose level (default: 0)
%    allowLoops:       Whether loops are allowed in solution. (Default = true)
%                      See `optimizeCbModel` for description
%    method:           when Vmin and Vmax are in the output, the flux vector can be (Default = 2-norm):
%
%                        * 'FBA'    : standards FBA solution
%                        * '0-norm' : minimzes the vector  0-norm
%                        * '1-norm' : minimizes the vector 1-norm
%                        * '2-norm' : minimizes the vector 2-norm
%                        * 'minOrigSol' : minimizes the euclidean distance of each vector to the original solution vector
%
%   cpxControl:        solver-specific parameter structure
%
%   advind:            switch to use the solution basis
%
%                           - 0 : default
%                           - 1 : uses the original problem solution basis as advanced basis
%
% OUTPUTS:
%    minFlux:          Minimum flux for each reaction
%    maxFlux:          Maximum flux for each reaction
%
% OPTIONAL OUTPUT:
%    Vmin:             Matrix of column flux vectors, where each column is a
%                      separate minimization.
%    Vmax:             Matrix of column flux vectors, where each column is a
%                      separate maximization.
%
% .. Authors:
%       - Markus Herrgard  8/21/06 Original code.
%       - Ronan Fleming   01/20/10 Take the extremal flux from the flux vector,
%                         not from the objective since this is invariant
%                         to the value and sign of the coefficient
%       - Ronan Fleming   27/09/10 Vmin, Vmax
%       - Marouen Ben Guebila 22/02/2017 Vmin,Vmax method

global CBT_LP_PARAMS

if nargin < 2 || isempty(optPercentage)
    optPercentage = 100;
end
if nargin < 3 || isempty(osenseStr)
    [osenseStr,~] = getObjectiveSense(model);
end
if nargin < 4 || isempty(rxnNameList)
    rxnNameList = model.rxns;
end
if nargin < 5 || isempty(printLevel)
    printLevel = 0;
end
if nargin < 6 || isempty(allowLoops)
    allowLoops = true;
end
if nargin < 7 || isempty(method)
    method = '2-norm';
end
if nargin < 8 || isempty(cpxControl)
    cpxControl = struct();
end
if nargin < 9 || isempty(advind)
   advind = 0;
end
allowLoopsError = false;
loopMethod = '';
if isscalar(allowLoops) && ~ischar(allowLoops)
    if allowLoops
        loopMethod = 'none';
    else
        % default using LLCs when the method is not specified
        loopMethod = 'LLC-NS';
    end
elseif ischar(allowLoops)
    for str = {'none', 'original', 'fastSNP', 'LLC-NS', 'LLC-EFM'}
        if strncmpi(allowLoops, str{:}, length(allowLoops))
            loopMethod = str{:};
            break
        end
    end
    allowLoops = strcmp(loopMethod, 'none');
    if isempty(loopMethod)
        allowLoopsError = true;
    end
else
    allowLoopsError = true;
end
if allowLoopsError
    error('"allowLoops" must be one of the following: 1 (usual FVA), 0 (default using ''LLC-NS''), ''original'', ''fastSNP'', ''LLC-NS'' or ''LLC-EFM''')
end

% pre-define LLC parameters
[alwaysLLC, loopInfo, conCompAlwaysOn, rxnInLoopsAlwaysOn, useRxnLink] = ...
    deal(false, struct(), false, false, false);
    
%Stop if there are reactions, which are not part of the model
if any(~ismember(rxnNameList,model.rxns))
    presence = ismember(rxnNameList,model.rxns);
    error('There were reactions in the rxnList which are not part of the model:\n%s\n',strjoin(rxnNameList(~presence),'\n'));
end

% Set up the problem size
[nMets,nRxns] = size(model.S);
Vmin=[];
Vmax=[];
if nargout > 2
    OutputMatrix = 1;
else
    OutputMatrix = 0;
end

% LP solution tolerance
if exist('CBT_LP_PARAMS', 'var')
    if isfield(CBT_LP_PARAMS, 'objTol')
        tol = CBT_LP_PARAMS.objTol;
    else
        tol = 1e-6;
    end
    if nargout < 3
        minNorm = 0;
    else
        minNorm = 1;
    end
end

%%%% They are not incompatible. Loopless flux distributions are not
%%%% necessarily minimal with respect to any norms available in the option.
%%%% This is very likely when there are different loopless pathways giving the same
%%%% max/min flux for the target reaction. And 
%%%% The converse is also not necessarily true. An FBA (LP) solution after
%%%% minimizing any norms may still contain loops, as long as there is a
%%%% loop that is essential for the max/min flux for the target reaction.

%Return if minNorm is not FBA but allowloops is set to false
%This is currently not supported as it requires mechanisms that are likely
%incompatible.
if ~allowLoops && minNorm && strcmp(method,'minOrigSol')
    error('minOrigSol is meant for finding a minimally adjusted solution from an FBA solution.\nCannot return solutions allowLoops is set to false.\nIf you want solutions without loops please set method to ''FBA'', ''2-norm'', ''1-norm'' or ''0-norm''.');
end

% Determine constraints for the correct space (0-100% of the full space)
if sum(model.c ~= 0) > 0
    hasObjective = true;
else
    hasObjective = false;
end

if printLevel > 1
    fprintf('%4s\t%4s\t%10s\t%9s\t%9s\n','No','Perc','Name','Min','Max');
end
if ~isfield(model,'b')
    model.b = zeros(size(model.S,1),1);
end
% Set up the general problem
LPproblem = buildLPproblemFromModel(model);

% Solve initial (normal) LP
if allowLoops
    tempSolution = solveCobraLP(LPproblem, cpxControl);
else
    % Both Fast-SNP and solving an MILP return a minimal feasible nullspace
    if printLevel
        switch loopMethod
            case 'original'
            % find the usual internal nullspace (Schellenberger et al., 2009)
            fprintf('Use the original loop law\n');
        case 'fastSNP'
            % find a minimal feasible nullspace Fast-SNP (Saa and Nielson, 2016)
            fprintf('Reduce complexity by nullspace preprocessing (Fast-SNP)\n')
        otherwise
            % find a minimal feasible nullspace by one single MILP (Chan et al., 2017)
            % then implement localized loopless constraints
            fprintf('Reduce complexity by nullspace preprocessing and implementing localized loopless constraints (LLCs)\n')
        end
    end
    [MILPproblem, loopInfo] = addLoopLawConstraints(LPproblem, model, 1:nRxns, [], [], loopMethod);
    if strcmp(loopMethod, 'LLC-EFM')
        if ~isempty(loopInfo.rxnLink)
            if printLevel
                fprintf('Use connections from EFMs to implement LLCs\n');
            end
            useRxnLink = true;
        elseif printLevel
            fprintf('Unable to find EFMs. Use connections from nullspace to implement LLCs\n');
        end
    end
    if strncmp(loopMethod, 'LLC', 3)
        [alwaysLLC, rxnInLoopsAlwaysOn, conCompAlwaysOn, x0] = preprocessLLC(LPproblem, ...
            model, nRxns, loopInfo.rxnInLoops, osenseStr, loopInfo.conComp, printLevel);        
        if alwaysLLC
            % apply LLCs for loopless FBA if the objective function or
            % additional constraints contain reaction fluxes that require
            % loop law for optimality under the loopless condition
            MILPproblem = updateLLCs(MILPproblem, conCompAlwaysOn, rxnInLoopsAlwaysOn, loopInfo, [], useRxnLink);
        end
    end
    tempSolution = solveCobraMILP(MILPproblem);
end

if tempSolution.stat == 1
    if strcmp(osenseStr,'max')
        objValue = floor(tempSolution.obj/tol)*tol*optPercentage/100;
    else
        objValue = ceil(tempSolution.obj/tol)*tol*optPercentage/100;
    end
else
    error('The FVA could not be run because the model is infeasible or unbounded')
end

%set the objective
if hasObjective
    LPproblem.A = [LPproblem.A;columnVector(LPproblem.c)'];
    LPproblem.b = [LPproblem.b;objValue];    
    if strcmp(osenseStr, 'max')
        LPproblem.csense(end+1) = 'G';
    else
        LPproblem.csense(end+1) = 'L';
    end
    model = addCOBRAConstraints(model,model.rxns(find(model.c)),objValue,'dsense',LPproblem.csense(end));
end

%get the initial basis
if advind == 1
    LPproblem.basis = tempSolution.basis;
end
LPproblem.S = LPproblem.A;%needed for sparse optimisation

% Loop through reactions
maxFlux = zeros(length(rxnNameList), 1);
minFlux = zeros(length(rxnNameList), 1);

%Thats not true. The Euclidean norm does not get rid of loops if the
%objective reaction is part of the loop.
% if length(minNorm)> 1 || minNorm > 0
%     %minimizing the Euclidean norm gets rid of the loops, so there
%     %is no need for a second slower MILP approach
%     allowLoops=1;
% end

solutionPool = zeros(length(model.lb), 0);

v=ver;
PCT = 'Parallel Computing Toolbox';
poolsize = 0;
if  any(strcmp(PCT,{v.Name})) && license('test','Distrib_Computing_Toolbox')
    try
        p = gcp('nocreate');
        PCT_status=1;
        if ~isempty(p)
            poolsize = p.NumWorkers;
        end
    catch
        PCT_status = 0;
    end
else
    PCT_status=0;  % Parallel Computing Toolbox not found.
end

minFlux = model.lb(ismember(model.rxns,rxnNameList));
maxFlux = model.ub(ismember(model.rxns,rxnNameList));
preCompMaxSols = cell(nRxns,1);
preCompMinSols = cell(nRxns,1);

%We will calculate a min and max sum flux solution.
%This solution will (hopefully) provide multiple solutions for individual
%reactions.
QuickProblem = LPproblem;
[Presence,Order] = ismember(rxnNameList,model.rxns);
QuickProblem.c(:) = 0;
QuickProblem.c(Order(Presence)) = 1;
if any(strcmp(loopMethod, {'original', 'fastSNP'}))
    % Skip this when using localized loopless constraints (LLCs) for two reasons:
    % 1. With loopless constraints, one does not expect to have many reactions hitting the bounds
    % 2. LLCs invoke a subset of all loopless constraints and the associated binary
    %    variables. Maximize everything at once will require invoking almost all binary variables
    QuickProblem = addLoopLawConstraints(QuickProblem,model,1:nRxns, [], [], loopMethod);
end
%Maximise all reactions
QuickProblem.osense = -1;
switch loopMethod
    case {'original', 'fastSNP'}
        sol = solveCobraMILP(QuickProblem);
    case {'LLC-NS', 'LLC-EFM'}
        % skip this if using LLCs
        sol = struct;
        sol.full = NaN(nRxns, 1);
        sol.stat = 0;
    case 'none'
        sol = solveCobraLP(QuickProblem);
end
%If we reach this point, we can be certain, that there is a solution, i.e.
%if the stat is not 1, we have to check all reactions.
if sol.stat == 1
    relSol = sol.full(Order(Presence));
    %Obtain fluxes at their boundaries
    maxSolved = model.ub(Order(Presence)) == relSol;
    minSolved = model.lb(Order(Presence)) == relSol;
    if minNorm
        preCompMaxSols(maxSolved) = {sol};
        preCompMinSols(minSolved) = {sol};
    end
else
    [maxSolved, minSolved] = deal(false(numel(rxnNameList), 1));
end
%Minimise reactions
QuickProblem.osense = 1;
switch loopMethod
    case {'original', 'fastSNP'}
        sol = solveCobraMILP(QuickProblem);
    case {'LLC-NS', 'LLC-EFM'}
        % skip this if using LLCs
        sol = struct;
        sol.full = NaN(nRxns, 1);
        sol.stat = 0;
    case 'none'
        sol = solveCobraLP(QuickProblem);
end
if sol.stat == 1
    relSol = sol.full(Order(Presence));
    %Again obtain fluxes at their boundaries
    maxSolved = maxSolved | (model.ub(Order(Presence)) == relSol);
    minSolved = minSolved | (model.lb(Order(Presence)) == relSol);
    %This is only necessary, if we want a min norm.
    if minNorm
        preCompMaxSols((model.ub(Order(Presence)) == relSol)) = {sol};
        preCompMinSols((model.lb(Order(Presence)) == relSol)) = {sol};
    end
end
%Restrict the reactions to test only those which are not at their boundariestestFv.
rxnListMin = rxnNameList(~minSolved);
rxnListMax = rxnNameList(~maxSolved);

% generate the loopless problem beforehand instead of during each loop
switch loopMethod
    case 'none'
        MILPproblem = [];
    case {'original', 'fastSNP'}
        MILPproblem = addLoopLawConstraints(LPproblem, model, 1:nRxns, [], [], loopMethod, loopInfo);
    case {'LLC-NS', 'LLC-EFM'}
        [MILPproblem, loopInfo] = addLoopLawConstraints(LPproblem, model, 1:nRxns, [], [], loopMethod, loopInfo);
        rhs0 = MILPproblem.b;
        % no need to regenerate the preprocessing information. They remain unchanged
end

if ~PCT_status || poolsize == 0 % aka nothing is active and do not turn on parpool by default
    if printLevel == 1
        showprogress(0,'Flux variability analysis in progress ...');
    end
    if minNorm
        for i = 1:length(rxnNameList)
        
            switch loopMethod
                case {'none', 'original', 'fastSNP'}
                    LPproblem.osense = 1;
                    [minFlux(i),Vmin(:,i)] = calcSolForEntry(model,rxnNameList,i,LPproblem,0, method, allowLoops,printLevel,minNorm,cpxControl,preCompMinSols{i},MILPproblem);
                    LPproblem.osense = -1;
                    [maxFlux(i),Vmax(:,i)] = calcSolForEntry(model,rxnNameList,i,LPproblem,0, method, allowLoops,printLevel,minNorm,cpxControl,preCompMaxSols{i},MILPproblem);
                otherwise
                    % use LLCs
                    i0 = findRxnIDs(model, rxnNameList(i));
                    if alwaysLLC || any(loopInfo.rxnInLoops(i0, :))
                        % reset the bounds and rhs in the MILP
                        MILPproblem = restoreOriginalBounds(MILPproblem, rhs0, loopInfo);
                        if ~any(loopInfo.rxnInLoops(i0, :))
                            % apply LLCs only to the always-on set of reactions
                            rxnID = [];
                        else
                            % apply LLCs to the always-on set + objective reaction that is in cycles
                            rxnID = i0;
                        end
                        % update bounds and rhs
                        MILPproblem = updateLLCs(MILPproblem, conCompAlwaysOn, rxnInLoopsAlwaysOn, loopInfo, rxnID, useRxnLink);
                    end
                    % minimization
                    LPproblem.osense = 1;
                    if ~alwaysLLC && ~loopInfo.rxnInLoops(i0, 1)
                        % solve as LP is fine if no LLCs are always on and the
                        % reverse direction of the current reaction is not in cycles
                        [minFlux(i),Vmin(:,i)] = calcSolForEntry(model,rxnNameList,i,LPproblem,0, ...
                            method, 1, printLevel,minNorm,cpxControl,preCompMinSols{i}, []);
                    else
                        [minFlux(i),Vmin(:,i)] = calcSolForEntry(model,rxnNameList,i,LPproblem,0, ...
                            method, allowLoops, printLevel,minNorm,cpxControl,preCompMinSols{i}, MILPproblem);
                    end
                    % maximization
                    LPproblem.osense = -1;
                    if ~alwaysLLC && ~loopInfo.rxnInLoops(i0, 2)
                        % solve as LP is fine if no LLCs are always on and the
                        % forward direction of the current reaction is not in cycles
                        [maxFlux(i),Vmax(:,i)] = calcSolForEntry(model,rxnNameList,i,LPproblem,0, ...
                            method, 1,printLevel,minNorm,cpxControl,preCompMaxSols{i}, []);
                    else
                        [maxFlux(i),Vmax(:,i)] = calcSolForEntry(model,rxnNameList,i,LPproblem,0, ...
                            method, allowLoops,printLevel,minNorm,cpxControl,preCompMaxSols{i}, MILPproblem);
                    end
            end
            if printLevel == 1
                showprogress(i/length(rxnNameList));
            end
            if printLevel > 1
                fprintf('%4d\t%4.0f\t%10s\t%9.3f\t%9.3f\n',i,100*i/length(rxnNameList),rxnNameList{i},minFlux(i),maxFlux(i));
            end
        end
    else
        % Do this to keep the progress printing in place
        for i = 1:length(rxnNameList)
            i0 = findRxnIDs(model, rxnNameList(i));
            if ~minSolved(i)
                %Calc minimums
                LPproblem.osense = 1;
                switch loopMethod
                    case {'none', 'original', 'fastSNP'}
                        minFlux(i) = calcSolForEntry(model,rxnNameList,i,LPproblem,0, method, allowLoops,printLevel,minNorm,cpxControl,[], MILPproblem);
                    otherwise
                        if ~alwaysLLC && ~loopInfo.rxnInLoops(i0, 1)
                            % solve as LP is fine if no LLCs are always on and the
                            % reverse direction of the current reaction is not in cycles
                            minFlux(i) = calcSolForEntry(model,rxnNameList,i,LPproblem,0, ...
                                method, 1, printLevel,minNorm,cpxControl,[], []);
                        else
                            % reset the bounds and rhs in the MILP
                            MILPproblem = restoreOriginalBounds(MILPproblem, rhs0, loopInfo);
                            rxnID = [];
                            if loopInfo.rxnInLoops(i0, 1)  % if the reverse direction of rxn i0 is in cycles
                                % apply LLCs to the objective reaction
                                rxnID = i0;
                            end
                            % update bounds and rhs
                            MILPproblem = updateLLCs(MILPproblem, conCompAlwaysOn, rxnInLoopsAlwaysOn, loopInfo, rxnID, useRxnLink);
                            minFlux(i) = calcSolForEntry(model,rxnNameList,i,LPproblem,0,method, allowLoops, printLevel,minNorm,cpxControl,[], MILPproblem);
                        end
                end
            end
            if ~maxSolved(i)
                LPproblem.osense = -1;
                switch loopMethod
                    case {'none', 'original', 'fastSNP'}
                        maxFlux(i) = calcSolForEntry(model,rxnNameList,i,LPproblem,0, method, allowLoops,printLevel,minNorm,cpxControl,[], MILPproblem);
                    otherwise
                        if ~alwaysLLC && ~loopInfo.rxnInLoops(i0, 2)
                            % solve as LP is fine if no LLCs are always on and the
                            % forward direction of the current reaction is not in cycles
                            maxFlux(i) = calcSolForEntry(model,rxnNameList,i,LPproblem,0, ...
                                method, 1, printLevel,minNorm,cpxControl,[], []);
                        else
                            % reset the bounds and rhs in the MILP
                            MILPproblem = restoreOriginalBounds(MILPproblem, rhs0, loopInfo);
                            rxnID = [];
                            if loopInfo.rxnInLoops(i0, 2)  % if the forward direction of rxn i0 is in cycles
                                % apply LLCs to the objective reaction
                                rxnID = i0;
                            end
                            % update bounds and rhs
                            MILPproblem = updateLLCs(MILPproblem, conCompAlwaysOn, rxnInLoopsAlwaysOn, loopInfo, rxnID, useRxnLink);
                            maxFlux(i) = calcSolForEntry(model,rxnNameList,i,LPproblem,0,method, allowLoops, printLevel,minNorm,cpxControl,[], MILPproblem);
                        end
                end
            end
            
            if printLevel == 1
                showprogress(i/length(rxnNameList));
            end
            if printLevel > 1
                fprintf('%4d\t%4.0f\t%10s\t%9.3f\t%9.3f\n',i,100*i/length(rxnNameList),rxnNameList{i},minFlux(i),maxFlux(i));
            end
        end
    end
else % parallel job.  pretty much does the same thing.
    environment = getEnvironment();
    
    if minNorm        
        parfor i = 1:length(rxnNameList)
            restoreEnvironment(environment,0);
            parLPproblem = LPproblem;
            parMILPproblem = MILPproblem;
            switch loopMethod
                case {'none', 'original', 'fastSNP'}
                    parLPproblem.osense = 1;
                    [minFlux(i),Vmin(:,i)] = calcSolForEntry(model,rxnNameList,i,parLPproblem,1, method, allowLoops,printLevel,minNorm,cpxControl,preCompMinSols{i},parMILPproblem);
                    parLPproblem.osense = -1;
                    [maxFlux(i),Vmax(:,i)] = calcSolForEntry(model,rxnNameList,i,parLPproblem,1, method, allowLoops,printLevel,minNorm,cpxControl,preCompMaxSols{i},parMILPproblem);
                otherwise
                    % apply localized loopless constraints
                    i0 = findRxnIDs(model, rxnNameList(i));
                    if alwaysLLC || any(loopInfo.rxnInLoops(i0, :))
                        if ~any(loopInfo.rxnInLoops(i0, :))
                            % apply LLCs only to the always-on set of reactions
                            rxnID = [];
                        else
                            % apply LLCs to the always-on set + objective reaction that is in cycles
                            rxnID = i0;
                        end
                        % update bounds and rhs
                        parMILPproblem = updateLLCs(parMILPproblem, conCompAlwaysOn, rxnInLoopsAlwaysOn, loopInfo, rxnID, useRxnLink);
                    end
                    % minimization
                    parLPproblem.osense = 1;
                    if ~alwaysLLC && ~loopInfo.rxnInLoops(i0, 1)
                        % solve as LP is fine if no LLCs are always on and the
                        % reverse direction of the current reaction is not in cycles
                        [minFlux(i),Vmin(:,i)] = calcSolForEntry(model,rxnNameList,i, parLPproblem,0, ...
                            method, 1, printLevel,minNorm,cpxControl,preCompMinSols{i}, []);
                    else
                        [minFlux(i),Vmin(:,i)] = calcSolForEntry(model,rxnNameList,i, parLPproblem,0, ...
                            method, allowLoops, printLevel,minNorm,cpxControl,preCompMinSols{i}, parMILPproblem);
                    end
                    % maximization
                    parLPproblem.osense = -1;
                    if ~alwaysLLC && ~loopInfo.rxnInLoops(i0, 2)
                        % solve as LP is fine if no LLCs are always on and the
                        % forward direction of the current reaction is not in cycles
                        [maxFlux(i),Vmax(:,i)] = calcSolForEntry(model,rxnNameList,i, parLPproblem,0, ...
                            method, 1,printLevel,minNorm,cpxControl,preCompMaxSols{i}, []);
                    else
                        [maxFlux(i),Vmax(:,i)] = calcSolForEntry(model,rxnNameList,i, parLPproblem,0, ...
                            method, allowLoops,printLevel,minNorm,cpxControl,preCompMaxSols{i}, parMILPproblem);
                    end
            end
        end
    else
        mins = -inf*ones(length(rxnListMin),1);
        LPproblem.osense = 1;
        parfor i = 1:length(rxnListMin)
            restoreEnvironment(environment,0);
            parLPproblem = LPproblem;
            parMILPproblem = MILPproblem;
            switch loopMethod
                case {'none', 'original', 'fastSNP'}
                    mins(i) = calcSolForEntry(model,rxnListMin,i,parLPproblem,1, method, allowLoops,printLevel,minNorm,cpxControl,[], parMILPproblem);
                otherwise
                    % use LLCs
                    i0 = findRxnIDs(model, rxnListMin(i));
                    if ~alwaysLLC && ~loopInfo.rxnInLoops(i0, 1)
                        % solve as LP is fine if no LLCs are always on and the
                        % reverse direction of the current reaction is not in cycles
                        mins(i) = calcSolForEntry(model,rxnListMax,i,parLPproblem,0,method, 1, printLevel,minNorm,cpxControl,[], []);
                    else
                        rxnID = [];
                        if loopInfo.rxnInLoops(i0, 1)  % if the reverse direction of rxn i0 is in cycles
                            % apply LLCs to the always-on set + objective reaction that is in cycles
                            rxnID = i0;
                        end
                        % update bounds and rhs
                        parMILPproblem = updateLLCs(parMILPproblem, conCompAlwaysOn, rxnInLoopsAlwaysOn, loopInfo, rxnID, useRxnLink);
                        mins(i) = calcSolForEntry(model,rxnListMin,i,parLPproblem,0,method, allowLoops, printLevel,minNorm,cpxControl,[], parMILPproblem);
                    end
            end
        end
        [minFluxPres,minFluxOrder] = ismember(rxnListMin,rxnNameList);
        minFlux(minFluxOrder(minFluxPres)) = mins;   
        %calc maximiums
        maxs = inf*ones(length(rxnListMax),1);
        LPproblem.osense = -1;
        parfor i = 1:length(rxnListMax)        
            restoreEnvironment(environment,0);
            parLPproblem = LPproblem;
            parMILPproblem = MILPproblem;
             switch loopMethod
                case {'none', 'original', 'fastSNP'}
                    maxs(i) = calcSolForEntry(model,rxnListMax,i,parLPproblem,1, method, allowLoops,printLevel,minNorm,cpxControl,[], parMILPproblem);
                 otherwise
                     % use LLCs
                     i0 = findRxnIDs(model, rxnListMax(i));
                     if ~alwaysLLC && ~loopInfo.rxnInLoops(i0, 2)
                         % solve as LP is fine if no LLCs are always on and the
                         % forward direction of the current reaction is not in cycles
                         maxs(i) = calcSolForEntry(model,rxnListMax,i, parLPproblem,0, method, 1, printLevel,minNorm,cpxControl,[], []);
                     else
                         rxnID = [];
                         if loopInfo.rxnInLoops(i0, 2)  % if the forward direction of rxn i0 is in cycles
                             % apply LLCs to the always-on set + objective reaction that is in cycles
                             rxnID = i0;
                         end
                         % update bounds and rhs
                         parMILPproblem = updateLLCs(parMILPproblem, conCompAlwaysOn, rxnInLoopsAlwaysOn, loopInfo, rxnID, useRxnLink);
                         maxs(i) = calcSolForEntry(model,rxnListMax,i, parLPproblem,0, method, allowLoops, printLevel,minNorm,cpxControl,[], parMILPproblem);
                     end
             end
        end
        [maxFluxPres,maxFluxOrder] = ismember(rxnListMax,rxnNameList);
        maxFlux(maxFluxOrder(maxFluxPres)) = maxs;         
    end
end

maxFlux = columnVector(maxFlux);
minFlux = columnVector(minFlux);
end

function [Flux,V] = calcSolForEntry(model,rxnNameList,i,LPproblem,parallelMode, method, allowLoops, printLevel, minNorm, cpxControl, sol, MILPproblem)

    %get Number of reactions
    nRxns = numel(model.rxns);
    %Set the correct objective
    LPproblem.c(:) = 0;
    LPproblem.c(strcmp(model.rxns,rxnNameList{i})) = 1;
    if isempty(sol)
        %%%% This messes up the text waitbar
        %if printLevel == 1 && ~parallelMode
        %    fprintf('iteration %d.\n', i);
        %end
        % do LP always
        if allowLoops
            LPsolution = solveCobraLP(LPproblem, cpxControl);
        else
            MILPproblem.osense = LPproblem.osense;
            MILPproblem.c(1:nRxns) = LPproblem.c;
            LPsolution = solveCobraMILP(MILPproblem);
        end
        % take the maximum flux from the flux vector, not from the obj -Ronan
        % A solution is possible, so the only problem should be if its
        % unbounded and if it is unbounded, the max flux is infinity.
        if LPsolution.stat == 2
            Flux = -LPproblem.osense * inf;
        elseif LPsolution.stat == 1        
            Flux = getObjectiveFlux(LPsolution, LPproblem);
        else
            error(['A Solution could not be found!\nThis should not be possible but can happen',...
                   'if the used solver cannot properly handle unboundedness, or if there are numerical issues.\n',...
                   'Please try to use a different solver.\n'])
        end
    else
        LPsolution = sol;
        Flux = getObjectiveFlux(LPsolution, LPproblem);        
    end
    % minimise the Euclidean norm of the optimal flux vector to remove loops -Ronan
    if minNorm == 1
        if allowLoops
            V = getMinNorm(LPproblem, LPsolution, nRxns, Flux, model, method, allowLoops);
        else
            V = getMinNorm(MILPproblem, LPsolution, nRxns, Flux, model, method, allowLoops);
        end
    end
end


function V = getMinNorm(LPproblem,LPsolution,nRxns,cFlux, model, method, allowLoops)
% get the Flux distribution for the specified min norm.

if strcmp(method, 'FBA')
    V = LPsolution.full(1:nRxns);
    return
end
% update LPproblem to fix objective function value for 1-norm and
% 0-norm to work
LPproblem.lb(LPproblem.c ~= 0) = cFlux - 1e-12;
LPproblem.ub(LPproblem.c ~= 0) = cFlux + 1e-12;
if allowLoops
    switch method
        case '2-norm'
            QPproblem=LPproblem;
            QPproblem.lb(LPproblem.c~=0) = cFlux - 1e-12;
            QPproblem.ub(LPproblem.c~=0) = cFlux + 1e12;
            QPproblem.c(:)=0;
            %Minimise Euclidean norm using quadratic programming
            QPproblem.F = [speye(nRxns,nRxns), sparse(nRxns,size(LPproblem.A,2)-nRxns);...
                sparse(size(LPproblem.A,2)-nRxns,size(LPproblem.A,2))];
            QPproblem.osense = 1;
            %quadratic optimization
            solution = solveCobraQP(QPproblem);
            V=solution.full(1:nRxns,1);
        case '1-norm'
            V = sparseFBA(LPproblem, 'min', 0, 0, 'l1');
        case '0-norm'
            V = sparseFBA(LPproblem, 'min', 0, 0);
        case 'minOrigSol'
            % we take the original model, and constrain the objective reaction
            % accordingly.
            LPproblemMOMA = model;
            LPproblemMOMA.lb(LPproblem.c(1:nRxns)~=0) = cFlux - 1e-11;
            LPproblemMOMA.ub(LPproblem.c(1:nRxns)~=0) = cFlux + 1e-11;
            momaSolution = linearMOMA(model,LPproblemMOMA);
            V=momaSolution.x;     
    end
else
    V = minNormForMILP(LPproblem, nRxns, method);
end
end

function V = minNormForMILP(MILPproblem, nRxns, method)
% It will be great if sparseFBA can somehow support MILP problems
[m, n] = size(MILPproblem.A);
switch method
    case '2-norm'
        MILPproblem.c(:)=0;
        %Minimise Euclidean norm using quadratic programming
        MILPproblem.F = [speye(nRxns,nRxns), sparse(nRxns, n - nRxns); ...
            sparse(n - nRxns, n)];
        MILPproblem.osense = 1;
                %quadratic optimization
        solution = solveCobraMIQP(MILPproblem);
        V = solution.full(1:nRxns);
    case '1-norm'
        MILPproblem.A = [MILPproblem.A,             sparse(m, nRxns); ... original problem
            sparse(1:nRxns, 1:nRxns, 1, nRxns, n),  -speye(nRxns); ...  v - |v| <= 0
            sparse(1:nRxns, 1:nRxns, -1, nRxns, n), -speye(nRxns)]; %  -v - |v| <= 0
        MILPproblem.b = [MILPproblem.b; zeros(nRxns * 2, 1)];
        MILPproblem.csense = [MILPproblem.csense(:); repmat('L', nRxns * 2, 1)];
        MILPproblem.c = [zeros(n, 1); ones(nRxns, 1)];
        MILPproblem.osense = 1;
        MILPproblem.vartype = [MILPproblem.vartype(:); repmat('C', nRxns, 1)];
        MILPproblem.lb = [MILPproblem.lb; zeros(nRxns, 1)];
        MILPproblem.ub = [MILPproblem.ub; max(abs([MILPproblem.lb(1:nRxns), MILPproblem.ub(1:nRxns)]), [],  2)];
        solution = solveCobraMILP(MILPproblem);
        V = solution.full(1:nRxns);
    case '0-norm'
        % use binary switch
        MILPproblem.A = [MILPproblem.A,             sparse(m, nRxns); ... original problem
            sparse(1:nRxns, 1:nRxns, 1, nRxns, n),  sparse(1:nRxns, 1:nRxns, -MILPproblem.ub(1:nRxns), nRxns, nRxns); ...   v - ub*a <= 0
            sparse(1:nRxns, 1:nRxns, -1, nRxns, n),  sparse(1:nRxns, 1:nRxns, MILPproblem.lb(1:nRxns), nRxns, nRxns)];  %  -v + lb*a <= 0
        MILPproblem.b = [MILPproblem.b; zeros(nRxns * 2, 1)];
        MILPproblem.c = [zeros(n, 1); ones(nRxns, 1)];
        MILPproblem.csense = [MILPproblem.csense(:); repmat('L', nRxns * 2, 1)];
        MILPproblem.osense = 1;
        MILPproblem.vartype = [MILPproblem.vartype(:); repmat('B', nRxns, 1)];
        MILPproblem.lb = [MILPproblem.lb; zeros(nRxns, 1)];
        MILPproblem.ub = [MILPproblem.ub; ones(nRxns, 1)];
        solution = solveCobraMILP(MILPproblem);
        V = solution.full(1:nRxns);
    case 'FBA'
        V=LPsolution.full(1:nRxns);
    case 'minOrigSol'
        warning('method ''minOrigSol'' not supported with ''allowLoops'' turned on. Return the ''FBA'' solution');
        V=LPsolution.full(1:nRxns);
end
        
end

function flux = getObjectiveFlux(LPsolution,LPproblem)
% Determine the current flux based on an LPsolution, the original LPproblem
% The LPproblem is used to retrieve the current objective position.
% min indicates, whether the minimum or maximum is requested, the
% upper/lower bounds are used, if the value is exceeding them

    Index = LPproblem.c~=0;
    if LPsolution.full(Index)<LPproblem.lb(Index) %takes out tolerance issues
        flux = LPproblem.lb(Index);
    elseif LPsolution.full(Index)>LPproblem.ub(Index)
        flux = LPproblem.ub(Index);
    else
        flux = LPsolution.full(Index);
    end
end

function [alwaysLLC, rxnInLoopsAlwaysOn, conCompAlwaysOn, x0] = preprocessLLC(LPproblem, ...
    model, nRxns, rxnInLoops, osenseStr, conComp, printLevel)
if strcmp(osenseStr, 'min')
    model.c = -model.c;
end
% determine the set of reactions for which LLCs are always required
% condition I in Prop. 2 in Chan et al., 2017
cond1 = rxnInLoops(:, 2) & model.c > 0;
% condition II in the paper in Prop. 2 in Chan et al., 2017 
cond2 = rxnInLoops(:, 1) & model.c < 0;
% condition III in the paper in Prop. 2 in Chan et al., 2017
[cond3A1, cond3A2, cond3B] = deal(false(nRxns, 1));
for i = (size(model.S, 1) + 1):size(LPproblem.A, 1)
    % for constraint p with sum(a_pj * v_j) <= b_p
    if ~strcmp(LPproblem.csense(i), 'G')  % '<=' or '=' constraint
        % if reaction j has its forward direction in cycles and a_pj < 0
        cond3A1 = cond3A1 | (rxnInLoops(:, 2) & LPproblem.A(i, 1:nRxns)' < 0);
        % if reaction j has its reverse direction in cycles and a_pj > 0
        cond3A2 = cond3A2 | (rxnInLoops(:, 1) & LPproblem.A(i, 1:nRxns)' > 0);
        % if the constraint involves 2 or more reactinos or RHS < 0
        cond3B = cond3B | (nnz(LPproblem.A(i, 1:nRxns)) > 1 | LPproblem.b(i) < 0);
    end
    if ~strcmp(LPproblem.csense(i), 'L')  % '>=' or '=' constraint
        cond3A1 = cond3A1 | (rxnInLoops(:, 2) & LPproblem.A(i, 1:nRxns)' > 0);
        cond3A2 = con3A2 | (rxnInLoops(:, 1) & LPproblem.A(i, 1:nRxns)' < 0);
        cond3B = cond3B | (nnz(LPproblem.A(i, 1:nRxns)) > 1 | LPproblem.b(i) > 0);
    end
end
% reactions satisfying (3A1 or 3A2) and 3B
cond3 = (cond3A1 | cond3A2) & cond3B;
% condition III for bound constraints can be simplified as follows:
cond3 = cond3 | (model.lb > 0 & rxnInLoops(:, 2)) | (model.ub < 0 & rxnInLoops(:, 1));
% reactions that are required to be constrained by loopless constraints all the time
rxnInLoopsAlwaysOn = cond1 | cond2 | cond3;
% LLCs are always required if the set is non-empty
alwaysLLC = any(rxnInLoopsAlwaysOn);
% the corresponding set of reactions in the same connected components as
% the always-on reactions
conCompAlwaysOn = false(max(conComp), 1);
conCompAlwaysOn(conComp(rxnInLoopsAlwaysOn)) = true;
if printLevel 
    fprintf('Reactions in internal nullspace can be divided into %d connected components.\n', max(conComp))
end

% get an initial feasible and loopless solution in case MipStart is needed
model2 = model;
model2.lb = model2.lb(1:size(model2.S, 2));
model2.ub = model2.ub(1:size(model2.S, 2));
model2.c = zeros(size(model2.S, 2), 1);
model2.b = zeros(size(model2.S, 1), 1);
sFeas = optimizeCbModel(model2, 'max', 'one');
x0 = sFeas.x;
clear sFeas model2
end

function MILPproblemLLC = updateLLCs(MILPproblemLLC, conCompAlwaysOn, rxnInLoopsAlwaysOn, llcInfo, rxnID, useRxnLink)
% apply LLCs by relaxing constraints and pre-assign values to variables
if nargin < 2
    rxnID = [];
end
conCompOn = conCompAlwaysOn;
conCompOn(llcInfo.conComp(rxnID)) = true;

bigM = inf;
if ~useRxnLink
    % use connections from nullspace
    for jCon = 1:numel(conCompOn)
        if ~conCompOn(jCon)
            % relax constraints not affecting optimality and feasibility
            MILPproblemLLC.b(llcInfo.con.vU(llcInfo.rxnInLoopIds(llcInfo.conComp == jCon))) = bigM;
            MILPproblemLLC.b(llcInfo.con.gU(llcInfo.rxnInLoopIds(llcInfo.conComp == jCon))) = bigM;
            MILPproblemLLC.b(llcInfo.con.vL(llcInfo.rxnInLoopIds(llcInfo.conComp == jCon))) = -bigM;
            MILPproblemLLC.b(llcInfo.con.gL(llcInfo.rxnInLoopIds(llcInfo.conComp == jCon))) = bigM;
            % fix variables not affecting optimality and feasibility
            MILPproblemLLC.lb(llcInfo.var.g(llcInfo.rxnInLoopIds(llcInfo.conComp == jCon))) = 0;
            MILPproblemLLC.ub(llcInfo.var.g(llcInfo.rxnInLoopIds(llcInfo.conComp == jCon))) = 0;
            MILPproblemLLC.ub(llcInfo.var.z(llcInfo.rxnInLoopIds(llcInfo.conComp == jCon))) = 0;
        end
    end
else
    % use connections from EFMs
    rxnOn = rxnInLoopsAlwaysOn;
    rxnOn(rxnID) = true;
    % reactions in cycles not sharing EFMs with the current rxn and
    % not one of the reactions required to have no flux through cycles
    id = ~any(llcInfo.rxnLink(rxnOn, :), 1)' & any(llcInfo.rxnInLoops, 2);
%     for iRxn = find(rxnOn(:))'
        
%         id = llcInfo.rxnLink(iRxn, :)' ~= 0
%     end
    MILPproblemLLC.b(llcInfo.con.vU(llcInfo.rxnInLoopIds(id))) = bigM;
    MILPproblemLLC.b(llcInfo.con.gU(llcInfo.rxnInLoopIds(id))) = bigM;
    MILPproblemLLC.b(llcInfo.con.vL(llcInfo.rxnInLoopIds(id))) = -bigM;
    MILPproblemLLC.b(llcInfo.con.gL(llcInfo.rxnInLoopIds(id))) = bigM;

    % pre-determine variables not connected to the reaction for FVA
    % except reactions required to be always constrained
    rxnKeep = llcInfo.conComp == 0;
    for jCon = 1:numel(conCompOn)
        if conCompOn(jCon)
            rxnKeep(llcInfo.conComp == jCon) = true;
        end
    end
    MILPproblemLLC.lb(llcInfo.var.g(llcInfo.rxnInLoopIds(~rxnKeep))) = 0;
    MILPproblemLLC.ub(llcInfo.var.g(llcInfo.rxnInLoopIds(~rxnKeep))) = 0;
    MILPproblemLLC.ub(llcInfo.var.z(llcInfo.rxnInLoopIds(~rxnKeep))) = 0;
end
end

function MILPproblemLLC = restoreOriginalBounds(MILPproblemLLC, rhs0, llcInfo)
    MILPproblemLLC.b = rhs0;
    MILPproblemLLC.ub(llcInfo.var.z) = 1;
    MILPproblemLLC.ub(llcInfo.var.g) = llcInfo.BDg;
    MILPproblemLLC.lb(llcInfo.var.g) = -llcInfo.BDg;
end
