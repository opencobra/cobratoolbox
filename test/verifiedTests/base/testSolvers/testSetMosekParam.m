% The COBRAToolbox: testSetMosekParam.m
%
% Purpose:
%     - setMosekParam turns COBRA / solveSCLP style solver parameters into the MOSEK command
%     string and the structure of MSK_* parameters passed to mosekopt, for the profiles
%     'default', 'manual', the four 'cobra*' profiles and the 'SCLP_*' profiles, applying the
%     print policy and the problem-type optimizer choice.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test. MOSEK itself is not needed: the function
%       only builds structures.
%
% Function under test:
%     src/base/solvers/mosek/setMosekParam.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Lines 620-621, the error for an unsupported SCLP profile inside applySCLPMosekPortfolio:
%     that local function is only called with one of the four ordinary SCLP profile names, so
%     the error cannot be triggered through setMosekParam.
%     Line 547, the free solve form of the strict block, which is never reached (see the
%     first defect below).
%     Line 775, the early return of localMosekParamStrip for a non-structure input: the
%     function is only called with a structure.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The strict option never switches MOSEK to a free solve form
%       SEVERITY: wrong-result
%       TRIGGER: param.strict non-empty with a cobra profile
%       OBSERVED: the interior-point solve form is already set to MSK_SOLVE_PRIMAL earlier in
%         the same profile, so the test for an absent solve form in the strict block is never
%         true and MSK_SOLVE_FREE is never set
%       EXPECTED: a strict solve uses MSK_SOLVE_FREE, as the header of the function states
%       LINES: 541-549
%     - DEFECT: The SCLP profiles fail when feasTol or numTol is not supplied
%       SEVERITY: error
%       TRIGGER: param.mosekParam set to an SCLP_* profile (other than SCLP_default) without
%         param.feasTol or without param.numTol
%       OBSERVED: the missing field is read directly, which raises an error
%         (Unrecognized field name "feasTol" or "numTol"), although the header states that all fields are optional
%       EXPECTED: documented defaults used for the absent tolerances
%       LINES: 596-601, 640-644
%
% Authors:
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSetMosekParam'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% relative tolerance for floating-point comparisons
tol = 1e-12;

% silent print level of the function: param.printLevel is reduced by one, so printLevel 0
% and 1 are silent, 2 uses MOSEK default printing and 3 keeps the profile log fields
LOUD = 3;

%% default arguments: the cobra profile with the silent print policy

[cmd, p] = setMosekParam();
assert(strcmp(cmd, 'minimize echo(0)'));
% the output holds MSK_* fields only
assert(all(strncmp(fieldnames(p), 'MSK_', 4)));
% tolerances: feasibility tolerance 1e-8 for primal, dual and gap, 1e-10 for mu
assertValue(p, 'MSK_DPAR_INTPNT_TOL_PFEAS', 1e-8, tol);
assertValue(p, 'MSK_DPAR_INTPNT_QO_TOL_PFEAS', 1e-8, tol);
assertValue(p, 'MSK_DPAR_INTPNT_CO_TOL_PFEAS', 1e-8, tol);
assertValue(p, 'MSK_DPAR_INTPNT_TOL_DFEAS', 1e-8, tol);
assertValue(p, 'MSK_DPAR_INTPNT_QO_TOL_DFEAS', 1e-8, tol);
assertValue(p, 'MSK_DPAR_INTPNT_CO_TOL_DFEAS', 1e-8, tol);
assertValue(p, 'MSK_DPAR_INTPNT_CO_TOL_REL_GAP', 1e-8, tol);
assertValue(p, 'MSK_DPAR_INTPNT_CO_TOL_MU_RED', 1e-10, tol);
assertValue(p, 'MSK_IPAR_INTPNT_SOLVE_FORM', 'MSK_SOLVE_PRIMAL', tol);
assertValue(p, 'MSK_IPAR_PRESOLVE_USE', 'MSK_PRESOLVE_MODE_FREE', tol);
assertValue(p, 'MSK_DPAR_PRESOLVE_TOL_PRIMAL_INFEAS_PERTURBATION', 0, tol);
% numerical tolerance default 1e-12: presolve tolerances 100 times larger, data tolerance equal
assertValue(p, 'MSK_DPAR_PRESOLVE_TOL_X', 1e-10, tol);
assertValue(p, 'MSK_DPAR_PRESOLVE_TOL_S', 1e-10, tol);
assertValue(p, 'MSK_DPAR_DATA_TOL_X', 1e-12, tol);
assertValue(p, 'MSK_DPAR_INTPNT_CO_TOL_NEAR_REL', 1, tol);
% the default problem type is CLP, which switches regularisation on
assertValue(p, 'MSK_IPAR_INTPNT_REGULARIZATION_USE', 'MSK_ON', tol);
% silent print policy
for name = {'MSK_IPAR_LOG', 'MSK_IPAR_LOG_INTPNT', 'MSK_IPAR_LOG_SIM', 'MSK_IPAR_LOG_PRESOLVE', 'MSK_IPAR_LOG_FEAS_REPAIR'}
    assertValue(p, name{1}, 0, tol);
