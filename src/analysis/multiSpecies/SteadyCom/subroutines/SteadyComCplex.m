function [sol, result, LP, LPminNorm, indLP] = SteadyComCplex(modelCom, options, solverParams, LP)
% Find the maximum community growth rate at community steady-state using the `SteadyCom` algorithm. Call the CPLEX dynamic object directly.
%
% USAGE:
%    [sol, result, LP, LPminNorm, indLP] = SteadyComCplex(modelCom, options, solverParams, LP)
%
% INPUT:
%    modelCom:       A community COBRA model structure with the following fields (created using createMultipleSpeciesModel)
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
%                      * saveModel ['']  String, if non-empty, save the `cplex` model, basis and parameters.
%
%    solverParams:   Cplex parameter structure. E.g. `struct('simplex', struct('tolerances', struct('feasibility', 1e-8)))`
%
% OUTPUTS:
%    sol:            cplex solution structure
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

t = tic;
t0 = 0;
%% Initialization
%check required fields for community model
if ~isfield(modelCom,'indCom')
    if ~isfield(modelCom,'infoCom') || ~isstruct(modelCom.infoCom) || ...
            ~all(isfield(modelCom.infoCom,{'spBm','EXcom','EXsp','spAbbr','rxnSps','metSps'}))
        error('SteadyComCplex: *.infoCom or *.indCom must be provided.\n');
    end
    %get useful reaction indices
    modelCom.indCom = SteadyComSubroutines('infoCom2indCom', modelCom);
end

%get paramters
if nargin < 2 || isempty(options)
    options = struct();
end
if nargin < 3 || isempty(solverParams) || isempty(fieldnames(solverParams))
    %default Cplex parameters
    solverParams = SteadyComSubroutines('getParams', 'CplexParam');
end

% get SteadyCom paramters. If a required parameter is in options, get its value, else equal to the
% default value in SteadyComSubroutines('getParams') if there is. Otherwise an empty matrix.
[GRguess, GR0, GRfx, GRtol, solveGR0, ...
    BMweight, BMtol, BMtolAbs, BMgdw, ...
    feasCrit, maxIter, verbFlag, algorithm, minNorm, LPonly, saveModel] ...
    = SteadyComSubroutines('getParams',  ...
    {'GRguess', 'GR0', 'GRfx', 'GRtol', 'solveGR0',...  % growth rate related
    'BMweight', 'BMtol', 'BMtolAbs', 'BMgdw',...  % biomass related
    'feasCrit', 'maxIter', 'verbFlag', 'algorithm', 'minNorm', 'LPonly', 'saveModel'}, ...  % algorithm related
    options, modelCom);

%print level
verbFlag = max(min(verbFlag, 3), 0);
pL = [0 10 5 1];
pL = pL(verbFlag + 1);

[m, n] = size(modelCom.S); %model size
nRxnSp = sum(modelCom.indCom.rxnSps > 0); %number of organism-specific rxns
nSp = numel(modelCom.indCom.spBm); %number of organism

if verbFlag && ~LPonly
    fprintf('Find maximum community growth rate..\n');
end
%% Construct LP

if nargin < 4
    %create the CPLEX LP problem if not given
    [LP,indLP] = constructLPcom(modelCom, options, solverParams);
else
    % LP given: delete the row constraining the sum of biomass if exist
    f = find(strcmp(cellstr(LP.Model.rowname),'UnityBiomass'));
    if ~isempty(f)
        LP.delRows(f);
    end
    LP.Model.obj(n+1:n+nSp) = 1;
    LP.Model.sense = 'maximize';
    indLP = [];
end
% Make sure the feasibility tolerance used in CPLEX and in the main loop
% are the same ('constructLPcom' has already reconciled the two tolerances)
feasTol = LP.Param.simplex.tolerances.feasibility.Cur;
LPminNorm = [];
% terminate if only the LP structure is called as output
if LPonly
    result = struct();
    [result.GRmax, result.vBM, result.BM, result.Ut, result.Ex, ...
        result.flux, result.iter, result.iter0, sol] = deal([]);
    result.stat = 'LPonly';
    return
end

%counter for iteration
k = 0;
iter = [];

