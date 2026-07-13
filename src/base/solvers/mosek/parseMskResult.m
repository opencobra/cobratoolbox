function [stat,origStat,x,y,yl,yu,z,zl,zu,s,basis,pobjval,dobjval] = parseMskResult(res)
% parseMskResult
%
% Parse the res structure returned by mosekopt.
%
% Solver status convention:
%   stat =  0   primal infeasible certificate
%   stat =  1   strict optimal solution
%   stat =  2   dual infeasible certificate, interpreted upstream as unbounded
%   stat =  3   near optimal / almost optimal solution
%   stat = -1   unknown, numerical issue, time limit, or unrecognised status
%
% Important conic-solver convention:
%
%   For conic problems with affine conic constraints, prefer the
%   interior-point solution res.sol.itr whenever it is available and has an
%   optimal or near-optimal solution status.
%
%   A basis solution, res.sol.bas, is mainly relevant for linear problems.
%   It should not override a valid interior-point solution for conic
%   subproblems.
%
% Dual sign convention returned by this parser:
%
%   y  = yl - yu
%   z  = zu - zl
%
% where
%
%   yl = lower linear-row multiplier
%   yu = upper linear-row multiplier
%   zl = lower variable-bound multiplier
%   zu = upper variable-bound multiplier
%
% With this convention, stationarity is naturally checked as
%
%   c - A'*y + z - F'*s = 0
%
% or equivalently
%
%   c - A'*(yl - yu) + (zu - zl) - F'*s = 0.
%
% This parser deliberately maps NEAR_OPTIMAL to stat = 3, not stat = 1.
% The caller can decide whether a near-optimal solution is acceptable, but
% solveSCLP should not silently accept it as a fully accurate inner solve.

% -------------------------------------------------------------------------
% Initialise outputs.
% -------------------------------------------------------------------------
stat = -1;
origStat = 'NO_SOLUTION_STATUS';

x = [];
y = [];
yl = [];
yu = [];
z = [];
zl = [];
zu = [];
s = [];
basis = [];

pobjval = [];
dobjval = [];

% -------------------------------------------------------------------------
% If MOSEK did not return a solution structure, return the response code.
% -------------------------------------------------------------------------
if ~isfield(res, 'sol')
    if isfield(res,'rcodestr') && ~isempty(res.rcodestr)
        origStat = res.rcodestr;
    else
        origStat = 'NO_RES_SOL_FIELD';
    end
    return
end

% -------------------------------------------------------------------------
% Choose which MOSEK solution to access.
%
% Rule:
%   1. Prefer res.sol.itr if it is strictly optimal or near optimal.
%   2. Use res.sol.bas only if no usable interior-point solution exists.
%   3. If neither is usable, report the most informative status and do not
%      fabricate x, y, z, or s.
% -------------------------------------------------------------------------
hasItr = isfield(res.sol,'itr');
hasBas = isfield(res.sol,'bas');

itrSolSta = getMosekSolStaLocal(res, 'itr');
basSolSta = getMosekSolStaLocal(res, 'bas');

accessSolution = 'dontAccess';

if hasItr && isUsableOptimalStatusLocal(itrSolSta)
    accessSolution = 'itr';
elseif hasBas && isUsableOptimalStatusLocal(basSolSta)
    accessSolution = 'bas';
elseif hasItr
    % For conic solvers, the interior-point status is usually the most
    % informative failure status.
    origStat = itrSolSta;
elseif hasBas
    origStat = basSolSta;
else
    origStat = 'NO_ITR_OR_BAS_SOLUTION';
end

% -------------------------------------------------------------------------
% Access the selected solution.
% -------------------------------------------------------------------------
switch accessSolution

    case 'itr'
        sol = res.sol.itr;
        origStat = itrSolSta;

        % Primal solution.
        x = getMosekVectorFieldLocal(sol, 'xx');

        % Linear-row duals. MOSEK may provide y directly, but computing it
        % from slc and suc keeps the sign convention explicit.
        yl = getMosekVectorFieldLocal(sol, 'slc');
        yu = getMosekVectorFieldLocal(sol, 'suc');
        y  = yl - yu;

        % Variable-bound duals.
        zl = getMosekVectorFieldLocal(sol, 'slx');
        zu = getMosekVectorFieldLocal(sol, 'sux');

        % Use z = zu - zl, matching solveSCLP and errorCLP.
        z = zu - zl;

        % Dual variables to affine conic constraints.
        % For MOSEK affine conic constraints, the interior-point field is
        % normally doty.
        s = getMosekVectorFieldLocal(sol, 'doty');

        pobjval = getMosekScalarFieldLocal(sol, 'pobjval');
        dobjval = getMosekScalarFieldLocal(sol, 'dobjval');

    case 'bas'
        sol = res.sol.bas;
        origStat = basSolSta;

        % Basis solutions should only be used when no usable interior-point
        % solution exists. This branch is mainly for nonconic linear models.
        x = getMosekVectorFieldLocal(sol, 'xx');

        yl = getMosekVectorFieldLocal(sol, 'slc');
        yu = getMosekVectorFieldLocal(sol, 'suc');
        y  = yl - yu;

        zl = getMosekVectorFieldLocal(sol, 'slx');
        zu = getMosekVectorFieldLocal(sol, 'sux');
        z  = zu - zl;

        % Basis solution fields for affine conic duals are not always
        % present. Try doty first, then s as a defensive fallback.
        s = getMosekVectorFieldLocal(sol, 'doty');
        if isempty(s)
            s = getMosekVectorFieldLocal(sol, 's');
        end

        % Basis-status fields are useful for hot-starting linear problems.
        if isfield(sol,'skc'), basis.skc = sol.skc; end
        if isfield(sol,'skx'), basis.skx = sol.skx; end
        if isfield(sol,'xc'),  basis.xc  = sol.xc;  end
        if isfield(sol,'xx'),  basis.xx  = sol.xx;  end

        pobjval = getMosekScalarFieldLocal(sol, 'pobjval');
        dobjval = getMosekScalarFieldLocal(sol, 'dobjval');

    case 'dontAccess'
        % Leave primal-dual vectors empty. This is important for infeasibility
        % certificates: certificate vectors should not be mistaken for primal
        % feasible points.