end
assertValue(p, 'MSK_IPAR_INFEAS_REPORT_AUTO', 'MSK_OFF', tol);
% nothing else is returned
assert(numel(fieldnames(p)) == 22);

% an empty input is the same as no input
[cmd2, p2] = setMosekParam([]);
assert(strcmp(cmd2, cmd) && isequal(p2, p));
[~, p3] = setMosekParam(struct());
assert(isequal(p3, p));

%% print level decides the command string and the log fields

% printLevel 0 and 1 give silence
[cmd, p] = setMosekParam(struct('printLevel', 0));
assert(strcmp(cmd, 'minimize echo(0)') && p.MSK_IPAR_LOG == 0);
[cmd, p] = setMosekParam(struct('printLevel', 1));
assert(strcmp(cmd, 'minimize echo(0)') && p.MSK_IPAR_LOG == 0);

% printLevel 2: MOSEK default printing, so explicit log fields are removed
[cmd, p] = setMosekParam(struct('printLevel', 2, 'mosekParam', 'cobraVerbose', 'debug', 1, 'repairInfeasibility', 1));
assert(strcmp(cmd, 'minimize'));
for name = {'MSK_IPAR_LOG', 'MSK_IPAR_LOG_INTPNT', 'MSK_IPAR_LOG_SIM', 'MSK_IPAR_LOG_PRESOLVE', ...
            'MSK_IPAR_LOG_FEAS_REPAIR', 'MSK_IPAR_INFEAS_REPORT_AUTO', 'MSK_IPAR_INFEAS_REPORT_LEVEL'}
    assert(~isfield(p, name{1}), name{1});
end

% printLevel 3 and above keeps the verbose log fields of the profile
[cmd, p] = setMosekParam(struct('printLevel', LOUD, 'mosekParam', 'cobraVerbose'));
assert(strcmp(cmd, 'minimize'));
assertValue(p, 'MSK_IPAR_LOG', 10, tol);
assertValue(p, 'MSK_IPAR_LOG_INTPNT', 10, tol);
assertValue(p, 'MSK_IPAR_LOG_SIM', 10, tol);
assertValue(p, 'MSK_IPAR_LOG_PRESOLVE', 10, tol);
assertValue(p, 'MSK_IPAR_INFEAS_REPORT_AUTO', 'MSK_ON', tol);
assertValue(p, 'MSK_IPAR_INFEAS_REPORT_LEVEL', 1, tol);

% an empty print level is the default 0
[cmd, ~] = setMosekParam(struct('printLevel', []));
assert(strcmp(cmd, 'minimize echo(0)'));

% silent mode overrides a verbose profile and removes the extra report fields
[cmd, p] = setMosekParam(struct('printLevel', 1, 'mosekParam', 'cobraNoPresolveVerbose'));
assert(strcmp(cmd, 'minimize echo(0)'));
assertValue(p, 'MSK_IPAR_LOG', 0, tol);
assertValue(p, 'MSK_IPAR_INFEAS_REPORT_AUTO', 'MSK_OFF', tol);
assert(~isfield(p, 'MSK_IPAR_INFEAS_REPORT_LEVEL'));

%% profile 'default': every MSK_* field supplied by the caller is dropped

in = struct('mosekParam', 'default', 'MSK_DPAR_INTPNT_TOL_PFEAS', 1e-3, 'MSK_IPAR_LOG', 5, 'feasTol', 1e-4);
[~, p] = setMosekParam(in);
% only the silent policy fields remain
assert(isequal(sort(fieldnames(p)), sort({'MSK_IPAR_LOG'; 'MSK_IPAR_LOG_INTPNT'; 'MSK_IPAR_LOG_SIM'; ...
    'MSK_IPAR_LOG_PRESOLVE'; 'MSK_IPAR_LOG_FEAS_REPAIR'; 'MSK_IPAR_INFEAS_REPORT_AUTO'})));
assert(p.MSK_IPAR_LOG == 0);
% with MOSEK default printing nothing at all is passed
in.printLevel = 2;
[cmd, p] = setMosekParam(in);
assert(strcmp(cmd, 'minimize') && isempty(fieldnames(p)));
% also with the profile log fields allowed
in.printLevel = LOUD;
[~, p] = setMosekParam(in);
assert(isempty(fieldnames(p)));

%% profile 'manual': caller MSK_* fields are kept, non-MSK fields are dropped, empty ones removed

in = struct('mosekParam', 'manual', 'printLevel', LOUD, 'MSK_DPAR_INTPNT_TOL_PFEAS', 1e-3, ...
            'MSK_IPAR_PRESOLVE_USE', 'MSK_PRESOLVE_MODE_OFF', 'MSK_IPAR_LOG', [], 'feasTol', 1e-4);