% if LP is supplied by user, directly jump to the main loop
if nargin < 4
    %% Test the ability of the model to stay at maintenance only.

    %solve for maintenance (zero growth)
    %This step usually costs very little time. Worth doing to confirm
    %feasibility
    feas = true;
    try
        LP.solve();
    catch ME
        %possible internal error of cplex
        if ErrBecauseInfeas(ME)
            %treat as infeasible
            feas = false;
        else
            disp(ME);
            error('Unknown error from CPLEX.');
        end
    end

    % check the feasibility of the solution manually
    dev = checkSolFeas(LP);

    result = struct();
    [result.GRmax, result.vBM, result.BM, result.Ut, result.Ex, result.flux, ...
        result.iter0, result.iter, result.stat] = deal([]);
    %terminate if time limit has been exceeded.
    if feas && LP.Solution.status == 11
        result.stat = 'time limit exceeded';
        sol = [];
        return
    end
    %biomass at zero growth rate
    BM0 = 0;
    if feas && isfield(LP.Solution, 'x') && dev <= feasTol
        if ~any(isnan(LP.Solution.x))
            %if feasible
            BM0 = LP.Model.obj' * LP.Solution.x;
        end
    end
    if BM0 < BMtolAbs
        %if no biomass is formed, infeasible. Terminate.
        if verbFlag
            t0 = toc(t);
            fprintf('Model infeasible at maintenance. Time elapsed: %.0f / %.0f sec\n', t0, t0);
        end
        sol = [];
        result.stat = 'infeasible';
        LPminNorm = [];
        return
    else
        %record the current result if feasible
        if verbFlag
            t0 = toc(t);
            fprintf('Model feasible at maintenance. Time elapsed: %.0f / %.0f sec\n', t0, t0);
        end
        sol = LP.Solution;
        if ~isempty(saveModel)
            LP.writeBasis([saveModel '.bas']);
        end
        result.GRmax = 0;
        result.vBM = LP.Solution.x(modelCom.indCom.spBm);
        result.BM = LP.Solution.x(n + 1 : n + nSp);
        result.BM(abs(result.BM) < 1e-8) = 0;
        % two different types of indexing
        if size(modelCom.indCom.EXcom, 2) == 2
            % uptake and excretion reactions separated
            result.Ut = LP.Solution.x(modelCom.indCom.EXcom(:,1));
            result.Ex = LP.Solution.x(modelCom.indCom.EXcom(:,2));
        else
            % uptake and excretion in one exchange reaction
            [result.Ut, result.Ex] = deal(LP.Solution.x(modelCom.indCom.EXcom(:,1)));
            result.Ut(result.Ut > 0) = 0;
            result.Ut = -result.Ut;
            result.Ex(result.Ex < 0) = 0;
        end
        result.flux = LP.Solution.x(1:n);
        result.iter0 = [0 BM0 0 dev];
        result.iter = [];
        result.stat = 'maintenance';
    end

    %% Test at very small growth rate to see if the model is able to grow
    % only if using the reference biomass at GR0 to define maximum growth rate
    if feasCrit == 2 || solveGR0
        %update the growth rate
        LP.Model.A =SteadyComSubroutines('updateLPcom', modelCom, GR0, GRfx, [], LP.Model.A, BMgdw);
        feas = true;
        try
            LP.solve();
        catch ME
            if ErrBecauseInfeas(ME)
                %treat as infeasible
                feas = false;
            else
                disp(ME);
                error('Unknown error from CPLEX.');
            end
        end
        if feas && LP.Solution.status == 11
            result.stat = 'time limit exceeded';
            sol = [];
            LPminNorm = [];
            return
        end
        % check the feasibility of the solution manually
        dev = checkSolFeas(LP);
        %biomass for reference (at a very low growth rate)
        BMref = 0;
        if feas && isfield(LP.Solution, 'x') && dev <= feasTol
            if ~any(isnan(LP.Solution.x))
                BMref = LP.Model.obj' * LP.Solution.x;
            end
        end

        iter = [iter; 0 GR0 BMref GR0 * BMref dev 0];
        if BMref < BMtolAbs
            %if no biomass can be formed, the model can only stay at maintenance.
            if verbFlag
                t1 = toc(t);
                fprintf('Model infeasible at a minimal growth rate (%.6f). Time elapsed: %.0f / %.0f sec\n.', GR0, t1 - t0, t1);
            end
            result.iter = iter;
            return
        else
            %able to grow. Compute bounds
            if verbFlag
                t1 = toc(t);
                fprintf('Model feasible at a minimal growth (%.6f). Time elapsed: %.0f / %.0f sec.\nLook for upper and lower bounds...\n', GR0, t1 - t0, t1);
                t0 = t1;
            end
            sol = LP.Solution;
            if ~isempty(saveModel)
                LP.writeBasis([saveModel '.bas']);
            end
            result.GRmax = GR0;
            result.vBM = LP.Solution.x(modelCom.indCom.spBm);
            result.BM = LP.Solution.x(n + 1 : n + nSp);
            result.BM(abs(result.BM) < 1e-8) = 0;
            % two different types of indexing
            if size(modelCom.indCom.EXcom, 2) == 2
                % uptake and excretion reactions separated
                result.Ut = LP.Solution.x(modelCom.indCom.EXcom(:,1));
                result.Ex = LP.Solution.x(modelCom.indCom.EXcom(:,2));
            else
                % uptake and excretion in one exchange reaction
                [result.Ut, result.Ex] = deal(LP.Solution.x(modelCom.indCom.EXcom(:,1)));
                result.Ut(result.Ut > 0) = 0;
                result.Ut = -result.Ut;
                result.Ex(result.Ex < 0) = 0;
            end
            result.flux = LP.Solution.x(1:n);
            result.stat = 'minimal growth';
        end
    end
    %initial growth rate
    grCur = GRguess(1);
