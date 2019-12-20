function varargout = processingLLCs(process, varargin)
% This function contains two different processes for manipulating the
% localized loop constraints (LLCs) to formulate a model-specific and
% objective-function-specific MILP for finding loopless flux distributions
% with a minimal number of binary variables
%
% USAGE:
%    1. Preprocess loop information after calling `addLoopLawConstraints`:
%       [solveLP, MILPproblem, loopInfo] = processingLLCs('preprocess', loopInfo, LPproblem, model, nRxns, osenseStr, MILPproblem)
%
%    2. Update the loop constraints for a specific objective vector
%       [solveLP, MILPproblem] = processingLLCs('update', loopInfo, osenseStr, MILPproblem, objVector)
%
% INPUTS:
%    loopInfo:      structure containing info about the loops, initially outputed
%                   from `addLoopLawConstraints` and updated by the current function
%    LPproblem:     original COBRA LP problem structure 
%    model:         the COBRA model from which LPproblem is constructed
%    nRxns:         number of reactions in the model (default size(model.S, 2))
%    osenseStr:     optimization sense of the current problem (e.g., FBA max v_biomass, or FVA min v_PYK)
%                   'max' (defaulted) or 'min'
%    MILPproblem:   COBRA MILP problem generated from LPproblem using `addLoopLawConstraints`
%                   (default generated from LPproblem if not given in the preprocessing call)
%    objVector:     nRxns-by-1 objective vector for the current optimization problem 
%                   for updating LLCs (e.g., FVA min v_PYK given fixed v_biomass)
%
% OUTPUTS:
%    solveLP:       true if solving LP is sufficient to gaurantee the objective function value 
%                   is the same as solving MILP with loop constraints
%    MILPproblem:   updated MILP problem with LLCs
%    loopInfo:      updated loopInfo with info about the loops (outputed only for the preprocess call)

solveLP = true;
switch process
    case 'preprocess'
        loopInfo = preprocessLLCs(varargin{1:5});
        MILPproblem = varargin{6};
        % initial update for MILP. No specific objective reactions
        if loopInfo.alwaysLLC
            % need to solve MILP if the problem constraints or original objective function necessitate the need
            solveLP = false;
            % update bounds and rhs
            MILPproblem = updateLLCs(MILPproblem, loopInfo, []);
        end
        varargout = {solveLP, MILPproblem, loopInfo};
    case 'update'
        loopInfo = varargin{1};
        osenseStr = varargin{2};
        if isempty(osenseStr)
            osenseStr = 'max';
        end
        MILPproblem = varargin{3};
        if numel(varargin) < 4
            objVector = [];
        else
            objVector = varargin{4};
        end
        
        if isempty(objVector)
            % if updating but no object vector is given, just restore the original bounds
            MILPproblem = restoreOriginalBounds(MILPproblem, loopInfo.rhs0, loopInfo.var, loopInfo.BDg);
        else
            % update with a specific objective function
            [rxnID, ~, cCoeff] = find(objVector(:));
            osense = strcmp(osenseStr, 'min') - strcmp(osenseStr, 'max');
            % need to solve MILP if the problem constraints or original objective function necessitate the need or 
            % the reactions being minimized has their reverse direction in loops or 
            % the reactions being maximized has their forward direction in loops
            if loopInfo.alwaysLLC || any(loopInfo.rxnInLoops(rxnID(cCoeff * osense > 0), 1)) || any(loopInfo.rxnInLoops(rxnID(cCoeff * osense < 0), 2))
                solveLP = false;
                % restore the original bounds
                MILPproblem = restoreOriginalBounds(MILPproblem, loopInfo.rhs0, loopInfo.var, loopInfo.BDg);
                % find the reactions in the objective function which are being minimized and has their reverse 
                % direction in loops or the reactions being maximized has their forward direction in loops
                rxnIdLLC = false(numel(rxnID));
                for j = 1:numel(rxnID)
                    if (loopInfo.rxnInLoops(rxnID(j), 1) && cCoeff(j) * osense > 0) ...
                            || (loopInfo.rxnInLoops(rxnID(j), 2) && cCoeff(j) * osense < 0)
                        rxnIdLLC(j) = true;
                    end
                end
                rxnIdLLC = rxnID(rxnIdLLC);
                % update bounds and rhs
                MILPproblem = updateLLCs(MILPproblem, loopInfo, rxnIdLLC);
            end
            
        end
        varargout = {solveLP, MILPproblem};
end

end

