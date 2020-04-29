function [rxnInLoops, N, loopInfo] = findMinNull(model, formulation, varargin)
% Find a minimal null-space for all internal cycles by solving a MILP, 
% as proposed in Chan et al., 2017.
%
% USAGE:
%    [rxnInLoops, N, loopInfo] = findMinNull(model, formulation, parameters)
%
% INPUT:
%    model:               COBRA model structure
%
% OPTIONAL INPUTS:
%    formulation:         1: solve the MILP problem for a minimal null-space basis 
%                            in an interlaced fashion by presolving some relaxed LPs to simultaneously
%                            determine the directions of reactions that participate in internal cycles
%                            (default, the quickest way as of 2017 Nov)
%                         2: directly solve the MILP. Then determine the directions
%                            of reactions that participate in internal cycles
%    parameters:          solver-specific parameter structure or name-value pair argument for solverCobraMILP
%
% OUTPUTS:
%    rxnInLoops:          #rxns-by-2 matrix. rxnInLoops(j, 1) = true => reverse direction of rxn j in loops
%                         rxnInLoops(j, 2) = true => forward direction of rxn j in loops
%    N:                   Minimal feasible null-space matrix for internal cycles
%    loopInfo:            structure containing the following parameters/information:
%                         *.M:          the bound for minimum/maximum flux 
%                         *.minFlux:    minimum flux required for a reaction to be active
%                         *.ignoreRxns: rxns with small coefficients that are prechecked 
%                                       before solving the MILP to avoid numerical issues
%                         *.nsTime:      wall time for finding the null-space
%                         *.nsCPU:      CPU time for finding the null-space
%                         *.loopPreprocessCPU:  CPU time for finding the directions of reactions participating in loops
%                         *.loopPreprocessTime: wall time for finding the directions of reactions participating in loops

if nargin < 2 || isempty(formulation)
	formulation = 1;
else
	if ~isscalar(formulation)
        % first varargin recognized as formulation
		varargin = [{formulation}; varargin(:)];
		formulation = 1;
	end
end
    
% filter out reactions with very small stoichiometric coefficents. They are
% usually not in loops. This can accelerate MILP solution time. 
% (part of nullspace preprocessing)
cpu0 = cputime;
t = tic;

bigM = 100;
minFlux = 0.1;
rxnIn = sum(model.S ~= 0, 1) > 1;
rxnInIDs = find(rxnIn);
nR = sum(rxnIn);
metIn = any(model.S(:, rxnIn), 2);
nM = sum(metIn);
feasTol = getCobraSolverParams('LP', 'feasTol');

% rxnInLoops(j, 1) = true => reverse direction in loops
% rxnInLoops(j, 2) = true => forward direction in loops
rxnInLoops = false(numel(model.rxns), 2);

nsCPU = cputime - cpu0;
nsTime = toc(t);