else
    % if LP is given, assume it has a starting basis for the growth rate
    % encoded in the problem. Start from there should give quick
    % convergence
    jSpGrCur = find(isnan(GRfx),1);
    %initial growth rate
    grCur = full(abs(LP.Model.A(m + 2*nRxnSp + jSpGrCur, n + jSpGrCur)));
end

%% main loop to solve for maximum growth rate

%feasibility criteria
switch feasCrit
    %condition1 for determining the feasibility of the current growth rate
    %condition2 for ensuring the final feasibility after the max growth
    %rate is found
    case 1
        %maximum growth rate given a fixed total community biomass, defaulted to be 1
        BMequiv = BMweight;
        condition1 = @(BMcur, grCur) BMcur >= BMweight;
        condition2 = @(BMcur, grCur) BMcur >= BMweight * (1 - BMtolAbs);
        %guess for grCur
        updateGRguess = @(BMcur, grCur) grCur * BMcur / BMweight;
        LP4fzero = @(grCur, LP)...
            LP4fzero1(grCur, LP, modelCom, GRfx, feasTol, BMequiv, BMgdw);
    case 2
        %maximum growth rate with production rate of community biomass not
        %less than the reference value at growth rate GR0
        BMequiv = BMtol * BMref;
        condition1 = @(BMcur, grCur) BMcur * grCur >= BMtol * BMref * GR0;
        condition2 = @(BMcur, grCur) BMcur * grCur >= BMtol * BMref * GR0 * (1 - BMtolAbs);
        %guess for grCur
        updateGRguess = @(BMcur, grCur) grCur * BMcur / (BMtol * BMref * GR0);
        LP4fzero = @(grCur, LP)...
            LP4fzero2(grCur, LP, modelCom, GRfx, feasTol, BMequiv, GR0, BMgdw);
end

grLB = 0;%lower bound for growth rate
grUB = Inf;%upper bound for growth rate
grLBrecord = grLB;%vector recording all intermediate grLB
grUBrecord = grUB;%vector recording all intermediate grUB
guessMethod = 0; %guess used for updating the growth rate
numInstab = false; %flag for numerical instability
grUnstable = []; %growth rate at which numerical instability occurs
optionsf0 = optimset; %matlab optimization parameters
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
optionsf0.MaxIter = maxIter; %max. number of iteration
optionsf0.TolX = GRtol; %tolerance for the root found
% optionsf0.TolFun = BMtolAbs;

%Finding an interval for the max. growth rate using the simple guess
%growth rate x max(biomass) = constant
%apparently better than guess by matlab fzero
%Then initiate fzero or continue using simple guess or bisection depending
%on the parameter 'algorithm'
col1disp = num2str(max([log10(maxIter)+1,4]));
if pL
    fprintf(['%' col1disp 's  %8s  %8s  %8s  Time elapsed (iteration/total)\n'],...
        'Iter','LB','To test', 'UB');
end
if 0
    %totally solved by fzero (unused)
    GRmax = fzero(@(x) LP4fzero(x, LP), grCur, optionsf0);
