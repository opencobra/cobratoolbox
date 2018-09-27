function [sol, result, LP, LPminNorm, indLP] = SteadyCom(modelCom, options, varargin)
% Find the maximum community growth rate at community steady-state using the `SteadyCom` algorithm
%
% USAGE:
%    [sol, result, LP, LPminNorm, indLP] = SteadyCom(modelCom, options, parameter, 'param1', value1, 'param2', value2, ...)
%
% INPUT:
%    modelCom:       A community COBRA model structure with the following fields (created using `createMultipleSpeciesModel`)
%                    (the first 5 fields are required, at least one of the last two is needed. Can be obtained using `getMultiSpecisModelId`):
%
%                      * S - Stoichiometric matrix
%                      * b - Right hand side
%                      * c - Objective coefficients
%                      * lb - Lower bounds
%                      * ub - Upper bounds
%                      * infoCom - structure containing community reaction info
%                      * indCom - the index structure corresponding to `infoCom`
%
% OPTIONAL INPUTS:
%    options:        struct with the following possible fields:
%                    (for constraining individual growth rates and biomass amounts, default []):
%
%                      * GRfx - Fixed growth rate for organisms apart from the community
%                        (:math:`N_{organisms} * 1` vector, NaN for unfixed growth rate,
%                        or [#organisms | value]) e.g. to fix organisms 2, 3
%                        at growth rate 0.1, `GRfx = [2, 0.1; 3, 0.1];`
%                      * BMcon - Biomass constraint matrix :math:`(\sum (a_{ij} * X_j) </=/> b_i)`
%                        (given as :math:`K * N_{organisms}` matrix for `K` constraints)
%                        e.g. [0 1 1 0] for :math:`X_2 + X_3` in a 4-organisms model
%                      * BMrhs - RHS for BMcon, `K x 1` vector for `K` constraints
%                      * BMcsense - Sense of the constraint, 'L', 'E', 'G' for <=, =, >=
%                        (for general constraints on e.g. total carbon uptake, molecular crowding, default [])
%                      * MC - :math:`K * (N_{rxns}+N_{organisms})` coefficient matrix, for `K` additional constraints
%                      * MCmode - :math:`K * (N_{rxns}+N_{organisms})` matrix , with number 0 ~ 3
%
%                        * 0: original variable
%                        * 1: positive part of the variable
%                        * 2: negative part of the variable
%                        * 3: absolute value of the variable
%                      * MCrhs - RHS of the constraints (default all zeros if .MC is given)
%                      * MClhs - LHS of the constraints (default -inf if .MC is given)
%                        (parameters in the iterative algorithm, [default value])
%                      * GRguess [0.2] - Initial guess of the growth rate.
%                      * feasCrit [1] - Criteria for feasibility, 1 or 2:
%                        The algorithm tests iteratively at a given growth rate
%                        whether a feasible solution can be found.
%
%                          1. Use a threshold total biomass `BMweight` (see below).
%                             i.e. :math:`\sum X \geq BMweight`
%                             (use it if the total biomass is known, the most common usage)
%                          2. Use a threshold on minimum biomass production
%                             (=specific growth rate x :math:`\sum biomass`, which is roughly
%                             constant over a range of growth rate if the sum of biomass
%                             is not bounded above)
%                             i.e. :math:`\sum X * gr \geq BMtol * BMref * GR0`
%                             where `BMref` is the maximum biomass at a small growth rate `GR0`
%                             and `BMtol` is a fraction ranging from 0 to 1
%                      * algorithm [1] - Algorithm to find the maximum growth rate
%
%                          1. `Fzero` after finding `grLB` and `grUB` with simple guessing [:math:`gr^T = gr * \sum X / \sum X^T`]
%                          2. Simple guessing with minimum one percent step size
%                          3. Bisection method
%                      * BMweight [1] - Minimum total biomass for feasibility. Used only if `feasCrit = 1`.
%                        Set BMweight to a close-to-zero value to compute the wash-out dilution rate.
%                      * GR0 [0.001] - A small growth rate to obtain a reference value for maximum total biomass production.
%                        Used only if `feasCrit = 2` or `solveGR0 = true`
%                      * BMtol [0.8] - Fractional tolerance for biomass production to check
%                        feasibility. Used only if `feasCrit = 2`
%                      * solveGR0[false] - true to solve the model at a low growth rate `GR0` first to test feasibility
%                      * GRtol [1e-6] - Precision for the growth rate found (:math:`grUB - grLB < GRtol`)
%                      * BMtolAbs [1e-5] - Absolute tolerance for positivity of biomass
%                      * maxIter (1e3) - maximum nummber of iteration
%                        (parameters in the optimization model, [default value])
%                      * minNorm [0] - 0: No `minNorm`. 1: min sum of absolution flux of the final solution.
%                      * BMgdw [all 1s] - The gram dry weight per mmol of the biomass reaction of
%                        each organism. Maybe used to scale the biomass reactions between organisms.
%                      * BMobj [all 1s] - Objective coefficient for the biomass of each organism
%                        when doing the maximization at each step.
%                        (other parameters)
%                      * verbFlag  [3]  - Print level. 0, 1, 2, 3 for silence, one log per 10, 5 (default) or 1 iteration respectively
%                      * LPonly [false] - Return the initial LP at zero growth rate only. Calculate nothing.
%                      * saveModel ['']  String, if non-empty, save the LP structure.
%
%    parameter:      structure for solver-specific parameters.
%                    'param1', value1, ...:  name-value pairs for `solveCobraLP` parameters. See `solveCobraLP` for details
%
% OUTPUTS:
%    sol:            COBRA solution structure (Cplex structure if using ibm_cplex)
%    result:         structure with the following fields:
%
%                      * GRmax: maximum specific growth rate found (/h)
%                      * vBM: biomass formation rate (gdw/h)
%                      * BM: Biomass vector at GRmax (gdw)
%                      * Ut: uptake fluxes (mmol/h)
%                      * Ex: export fluxes (mmol/h)
%                      * flux: flux distribution for the original model
%                        (the following 'iter' fields are status in each iteration:)
%                        [GR | biomass X | biomass flux (`GR * X`) | max. infeas. of solution])
%                      * iter0: stationary, no growth, `gr = 0`
%                      * iter: iterations for finding max gr
%                      * stat: status at the termination of the algorithm:
%
%                        * optimal: optimal growth rate found
%                        * maintenance: feasible at maintenance, but cannot grow
%                        * minimal growth: feasible at a minimal growth rate (possible only if options.solveGR0 = true)
%                        * infeasible: infeasible model, even with maintenance requirement only
%                        * LPonly: return the LP structure only. No optimization performed (only if options.LPonly = true)
%                        * xxx (minNorm L1-norm): in result.flux the sum of absolute fluxes is minimized. 'xxx' is one of the status above.

if isfield(modelCom,'C') || isfield(modelCom,'E')
    issueConfirmationWarning('SteadyCom does not handle the additional constraints and variables defined in the model structure (fields .C and .E.)\n It will only use the stoichiometry provided.');
end

t = tic;
t0 = 0;
%% Initialization
[modelCom, ibm_cplex, feasTol, solverParams, parameters] = SteadyComSubroutines('initialize', modelCom, varargin{:});
if nargin < 2 || isempty(options)
    options = struct();
end
% handle solveCobraLP name-value arguments that are specially treated in SteadyCom functions
[options, varargin] = SteadyComSubroutines('solveCobraLP_arg', options, parameters, varargin);

if ibm_cplex
    [sol, result, LP, LPminNorm, indLP] = SteadyComCplex(modelCom, options, solverParams);
    return
end

% get SteadyCom paramters. If a required parameter is in options, get its value, else equal to the
% default value in SteadyComSubroutines('getParams') if there is. Otherwise an empty matrix.
[GRguess, GR0, GRfx, GRtol, solveGR0, ...
    BMweight, BMtol, BMtolAbs, BMgdw, ...
    feasCrit, maxIter, verbFlag, algorithm, minNorm, LPonly, saveModel] ...
    = SteadyComSubroutines('getParams',  ...
    {'GRguess', 'GR0', 'GRfx', 'GRtol', 'solveGR0', ...  % growth rate related
    'BMweight', 'BMtol', 'BMtolAbs', 'BMgdw', ...  % biomass related
    'feasCrit', 'maxIter', 'verbFlag', 'algorithm', 'minNorm', 'LPonly', 'saveModel'}, ...  % algorithm related
    options, modelCom);

% print level
verbFlag = max(min(verbFlag, 3), 0);
pL = [0 10 5 1];
pL = pL(verbFlag + 1);

n = size(modelCom.S, 2);  % model size
nSp = numel(modelCom.indCom.spBm);  % number of organism

if verbFlag && ~LPonly
    fprintf('Find maximum community growth rate..\n');
end
%% Construct LP
[LP, indLP] = constructLPcom(modelCom, options);
LPminNorm = [];
% terminate if only the LP structure is called as output
if LPonly
    result = struct();
    [result.GRmax, result.vBM, result.BM, result.Ut, result.Ex, ...
        result.flux, result.iter, result.iter0, sol] = deal([]);
    result.stat = 'LPonly';
    return
end

% number of iteration
k = 0;
% solution record: [#iter, growth rate, biomass, growth rate * biomass, infeasibility, method for next guess];
iter = [];

%% Test the ability of the model to stay at maintenance only.

% solve for maintenance (zero growth). This step usually costs very little time. Worth doing to confirm feasibility
sol = solveCobraLP(LP, varargin{:});
% check the feasibility of the solution manually
dev = checkSolFeas(LP, sol);

result = struct();
[result.GRmax, result.vBM, result.BM, result.Ut, result.Ex, result.flux, ...
    result.iter0, result.iter, result.stat] = deal([]);

% biomass at zero growth rate
BM0 = 0;
if dev <= feasTol  % feasible
    BM0 = sol.obj;
end
if BM0 < BMtolAbs
    % if no biomass is formed, infeasible. Terminate.
    if verbFlag
        t0 = toc(t);
        fprintf('Model infeasible at maintenance. Time elapsed: %.0f / %.0f sec\n', t0, t0);
    end
    result.stat = 'infeasible';
    LPminNorm = [];
    return
else
    % record the current result if feasible
    if verbFlag
        t0 = toc(t);
        fprintf('Model feasible at maintenance. Time elapsed: %.0f / %.0f sec\n', t0, t0);
    end
    result.GRmax = 0;
    result.vBM = sol.full(modelCom.indCom.spBm);
    result.BM = sol.full(n + 1 : n + nSp);
    result.BM(abs(result.BM) < 1e-8) = 0;
    % two different types of indexing
    if size(modelCom.indCom.EXcom, 2) == 2
        % uptake and excretion reactions separated
        result.Ut = sol.full(modelCom.indCom.EXcom(:,1));
        result.Ex = sol.full(modelCom.indCom.EXcom(:,2));
    else
        % uptake and excretion in one exchange reaction
        [result.Ut, result.Ex] = deal(sol.full(modelCom.indCom.EXcom(:,1)));
        result.Ut(result.Ut > 0) = 0;
        result.Ut = -result.Ut;
        result.Ex(result.Ex < 0) = 0;
    end
    result.flux = sol.full(1:n);
    result.iter0 = [0 BM0 0 dev];
    result.iter = [];
    result.stat = 'maintenance';
    if isfield(sol, 'basis')
        LP.basis = sol.basis;  % reuse basis
    end
end

%% Test at very small growth rate to see if the model is able to grow
% only if using the reference biomass at GR0 to define maximum growth rate
if feasCrit == 2 || solveGR0
    % update the growth rate as GR0 and solve
    LP.A =SteadyComSubroutines('updateLPcom', modelCom, GR0, GRfx, [], LP.A, BMgdw);
    sol = solveCobraLP(LP, varargin{:});
    % check the feasibility of the solution manually
    dev = checkSolFeas(LP, sol);
    % biomass for reference (at a very low growth rate)
    BMref = 0;
    if dev <= feasTol
        BMref = sol.obj;
    end
    iter = [iter; 0 GR0 BMref GR0 * BMref dev 0];
    if BMref < BMtolAbs
        % if no biomass can be formed, the model can only stay at maintenance.
        if verbFlag
            t1 = toc(t);
            fprintf('Model infeasible at a minimal growth rate (%.6f). Time elapsed: %.0f / %.0f sec\n.', GR0, t1 - t0, t1);
        end
        result.iter = iter;
        return
    else
        % able to grow. Continue
        if verbFlag
            t1 = toc(t);
            fprintf('Model feasible at a minimal growth (%.6f). Time elapsed: %.0f / %.0f sec.\nLook for upper and lower bounds...\n', GR0, t1 - t0, t1);
            t0 = t1;
        end
        result.GRmax = GR0;
        result.vBM = sol.full(modelCom.indCom.spBm);
        result.BM = sol.full(n + 1 : n + nSp);
        result.BM(abs(result.BM) < 1e-8) = 0;
        % two different types of indexing
        if size(modelCom.indCom.EXcom, 2) == 2
            % uptake and excretion reactions separated
            result.Ut = sol.full(modelCom.indCom.EXcom(:,1));
            result.Ex = sol.full(modelCom.indCom.EXcom(:,2));
        else
            % uptake and excretion in one exchange reaction
            [result.Ut, result.Ex] = deal(sol.full(modelCom.indCom.EXcom(:,1)));
            result.Ut(result.Ut > 0) = 0;
            result.Ut = -result.Ut;
            result.Ex(result.Ex < 0) = 0;
        end
        result.flux = sol.full(1:n);
        result.stat = 'minimal growth';
        if isfield(sol, 'basis')
            LP.basis = sol.basis;  % reuse basis
        end
    end
end
% initial growth rate
grCur = GRguess(1);

%% main loop to solve for maximum growth rate
% feasibility criteria
switch feasCrit
    % condition1 for determining the feasibility of the current growth rate
    % condition2 for ensuring the final feasibility after the max growth rate is found
    case 1
        % maximum growth rate given a fixed total community biomass, defaulted
        BMequiv = BMweight;
        condition1 = @(BMcur, grCur) BMcur >= BMweight;
        condition2 = @(BMcur, grCur) BMcur >= BMweight * (1 - BMtolAbs);
        % guess for grCur
        updateGRguess = @(BMcur, grCur) grCur * BMcur / BMweight;
        LP4fzero = @(grCur, LP)...
            LP4fzero1(grCur, LP, modelCom, GRfx, feasTol, BMequiv, BMgdw, varargin{:});
    case 2
        %maximum growth rate with production rate of community biomass >= the reference value at growth rate GR0
        BMequiv = BMtol * BMref;
        condition1 = @(BMcur, grCur) BMcur * grCur >= BMtol * BMref * GR0;
        condition2 = @(BMcur, grCur) BMcur * grCur >= BMtol * BMref * GR0 * (1 - BMtolAbs);
        % guess for grCur
        updateGRguess = @(BMcur, grCur) grCur * BMcur / (BMtol * BMref * GR0);
        LP4fzero = @(grCur, LP)...
            LP4fzero2(grCur, LP, modelCom, GRfx, feasTol, BMequiv, GR0, BMgdw, varargin{:});
end

grLB = 0;  % lower bound for growth rate
grUB = Inf;  % upper bound for growth rate
grLBrecord = grLB;  % vector recording all intermediate grLB (for debugging)
grUBrecord = grUB;  % vector recording all intermediate grUB (for debugging)
guessMethod = 0;  % guess used for updating the growth rate
numInstab = false;  % flag for numerical instability
grUnstable = [];  % growth rate at which numerical instability occurs
optionsf0 = optimset;  % matlab optimization parameters for using fzero
%set display setting for fzero
switch pL
    case 0
        optionsf0.Display = 'off';
    case 10
        optionsf0.Display = 'final';
    case 5
        optionsf0.Display = 'notify';
    case 1
        optionsf0.Display = 'iter';
end
optionsf0.MaxIter = maxIter;  % max. number of iteration
optionsf0.TolX = GRtol;  % tolerance for the root found

% find an interval for the max. growth rate using the naive guess growth rate x max(biomass) = constant
% which gives better guess than matlab fzero. Then initiate fzero or continue using simple guess or bisection
col1disp = num2str(max([log10(maxIter)+1,4]));  % number of characters for column 1
if pL
    fprintf(['%' col1disp 's  %8s  %8s  %8s  Time elapsed (iteration/total)\n'],...
        'Iter','LB','To test', 'UB');
end
if 0
    % totally solved by fzero (unused)
    GRmax = fzero(@(x) LP4fzero(x, LP), grCur, optionsf0);
else
    k1LB = false;  % if lower bound found at k = 1
    % If an LB is found at k = 1, kLU counts the number of LBs found.
    % If an UB is found at k = 1, kLU counts the number of UBs found.
    kLU = 0;
    while true
        % solve for initial guess
        k = k + 1;
        if mod(k, pL) == 0
            t1 = toc(t);
            if ~numInstab
                fprintf(['%' col1disp 'd  %8.6f  %8.6f  %8.6f  %.0f / %.0f sec\n'],...
                    k, grLB, grCur, grUB, t1 - t0, t1);
            else
                fprintf(['%' col1disp 'd  %8.6f  %8.6f  %8.6f  %.0f / %.0f sec (numerical instability)\n'],...
                    k, grLB, grCur, grUB, t1 - t0, t1);
                numInstab = false;
            end
            t0 = t1;
        end
        % update growth rate and solve
        LP.A = SteadyComSubroutines('updateLPcom', modelCom, grCur, GRfx, [], LP.A, BMgdw);
        sol = solveCobraLP(LP, varargin{:});
        % check the feasibility of the solution manually
        dev = checkSolFeas(LP, sol);
        % biomass of the current iteration
        BMcur = 0;
        if dev <= feasTol
            % update the current biomass if successfully solved
            BMcur = sol.obj;
            if condition1(BMcur, grCur)
                % feasible at the current growth rate (sum(X) >= X_0) ==> an LB is found
                grLB = grCur;
                grLBrecord = [grLBrecord; grLB];
                if k == 1
                    k1LB = true;  % if LB is found at step 1
                end
                kLU = kLU + k1LB;
            else
                % infeasible at the current growth rate (sum(X) < X_0) ==> an UB is found
                grUB = grCur;
                grUBrecord = [grUBrecord; grUB];
                if k == 1
                    k1LB = false;  % if LB is not found at step 1
                end
                kLU = kLU + ~k1LB;
            end
            if isfield(sol, 'basis')
                LP.basis = sol.basis;  % reuse basis
            end
        else
            % no solution (can become infeasible because of numerical instability)
            grUB = grCur;
            grUBrecord = [grUBrecord; grUB];
            if k == 1
                k1LB = false;
            end
            kLU = kLU + ~k1LB;
        end
        % record results for the current iteration
        iter = [iter; k, grCur, BMcur, grCur * BMcur, dev, guessMethod];

        % condition for switching to fzero or concluding GRmax = 0:
        %   kLU >= 2 to ensure neither of the bounds is the initial guess.
        % Algorithm:
        %   1. Fzero after finding LB and UB by simple guessing [gr' = gr * sum(X)/sum(X')]
        %   2. Simple guessing with minimum one percent step size
        %   3. Bisection method
        if (grLB > 0 && grUB < Inf && kLU >= 2 && algorithm == 1)
            %switch to fzero
            [dBMneg, LP] = LP4fzero(grLB, LP);%expected to be -ve
            [dBMpos, LP, BMcur, sol] = LP4fzero(grUB, LP);%expected to be +ve
            % Check for numerical instability.
            % Can happens when the model is bounded in a way such that the maximum growth rate
            % for the given biomass is close to the critical wash-out dilution rate
            % of the system. In this case, the maximum biomass sum(X) can drop very
            % abruptly with sum(X) ~ 0 at GRmax but sum(X) >> BMequiv at GRmax - epsilon.
            % Feasibility in this range returned by the solver is not trustworthy.
            % Should consider adjust the BMweight to a higher level. Or scan the whole
            % range of growth rate to see how it changes. (To be implemented)
            if dBMneg > 0  % the lower bound (grLB) is indeed infeasible
                [~, LP] = LP4fzero(grLBrecord(end - 1), LP);
                [dBMpos, LP, BMcur, sol] = LP4fzero(grLB, LP);
                grUnstable = [grUnstable; grLB];
                numInstab = true;  % unstable
                % reset the bounds
                if dBMpos > 0  % keep infeasible even optimizing again provided the previous lower bound basis
                    [grUB, grLB] = deal(grLB, 0);
                    grCur = (grLBrecord(end - 1) + grUB) / 2;
                    grUBrecord(end) = grUB;
                    grLBrecord(end) = grLB;
                    % loop until it becomes feasible again
                else  % dBMpos < 0, grLB becomes feasible again
                    % unstable solution. BMcur here corresponds to the current grLB
                    GRmax = grLB;
                    grUBrecord(end) = grUB;
                    grLBrecord(end) = grLB;
                    break
                end
            elseif dBMpos < 0  % the upper bound (grUB) is indeed feasible
                % unstable solution. BMcur here corresponds to the current grUB
                GRmax = grUB;
                grLB = grUB;
                grUB = inf;
                grUBrecord(end) = grUB;
                grLBrecord(end) = grLB;
                numInstab = true;
                break
            else
                % normal situation
                % got interval, use fzero, LP will also be dynamically updated
                % (Users may create a modified version of fzero on their own
                % to supply function values [dBMneg, dBMpos] for the initial
                % points to save the time for evaluting the initial points)
                GRmax = fzero(@(x) LP4fzero(x, LP), [grLB, grUB], optionsf0);
                % the final LP may not be at GRmax
                [~, LP, BMcur, sol] = LP4fzero(GRmax, LP);
                break
            end

        elseif grUB <= GRtol  % zero growth rate
            GRmax = 0;
            % update the LP for zero growth rate
            [~, LP, BMcur, sol] = LP4fzero(GRmax, LP);
            break
        else
            if algorithm ~= 1 && (grUB - grLB < GRtol)
                % maximum growth rate found using an algorithm other than fzero
                GRmax = grLB;
                [~, LP, BMcur, sol] = LP4fzero(GRmax, LP);
                break
            end
            % new guess for the growth rate using simple guess or bisection
            grNext = updateGRguess(BMcur, grCur);  % simple guess
            if grNext >= grUB * 0.99 || algorithm == 3
                % bisection if designated or the guess is too close to the upper bound
                if isinf(grUB)
                    grCur = grLB * 2;
                else
                    grCur = (grUB + grLB) / 2;
                end
                guessMethod = 1;
            elseif grNext <= max([grLB * 1.01, GRtol])
                % if the guess is too close to the lower bound
                if ~isinf(grUB)
                    %bisection if finite UB has been found
                    grCur = (grUB + grLB) / 2;
                else
                    % 1% larger than LB if UB not found yet
                    grCur = grLB * 1.01;
                end
                guessMethod = 2;
            elseif abs(grNext - grCur) < 1e-2 * grCur
                % When the step size is less than 1%, should be quite close to the solution
                % but still not bounded from the other side. Use a 1% distance to get a bound
                if grNext > grCur
                    grCur = grCur * 1.01;
                else
                    grCur = grCur * 0.99;
                end
                guessMethod = 3;
            else
                %new guess from simple guessing
                grCur = grNext;
                guessMethod = 0;
            end
        end
    end
end

%% final correction for a feasible solution in case of numerical instability
% In this case fzero may return a GRmax with sum(X) = 0.
% If it happens, take a slightly smaller growth rate
kGRadjust = 0;
while ~condition2(BMcur, GRmax) && GRmax > GRtol && kGRadjust <= 10
    kGRadjust = kGRadjust + 1;
    GRmax = GRmax - GRtol / 10;
    [~, LP, BMcur, sol] = LP4fzero(GRmax, LP);
    if verbFlag
        fprintf('GRmax adjustment: %d\n',kGRadjust);
    end
end
% corrected solution still not feasible
numInstab2 = ~condition2(BMcur, GRmax) && GRmax > GRtol;
result.GRmax = GRmax;
solOut = sol;  % the current solution as the output solution
flux = sol.full;
% add maximum biomass as a constraint to ensure
% that the model is feasible for further analysis (e.g. FVA)
LP.A = [LP.A; sparse([ones(nSp, 1); 2 * ones(nSp, 1)], repmat((n + 1):(n + nSp), 1, 2),...
    ones(nSp * 2, 1), 2, size(LP.A, 2))];
LP.b = [LP.b; BMcur; BMcur * (1 - feasTol * 100)];
LP.c(:) = 0;
LP.osense = 1;
LP.csense = [LP.csense, 'LG'];
if isfield(LP, 'basis') && isstruct(LP.basis) && isfield(LP.basis, 'cbasis')
    % add 0s to the constraint basis if using gurobi
    LP.basis.cbasis = [LP.basis.cbasis; 0; 0];
end
sol = solveCobraLP(LP, varargin{:});
if isfield(sol, 'basis')
    LP.basis = sol.basis;  % reuse basis
end
dev = checkSolFeas(LP, sol);

% the infeasibility may increase after adding the biomass constraint (Cplex issue),
% adjust the minimum biomass slightly until feasible
kBMadjust = 0;
BMmaxLB = LP.b(end);
while ~(dev <= feasTol) && kBMadjust < 10
    kBMadjust = kBMadjust + 1;
    LP.b(end) = BMmaxLB * (1 - feasTol/(11 - kBMadjust));
    sol = solveCobraLP(LP, varargin{:});
    if isfield(sol, 'basis')
        LP.basis = sol.basis;  % reuse basis
    end
    dev = checkSolFeas(LP, sol);
    if verbFlag
        fprintf('BMmax adjustment: %d\n',kBMadjust);
    end
end
% solution after adding the biomass constraint becomes infeasible
numInstab3 = ~(dev <= feasTol);
% result status
if result.GRmax > GRtol
    if numInstab
        result.stat = 'Numerical instability (feasibility)';
    elseif numInstab2
        result.stat = 'Numerical instability (growth rate correction)';
    elseif numInstab3
        result.stat = 'Numerical instability (biomass constraint)';
    else
        result.stat = 'optimal';
    end
end
% minimize L1-norm if required
LPminNorm = [];
if numel(minNorm) == 1 && minNorm == 1
    if verbFlag
        fprintf('Minimizing L1-norm...\n');
    end
    LPminNorm = LP;
    LPminNorm.c(:) = 0;
    n2 = size(LPminNorm.A, 2);
    LPminNorm.A = [LPminNorm.A, sparse(size(LPminNorm.A, 1), n);...
        sparse([1:n, 1:n], [1:n, (n2 + 1) : (n2 + n)], [ones(n, 1); -ones(n, 1)], n, n2 + n);...
        sparse([1:n, 1:n], [1:n, (n2 + 1) : (n2 + n)], [-ones(n, 1); -ones(n, 1)], n, n2 + n)];
    LPminNorm.lb = [LPminNorm.lb; zeros(n, 1)];
    LPminNorm.ub = [LPminNorm.ub; inf(n, 1)];
    LPminNorm.c = [LPminNorm.c; ones(n, 1)];
    LPminNorm.osense = 1;
    LPminNorm.b = [LPminNorm.b; zeros(n * 2, 1)];
    LPminNorm.csense = [LPminNorm.csense, char('L' * ones(1, n * 2))];
    indLP.var.vAbs = (n2 + 1) : (n2 + n);
    indLP.con.vAbs1 = (size(LPminNorm.A, 1) - (n * 2) + 1) : (size(LPminNorm.A, 1) - n);
    indLP.con.vAbs2 = (size(LPminNorm.A, 1) - n + 1) : size(LPminNorm.A, 1);
    if isfield(LPminNorm, 'basis') && ~isempty(LPminNorm.basis)
        if isstruct(LPminNorm.basis)
            % gurobi basis
            if isfield(LPminNorm.basis, 'vbasis')
                LPminNorm.basis.vbasis = [LPminNorm.basis.vbasis; zeros(n, 1)];
            end
            if isfield(LPminNorm.basis, 'cbasis')
                LPminNorm.basis.cbasis = [LPminNorm.basis.cbasis; zeros(n * 2, 1)];
            end
        else
            % variable basis for other solvers
            LPminNorm.basis = [LPminNorm.basis; zeros(n, 1)];
        end
    end
    sol = solveCobraLP(LPminNorm, varargin{:});
    dev = checkSolFeas(LPminNorm, sol);
    if dev <= feasTol
        flux = sol.full;
        result.stat = [result.stat ' (min L1-norm)'];
    end
end
if GRmax > 0
    result.vBM = flux(modelCom.indCom.spBm);
    result.BM = flux(n + 1 : n + nSp);
    result.BM(abs(result.BM) < 1e-8) = 0;
    % two different types of indexing
    if size(modelCom.indCom.EXcom, 2) == 2
        % uptake and excretion reactions separated
        result.Ut = sol.full(modelCom.indCom.EXcom(:,1));
        result.Ex = sol.full(modelCom.indCom.EXcom(:,2));
    else
        % uptake and excretion in one exchange reaction
        [result.Ut, result.Ex] = deal(sol.full(modelCom.indCom.EXcom(:,1)));
        result.Ut(result.Ut > 0) = 0;
        result.Ut = -result.Ut;
        result.Ex(result.Ex < 0) = 0;
    end
    result.flux = flux(1:n);
end
result.iter = iter;
sol = solOut;
if ~isempty(saveModel)  % save LP structure if selected
    if ~ischar(saveModel)
        warning('saveInput / options.saveModel is not a string. Save as SteadyComLP.mat');
        save('SteadyComLP.mat', 'LP', 'LPminNorm')
    else
        if ~find(regexp(saveModel, '.mat'))
            saveModel = [saveModel '.mat'];
        end
        if verbFlag
            display(['Saving LPproblem in ' saveModel]);
        end
        save(saveModel, 'LP', 'LPminNorm')
    end
end
if pL
    if numInstab
        fprintf('Numerical instability for feasibility occurs during the iterations.\n');
    elseif numInstab2
        fprintf('Numerical instability occurs after final correction of growth rate.\n');
    elseif numInstab3
        fprintf('Numerical instability occurs after adding the biomass constraint.\n');
    end
    fprintf('Maximum community growth rate: %.6f (abs. error < %.1g).\tTime elapsed: %.0f sec\n', GRmax, GRtol, toc(t));
end
end

function [LP,index] = constructLPcom(modelCom, options)
% Construct an LP structure for solveCobraLP for solving SteadyCom.
% The problem matrix is structured as follows:
%   Variables (column):
%     [flux (organism-specific rxn) | flux (community exchange) | biomass | absolute flux for MC]
%   Constraint (row):
%   [mass balance; (Sv = 0)
%    flux bouned above by ub * biomass; (V - ub*X <= 0)
%    flux bouned below by lb * biomass; (V - lb*X >= 0)
%    biomass reaction = growth rate * biomass; (V_biomass - mu*X = 0)
%    LHS <= sum(coeff_j * flux_j) + sum(coeff_k * X_k) <= RHS (user-supplied constraints);]
%
% USAGE:
%    [LP,index] = constructLPcom(modelCom, options)
%
% INPUTS:
%    modelCom:   community model. See doc for the main function
%    options:    option structure. See doc for the main function

%% Initialization
% get paramters
if ~exist('options', 'var')
    options = struct();
end
[BMcon, BMrhs, BMcsense, BMobj, BMgdw, GRfx, verbFlag] = SteadyComSubroutines('getParams',  ...
    {'BMcon', 'BMrhs','BMcsense', 'BMobj', 'BMgdw', 'GRfx', 'verbFlag'}, options, modelCom);

[m, n] = size(modelCom.S);
nRxnSp = sum(modelCom.indCom.rxnSps > 0);  % number of organism-specific rxns
nSp = numel(modelCom.indCom.spBm);  % number of organisms

if ~isempty(BMcon)
    if size(BMcon,2) ~= nSp || numel(unique([size(BMcon, 1) numel(BMrhs) length(BMcsense)])) ~= 1
        error('size of BMcon, BMrhs or BMcsense not correct.')
    end
end

if ~isempty(BMcon)
    if ismember(BMobj(:)', BMcon, 'rows')
        warning('BMobj should not be constrained. The algorithm may not converge.');
    end
end

%% construct LP
nVar = 0;  % number of variables
nCon = 0;  % number of constraints
% objective vector
obj = zeros(n + nSp, 1);
% sum of biomass at default
obj(n + 1: n + nSp) = BMobj;
%constraint matrix
A = SteadyComSubroutines('updateLPcom', modelCom, 0, GRfx, BMcon, [], BMgdw);
% organism-specific fluxes bounded by biomass variable but not by constant
lb = -inf(nRxnSp, 1);
lb(modelCom.lb(1:nRxnSp)>=0) = 0;
lb = [lb; modelCom.lb(nRxnSp + 1: n); zeros(nSp, 1)];
% biomass upper bound should also be arbitrarily large, but set as 1000 here
ub = inf(nRxnSp, 1);
ub(modelCom.ub(1:nRxnSp)<=0) = 0;
ub = [ub; modelCom.ub(nRxnSp + 1: n); 1000 * ones(nSp, 1)];
index.var.v = nVar + 1: nVar + n;
index.var.x = nVar + n + 1 : nVar + n + nSp;
nVar = nVar + n + nSp;

%handle constraint sense
if ~isfield(modelCom, 'csense')
    cs = char(['E' * ones(1, m) 'L' * ones(1, 2 * nRxnSp) 'E' * ones(1, nSp) BMcsense(:)']);
else
    cs = [modelCom.csense(:)' char(['L' * ones(1, 2 * nRxnSp) 'E' * ones(1, nSp) BMcsense(:)'])];
end
%LHS, RHS for constraints
[rhsAdd, lhsAdd] = deal(zeros(size(A, 1), 1));
rhsAdd(cs == 'G') = inf;
lhsAdd(cs == 'L') = -inf;
rhs = [modelCom.b; zeros(2 * nRxnSp + nSp, 1); BMrhs(:)] + rhsAdd;
lhs = [modelCom.b; zeros(2 * nRxnSp + nSp, 1); BMrhs(:)] + lhsAdd;

index.con.mb = nCon + 1 : nCon + m;
nCon = nCon + m;
index.con.ub = nCon + 1 : nCon + nRxnSp;
nCon = nCon + nRxnSp;
index.con.lb = nCon + 1 : nCon + nRxnSp;
nCon = nCon + nRxnSp;
index.con.gr = nCon + 1 : nCon + nSp;
nCon = nCon + nSp;
%names for biomass constraints if any
if ~isempty(BMcon)
    index.con.bm = nCon + 1 : nCon + size(BMcon,1);
    nCon = nCon + size(BMcon,1);
end

%% More user-supplied constraints
%options.MC: [n+nSp x K] matrix, for K additional constraints
%options.MCmode: [n+nSp x K] matrix, with number 0 ~ 3
%       0: original variable
%       1: positive part of the variable
%       2: negative part of the variable
%       3: absolute value of the variable
%options.MCrhs: right hand side of the constraints (optional, default all zeros)
%options.MClhs: left hand side of the constraints (optional, default -inf)
if isfield(options, 'MC') && ~isempty(options.MC)
    MCcont = true;
    %Check sizes
    if isfield(options,'MCmode')
        %MC and MCmode must have the same size of n+nSp x no. of constraints
        if ~isequal(size(options.MC),size(options.MCmode))
            if ~isequal(size(options.MC),size(options.MCmode'))
                warning('Size of MCmode does not match that of MC. Ignore.')
                MCcont = false;
            else
                MCmode = options.MCmode';
            end
        else
            MCmode = options.MCmode;
        end
    else
        MCmode = sparse(size(options.MC,1),size(options.MC,2));
    end
    if size(options.MC, 1) ~= n + nSp
        if size(options.MC,2) == n + nSp
            options.MC = options.MC';
        else
            warning('Size of the crowding constraint matrix not correct. Ignore.')
            MCcont = false;
        end
    end
    %RHS for MC constraint.
    if isfield(options,'MCrhs')
        MCrhs = options.MCrhs(:);
    else
        MCrhs = zeros(size(options.MC,2),1);
    end
    if numel(MCrhs) == 1
        MCrhs = MCrhs * ones(size(options.MC,2),1);
    elseif numel(MCrhs) ~= size(options.MC,2)
        warning('size of MCrhs not equal to size(options.MC,2). Ignore.')
        MCcont = false;
    end
    %LHS for MC constraint.
    if isfield(options,'MClhs')
        MClhs = options.MClhs(:);
    else
        MClhs = -inf(size(options.MC,2),1);
    end
    if numel(MClhs) == 1
        MClhs = MClhs * ones(size(options.MC,2),1);
    elseif numel(MClhs) ~= size(options.MC,2)
        warning('size of MClhs not equal to size(options.MC,2). Ignore.')
        MCcont = false;
    end

    if MCcont
        if verbFlag
            fprintf('User-supplied constraints imposed.\n');
        end
        %list of fluxes requiring decomposition variables (non-zero MCmode and
        %non-zero MC)
        %first filter by lb and ub to reduce variables to be added
        for j = 1:size(MCmode,2)
            %Ignore variables with non-negative lb but designated to use
            %negative part. Must be zero
            options.MC(lb >= 0 & MCmode(:,j) == 2,j) = 0;
            %variables with non-negative lb and designated to use positive part or
            %absolute value, simply using the original variable
            MCmode(lb >= 0 & (MCmode(:,j) == 3 | MCmode(:,j) == 1),j) = 0;
            %Ignore variables with non-positive ub but designated to use
            %positive part. Must be zero
            options.MC(ub <= 0 & MCmode(:,j) == 1,j) = 0;
            %variables with non-positive ub and designated to use negative part or
            %absolute value, simply using the negative of the original variable
            options.MC(ub <= 0 & (MCmode(:,j) == 3 | MCmode(:,j) == 2),j) ...
                = - options.MC(ub <= 0 & (MCmode(:,j) == 3 | MCmode(:,j) == 2),j);
            MCmode(ub <= 0 & (MCmode(:,j) == 3 | MCmode(:,j) == 2),j) = 0;
        end
        Vdecomp = find(any(options.MC ~=0 & MCmode ~= 0,2));
        nMCrow = numel(Vdecomp);
        %record the index for each new variable and flux
        VdecompInd = [(1:n+nSp)', sparse(repmat(Vdecomp(:),2,1),reshape(repmat(1:2,nMCrow,1),2*nMCrow,1),...
            n+nSp+1:n+nSp+nMCrow*2,n+nSp,2)];
        %new columns for decomposition variables
        obj = [obj; zeros(nMCrow*2,1)];
        lb = [lb;zeros(nMCrow*2,1)];
        ub = [ub;inf(nMCrow*2,1)];
        index.var.vp = nVar + 1 : nVar + nMCrow;
        nVar = nVar + nMCrow;
        index.var.vn = nVar + 1 : nVar + nMCrow;
        nVar = nVar + nMCrow;
        %new rows to add ( 0<= V - V_pos + V_neg <= 0)
        lhs = [lhs; zeros(nMCrow,1)];
        rhs = [rhs; zeros(nMCrow,1)];
        %matrix to update
        row = [1:nMCrow, 1:nMCrow, 1:nMCrow];
        col = [Vdecomp(:)', n+nSp+1:n+nSp+nMCrow*2];
        entry = [ones(1,nMCrow), -ones(1,nMCrow), ones(1,nMCrow)];
        A = [A sparse(size(A, 1), nMCrow*2);...
            sparse(row, col, entry, nMCrow, n + nSp + nMCrow*2)];
        index.con.decomp = nCon + 1 : nCon + nMCrow;
        nCon = nCon + nMCrow;
        %add MC constraints
        MCmodeLogic = repmat(struct('mode',[]),3,1);
        %MCmode: 0, original flux; 1, +ve flux; 2, -ve flux; 3, absolute flux
        %original variable
        MCmodeLogic(1).mode = MCmode == 0 & options.MC ~= 0;
        %positive part
        MCmodeLogic(2).mode = (MCmode == 1 | MCmode == 3) & options.MC ~= 0;
        %negative part
        MCmodeLogic(3).mode = (MCmode == 2 | MCmode == 3) & options.MC ~= 0;
        nMCcon = 0;
        for j = 1:3
            nMCcon = nMCcon + nnz(MCmodeLogic(j).mode);
        end
        %each original, positive or negative flux 1 entry, each absolute
        %flux 2 entires
        [row, col, entry] = deal(zeros(nMCcon , 1));
        ct = 0;
        ct1 = 0;
        for j = 1:size(options.MC,2)
            for k = 1:3
                %add the corresponding variables into the constraint:
                %original, positive part and negative part
                nJ = MCmodeLogic(k).mode(:,j);
                col(ct1+1:ct1+sum(nJ)) = VdecompInd(nJ,k);
                entry(ct1+1:ct1+sum(nJ)) = options.MC(nJ,j);
                ct1 = ct1 + sum(nJ);
            end
            row(ct+1:ct1) = j;
            ct = ct1;
        end
        lhs = [lhs; MClhs];
        rhs = [rhs; MCrhs];
        A = [A; sparse(row, col, entry, size(options.MC,2), n + nSp + nMCrow*2)];
        index.con.mc = nCon + 1 : nCon + size(options.MC,2);
        nCon = nCon + size(options.MC,2);
    end
end

twoSidedConst = rhs ~= lhs & ~isinf(rhs) & ~isinf(lhs);  % constraints bounded at both sides
%LP structure for solveCobraLP
LP = struct();
LP.A = [A; A(twoSidedConst, :)];
LP.b = rhs;
LP.b(isinf(rhs)) = lhs(isinf(rhs));
LP.b = [LP.b; lhs(twoSidedConst)];
LP.c = obj;
LP.lb = lb;
LP.ub = ub;
LP.osense = -1;
LP.csense = zeros(1,numel(rhs));
LP.csense(isinf(rhs)) = 'G';
LP.csense(isinf(lhs)) = 'L';
LP.csense(rhs == lhs ) = 'E';
LP.csense(twoSidedConst) = 'G';
LP.csense = char(LP.csense);

end

function [dBM, LP, BMcur, sol] = LP4fzero1(grCur, LP, modelCom, GRfx, feasTol, BMequiv,BMgdw, varargin)
% update growth rate and solve
LP.A =SteadyComSubroutines('updateLPcom', modelCom, grCur, GRfx, [], LP.A, BMgdw);
sol = solveCobraLP(LP, varargin{:});
% check the feasibility of the solution manually
dev = checkSolFeas(LP, sol);
% biomass of the current iteration
BMcur = 0;
if dev <= feasTol
    BMcur = sol.obj;
    LP.basis = sol.basis;  % reuse basis
end
dBM = BMequiv - BMcur;
end

function [dBM, LP, BMcur, sol] = LP4fzero2(grCur, LP, modelCom, GRfx, feasTol, BMequiv, GR0, BMgdw, varargin)
% update growth rate and solve
LP.A =SteadyComSubroutines('updateLPcom', modelCom, grCur, GRfx, [], LP.A, BMgdw);
sol = solveCobraLP(LP, varargin{:});
% check the feasibility of the solution manually
dev = checkSolFeas(LP, sol);
% biomass of the current iteration
BMcur = 0;
if dev <= feasTol
    BMcur = sol.obj;
    LP.basis = sol.basis;  % reuse basis
end
dBM = (BMequiv * GR0 / grCur) - BMcur;
end