if formulation == 1
    % Formulation 1: the procedure stated in SI Methods section 7 in Chan et al. (2017)
    % Determine reactions in loops and their feasible directions in loops
    % in an interlaced fashion
    
    % find maximum number of active reactions
    % (part of nullspace preprocessing)
    cpu0 = cputime;
    t = tic;

    MILP.A = [model.S(metIn, rxnIn),  sparse(nM, nR * 2); ... Sv = 0
             -speye(nR),             -bigM * speye(nR)    sparse(nR, nR); ...  -v - M z_pos <= -minFlux
              speye(nR),              sparse(nR, nR),    -bigM * speye(nR)];  % v - M z_neg <= -minFlux
    MILP.b = [zeros(nM, 1); -minFlux * ones(nR * 2, 1)];
    MILP.c = [zeros(nR, 1); ones(nR * 2, 1)];
    
    % Step 2 in SI Methods section 7. 
    % Find all irreversible reactions that are in loops
    % fix z_pos = 1 if lb < 0, i.e., v may be negative
    % fix z_neg = 1 if ub > 0, i.e., v may be positive
    % (=> z_pos = z_neg = 1 for truly reversible reactions)
    MILP.lb = [-bigM * (model.lb(rxnIn) < 0); model.lb(rxnIn) < 0; model.ub(rxnIn) > 0];
    MILP.ub = [bigM * (model.ub(rxnIn) > 0); ones(nR * 2, 1)];
    MILP.osense = 1;
    MILP.csense = char(['E' * ones(1, nM), 'L' * ones(1, nR * 2)]);
    sol.irr = solveCobraLP(MILP, varargin{:});
    
    % Step 3 in SI Methods section 7. 
    % Record identified reactions
    rxnInLoops(rxnIn, 1) = rxnInLoops(rxnIn, 1) | sol.irr.full(1:nR) < -1e-3;
    rxnInLoops(rxnIn, 2) = rxnInLoops(rxnIn, 2) | sol.irr.full(1:nR) > 1e-3;
    
    % Step 4 in SI Methods section 7. 
    % Check reversible reactions whose forward direction not yet found to be in loops
    rxnCk = ~rxnInLoops(rxnIn, 2) & (model.lb(rxnIn) < 0 & model.ub(rxnIn) >0);
    % fix irreversible reactions known to be not in loops
    MILP.lb((model.lb(rxnIn) >= 0 | model.ub(rxnIn) <= 0) & ~any(rxnInLoops(rxnIn, :), 2)) = 0;
    MILP.ub((model.lb(rxnIn) >= 0 | model.ub(rxnIn) <= 0) & ~any(rxnInLoops(rxnIn, :), 2)) = 0;
    % fix z_pos = 1 for reactions not in rxnCk
    MILP.lb((nR + 1):end) = [~rxnCk; ones(nR, 1)];
    sol.rev1 = solveCobraLP(MILP, varargin{:});
    % Record identified reactions
    rxnInLoops(rxnIn, 1) = rxnInLoops(rxnIn, 1) | sol.rev1.full(1:nR) < -1e-3;
    rxnInLoops(rxnIn, 2) = rxnInLoops(rxnIn, 2) | sol.rev1.full(1:nR) > 1e-3;
    
    % Step 5 in SI Methods section 7. 
    % Check reversible reactions whose reverse direction not yet found to be in loops
    rxnCk = ~rxnInLoops(rxnIn, 1) & (model.lb(rxnIn) < 0 & model.ub(rxnIn) >0);
    % fix z_neg = 1 for reactions not in rxnCk
    MILP.lb((nR + 1):end) = [ones(nR, 1); ~rxnCk];
    sol.rev2 = solveCobraLP(MILP, varargin{:});
    % Record identified reactions
    rxnInLoops(rxnIn, 1) = rxnInLoops(rxnIn, 1) | sol.rev2.full(1:nR) < -1e-3;
    rxnInLoops(rxnIn, 2) = rxnInLoops(rxnIn, 2) | sol.rev2.full(1:nR) > 1e-3;
    
    % This step is not mentioned in SI. 
    % Filter reactions with small coefficients before solving MILP. 
    % They are usually not in loops. This can accelerate MILP solution time. 
    % reactions to be checked
    rxnCk = find(any(abs(model.S(:, rxnIn)) > 0 & abs(model.S(:, rxnIn)) < 1e-3, 1)' ...
        & model.lb(rxnIn) < 0 & model.ub(rxnIn) > 0 & ~any(rxnInLoops(rxnIn, :), 2));
    % fix all z_pos and z_neg
    MILP.lb((nR + 1):end) = 1;
    MILP.c(:) = 0;
    for j = 1:numel(rxnCk)
        % check feasibility in the forward direction
        if ~rxnInLoops(rxnInIDs(rxnCk(j)), 2) && MILP.ub(rxnCk(j)) > 0
            bd0 = MILP.lb(rxnCk(j));
            MILP.lb(rxnCk(j)) = minFlux / 10;
            solJ = solveCobraLP(MILP, varargin{:});
            if checkSolFeas(MILP, solJ) <= feasTol
                rxnInLoops(rxnIn, 1) = rxnInLoops(rxnIn, 1) | solJ.full(1:nR) < -1e-3;
                rxnInLoops(rxnIn, 2) = rxnInLoops(rxnIn, 2) | solJ.full(1:nR) > 1e-3;
            end
            MILP.lb(rxnCk(j)) = bd0;
        end
        % check feasibility in the reverse direction
        if ~rxnInLoops(rxnInIDs(rxnCk(j)), 1) && MILP.lb(rxnCk(j)) < 0
            bd0 = MILP.ub(rxnCk(j));
            MILP.ub(rxnCk(j)) = -minFlux / 10;
            solJ = solveCobraLP(MILP, varargin{:});
            if checkSolFeas(MILP, solJ) <= feasTol
                rxnInLoops(rxnIn, 1) = rxnInLoops(rxnIn, 1) | solJ.full(1:nR) < -1e-3;
                rxnInLoops(rxnIn, 2) = rxnInLoops(rxnIn, 2) | solJ.full(1:nR) > 1e-3;
            end
            MILP.ub(rxnCk(j)) = bd0;
        end
    end
    ignoreRxns = rxnCk(~any(rxnInLoops(rxnInIDs(rxnCk), :), 2));
    MILP.lb(ignoreRxns) = 0;
    MILP.ub(ignoreRxns) = 0;
    ignoreRxns = rxnInIDs(ignoreRxns);
    
    % Step 6 in SI Methods section 7.
    % Solve MILP for the forward directions
    rxnCk = ~rxnInLoops(rxnIn, 2) & (model.lb(rxnIn) < 0 & model.ub(rxnIn) >0);
    % fix z_pos for those not rxnCk. Fix all z_neg
    MILP.lb((nR + 1):end) = [~rxnCk; ones(nR, 1)];
    MILP.vartype = char(['C' * ones(1, nR), 'B' * ones(1, nR * 2)]);
    MILP.x0 = [];
    % minimize z_pos + z_neg
    MILP.c((nR + 1):end) = 1;
    sol.rev3 = solveCobraMILP(MILP, varargin{:});
    % Record identified reactions
    rxnInLoops(rxnIn, 1) = rxnInLoops(rxnIn, 1) | sol.rev3.full(1:nR) < -1e-3;
    rxnInLoops(rxnIn, 2) = rxnInLoops(rxnIn, 2) | sol.rev3.full(1:nR) > 1e-3;
                    
    % end of the first part of null-space preprocessing
    nsCPU = nsCPU + (cputime - cpu0);
    nsTime = nsTime + toc(t);
    
    % Step 7 in SI Methods section 7.
    % Check whether the reactions with negative fluxes in sol.rev3.x can
    % actual have positive fluxes (part of looping reaction preprocessing)
    cpu0 = cputime;
    t = tic;
    
    rxnCk = find(sol.rev3.full(1:nR) < -1e-3 & rxnCk);
    if ~isempty(rxnCk)
        % fix all z when solving LP
        MILP.lb((nR + 1):end) = 1;
        MILP.c(:) = 0;
        for j = 1:numel(rxnCk)
            if ~rxnInLoops(rxnInIDs(rxnCk(j)), 2)
                bd0 = MILP.lb(rxnCk(j));
                MILP.lb(rxnCk(j)) = minFlux / 10;
                solJ = solveCobraLP(MILP, varargin{:});
                if checkSolFeas(MILP, solJ) <= feasTol
                    rxnInLoops(rxnIn, 1) = rxnInLoops(rxnIn, 1) | solJ.full(1:nR) < -1e-3;
                    rxnInLoops(rxnIn, 2) = rxnInLoops(rxnIn, 2) | solJ.full(1:nR) > 1e-3;
                end
                MILP.lb(rxnCk(j)) = bd0;
            end
        end
    end
    
    % end of the first part of loop preprocessing time
    loopPreprocessCPU = cputime - cpu0;
    loopPreprocessTime = toc(t);
    
    % Step 8 in SI Methods section 7.
    % Solve MILP for the reverse direction. (2nd part of nullspace preprocessing)
    cpu0 = cputime;
    t = tic;
    
    rxnCk = ~rxnInLoops(rxnIn, 1) & (model.lb(rxnIn) < 0 & model.ub(rxnIn) >0);
    % fix z_neg for those not rxnCk. Fix all z_pos
    MILP.lb((nR + 1):end) = [ones(nR, 1); ~rxnCk];
    MILP.c((nR + 1):end) = 1;
    sol.rev4 = solveCobraMILP(MILP, varargin{:});
    
    rxnInLoops(rxnIn, 1) = rxnInLoops(rxnIn, 1) | sol.rev4.full(1:nR) < -1e-3;
    rxnInLoops(rxnIn, 2) = rxnInLoops(rxnIn, 2) | sol.rev4.full(1:nR) > 1e-3;
    
    nsCPU = nsCPU + (cputime - cpu0);
    nsTime = nsTime + toc(t);
    
    % Step 9 in SI Methods section 7.
    % Check whether the reactions with positive fluxes in sol.rev4.cont can
    % actual have negative fluxes (part of looping reaction preprocessing)
    cpu0 = cputime;
    t = tic;
    
    rxnCk = find(sol.rev4.full(1:nR) > 1e-3 & rxnCk);
    if ~isempty(rxnCk)
        % fix all z when solving LP
        MILP.lb((nR + 1):end) = 1;
        MILP.c(:) = 0;
        for j = 1:numel(rxnCk)
            if ~rxnInLoops(rxnInIDs(rxnCk(j)), 1)
                bd0 = MILP.ub(rxnCk(j));
                MILP.ub(rxnCk(j)) = -minFlux / 10;
                solJ = solveCobraLP(MILP, varargin{:});
                if checkSolFeas(MILP, solJ) <= feasTol
                    rxnInLoops(rxnIn, 1) = rxnInLoops(rxnIn, 1) | solJ.full(1:nR) < -1e-3;
                    rxnInLoops(rxnIn, 2) = rxnInLoops(rxnIn, 2) | solJ.full(1:nR) > 1e-3;
                end
                MILP.ub(rxnCk(j)) = bd0;
            end
        end
    end
    loopPreprocessCPU = loopPreprocessCPU + (cputime - cpu0);
    loopPreprocessTime = loopPreprocessTime + toc(t);