else
    k1LB = false; %lower bound found at k = 1
    %If an LB is found at k = 1, kLU counts the number of LBs found.
    %If an UB is found at k = 1, kLU counts the number of UBs found.
    kLU = 0;
    while true
        %solve for initial guess
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
            %fprintf('%.0f\t%.6f\t%.6f\tTime elapsed: %.0f / %.0f sec\n', k, grLB, grUB, t1 - t0, t1);
            t0 = t1;
        end
        %update growth rate
        LP.Model.A = SteadyComSubroutines('updateLPcom', modelCom, grCur, GRfx, [], LP.Model.A, BMgdw);
        feas = true;
        try
            LP.solve();
        catch ME
            if ErrBecauseInfeas(ME)
                %treat as infeasible
                feas = false;
            else
                disp(ME);
                error('Unknown error from CPLEX.');
            end
        end
        if feas && LP.Solution.status == 11
            result.stat = 'time limit exceeded';
            sol = [];
            LPminNorm = [];
            return
        end
        % check the feasibility of the solution manually
        dev = checkSolFeas(LP);
        %get biomass of the current iteration
        BMcur = 0;
        if feas && isfield(LP.Solution, 'x') && dev <= feasTol
            if ~any(isnan(LP.Solution.x))
                %update the current biomass if successfully solved
                BMcur = LP.Model.obj' * LP.Solution.x;
            end
            if condition1(BMcur, grCur)
                %feasible at the current growth rate (sum(X) >= X_0)
                grLB = grCur; %an LB is found
                grLBrecord = [grLBrecord; grLB];
                if k == 1
                    k1LB = true;
                end
                kLU = kLU + k1LB;
            else
                %infeasible at the current growth rate (sum(X) < X_0)
                grUB = grCur; %an UB is found
                grUBrecord = [grUBrecord; grUB];
                if k == 1
                    k1LB = false;
                end
                kLU = kLU + ~k1LB;
            end
        else
            %No solution
            %(can become infeasible because of numerical instability)
            grUB = grCur;
            grUBrecord = [grUBrecord; grUB];
            if k == 1
                k1LB = false;
            end
            kLU = kLU + ~k1LB;
        end
        %record results for the current iteration
        iter = [iter; k, grCur, BMcur, grCur * BMcur, dev, guessMethod];

        % condition for switching to fzero or concluding GRmax = 0:
        %   kLU >= 2 to ensure neither of the bounds is the initial guess.
        % Algorithm:
        %   1. Fzero after finding LB and UB by simple guessing [gr' = gr * sum(X)/sum(X')]
        %   2. Simple guessing with minimum one percent step size
        %   3. Bisection method
        if (grLB > 0 && grUB < Inf && kLU >= 2 && algorithm == 1)
            %switch to fzero
            dBMneg = LP4fzero(grLB, LP);%expected to be -ve
            [dBMpos, BMcur] = LP4fzero(grUB, LP);%expected to be +ve
            if isempty(dBMneg) || isempty(dBMpos)
                result.stat = 'time limit exceeded';
                sol = [];
                LPminNorm = [];
                return
            end
            %Check for numerical instability.
            % Can happens when the model is bounded such that the maximum growth rate
            % for the given biomass is close to the critical wash-out dilution rate
            % of the system. In this case, the maximum biomass sum(X) can drop very
            % abruptly with sum(X) ~ 0 at GRmax but sum(X) >> BMequiv at GRmax - eps.
            % Feasibility in this range returned by the solver is not trustworthy.
            % Should consider adjust the BMweight to a higher level. Or scan the whole
            % range of growth rate to see how it changes. (To be implemented)
            if dBMneg > 0 %the lower bound is indeed infeasible
                LP4fzero(grLBrecord(end - 1), LP);
                [dBMpos, BMcur] = LP4fzero(grLB, LP);
                grUnstable = [grUnstable; grLB];
                numInstab = true; %unstable
                %reset the bounds
                if dBMpos > 0 %keep infeasible even optimizing again provided the previous lower bound basis
                    grUB = grLB;
                    grLB = 0;
                    grCur = (grLBrecord(end - 1) + grUB) / 2;
                    grUBrecord(end) = grUB;
                    grLBrecord(end) = grLB;
                    %loop until it becomes feasible again
                else %can indeed feasible
                    %unstable solution
                    GRmax = grLB;
                    grUBrecord(end) = grUB;
                    grLBrecord(end) = grLB;
                    break
                end
            elseif dBMpos < 0 %the upper bound is indeed feasible
                GRmax = grUB;
                grLB = grUB;
                grUB = inf;
                grUBrecord(end) = grUB;
                grLBrecord(end) = grLB;
                numInstab = true; %unstable
                break
            else
                % normal situation
                % got interval, use fzero, LP will also be dynamically updated
                % (Users may create a modified version of fzero on their own
                % to supply function values [dBMneg, dBMpos] for the initial
                % points to save the time for evaluting the initial points)
                GRmax = fzero(@(x) LP4fzero(x, LP), [grLB, grUB], optionsf0);
                %the final LP may not be at GRmax
                [~, BMcur] = LP4fzero(GRmax, LP);
                break
            end

        elseif grUB <= GRtol %zero growth rate
            GRmax = 0;
            % update the LP for zero growth rate
            [~, BMcur] = LP4fzero(GRmax, LP);
            break
        else
            if algorithm ~= 1 && (grUB - grLB < GRtol)
                %maximum growth rate found using an algorithm other than fzero
                GRmax = grLB;
                LP.Model.A =SteadyComSubroutines('updateLPcom', modelCom, GRmax, GRfx, [], LP.Model.A, BMgdw);
                feas = true;
                try
                    LP.solve();
                catch ME
                    if ErrBecauseInfeas(ME)
                        %treat as infeasible
                        feas = false;
                    else
                        disp(ME);
                        error('Unknown error from CPLEX.');
                    end
                end
                if feas && LP.Solution.status == 11
                    result.stat = 'time limit exceeded';
                    sol = [];
                    LPminNorm = [];
                    return
                end
                BMcur = 0;
                dev = checkSolFeas(LP);
                if dev <= feasTol
                    %update current biomass if successfully solved
                    BMcur = LP.Model.obj' * LP.Solution.x;
                end
                break
            end
            %Get the new guess for the growth rate using simple guess or bisection
            %Simple guess
            grNext = updateGRguess(BMcur, grCur);
            if grNext >= grUB * 0.99 || algorithm == 3
                %bisection if designated or the guess is too close to the
                %upper bound
                if isinf(grUB)
                    grCur = grLB * 2;
                else
                    grCur = (grUB + grLB) / 2;
                end
                 guessMethod = 1;
            elseif grNext <= max([grLB * 1.01, GRtol])
                %if the guess is too close to the lower bound
                if ~isinf(grUB)
                    %bisection if finite UB has been found
                    grCur = (grUB + grLB) / 2;
                else
                    % 1% larger than LB if UB not found yet
                    grCur = grLB * 1.01;
                end
                guessMethod = 2;
            elseif abs(grNext - grCur) < 1e-2 * grCur
                %When the step size is less than 1%, should be quite close to
                %the solution but still not bounded from the
                %other side. Use a 1% distance to get a bound
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
    LP.Model.A =SteadyComSubroutines('updateLPcom', modelCom, GRmax, GRfx, [], LP.Model.A, BMgdw);
    feas = true;
    try
        LP.solve();
    catch ME
        if ErrBecauseInfeas(ME)
            %treat as infeasible
            feas = false;
        else
            disp(ME);
            error('Unknown error from CPLEX.');
        end
    end
    if feas && LP.Solution.status == 11
        result.stat = 'time limit exceeded';
        sol = [];
        LPminNorm = [];
        return
    end
    % check the feasibility of the solution manually
    dev = checkSolFeas(LP);
    % biomass of the current iteration
    BMcur = 0;
    if feas && isfield(LP.Solution, 'objval') && dev <= feasTol
        BMcur = LP.Solution.objval;
    end
    if verbFlag
        fprintf('GRmax adjustment: %d\n',kGRadjust);
    end