[~, p] = setMosekParam(in);
assert(isequal(sort(fieldnames(p)), {'MSK_DPAR_INTPNT_TOL_PFEAS'; 'MSK_IPAR_PRESOLVE_USE'}));
assert(p.MSK_DPAR_INTPNT_TOL_PFEAS == 1e-3);
assert(strcmp(p.MSK_IPAR_PRESOLVE_USE, 'MSK_PRESOLVE_MODE_OFF'));

%% profile name handling

% a string, with surrounding blanks
[~, p] = setMosekParam(struct('mosekParam', "  manual  ", 'printLevel', LOUD, 'MSK_IPAR_LOG', 4));
assert(isequal(p, struct('MSK_IPAR_LOG', 4)));
% empty or blank names fall back to the cobra profile
[~, pa] = setMosekParam(struct('mosekParam', ''));
[~, pb] = setMosekParam(struct('mosekParam', '   '));
[~, pc] = setMosekParam(struct());
assert(isequal(pa, pc) && isequal(pb, pc));
% an unknown profile is an error that names the profile
try
    setMosekParam(struct('mosekParam', 'notAProfile'));
    error('expected setMosekParam to fail for an unknown profile');
catch err
    assert(strcmp(err.identifier, 'setMosekParam:badProfile'));
    assert(contains(err.message, 'notAProfile'));
end

%% cobra profiles: tolerances

% mosekInnerTol overrides the primal and dual tolerances, and sets mu to 1e-2 of it
[~, p] = setMosekParam(struct('mosekInnerTol', 1e-6, 'feasTol', 1e-3, 'optTol', 1e-4));
assertValue(p, 'MSK_DPAR_INTPNT_TOL_PFEAS', 1e-6, tol);
assertValue(p, 'MSK_DPAR_INTPNT_TOL_DFEAS', 1e-6, tol);
assertValue(p, 'MSK_DPAR_INTPNT_CO_TOL_REL_GAP', 1e-6, tol);
assertValue(p, 'MSK_DPAR_INTPNT_CO_TOL_MU_RED', 1e-8, tol);

% mosekInnerMuTol overrides the mu tolerance
[~, p] = setMosekParam(struct('mosekInnerTol', 1e-6, 'mosekInnerMuTol', 1e-9));
assertValue(p, 'MSK_DPAR_INTPNT_CO_TOL_MU_RED', 1e-9, tol);

% without mosekInnerTol the feasibility and optimality tolerances are used
[~, p] = setMosekParam(struct('feasTol', 1e-5, 'optTol', 1e-7));
assertValue(p, 'MSK_DPAR_INTPNT_TOL_PFEAS', 1e-5, tol);
assertValue(p, 'MSK_DPAR_INTPNT_TOL_DFEAS', 1e-7, tol);
assertValue(p, 'MSK_DPAR_INTPNT_CO_TOL_MU_RED', 1e-7, tol);
% optTol absent: the dual tolerance follows the primal one
[~, p] = setMosekParam(struct('feasTol', 1e-5));
assertValue(p, 'MSK_DPAR_INTPNT_TOL_DFEAS', 1e-5, tol);

% values that are not finite scalars fall back to the defaults
[~, p] = setMosekParam(struct('mosekInnerTol', Inf, 'mosekInnerMuTol', NaN));
assertValue(p, 'MSK_DPAR_INTPNT_TOL_PFEAS', 1e-8, tol);
assertValue(p, 'MSK_DPAR_INTPNT_CO_TOL_MU_RED', 1e-10, tol);
[~, p] = setMosekParam(struct('feasTol', 'text'));
assertValue(p, 'MSK_DPAR_INTPNT_TOL_PFEAS', 1e-8, tol);
% a vector uses its first element, a logical is converted
[~, p] = setMosekParam(struct('feasTol', [1e-4 1e-9]));
assertValue(p, 'MSK_DPAR_INTPNT_TOL_PFEAS', 1e-4, tol);
[~, p] = setMosekParam(struct('feasTol', true));
assertValue(p, 'MSK_DPAR_INTPNT_TOL_PFEAS', 1, tol);

% MSK_* values supplied by the caller are never overridden
in = struct('feasTol', 1e-3, 'MSK_DPAR_INTPNT_TOL_PFEAS', 5, 'MSK_DPAR_INTPNT_QO_TOL_PFEAS', 6, ...
            'MSK_DPAR_INTPNT_CO_TOL_PFEAS', 7, 'MSK_DPAR_INTPNT_TOL_DFEAS', 8, ...
            'MSK_DPAR_INTPNT_QO_TOL_DFEAS', 9, 'MSK_DPAR_INTPNT_CO_TOL_DFEAS', 10, ...
            'MSK_DPAR_INTPNT_CO_TOL_REL_GAP', 11, 'MSK_DPAR_INTPNT_CO_TOL_MU_RED', 12, ...
            'MSK_IPAR_INTPNT_SOLVE_FORM', 'MSK_SOLVE_DUAL', 'MSK_IPAR_PRESOLVE_USE', 'MSK_PRESOLVE_MODE_ON', ...
            'MSK_DPAR_PRESOLVE_TOL_PRIMAL_INFEAS_PERTURBATION', 13, 'MSK_DPAR_PRESOLVE_TOL_X', 14, ...
            'MSK_DPAR_PRESOLVE_TOL_S', 15, 'MSK_DPAR_DATA_TOL_X', 16, 'MSK_DPAR_INTPNT_CO_TOL_NEAR_REL', 17);