else
    % Formulation 2: directly solve the MILP and find the feasible reaction 
    % direction participating in loops for each reaction
    
    % find maximum number of active reactions (nullspace preprocessing)
    cpu0 = cputime;
    t = tic;
    
    % filter reactions with small coefficients before solving MILP
    % reactions to be checked
    LP.A = model.S(metIn, rxnIn);
    LP.b = zeros(nM, 1);
    LP.c = zeros(nR, 1);
    LP.lb = -bigM * (model.lb(rxnIn) < 0);
    LP.ub = bigM * (model.ub(rxnIn) > 0);
    LP.csense = char('E' * ones(1, nM));
    [lb0, ub0] = deal(LP.lb, LP.ub);
    % reactions to be checked
    rxnCk = find(any(abs(model.S(:, rxnIn)) > 0 & abs(model.S(:, rxnIn)) < 1e-3, 1));
    for j = 1:numel(rxnCk)
        % check feasibility in the forward direction
        if LP.ub(rxnCk(j)) > 0
            LP.lb(rxnCk(j)) = minFlux / 10;
            solJ = solveCobraLP(LP, varargin{:});
            if checkSolFeas(LP, solJ) <= feasTol
                rxnInLoops(rxnInIDs(rxnCk(j)), 2) = true;
            end
            LP.lb(rxnCk(j)) = lb0(rxnCk(j));
        end
        % check feasibility in the reverse direction
        if ~rxnInLoops(rxnInIDs(rxnCk(j)), 2) && LP.lb(rxnCk(j)) < 0
            LP.ub(rxnCk(j)) = -minFlux / 10;
            solJ = solveCobraLP(LP, varargin{:});
            if checkSolFeas(LP, solJ) <= feasTol
                rxnInLoops(rxnInIDs(rxnCk(j)), 1) = true;
            end
            LP.ub(rxnCk(j)) = ub0(rxnCk(j));
        end
    end
    clear LP
    ignoreRxns = rxnInIDs(rxnCk(~any(rxnInLoops(rxnInIDs(rxnCk), :), 2)));
    rxnIn(ignoreRxns) = false;
    nR = sum(rxnIn);
    metIn = any(model.S(:, rxnIn), 2);
    nM = sum(metIn);
    rxnInIDs = find(rxnIn);
    
    % solve MILP
    MILP.A = [model.S(metIn, rxnIn),  sparse(nM, nR * 2); ... Sv = 0
             -speye(nR),             -bigM * speye(nR)    sparse(nR, nR); ...  -v - M z_pos <= -1
              speye(nR),              sparse(nR, nR),    -bigM * speye(nR); ...   % v - M z_neg <= -1
              sparse(nR, nR),         speye(nR),          speye(nR)];   % z_pos + z_neg >= 1
    MILP.b = [zeros(nM, 1); -minFlux * ones(nR * 2, 1); ones(nR, 1)];
    MILP.c = [zeros(nR, 1); ones(nR * 2, 1)];
    % fix z_pos = 1 for reactions with ub <= 0. Fix z_neg = 1 for reactions with lb >= 0
    MILP.lb = [-bigM * (model.lb(rxnIn) < 0); model.ub(rxnIn) <= 0; model.lb(rxnIn) >= 0];
    MILP.ub = [bigM * (model.ub(rxnIn) > 0); ones(nR * 2, 1)];
    MILP.osense = 1;
    MILP.csense = char(['E' * ones(1, nM), 'L' * ones(1, nR * 2), 'G' * ones(1, nR)]);
    MILP.vartype = char(['C' * ones(1, nR), 'B' * ones(1, nR * 2)]);
    % z_pos for reactions with lb >= 0 and z_neg for reactions with ub <= 0 can be treated as continuous
    MILP.vartype(nR + find(model.lb(rxnIn) >= 0)) = 'C';
	MILP.vartype(nR * 2 + find(model.ub(rxnIn) <= 0)) = 'C';
    MILP.x0 = [zeros(nR, 1); ones(nR * 2, 1)];
    sol = solveCobraMILP(MILP, varargin{:});
    if isempty(sol.full)
		varargin2 = [{'feasTol'; 1e-7}; varargin(:)];
		sol = solveCobraMILP(MILP, varargin2{:});
    end
    
    nsCPU = nsCPU + (cputime - cpu0);
    nsTime = nsTime + toc(t);
    
    cpu0 = cputime;
    t = tic;
    
    % Check whether the reversible reactions with nonzero fluxes in sol.cont can
    % have fluxes in the opposite sign (part of looping reaction preprocessing)
    
    rxnInLoops(rxnIn, 1) = sol.full(1:nR) < -1e-3;
    rxnInLoops(rxnIn, 2) = sol.full(1:nR) > 1e-3;
    
    rxnCk = find(sol.full(1:nR) < -1e-3 | sol.full(1:nR) > 1e-3 & model.lb(rxnIn) < 0 & model.ub(rxnIn) > 0);
    
    LP.A = model.S(metIn, rxnIn);
    LP.b = zeros(nM, 1);
    LP.c = zeros(nR, 1);
    LP.lb = MILP.lb(1:nR) .* any(rxnInLoops(rxnIn, :), 2);
    LP.ub = MILP.ub(1:nR) .* any(rxnInLoops(rxnIn, :), 2);
    LP.csense = MILP.csense(1:nM);
    clear MILP
    
    for j = 1:numel(rxnCk)
        if ~rxnInLoops(rxnInIDs(rxnCk(j)), 2)
			bd0 = LP.lb(rxnCk(j));
            LP.lb(rxnCk(j)) = minFlux / 10;
            solJ = solveCobraLP(LP, varargin{:});
            if checkSolFeas(LP, solJ) <= feasTol
                rxnInLoops(rxnIn, 1) = rxnInLoops(rxnIn, 1) | solJ.full(1:nR) < -1e-3;
				rxnInLoops(rxnIn, 2) = rxnInLoops(rxnIn, 2) | solJ.full(1:nR) > 1e-3;
            end
            LP.lb(rxnCk(j)) = bd0;
        end
        if ~rxnInLoops(rxnInIDs(rxnCk(j)), 1)
			bd0 = LP.ub(rxnCk(j));
            LP.ub(rxnCk(j)) = -minFlux / 10;
            solJ = solveCobraLP(LP, varargin{:});
            if checkSolFeas(LP, solJ) <= feasTol
                rxnInLoops(rxnIn, 1) = rxnInLoops(rxnIn, 1) | solJ.full(1:nR) < -1e-3;
				rxnInLoops(rxnIn, 2) = rxnInLoops(rxnIn, 2) | solJ.full(1:nR) > 1e-3;
            end
            LP.ub(rxnCk(j)) = bd0;
        end
    end
    
    loopPreprocessCPU = cputime - cpu0;
    loopPreprocessTime = toc(t);
end

% get the nullspace matrix (part of nullspace preprocessing)
cpu0 = cputime;
t = tic;
    
rxnCyc = any(rxnInLoops, 2);
N = sparseNull(model.S(any(model.S(:, rxnCyc), 2), rxnCyc));
[row, col, entry] = find(N);
rxnCyc = find(rxnCyc);
row = rxnCyc(row);
N = sparse(row, col, entry, size(model.S, 2), size(N, 2));

nsCPU = nsCPU + (cputime - cpu0);
nsTime = nsTime + toc(t);

loopInfo.M = bigM;
loopInfo.minFlux = minFlux;
loopInfo.nsCPU = nsCPU;
loopInfo.nsTime = nsTime;
loopInfo.loopPreprocessCPU = loopPreprocessCPU;
loopInfo.loopPreprocessTime = loopPreprocessTime;
loopInfo.ignoreRxns = model.rxns(ignoreRxns);
end