end
% corrected solution not feasible
numInstab2 = ~condition2(BMcur, GRmax) && GRmax > GRtol;
result.GRmax = GRmax;
if ~feas
    result.stat = 'infeasible';
    sol = [];
    LPminNorm = [];
    return
end
% take this as the solution as it contains useful information on dual values and
% reduced cost (e.g. to find out limiting substrate)
sol = LP.Solution;
% add maximum biomass as a constraint to ensure that the model is feasible for further analysis (e.g. FVA)
LP.addRows(BMcur * (1 - feasTol * 100),...
    sparse(ones(nSp,1), (n+1):(n+nSp), ones(nSp,1), 1, size(LP.Model.A,2)),...
    BMcur,'UnityBiomass');
LP.Model.obj(:) = 0;
LP.Model.sense = 'minimize';
feas = true;
try
    LP.solve();
catch ME
    if ErrBecauseInfeas(ME)
        %treat as infeasible
        feas = false;
    else
        disp(ME);
        error('Unknown error from CPLEX.');
    end
end
if feas && LP.Solution.status == 11
    result.stat = 'time limit exceeded';
    sol = [];
    LPminNorm = [];
    return
end
dev = checkSolFeas(LP);

% the infeasibility may increase after adding the biomass constraint (Cplex issue),
% adjust the minimum biomass slightly until feasible
kBMadjust = 0;
BMmaxLB = LP.Model.lhs(end);
while (~isfield(LP.Solution, 'x') || dev > feasTol) && kBMadjust < 10
    kBMadjust = kBMadjust + 1;
    LP.Model.lhs(end) = BMmaxLB * (1 - feasTol/(11 - kBMadjust));
    LP.solve();
    if LP.Solution.status == 11
        result.stat = 'time limit exceeded';
        sol = [];
        LPminNorm = [];
        return
    end
    dev = checkSolFeas(LP);
    if verbFlag
        fprintf('BMmax adjustment: %d\n',kBMadjust);
    end