[~, p] = setMosekParam(in);
values = [5 6 7 8 9 10 11 12];
names = {'INTPNT_TOL_PFEAS', 'INTPNT_QO_TOL_PFEAS', 'INTPNT_CO_TOL_PFEAS', 'INTPNT_TOL_DFEAS', ...
         'INTPNT_QO_TOL_DFEAS', 'INTPNT_CO_TOL_DFEAS', 'INTPNT_CO_TOL_REL_GAP', 'INTPNT_CO_TOL_MU_RED'};
for i = 1:numel(names)
    assertValue(p, ['MSK_DPAR_' names{i}], values(i), tol);
end
assertValue(p, 'MSK_IPAR_INTPNT_SOLVE_FORM', 'MSK_SOLVE_DUAL', tol);
assertValue(p, 'MSK_IPAR_PRESOLVE_USE', 'MSK_PRESOLVE_MODE_ON', tol);
assertValue(p, 'MSK_DPAR_PRESOLVE_TOL_PRIMAL_INFEAS_PERTURBATION', 13, tol);
assertValue(p, 'MSK_DPAR_PRESOLVE_TOL_X', 14, tol);
assertValue(p, 'MSK_DPAR_PRESOLVE_TOL_S', 15, tol);
assertValue(p, 'MSK_DPAR_DATA_TOL_X', 16, tol);
assertValue(p, 'MSK_DPAR_INTPNT_CO_TOL_NEAR_REL', 17, tol);

%% cobra profiles: solve form, presolve and data tolerances

in = struct('mosekSolveForm', 'MSK_SOLVE_DUAL', 'mosekPresolveUse', 'MSK_PRESOLVE_MODE_ON', ...
            'mosekPrimalInfeasPerturbationTol', 1e-7, 'mosekPresolveTolX', 2e-9, ...
            'mosekPresolveTolS', 3e-9, 'mosekDataTolX', 4e-9, 'mosekNearRel', 5);
[~, p] = setMosekParam(in);
assertValue(p, 'MSK_IPAR_INTPNT_SOLVE_FORM', 'MSK_SOLVE_DUAL', tol);
assertValue(p, 'MSK_IPAR_PRESOLVE_USE', 'MSK_PRESOLVE_MODE_ON', tol);
assertValue(p, 'MSK_DPAR_PRESOLVE_TOL_PRIMAL_INFEAS_PERTURBATION', 1e-7, tol);
assertValue(p, 'MSK_DPAR_PRESOLVE_TOL_X', 2e-9, tol);
assertValue(p, 'MSK_DPAR_PRESOLVE_TOL_S', 3e-9, tol);
assertValue(p, 'MSK_DPAR_DATA_TOL_X', 4e-9, tol);
assertValue(p, 'MSK_DPAR_INTPNT_CO_TOL_NEAR_REL', 5, tol);

% numTol scales the presolve (times 100) and data (times 1) tolerances
[~, p] = setMosekParam(struct('numTol', 1e-9));
assertValue(p, 'MSK_DPAR_PRESOLVE_TOL_X', 1e-7, tol);
assertValue(p, 'MSK_DPAR_PRESOLVE_TOL_S', 1e-7, tol);
assertValue(p, 'MSK_DPAR_DATA_TOL_X', 1e-9, tol);

% blank text options fall back to the defaults
[~, p] = setMosekParam(struct('mosekSolveForm', '   ', 'mosekPresolveUse', ''));
assertValue(p, 'MSK_IPAR_INTPNT_SOLVE_FORM', 'MSK_SOLVE_PRIMAL', tol);
assertValue(p, 'MSK_IPAR_PRESOLVE_USE', 'MSK_PRESOLVE_MODE_FREE', tol);

% the no-presolve profiles switch presolve off, even when a presolve option is given
for name = {'cobraNoPresolve', 'cobraNoPresolveVerbose'}
    [~, p] = setMosekParam(struct('mosekParam', name{1}, 'mosekPresolveUse', 'MSK_PRESOLVE_MODE_ON', ...
                                  'MSK_IPAR_PRESOLVE_USE', 'MSK_PRESOLVE_MODE_ON'));
    assertValue(p, 'MSK_IPAR_PRESOLVE_USE', 'MSK_PRESOLVE_MODE_OFF', tol);
end

%% cobra profiles: time limit