end

% -------------------------------------------------------------------------
% Convert MOSEK solution status into the standard COBRA-style status flag.
% -------------------------------------------------------------------------
if isStrictOptimalStatusLocal(origStat)
    stat = 1;

elseif isNearOptimalStatusLocal(origStat)
    % Near optimal is intentionally not stat = 1.
    % This prevents solveSCLP from silently accepting an inner point that
    % may only satisfy relaxed feasibility/optimality tolerances.
    stat = 3;

elseif isPrimalInfeasibleCertificateLocal(origStat)
    stat = 0;

elseif isDualInfeasibleCertificateLocal(origStat)
    stat = 2;

else
    stat = -1;
end

% -------------------------------------------------------------------------
% Append the MOSEK response code for traceability.
% -------------------------------------------------------------------------
if isfield(res,'rcodestr') && ~isempty(res.rcodestr)
    origStat = [origStat ' & ' res.rcodestr];
end

end


function solsta = getMosekSolStaLocal(res, whichSol)
% getMosekSolStaLocal
%
% Safely extract res.sol.<whichSol>.solsta.

solsta = 'NO_SOLSTA';

if ~isfield(res,'sol') || ~isfield(res.sol,whichSol)
    return
end

sol = res.sol.(whichSol);

if isfield(sol,'solsta') && ~isempty(sol.solsta)
    solsta = char(string(sol.solsta));
end

end


function tf = isUsableOptimalStatusLocal(solsta)
% isUsableOptimalStatusLocal
%
% A usable solution is one for which MOSEK returned a primal-dual point.
% The caller still distinguishes strict optimal from near optimal later.

tf = isStrictOptimalStatusLocal(solsta) || isNearOptimalStatusLocal(solsta);

end


function tf = isStrictOptimalStatusLocal(solsta)
% isStrictOptimalStatusLocal
%
% Strict optimality statuses.

solsta = char(string(solsta));

tf = any(strcmp(solsta, { ...
    'OPTIMAL', ...
    'MSK_SOL_STA_OPTIMAL', ...
    'INTEGER_OPTIMAL', ...
    'MSK_SOL_STA_INTEGER_OPTIMAL'}));

end


function tf = isNearOptimalStatusLocal(solsta)
% isNearOptimalStatusLocal
%
% Near optimality statuses. These should not be treated as strict optimality.

solsta = char(string(solsta));

tf = any(strcmp(solsta, { ...
    'NEAR_OPTIMAL', ...
    'MSK_SOL_STA_NEAR_OPTIMAL'}));

end


function tf = isPrimalInfeasibleCertificateLocal(solsta)
% isPrimalInfeasibleCertificateLocal
%
% Primal infeasibility certificate statuses.

solsta = char(string(solsta));

tf = any(strcmp(solsta, { ...
    'PRIMAL_INFEASIBLE_CER', ...
    'PRIM_INFEAS_CER', ...
    'MSK_SOL_STA_PRIM_INFEAS_CER', ...
    'MSK_SOL_STA_NEAR_PRIM_INFEAS_CER'}));

end


function tf = isDualInfeasibleCertificateLocal(solsta)
% isDualInfeasibleCertificateLocal
%
% Dual infeasibility certificate statuses.

solsta = char(string(solsta));

tf = any(strcmp(solsta, { ...
    'DUAL_INFEASIBLE_CER', ...
    'DUAL_INFEAS_CER', ...
    'MSK_SOL_STA_DUAL_INFEAS_CER', ...
    'MSK_SOL_STA_NEAR_DUAL_INFEAS_CER'}));

end


function v = getMosekVectorFieldLocal(sol, fieldName)
% getMosekVectorFieldLocal
%
% Return a dense column vector if the field exists. Return [] otherwise.

v = [];

if ~isfield(sol, fieldName) || isempty(sol.(fieldName))
    return
end

v = sol.(fieldName);

if issparse(v)
    v = full(v);
end

v = double(v(:));

end


function a = getMosekScalarFieldLocal(sol, fieldName)
% getMosekScalarFieldLocal
%
% Return a scalar field if it exists. Return [] otherwise.

a = [];

if ~isfield(sol, fieldName) || isempty(sol.(fieldName))
    return
end

a = sol.(fieldName);

if isnumeric(a) && isscalar(a)
    a = double(a);
else
    a = [];
end

end