end
% solution after adding the biomass constraint becomes infeasible
numInstab3 = ~isfield(LP.Solution, 'x') || dev > feasTol;
% result status
if result.GRmax > GRtol
    if numInstab
        result.stat = 'Numerical instability (feasibility)';
    elseif numInstab2
        result.stat = 'Numerical instability (growth rate correction)';
    elseif numInstab3
        result.stat = 'Numerical instability (biomass constraint)';
    else
        % otherwise 'maintenance' set at the very beginning
        result.stat = 'optimal';
    end
end
% minimize L1-norm if required
LPminNorm = [];
flux = LP.Solution.x;
if numel(minNorm) == 1
    if minNorm == 1
        if verbFlag
            fprintf('Minimizing L1-norm...\n');
        end
        LPminNorm = Cplex('minSumFlux');
        LPminNorm.DisplayFunc = [];
        LPminNorm.Model = LP.Model;
        LPminNorm = setCplexParam(LPminNorm, solverParams);
        LPminNorm.Start = LP.Start;
        LPminNorm.Model.obj(:) = 0;
        LPminNorm.Model.sense = 'minimize';
        LPminNorm.addCols(ones(n, 1), sparse(size(LPminNorm.Model.A, 1), n), zeros(n, 1), inf(n, 1));
        n2 = size(LPminNorm.Model.A, 2);
        indLP.var.vAbs = (n2 - n + 1) : n2;
        LPminNorm.addRows(-inf(n, 1), sparse([1:n, 1:n], [1:n, (n2 - n + 1) : n2], ...
            [ones(n, 1); -ones(n, 1)], n, n2), zeros(n, 1), char(strcat(modelCom.rxns, '_MinSumAbs1')));
        indLP.con.vAbs1 = (size(LPminNorm.Model.A, 1) - n + 1) : size(LPminNorm.Model.A, 1);
        LPminNorm.addRows(-inf(n, 1), sparse([1:n, 1:n], [1:n, (n2 - n + 1) : n2], ...
            [-ones(n, 1); -ones(n, 1)], n, n2), zeros(n, 1), char(strcat(modelCom.rxns, '_MinSumAbs2')));
        indLP.con.vAbs2 = (size(LPminNorm.Model.A, 1) - n + 1) : size(LPminNorm.Model.A, 1);
        LPminNorm.solve();
        if checkSolFeas(LPminNorm) <= feasTol
            flux = LPminNorm.Solution.x;
            result.stat = [result.stat ' (min L1-norm)'];
        end
    end
end
if GRmax > 0
    result.vBM = flux(modelCom.indCom.spBm);
    result.BM = flux(n + 1 : n + nSp);
    % result.BM(abs(result.BM) < 1e-8) = 0;
    % two different types of indexing
    if size(modelCom.indCom.EXcom, 2) == 2
        % uptake and excretion reactions separated
        result.Ut = LP.Solution.x(modelCom.indCom.EXcom(:, 1));
        result.Ex = LP.Solution.x(modelCom.indCom.EXcom(:, 2));
    else
        % uptake and excretion in one exchange reaction
        [result.Ut, result.Ex] = deal(LP.Solution.x(modelCom.indCom.EXcom(:, 1)));
        result.Ut(result.Ut > 0) = 0;
        result.Ut = -result.Ut;
        result.Ex(result.Ex < 0) = 0;
    end
    result.flux = flux(1:n);