[~, p] = setMosekParam(struct('timelimit', 30));
assertValue(p, 'MSK_DPAR_OPTIMIZER_MAX_TIME', 30, tol);
% a caller value wins over the COBRA time limit
[~, p] = setMosekParam(struct('timelimit', 30, 'MSK_DPAR_OPTIMIZER_MAX_TIME', 5));
assertValue(p, 'MSK_DPAR_OPTIMIZER_MAX_TIME', 5, tol);
% an empty time limit is ignored
[~, p] = setMosekParam(struct('timelimit', []));
assert(~isfield(p, 'MSK_DPAR_OPTIMIZER_MAX_TIME'));

%% cobra profiles: historical special cases

% lifted problems switch the eliminator off
[~, p] = setMosekParam(struct('lifted', 1));
assertValue(p, 'MSK_IPAR_PRESOLVE_ELIMINATOR_MAX_NUM_TRIES', 0, tol);
[~, p] = setMosekParam(struct('lifted', 1, 'MSK_IPAR_PRESOLVE_ELIMINATOR_MAX_NUM_TRIES', 9));
assertValue(p, 'MSK_IPAR_PRESOLVE_ELIMINATOR_MAX_NUM_TRIES', 9, tol);
[~, p] = setMosekParam(struct('lifted', 0));
assert(~isfield(p, 'MSK_IPAR_PRESOLVE_ELIMINATOR_MAX_NUM_TRIES'));

% multiscale problems turn MOSEK's own scaling off, unless the problem is lifted
[~, p] = setMosekParam(struct('multiscale', 1));
assertValue(p, 'MSK_IPAR_PRESOLVE_LINDEP_NEW', 'MSK_OFF', tol);
assertValue(p, 'MSK_IPAR_INTPNT_SCALING', 'MSK_SCALING_NONE', tol);
assertValue(p, 'MSK_IPAR_SIM_SCALING', 'MSK_SCALING_NONE', tol);
[~, p] = setMosekParam(struct('multiscale', 1, 'lifted', 0));
assertValue(p, 'MSK_IPAR_INTPNT_SCALING', 'MSK_SCALING_NONE', tol);
[~, p] = setMosekParam(struct('multiscale', 1, 'lifted', 1));
assert(~isfield(p, 'MSK_IPAR_INTPNT_SCALING') && ~isfield(p, 'MSK_IPAR_SIM_SCALING'));
% caller values are kept
[~, p] = setMosekParam(struct('multiscale', 1, 'MSK_IPAR_PRESOLVE_LINDEP_NEW', 'MSK_ON', ...
                              'MSK_IPAR_INTPNT_SCALING', 'MSK_SCALING_FREE', 'MSK_IPAR_SIM_SCALING', 'MSK_SCALING_FREE'));
assertValue(p, 'MSK_IPAR_PRESOLVE_LINDEP_NEW', 'MSK_ON', tol);
assertValue(p, 'MSK_IPAR_INTPNT_SCALING', 'MSK_SCALING_FREE', tol);
assertValue(p, 'MSK_IPAR_SIM_SCALING', 'MSK_SCALING_FREE', tol);

% debug asks for infeasibility reports (visible when the log fields are kept)
[~, p] = setMosekParam(struct('debug', 1, 'printLevel', LOUD));
assertValue(p, 'MSK_IPAR_INFEAS_REPORT_AUTO', 'MSK_ON', tol);
% but silent mode wins
[~, p] = setMosekParam(struct('debug', 1));
assertValue(p, 'MSK_IPAR_INFEAS_REPORT_AUTO', 'MSK_OFF', tol);

% strict solves: infeasibility tolerance and basis identification limit
[~, p] = setMosekParam(struct('strict', 1));
assertValue(p, 'MSK_IPAR_BI_IGNORE_MAX_ITER', 'MSK_OFF', tol);
assertValue(p, 'MSK_DPAR_INTPNT_TOL_INFEAS', 1e-8, tol);
[~, p] = setMosekParam(struct('strict', 1, 'MSK_IPAR_BI_IGNORE_MAX_ITER', 'MSK_ON', 'MSK_DPAR_INTPNT_TOL_INFEAS', 1e-3));
assertValue(p, 'MSK_IPAR_BI_IGNORE_MAX_ITER', 'MSK_ON', tol);
assertValue(p, 'MSK_DPAR_INTPNT_TOL_INFEAS', 1e-3, tol);
% an empty strict option is ignored
[~, p] = setMosekParam(struct('strict', []));
assert(~isfield(p, 'MSK_IPAR_BI_IGNORE_MAX_ITER'));

% feasibility repair logging is copied from repairInfeasibility
[~, p] = setMosekParam(struct('repairInfeasibility', 2, 'printLevel', LOUD));
assertValue(p, 'MSK_IPAR_LOG_FEAS_REPAIR', 2, tol);
[~, p] = setMosekParam(struct('repairInfeasibility', 2, 'printLevel', LOUD, 'MSK_IPAR_LOG_FEAS_REPAIR', 4));
assertValue(p, 'MSK_IPAR_LOG_FEAS_REPAIR', 4, tol);
[~, p] = setMosekParam(struct('repairInfeasibility', [], 'printLevel', LOUD));
assert(~isfield(p, 'MSK_IPAR_LOG_FEAS_REPAIR'));