function loopInfo = preprocessLLCs(loopInfo, LPproblem, model, nRxns, osenseStr)
if nargin < 4 || isempty(nRxns)
    nRxns = size(model.S, 2);
end
if nargin < 5 || isempty(osenseStr)
    osenseStr = 'max';
end
if strcmp(osenseStr, 'min')
    model.c = -model.c;
end
rxnInLoops = loopInfo.rxnInLoops;
conComp  = loopInfo.conComp;

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
if loopInfo.printLevel 
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
[loopInfo.alwaysLLC, loopInfo.rxnInLoopsAlwaysOn, loopInfo.conCompAlwaysOn, loopInfo.x0] ...
    = deal(alwaysLLC, rxnInLoopsAlwaysOn, conCompAlwaysOn, x0);
end

function MILPproblemLLC = updateLLCs(MILPproblemLLC, loopInfo, rxnID)
% apply LLCs by relaxing constraints and pre-assign values to variables
if nargin < 3
    rxnID = [];
end
conCompOn = loopInfo.conCompAlwaysOn;
conCompOn(loopInfo.conComp(rxnID)) = true;

bigM = inf;
if ~loopInfo.useRxnLink
    % use connections from nullspace
    for jCon = 1:numel(loopInfo.conCompAlwaysOn)
        if ~conCompOn(jCon)
            % relax constraints not affecting optimality and feasibility
            MILPproblemLLC.b(loopInfo.con.vU(loopInfo.rxnInLoopIds(loopInfo.conComp == jCon))) = bigM;
            MILPproblemLLC.b(loopInfo.con.gU(loopInfo.rxnInLoopIds(loopInfo.conComp == jCon))) = bigM;
            MILPproblemLLC.b(loopInfo.con.vL(loopInfo.rxnInLoopIds(loopInfo.conComp == jCon))) = -bigM;
            MILPproblemLLC.b(loopInfo.con.gL(loopInfo.rxnInLoopIds(loopInfo.conComp == jCon))) = -bigM;
            % fix variables not affecting optimality and feasibility
            MILPproblemLLC.lb(loopInfo.var.g(loopInfo.rxnInLoopIds(loopInfo.conComp == jCon))) = 0;
            MILPproblemLLC.ub(loopInfo.var.g(loopInfo.rxnInLoopIds(loopInfo.conComp == jCon))) = 0;
            MILPproblemLLC.ub(loopInfo.var.z(loopInfo.rxnInLoopIds(loopInfo.conComp == jCon))) = 0;
        end
    end
else
    % use connections from EFMs
    rxnOn = loopInfo.rxnInLoopsAlwaysOn;
    rxnOn(rxnID) = true;
    
    % reactions in cycles not sharing EFMs with the current rxns and
    % not being one of the reactions required to have no flux through cycles
    id = ~any(loopInfo.rxnLink(rxnOn, :), 1)' & any(loopInfo.rxnInLoops, 2);
    % the loop constraints on them are relaxed
    MILPproblemLLC.b(loopInfo.con.vU(loopInfo.rxnInLoopIds(id))) = bigM;
    MILPproblemLLC.b(loopInfo.con.gU(loopInfo.rxnInLoopIds(id))) = bigM;
    MILPproblemLLC.b(loopInfo.con.vL(loopInfo.rxnInLoopIds(id))) = -bigM;
    MILPproblemLLC.b(loopInfo.con.gL(loopInfo.rxnInLoopIds(id))) = -bigM;

    % pre-determine variables not connected to the reaction for FVA
    % except reactions required to be always constrained
    rxnKeep = loopInfo.conComp == 0;
    for jCon = 1:numel(conCompOn)
        if conCompOn(jCon)
            rxnKeep(loopInfo.conComp == jCon) = true;
        end
    end
    MILPproblemLLC.lb(loopInfo.var.g(loopInfo.rxnInLoopIds(~rxnKeep))) = 0;
    MILPproblemLLC.ub(loopInfo.var.g(loopInfo.rxnInLoopIds(~rxnKeep))) = 0;
    MILPproblemLLC.ub(loopInfo.var.z(loopInfo.rxnInLoopIds(~rxnKeep))) = 0;
end
end

function MILPproblemLLC = restoreOriginalBounds(MILPproblemLLC, rhs0, varInd, BDg)
    MILPproblemLLC.b = rhs0;
    MILPproblemLLC.ub(varInd.z) = 1;
    MILPproblemLLC.ub(varInd.g) = BDg;
    MILPproblemLLC.lb(varInd.g) = -BDg;
end