end
result.iter = iter;
if pL
    if numInstab
        fprintf('Numerical instability for feasibility during the iterations.\n');
    elseif numInstab2
        fprintf('Numerical instability after final correction of growth rate.\n');
    elseif numInstab3
        fprintf('Numerical instability after adding the biomass constraint.\n');
    end
    fprintf('Maximum community growth rate: %.6f (abs. error < %.1g).\tTime elapsed: %.0f sec\n', GRmax, GRtol, toc(t));
end

if ~isempty(saveModel)
    LP.writeModel([saveModel '.mps']);
    LP.writeBasis([saveModel '.bas']);
end

end

function [LP, index] = constructLPcom(modelCom, options, solverParams)
% Construct the model using IBM-ILOG Cplex classLP for solving SteadyCom.
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
%    [LP, index] = constructLPcom(modelCom, options)
%
% INPUTS:
%    modelCom:   community model. See doc for the main function
%    options:    option structure. See doc for the main function

%% Initialization
% get paramters
if nargin < 2 || isempty(options)
    options = struct();
end
if nargin < 3 || isempty(solverParams)
    solverParams = struct();
end
[BMcon, BMrhs, BMcsense, BMobj, BMgdw, GRfx, verbFlag, saveModel] = SteadyComSubroutines('getParams',  ...
    {'BMcon', 'BMrhs','BMcsense', 'BMobj', 'BMgdw', 'GRfx', 'verbFlag', 'saveModel'}, options, modelCom);

[feasTol, optTol] = getCobraSolverParams('LP',{'feasTol'; 'optTol'}, solverParams);
if isfield(solverParams,'simplex') && isfield(solverParams.simplex, 'tolerances') && isfield(solverParams.simplex.tolerances,'feasibility')
    % override the feasTol in CobraSolverParam if given in solverParams
    feasTol = solverParams.simplex.tolerances.feasibility;
end
if isfield(solverParams,'simplex') && isfield(solverParams.simplex, 'tolerances') && isfield(solverParams.simplex.tolerances,'optimality')
    % override the optTol in CobraSolverParam if given in solverParams
    optTol = solverParams.simplex.tolerances.optimality;
end
% make sure Cplex use the same feasTol and optTol as the script
[solverParams.simplex.tolerances.feasibility, solverParams.simplex.tolerances.optimality] = deal(feasTol, optTol);