%% optimizer choice by problem type

% LP uses lpmethod and no regularisation field is added
[~, p] = setMosekParam(struct('problemType', 'LP', 'lpmethod', 'INTPNT'));
assertValue(p, 'MSK_IPAR_OPTIMIZER', 'MSK_OPTIMIZER_INTPNT', tol);
assert(~isfield(p, 'MSK_IPAR_INTPNT_REGULARIZATION_USE'));
% names that already carry the prefix are kept, blanks are trimmed, lower case problem types work
[~, p] = setMosekParam(struct('problemType', 'lp', 'lpmethod', ' MSK_OPTIMIZER_FREE_SIMPLEX '));
assertValue(p, 'MSK_IPAR_OPTIMIZER', 'MSK_OPTIMIZER_FREE_SIMPLEX', tol);
% a blank method falls back to the interior-point optimizer
[~, p] = setMosekParam(struct('problemType', 'LP', 'lpmethod', '   '));
assertValue(p, 'MSK_IPAR_OPTIMIZER', 'MSK_OPTIMIZER_INTPNT', tol);
% a string is accepted
[~, p] = setMosekParam(struct('problemType', 'LP', 'lpmethod', "PRIMAL_SIMPLEX"));
assertValue(p, 'MSK_IPAR_OPTIMIZER', 'MSK_OPTIMIZER_PRIMAL_SIMPLEX', tol);
% no method, no optimizer field
[~, p] = setMosekParam(struct('problemType', 'LP'));
assert(~isfield(p, 'MSK_IPAR_OPTIMIZER'));

% QP uses qpmethod
[~, p] = setMosekParam(struct('problemType', 'QP', 'qpmethod', 'CONIC', 'lpmethod', 'INTPNT'));
assertValue(p, 'MSK_IPAR_OPTIMIZER', 'MSK_OPTIMIZER_CONIC', tol);
[~, p] = setMosekParam(struct('problemType', 'QP'));
assert(~isfield(p, 'MSK_IPAR_OPTIMIZER'));

% CLP uses clpmethod and switches regularisation on unless supplied
[~, p] = setMosekParam(struct('problemType', 'CLP', 'clpmethod', 'INTPNT'));
assertValue(p, 'MSK_IPAR_OPTIMIZER', 'MSK_OPTIMIZER_INTPNT', tol);
assertValue(p, 'MSK_IPAR_INTPNT_REGULARIZATION_USE', 'MSK_ON', tol);
[~, p] = setMosekParam(struct('MSK_IPAR_INTPNT_REGULARIZATION_USE', 'MSK_OFF'));
assertValue(p, 'MSK_IPAR_INTPNT_REGULARIZATION_USE', 'MSK_OFF', tol);

% EP uses epmethod, regularisation and a 400 iteration limit unless supplied
[~, p] = setMosekParam(struct('problemType', 'EP', 'epmethod', 'FREE'));
assertValue(p, 'MSK_IPAR_OPTIMIZER', 'MSK_OPTIMIZER_FREE', tol);
assertValue(p, 'MSK_IPAR_INTPNT_REGULARIZATION_USE', 'MSK_ON', tol);
assertValue(p, 'MSK_IPAR_INTPNT_MAX_ITERATIONS', 400, tol);
[~, p] = setMosekParam(struct('problemType', 'EP', 'MSK_IPAR_INTPNT_MAX_ITERATIONS', 50, ...
                              'MSK_IPAR_INTPNT_REGULARIZATION_USE', 'MSK_OFF'));
assertValue(p, 'MSK_IPAR_INTPNT_MAX_ITERATIONS', 50, tol);
assertValue(p, 'MSK_IPAR_INTPNT_REGULARIZATION_USE', 'MSK_OFF', tol);
assert(~isfield(p, 'MSK_IPAR_OPTIMIZER'));

% VK and unrecognised problem types add nothing
for type = {'VK', 'NOTATYPE'}
    [~, p] = setMosekParam(struct('problemType', type{1}, 'lpmethod', 'INTPNT'));
    assert(~isfield(p, 'MSK_IPAR_OPTIMIZER') && ~isfield(p, 'MSK_IPAR_INTPNT_REGULARIZATION_USE'));
end
% an empty problem type is the default CLP
[~, p] = setMosekParam(struct('problemType', []));
assertValue(p, 'MSK_IPAR_INTPNT_REGULARIZATION_USE', 'MSK_ON', tol);

%% SCLP profiles: ordinary profiles with feasibility and numerical tolerances 1e-6 and 1e-9

base = struct('feasTol', 1e-6, 'numTol', 1e-9);

% inner tolerance max(1e-3 * 1e-6, 10 * 1e-9) = 1e-8, mu tolerance max(1e-5 * 1e-6, 1e-9) = 1e-9
in = base;
in.mosekParam = 'SCLP_normalPresolve';
[cmd, p] = setMosekParam(in);
assert(strcmp(cmd, 'minimize echo(0)'));
assertValue(p, 'MSK_IPAR_INTPNT_SOLVE_FORM', 'MSK_SOLVE_PRIMAL', tol);
assertValue(p, 'MSK_DPAR_INTPNT_CO_TOL_PFEAS', 1e-8, tol);
assertValue(p, 'MSK_DPAR_INTPNT_CO_TOL_DFEAS', 1e-8, tol);
assertValue(p, 'MSK_DPAR_INTPNT_CO_TOL_REL_GAP', 1e-8, tol);
assertValue(p, 'MSK_DPAR_INTPNT_CO_TOL_MU_RED', 1e-9, tol);
assertValue(p, 'MSK_IPAR_PRESOLVE_USE', 'MSK_PRESOLVE_MODE_FREE', tol);
assertValue(p, 'MSK_DPAR_PRESOLVE_TOL_PRIMAL_INFEAS_PERTURBATION', 0, tol);
assertValue(p, 'MSK_DPAR_PRESOLVE_TOL_X', 1e-7, tol);
assertValue(p, 'MSK_DPAR_PRESOLVE_TOL_S', 1e-7, tol);
assertValue(p, 'MSK_DPAR_DATA_TOL_X', 1e-9, tol);
assertValue(p, 'MSK_DPAR_INTPNT_CO_TOL_NEAR_REL', 1, tol);
% the default time limit is 600 seconds and regularisation is on
assertValue(p, 'MSK_DPAR_OPTIMIZER_MAX_TIME', 600, tol);
assertValue(p, 'MSK_IPAR_INTPNT_REGULARIZATION_USE', 'MSK_ON', tol);
% no QO or non-conic tolerances are set by the SCLP profiles
assert(~isfield(p, 'MSK_DPAR_INTPNT_TOL_PFEAS') && ~isfield(p, 'MSK_DPAR_INTPNT_QO_TOL_PFEAS'));

% no-presolve profile
in.mosekParam = 'SCLP_noPresolve';
[~, p] = setMosekParam(in);
assertValue(p, 'MSK_IPAR_PRESOLVE_USE', 'MSK_PRESOLVE_MODE_OFF', tol);
assertValue(p, 'MSK_DPAR_INTPNT_CO_TOL_PFEAS', 1e-8, tol);

% verbose profiles keep the log fields at a high print level and drop them at print level 1
for name = {'SCLP_verbose', 'SCLP_noPresolveVerbose'}
    in.mosekParam = name{1};
    in.printLevel = LOUD;
    [cmd, p] = setMosekParam(in);
    assert(strcmp(cmd, 'minimize'));
    assertValue(p, 'MSK_IPAR_LOG', 10, tol);
    assertValue(p, 'MSK_IPAR_LOG_INTPNT', 10, tol);
    assertValue(p, 'MSK_IPAR_LOG_SIM', 10, tol);
    assertValue(p, 'MSK_IPAR_LOG_PRESOLVE', 10, tol);
    in.printLevel = 2;
    [~, p] = setMosekParam(in);
    assert(~isfield(p, 'MSK_IPAR_LOG'));
end
in.mosekParam = 'SCLP_verbose';
[~, p] = setMosekParam(rmfield(in, 'printLevel'));
assertValue(p, 'MSK_IPAR_LOG', 0, tol);
[~, p] = setMosekParam(setfield(in, 'mosekParam', 'SCLP_noPresolveVerbose')); %#ok<SFLD>
assertValue(p, 'MSK_IPAR_PRESOLVE_USE', 'MSK_PRESOLVE_MODE_OFF', tol);

% the tight start profiles inherit the ordinary profile and tighten the accuracy
in = base;
in.mosekParam = 'SCLP_startTight';
[~, p] = setMosekParam(in);
for name = {'MSK_DPAR_INTPNT_CO_TOL_PFEAS', 'MSK_DPAR_INTPNT_CO_TOL_DFEAS', ...
            'MSK_DPAR_INTPNT_CO_TOL_REL_GAP', 'MSK_DPAR_INTPNT_CO_TOL_MU_RED'}
    assertValue(p, name{1}, 1e-10, tol);
end
assertValue(p, 'MSK_DPAR_INTPNT_CO_TOL_NEAR_REL', 10, tol);
assertValue(p, 'MSK_IPAR_INTPNT_MAX_ITERATIONS', 200, tol);
assertValue(p, 'MSK_IPAR_PRESOLVE_USE', 'MSK_PRESOLVE_MODE_FREE', tol);
% inherited fields
assertValue(p, 'MSK_DPAR_OPTIMIZER_MAX_TIME', 600, tol);
assertValue(p, 'MSK_DPAR_PRESOLVE_TOL_X', 1e-7, tol);