[m, n] = size(modelCom.S);
nRxnSp = sum(modelCom.indCom.rxnSps > 0); %number of species-specific rxns
nSp = numel(modelCom.indCom.spBm); %number of species

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
%create CPLEX interactive object
LP = Cplex('maxGrCom');
LP.DisplayFunc = [];
nVar = 0;
nCon = 0;
%optimization sense
LP.Model.sense = 'maximize';
%objective vector
obj = zeros(n + nSp, 1);
%sum of biomass at default
obj(n + 1: n + nSp) = BMobj;
%constraint matrix
A = SteadyComSubroutines('updateLPcom', modelCom, 0, GRfx, BMcon, [], BMgdw);
% species-specific fluxes bounded by biomass variable but not by constant
lb = -inf(nRxnSp, 1);
lb(modelCom.lb(1:nRxnSp)>=0) = 0;
lb = [lb; modelCom.lb(nRxnSp + 1: n); zeros(nSp, 1)];
% biomass upper bound should also be arbitrarily large, but set as 1000 here
ub = inf(nRxnSp, 1);
ub(modelCom.ub(1:nRxnSp)<=0) = 0;
ub = [ub; modelCom.ub(nRxnSp + 1: n); 1000 * ones(nSp, 1)];
%variable type, all continuous
ctype = char('C' * ones(1, n + nSp));
%variable names, X for biomass
colname = [modelCom.rxns; strcat('X_', modelCom.infoCom.spAbbr(:))];
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
%constraints' names
rowname = [modelCom.mets; strcat(modelCom.rxns(modelCom.indCom.rxnSps > 0), '_ub');...
    strcat(modelCom.rxns(modelCom.indCom.rxnSps > 0), '_lb'); ...
    strcat('gr,mu,X_', modelCom.infoCom.spAbbr(:))];
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
    rowname = [rowname;strcat('BMcon_',cellstr(num2str((1:size(BMcon,1))')))];
    index.con.bm = nCon + 1 : nCon + size(BMcon,1);
    nCon = nCon + size(BMcon,1);
end

%% More user-supplied constraints (optional)
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
            warning('Size of the constraint matrix not correct. Ignore.')
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
        warning('size of MCrhs not equal to the number of columns in MC. Ignore.')
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
        warning('size of MClhs not equal to the number of columns in MC. Ignore.')
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
        colname = [colname; strcat(modelCom.rxns(Vdecomp),'_pos');strcat(modelCom.rxns(Vdecomp),'_neg')];
        index.var.vp = nVar + 1 : nVar + nMCrow;
        nVar = nVar + nMCrow;
        index.var.vn = nVar + 1 : nVar + nMCrow;
        nVar = nVar + nMCrow;
        ctype = [ctype char('C' * ones(1, nMCrow*2))];
        %new rows to add ( 0<= V - V_pos + V_neg <= 0)
        lhs = [lhs; zeros(nMCrow,1)];
        rhs = [rhs; zeros(nMCrow,1)];
        %matrix to update
        row = [1:nMCrow, 1:nMCrow, 1:nMCrow];
        col = [Vdecomp(:)', n+nSp+1:n+nSp+nMCrow*2];
        entry = [ones(1,nMCrow), -ones(1,nMCrow), ones(1,nMCrow)];
        A = [A sparse(size(A, 1), nMCrow*2);...
            sparse(row, col, entry, nMCrow, n + nSp + nMCrow*2)];
        rowname = [rowname; strcat(modelCom.rxns(Vdecomp),'_decomp')];
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
        rowname = [rowname; strcat('more_con_', ...
            strtrim(cellstr(num2str((1:size(options.MC,2))'))))];
        index.con.mc = nCon + 1 : nCon + size(options.MC,2);
        nCon = nCon + size(options.MC,2);
    end
end
% add constraints and variables to the Cplex object
LP.addRows(lhs, [], rhs, char(rowname));
LP.addCols(obj,A,lb,ub,[],char(colname));

% set Cplex parameters
LP = setCplexParam(LP, solverParams);
% save Cplex parameters
if ~isempty(saveModel)
    LP.writeParam([saveModel '.prm']);
end

end

function [dBM, BMcur] = LP4fzero1(grCur, LP, modelCom, GRfx, feasTol, BMequiv,BMgdw)
    LP.Model.A =SteadyComSubroutines('updateLPcom', modelCom, grCur, GRfx, [], LP.Model.A, BMgdw);
    LP.solve();
    if LP.Solution.status == 11
        dBM = [];
        return
    end
    % check the feasibility of the solution manually
    dev = checkSolFeas(LP);
    %biomass of the current iteration
    BMcur = 0;
    if isfield(LP.Solution, 'x') && dev <= feasTol
        if ~any(isnan(LP.Solution.x))
            BMcur = LP.Model.obj' * LP.Solution.x;
        end
    end
    dBM = BMequiv - BMcur;
end

function [dBM, BMcur] = LP4fzero2(grCur, LP, modelCom, GRfx, feasTol, BMequiv, GR0, BMgdw)
    LP.Model.A =SteadyComSubroutines('updateLPcom', modelCom, grCur, GRfx, [], LP.Model.A, BMgdw);
    LP.solve();
    if LP.Solution.status == 11
        dBM = [];
        return
    end
    % check the feasibility of the solution manually
    dev = checkSolFeas(LP);
    %biomass of the current iteration
    BMcur = 0;
    if isfield(LP.Solution, 'x') && dev <= feasTol
        if ~any(isnan(LP.Solution.x))
            BMcur = LP.Model.obj' * LP.Solution.x;
        end
    end
    dBM = (BMequiv * GR0 / grCur) - BMcur;
end

function yn = ErrBecauseInfeas(ME)
yn = ~isempty(strfind(lower(ME.message),'cplex')) && ...
    ~isempty(strfind(lower(ME.message),'error')) && ...
    ~isempty(strfind(lower(ME.message),'1256'));
end