in.mosekParam = 'SCLP_startTightNoPresolve';
[~, p] = setMosekParam(in);
assertValue(p, 'MSK_DPAR_INTPNT_CO_TOL_PFEAS', 1e-10, tol);
assertValue(p, 'MSK_DPAR_INTPNT_CO_TOL_NEAR_REL', 10, tol);
assertValue(p, 'MSK_IPAR_INTPNT_MAX_ITERATIONS', 200, tol);
assertValue(p, 'MSK_IPAR_PRESOLVE_USE', 'MSK_PRESOLVE_MODE_OFF', tol);

% the default SCLP profile passes no tolerance or presolve fields, only the print policy
in = base;
in.mosekParam = 'SCLP_default';
in.MSK_DPAR_INTPNT_CO_TOL_PFEAS = 1;
[~, p] = setMosekParam(in);
assert(~isfield(p, 'MSK_DPAR_INTPNT_CO_TOL_PFEAS') && ~isfield(p, 'MSK_IPAR_PRESOLVE_USE'));
assert(p.MSK_IPAR_LOG == 0);

%% SCLP profiles: factors, time limit and caller values

in = struct('mosekParam', 'SCLP_normalPresolve', 'feasTol', 1e-6, 'numTol', 1e-9, 'timelimit', 42, ...
            'innerMosekTolFactor', 1, 'innerMosekTolFloorFactor', 1, ...
            'innerMosekMuTolFactor', 1, 'innerMosekMuTolFloorFactor', 1, ...
            'mosekPresolveTolXFactor', 2, 'mosekPresolveTolSFactor', 3, 'mosekDataTolXFactor', 4);
[~, p] = setMosekParam(in);
% inner tolerance max(1 * 1e-6, 1 * 1e-9) = 1e-6, the same for mu
assertValue(p, 'MSK_DPAR_INTPNT_CO_TOL_PFEAS', 1e-6, tol);
assertValue(p, 'MSK_DPAR_INTPNT_CO_TOL_MU_RED', 1e-6, tol);
assertValue(p, 'MSK_DPAR_PRESOLVE_TOL_X', 2e-9, tol);
assertValue(p, 'MSK_DPAR_PRESOLVE_TOL_S', 3e-9, tol);
assertValue(p, 'MSK_DPAR_DATA_TOL_X', 4e-9, tol);
assertValue(p, 'MSK_DPAR_OPTIMIZER_MAX_TIME', 42, tol);

% empty factors and time limit fall back to their defaults
in = struct('mosekParam', 'SCLP_normalPresolve', 'feasTol', 1e-6, 'numTol', 1e-9, 'timelimit', [], ...
            'innerMosekTolFactor', [], 'innerMosekTolFloorFactor', [], 'innerMosekMuTolFactor', [], ...
            'innerMosekMuTolFloorFactor', [], 'mosekPresolveTolXFactor', [], ...
            'mosekPresolveTolSFactor', [], 'mosekDataTolXFactor', []);
[~, p] = setMosekParam(in);
assertValue(p, 'MSK_DPAR_INTPNT_CO_TOL_PFEAS', 1e-8, tol);
assertValue(p, 'MSK_DPAR_INTPNT_CO_TOL_MU_RED', 1e-9, tol);
assertValue(p, 'MSK_DPAR_PRESOLVE_TOL_X', 1e-7, tol);
assertValue(p, 'MSK_DPAR_OPTIMIZER_MAX_TIME', 600, tol);

% caller MSK_* values for the time limit and regularisation are kept
in = struct('mosekParam', 'SCLP_normalPresolve', 'feasTol', 1e-6, 'numTol', 1e-9, ...
            'MSK_DPAR_OPTIMIZER_MAX_TIME', 7, 'MSK_IPAR_INTPNT_REGULARIZATION_USE', 'MSK_OFF');
[~, p] = setMosekParam(in);
assertValue(p, 'MSK_DPAR_OPTIMIZER_MAX_TIME', 7, tol);
assertValue(p, 'MSK_IPAR_INTPNT_REGULARIZATION_USE', 'MSK_OFF', tol);

% the problem type optimizer choice also applies to the SCLP profiles
in = struct('mosekParam', 'SCLP_normalPresolve', 'feasTol', 1e-6, 'numTol', 1e-9, ...
            'problemType', 'CLP', 'clpmethod', 'INTPNT');
[~, p] = setMosekParam(in);
assertValue(p, 'MSK_IPAR_OPTIMIZER', 'MSK_OPTIMIZER_INTPNT', tol);

% change the directory
cd(currentDir)


function assertValue(s, name, expected, tol)
% Assert that the structure s has the field name equal to expected (text exactly, numbers
% within a relative tolerance).
assert(isfield(s, name), 'missing field %s', name);
if ischar(expected)
    assert(ischar(s.(name)) && strcmp(s.(name), expected), 'field %s', name);
else
    assert(isnumeric(s.(name)) && isscalar(s.(name)), 'field %s', name);
    assert(abs(s.(name) - expected) <= tol * abs(expected), 'field %s', name);
end
end
