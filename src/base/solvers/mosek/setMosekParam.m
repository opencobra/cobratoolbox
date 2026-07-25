function [cmd, mosekParam] = setMosekParam(param)
% Single-file source of truth for MOSEK parameter materialisation
%
% This function deliberately does not call external helper files to set,
% strip, normalise, or otherwise manipulate MOSEK parameters. All helper
% functions used below are local functions in this same file.
%
% Supported profiles (`param.mosekParam`):
%
%   'default'
%       True MOSEK default profile. No MSK_* parameters are passed except
%       those needed to enforce the requested print policy.
%
%   'manual'
%       Pass caller-supplied MSK_* fields through, after applying the print
%       policy and stripping non-MOSEK fields.
%
%   'cobra'
%   'cobraNoPresolve'
%   'cobraVerbose'
%   'cobraNoPresolveVerbose'
%       Backward-compatible COBRA-style profiles.
%
%   'SCLP_default'
%       True MOSEK default profile for solveSCLP inner solves.
%
%   'SCLP_normalPresolve'
%   'SCLP_noPresolve'
%   'SCLP_verbose'
%   'SCLP_noPresolveVerbose'
%       solveSCLP-specific ordinary conic profiles.
%
%   'SCLP_startTight'
%   'SCLP_startTightNoPresolve'
%       solveSCLP-specific tight profiles for initial centring and
%       centred-start raw repair. These inherit the ordinary SCLP profile
%       first, then override only accuracy-related parameters.
%
% Print policy:
%
%   The line `param.printLevel = param.printLevel - 1;` is intentional. It
%   prevents inner MOSEK solve traces from appearing during ordinary use of
%   solveSCLP inside higher-level algorithms.
%
%   Effective behaviour:
%
%       solveSCLP printLevel = 0  -> MOSEK silent
%       solveSCLP printLevel = 1  -> MOSEK silent
%       solveSCLP printLevel = 2  -> MOSEK default printing
%       solveSCLP printLevel > 2  -> verbose-profile MOSEK logs may print
%
% USAGE:
%
%    [cmd, mosekParam] = setMosekParam(param)
%
% INPUTS:
%    param:         Structure of COBRA/solveSCLP-style solver parameters.
%                   All fields are optional; absent fields fall back to the
%                   defaults noted below. Fields read or written:
%
%                     * .printLevel - COBRA print level (default 0);
%                       reduced by 1 before it drives the MOSEK print policy
%                     * .debug - debug flag (default 0); when 1, requests
%                       MOSEK infeasibility reporting in the `cobra*` profiles
%                     * .problemType - COBRA problem type, e.g. `'LP'`,
%                       `'QP'`, `'CLP'`, `'EP'`, `'VK'` (default `'CLP'`);
%                       selects the optimizer choice below
%                     * .mosekParam - name of the requested profile listed
%                       above (default `'cobra'`)
%                     * .timelimit - COBRA-style solve time limit in
%                       seconds; copied to `.MSK_DPAR_OPTIMIZER_MAX_TIME`
%                       when the latter is not already supplied (SCLP
%                       profiles default it to 600 when absent)
%                     * .mosekInnerTol - overrides the MOSEK primal
%                       interior-point tolerance directly (and the dual
%                       tolerance too, unless `.mosekInnerMuTol` is given)
%                     * .feasTol - COBRA feasibility tolerance, used as the
%                       MOSEK primal tolerance default when
%                       `.mosekInnerTol` is absent (also scales the
%                       solveSCLP inner tolerances)
%                     * .optTol - COBRA optimality tolerance, used as the
%                       MOSEK dual tolerance default when `.mosekInnerTol`
%                       is absent
%                     * .mosekInnerMuTol - overrides the MOSEK
%                       complementarity (mu) tolerance directly
%                     * .mosekSolveForm - overrides the default
%                       `MSK_IPAR_INTPNT_SOLVE_FORM` value
%                       (`'MSK_SOLVE_PRIMAL'`)
%                     * .mosekPresolveUse - overrides the default
%                       `MSK_IPAR_PRESOLVE_USE` value
%                       (`'MSK_PRESOLVE_MODE_FREE'`)
%                     * .mosekPrimalInfeasPerturbationTol - overrides the
%                       default
%                       `MSK_DPAR_PRESOLVE_TOL_PRIMAL_INFEAS_PERTURBATION`
%                       value (0)
%                     * .mosekPresolveTolX - overrides the default
%                       `MSK_DPAR_PRESOLVE_TOL_X` value
%                     * .mosekPresolveTolS - overrides the default
%                       `MSK_DPAR_PRESOLVE_TOL_S` value
%                     * .mosekDataTolX - overrides the default
%                       `MSK_DPAR_DATA_TOL_X` value
%                     * .numTol - COBRA numerical tolerance, the basis
%                       (times 100 or 1) for the presolve/data tolerance
%                       defaults above
%                     * .mosekNearRel - overrides the default
%                       `MSK_DPAR_INTPNT_CO_TOL_NEAR_REL` value (1.0)
%                     * .lifted - when 1, disables the MOSEK eliminator
%                       retry (`MSK_IPAR_PRESOLVE_ELIMINATOR_MAX_NUM_TRIES`
%                       set to 0) unless already supplied
%                     * .multiscale - when 1 and `.lifted` is 0/absent,
%                       turns off MOSEK's own scaling
%                       (`MSK_IPAR_PRESOLVE_LINDEP_NEW`,
%                       `MSK_IPAR_INTPNT_SCALING`, `MSK_IPAR_SIM_SCALING`)
%                       unless already supplied
%                     * .strict - when non-empty, requests a stricter
%                       solve: disables the basis-identification iteration
%                       limit, forces a free solve form, and tightens the
%                       infeasibility tolerance, unless the corresponding
%                       `MSK_*` fields are already supplied
%                     * .repairInfeasibility - when non-empty, copied to
%                       `MSK_IPAR_LOG_FEAS_REPAIR` unless already supplied
%                     * .lpmethod, .qpmethod, .clpmethod, .epmethod -
%                       COBRA solver-method selectors, normalised and
%                       copied to `MSK_IPAR_OPTIMIZER` when `.problemType`
%                       is respectively `'LP'`, `'QP'`, `'CLP'`, or `'EP'`
%                     * .innerMosekTolFactor, .innerMosekTolFloorFactor,
%                       .innerMosekMuTolFactor, .innerMosekMuTolFloorFactor -
%                       factors (defaults `1e-3`, `10`, `1e-5`, `1`) that
%                       scale `.feasTol`/`.numTol` into the solveSCLP inner
%                       interior-point/complementarity tolerances
%                     * .mosekPresolveTolXFactor, .mosekPresolveTolSFactor,
%                       .mosekDataTolXFactor - factors (defaults `100`,
%                       `100`, `1`) that scale `.numTol` into the solveSCLP
%                       presolve and data tolerances
%                     * caller-supplied `MSK_*` fields, honoured as-is
%                       wherever the profile logic above checks for them
%                       first, rather than being overridden:
%                       `.MSK_DPAR_OPTIMIZER_MAX_TIME`,
%                       `.MSK_DPAR_INTPNT_TOL_PFEAS`,
%                       `.MSK_DPAR_INTPNT_QO_TOL_PFEAS`,
%                       `.MSK_DPAR_INTPNT_CO_TOL_PFEAS`,
%                       `.MSK_DPAR_INTPNT_TOL_DFEAS`,
%                       `.MSK_DPAR_INTPNT_QO_TOL_DFEAS`,
%                       `.MSK_DPAR_INTPNT_CO_TOL_DFEAS`,
%                       `.MSK_DPAR_INTPNT_CO_TOL_REL_GAP`,
%                       `.MSK_DPAR_INTPNT_CO_TOL_MU_RED`,
%                       `.MSK_IPAR_INTPNT_SOLVE_FORM`,
%                       `.MSK_IPAR_PRESOLVE_USE`,
%                       `.MSK_DPAR_PRESOLVE_TOL_PRIMAL_INFEAS_PERTURBATION`,
%                       `.MSK_DPAR_PRESOLVE_TOL_X`,
%                       `.MSK_DPAR_PRESOLVE_TOL_S`,
%                       `.MSK_DPAR_DATA_TOL_X`,
%                       `.MSK_DPAR_INTPNT_CO_TOL_NEAR_REL`,
%                       `.MSK_IPAR_PRESOLVE_ELIMINATOR_MAX_NUM_TRIES`,
%                       `.MSK_IPAR_PRESOLVE_LINDEP_NEW`,
%                       `.MSK_IPAR_INTPNT_SCALING`, `.MSK_IPAR_SIM_SCALING`,
%                       `.MSK_IPAR_BI_IGNORE_MAX_ITER`,
%                       `.MSK_DPAR_INTPNT_TOL_INFEAS`,
%                       `.MSK_IPAR_LOG_FEAS_REPAIR`, `.MSK_IPAR_LOG`,
%                       `.MSK_IPAR_LOG_INTPNT`, `.MSK_IPAR_LOG_SIM`,
%                       `.MSK_IPAR_LOG_PRESOLVE`,
%                       `.MSK_IPAR_INFEAS_REPORT_AUTO`,
%                       `.MSK_IPAR_INFEAS_REPORT_LEVEL`,
%                       `.MSK_IPAR_INTPNT_REGULARIZATION_USE`, and
%                       `.MSK_IPAR_OPTIMIZER`;
%                       `.MSK_IPAR_INTPNT_MAX_ITERATIONS` is additionally
%                       set to 400 for the `EP` problem type unless already
%                       supplied
%
% OUTPUTS:
%    cmd:           MOSEK command string, usually `'minimize echo(0)'` or
%                   `'minimize'`
%    mosekParam:    Structure containing only `MSK_*` fields, ready to be
%                   passed to `mosekopt`

if nargin < 1 || isempty(param)
    param = struct();
end

% -------------------------------------------------------------------------
% Intentional one-level reduction in MOSEK print level.
%
% This is required because solveSCLP itself prints the outer trace.  The
% inner MOSEK solve should usually be quieter than solveSCLP.
% -------------------------------------------------------------------------
if ~isfield(param, 'printLevel') || isempty(param.printLevel)
    param.printLevel = 0;
else
    param.printLevel = param.printLevel - 1;
end

if ~isfield(param, 'debug') || isempty(param.debug)
    param.debug = 0;
end

if ~isfield(param, 'problemType') || isempty(param.problemType)
    param.problemType = 'CLP';
end

profile = normaliseMosekParamProfile(param);
cmd = buildMosekCommandFromPrintLevel(param.printLevel);

switch profile

    case 'default'
        % True MOSEK default mode.  Remove all caller-created MSK_* fields.
        mosekParam = removeMosekParameterFields(param);

    case 'manual'
        % Manual means: keep caller-supplied MSK_* fields, but do not derive
        % any COBRA or solveSCLP defaults.
        mosekParam = param;

    case {'cobra', ...
          'cobraNoPresolve', ...
          'cobraVerbose', ...
          'cobraNoPresolveVerbose'}

        % Backward-compatible COBRA/MOSEK parameter portfolio.
        mosekParam = applyCobraMosekPortfolio(param, profile);

    case 'SCLP_default'
        % True MOSEK default mode for solveSCLP.
        %
        % This intentionally does not inherit the ordinary SCLP profile.
        % It asks MOSEK to use its own defaults, apart from print-policy
        % fields added later if needed.
        mosekParam = removeMosekParameterFields(param);

    case {'SCLP_normalPresolve', ...
          'SCLP_noPresolve', ...
          'SCLP_verbose', ...
          'SCLP_noPresolveVerbose'}

        % Ordinary solveSCLP conic profiles.
        mosekParam = applySCLPMosekPortfolio(param, profile);

    case 'SCLP_startTight'
        % Tight profile for initial centring and centred-start raw repair.
        %
        % Important:
        %   Start from the ordinary solveSCLP normal-presolve profile.  This
        %   ensures that the tight profile inherits solve form, regularisation,
        %   time limit, presolve/data tolerances, and other SCLP settings.
        %   Then override only the accuracy-related parameters.
        mosekParam = applySCLPMosekPortfolio(param, 'SCLP_normalPresolve');

        mosekParam.MSK_DPAR_INTPNT_CO_TOL_PFEAS    = 1e-10;
        mosekParam.MSK_DPAR_INTPNT_CO_TOL_DFEAS    = 1e-10;
        mosekParam.MSK_DPAR_INTPNT_CO_TOL_REL_GAP  = 1e-10;
        mosekParam.MSK_DPAR_INTPNT_CO_TOL_MU_RED   = 1e-10;
        mosekParam.MSK_DPAR_INTPNT_CO_TOL_NEAR_REL = 10;

        mosekParam.MSK_IPAR_INTPNT_MAX_ITERATIONS = 200;
        mosekParam.MSK_IPAR_PRESOLVE_USE = 'MSK_PRESOLVE_MODE_FREE';

    case 'SCLP_startTightNoPresolve'
        % Tight profile for initial centring and centred-start raw repair,
        % with presolve disabled.
        %
        % Important:
        %   Start from the ordinary solveSCLP no-presolve profile so this
        %   profile inherits the same SCLP defaults as SCLP_noPresolve.
        mosekParam = applySCLPMosekPortfolio(param, 'SCLP_noPresolve');

        mosekParam.MSK_DPAR_INTPNT_CO_TOL_PFEAS    = 1e-10;
        mosekParam.MSK_DPAR_INTPNT_CO_TOL_DFEAS    = 1e-10;
        mosekParam.MSK_DPAR_INTPNT_CO_TOL_REL_GAP  = 1e-10;
        mosekParam.MSK_DPAR_INTPNT_CO_TOL_MU_RED   = 1e-10;
        mosekParam.MSK_DPAR_INTPNT_CO_TOL_NEAR_REL = 10;

        mosekParam.MSK_IPAR_INTPNT_MAX_ITERATIONS = 200;
        mosekParam.MSK_IPAR_PRESOLVE_USE = 'MSK_PRESOLVE_MODE_OFF';

    otherwise
        error('setMosekParam:badProfile', ...
            'Unsupported param.mosekParam profile: %s', profile);
end

% Apply the print policy after the selected profile has materialised its
% ordinary MOSEK parameters.  This is deliberately last so that printLevel
% can override even verbose profiles.
mosekParam = applyMosekPrintPolicy(mosekParam, param.printLevel);

% Return only actual MOSEK parameters.  This local function replaces any
% external mosekParamStrip dependency.
mosekParam = localMosekParamStrip(mosekParam);

end


function profile = normaliseMosekParamProfile(param)
% normaliseMosekParamProfile
%
% Return the requested profile as a scalar character vector.

if ~isfield(param, 'mosekParam') || isempty(param.mosekParam)
    profile = 'cobra';
else
    profile = char(string(param.mosekParam));
end

profile = strtrim(profile);

if isempty(profile)
    profile = 'cobra';
end
end


function cmd = buildMosekCommandFromPrintLevel(printLevel)
% buildMosekCommandFromPrintLevel
%
% Build the MOSEK command string using only the effective MOSEK print level.

if printLevel <= 0
    cmd = 'minimize echo(0)';
else
    cmd = 'minimize';
end
end


function param = applyMosekPrintPolicy(param, printLevel)
% applyMosekPrintPolicy
%
% Enforce the single print policy after a profile has been materialised.
%
%   printLevel <= 0:
%       Force MOSEK silence.
%
%   printLevel == 1:
%       Use MOSEK default printing.  Remove explicit log fields.
%
%   printLevel > 1:
%       Keep profile-specific log fields.

if printLevel <= 0

    % Force MOSEK logging off.  Use both the command echo(0) and explicit
    % log fields to avoid accidental output from verbose profiles.
    param.MSK_IPAR_LOG = 0;
    param.MSK_IPAR_LOG_INTPNT = 0;
    param.MSK_IPAR_LOG_SIM = 0;
    param.MSK_IPAR_LOG_PRESOLVE = 0;
    param.MSK_IPAR_LOG_FEAS_REPAIR = 0;

    % Avoid infeasibility-report printing in silent mode.
    param.MSK_IPAR_INFEAS_REPORT_AUTO = 'MSK_OFF';

    % Remove fields that request extra output, while keeping the explicit
    % silence fields above.
    param = removeFieldsIfPresent(param, { ...
        'MSK_IPAR_INFEAS_REPORT_LEVEL', ...
        'MSK_IPAR_WRITE_DATA_PARAM'});

elseif printLevel == 1

    % Let MOSEK use default printing.  Do not let a profile explicitly
    % increase or suppress logging.
    param = removeFieldsIfPresent(param, { ...
        'MSK_IPAR_LOG', ...
        'MSK_IPAR_LOG_INTPNT', ...
        'MSK_IPAR_LOG_SIM', ...
        'MSK_IPAR_LOG_PRESOLVE', ...
        'MSK_IPAR_LOG_FEAS_REPAIR', ...
        'MSK_IPAR_INFEAS_REPORT_AUTO', ...
        'MSK_IPAR_INFEAS_REPORT_LEVEL', ...
        'MSK_IPAR_WRITE_DATA_PARAM'});

else
    % printLevel > 1:
    % Keep whatever log fields the selected profile materialised.
end
end


function param = applyCobraMosekPortfolio(param, profile)
% applyCobraMosekPortfolio
%
% Backward-compatible COBRA-style MOSEK parameter portfolio.
%
% This local function intentionally uses the same profile names as the
% previous implementation.  It derives MSK_* fields from commonly used COBRA
% and solveSCLP fields, but it does not rely on any external helper files.

% -------------------------------------------------------------------------
% Verbose logging requested by COBRA verbose profiles.
% The final print policy may still remove these fields.
% -------------------------------------------------------------------------
if any(strcmp(profile, {'cobraVerbose', 'cobraNoPresolveVerbose'}))
    param.MSK_IPAR_LOG = 10;
    param.MSK_IPAR_LOG_INTPNT = 10;
    param.MSK_IPAR_LOG_SIM = 10;
    param.MSK_IPAR_LOG_PRESOLVE = 10;
    param.MSK_IPAR_INFEAS_REPORT_AUTO = 'MSK_ON';
    param.MSK_IPAR_INFEAS_REPORT_LEVEL = 1;
end

% -------------------------------------------------------------------------
% Time limit.
% -------------------------------------------------------------------------
if ~isfield(param, 'MSK_DPAR_OPTIMIZER_MAX_TIME') && ...
        isfield(param, 'timelimit') && ~isempty(param.timelimit)
    param.MSK_DPAR_OPTIMIZER_MAX_TIME = param.timelimit;
end

% -------------------------------------------------------------------------
% Generic primal, dual, and barrier tolerances.
% -------------------------------------------------------------------------
if isfield(param, 'mosekInnerTol') && ~isempty(param.mosekInnerTol)
    primalTol = scalarOrDefault(param.mosekInnerTol, 1e-8);
else
    primalTol = getScalarFieldOrDefault(param, 'feasTol', 1e-8);
end

if isfield(param, 'mosekInnerTol') && ~isempty(param.mosekInnerTol)
    dualTol = scalarOrDefault(param.mosekInnerTol, primalTol);
else
    dualTol = getScalarFieldOrDefault(param, 'optTol', primalTol);
end

if isfield(param, 'mosekInnerMuTol') && ~isempty(param.mosekInnerMuTol)
    muTol = scalarOrDefault(param.mosekInnerMuTol, primalTol * 1e-2);
else
    muTol = primalTol * 1e-2;
end

if ~isfield(param, 'MSK_DPAR_INTPNT_TOL_PFEAS')
    param.MSK_DPAR_INTPNT_TOL_PFEAS = primalTol;
end

if ~isfield(param, 'MSK_DPAR_INTPNT_QO_TOL_PFEAS')
    param.MSK_DPAR_INTPNT_QO_TOL_PFEAS = primalTol;
end

if ~isfield(param, 'MSK_DPAR_INTPNT_CO_TOL_PFEAS')
    param.MSK_DPAR_INTPNT_CO_TOL_PFEAS = primalTol;
end

if ~isfield(param, 'MSK_DPAR_INTPNT_TOL_DFEAS')
    param.MSK_DPAR_INTPNT_TOL_DFEAS = dualTol;
end

if ~isfield(param, 'MSK_DPAR_INTPNT_QO_TOL_DFEAS')
    param.MSK_DPAR_INTPNT_QO_TOL_DFEAS = dualTol;
end

if ~isfield(param, 'MSK_DPAR_INTPNT_CO_TOL_DFEAS')
    param.MSK_DPAR_INTPNT_CO_TOL_DFEAS = dualTol;
end

if ~isfield(param, 'MSK_DPAR_INTPNT_CO_TOL_REL_GAP')
    param.MSK_DPAR_INTPNT_CO_TOL_REL_GAP = primalTol;
end

if ~isfield(param, 'MSK_DPAR_INTPNT_CO_TOL_MU_RED')
    param.MSK_DPAR_INTPNT_CO_TOL_MU_RED = muTol;
end

% -------------------------------------------------------------------------
% Solve form.
% -------------------------------------------------------------------------
if ~isfield(param, 'MSK_IPAR_INTPNT_SOLVE_FORM')
    param.MSK_IPAR_INTPNT_SOLVE_FORM = ...
        getTextFieldOrDefault(param, 'mosekSolveForm', 'MSK_SOLVE_PRIMAL');
end

% -------------------------------------------------------------------------
% Presolve profile.
% -------------------------------------------------------------------------
if any(strcmp(profile, {'cobraNoPresolve', 'cobraNoPresolveVerbose'}))
    param.MSK_IPAR_PRESOLVE_USE = 'MSK_PRESOLVE_MODE_OFF';
elseif ~isfield(param, 'MSK_IPAR_PRESOLVE_USE')
    param.MSK_IPAR_PRESOLVE_USE = ...
        getTextFieldOrDefault(param, 'mosekPresolveUse', 'MSK_PRESOLVE_MODE_FREE');
end

% -------------------------------------------------------------------------
% Presolve and data tolerances.
% -------------------------------------------------------------------------
if ~isfield(param, 'MSK_DPAR_PRESOLVE_TOL_PRIMAL_INFEAS_PERTURBATION')
    param.MSK_DPAR_PRESOLVE_TOL_PRIMAL_INFEAS_PERTURBATION = ...
        getScalarFieldOrDefault(param, 'mosekPrimalInfeasPerturbationTol', 0);
end

if ~isfield(param, 'MSK_DPAR_PRESOLVE_TOL_X')
    param.MSK_DPAR_PRESOLVE_TOL_X = ...
        getScalarFieldOrDefault(param, 'mosekPresolveTolX', ...
        100 * getScalarFieldOrDefault(param, 'numTol', 1e-12));
end

if ~isfield(param, 'MSK_DPAR_PRESOLVE_TOL_S')
    param.MSK_DPAR_PRESOLVE_TOL_S = ...
        getScalarFieldOrDefault(param, 'mosekPresolveTolS', ...
        100 * getScalarFieldOrDefault(param, 'numTol', 1e-12));
end

if ~isfield(param, 'MSK_DPAR_DATA_TOL_X')
    param.MSK_DPAR_DATA_TOL_X = ...
        getScalarFieldOrDefault(param, 'mosekDataTolX', ...
        getScalarFieldOrDefault(param, 'numTol', 1e-12));
end

if ~isfield(param, 'MSK_DPAR_INTPNT_CO_TOL_NEAR_REL')
    param.MSK_DPAR_INTPNT_CO_TOL_NEAR_REL = ...
        getScalarFieldOrDefault(param, 'mosekNearRel', 1.0);
end

% -------------------------------------------------------------------------
% Historical COBRA special cases.
% -------------------------------------------------------------------------
if isfield(param, 'lifted') && isequal(double(param.lifted), 1)
    if ~isfield(param, 'MSK_IPAR_PRESOLVE_ELIMINATOR_MAX_NUM_TRIES')
        param.MSK_IPAR_PRESOLVE_ELIMINATOR_MAX_NUM_TRIES = 0;
    end
end

if isfield(param, 'multiscale') && isequal(double(param.multiscale), 1) && ...
        (~isfield(param, 'lifted') || isequal(double(param.lifted), 0))

    if ~isfield(param, 'MSK_IPAR_PRESOLVE_LINDEP_NEW')
        param.MSK_IPAR_PRESOLVE_LINDEP_NEW = 'MSK_OFF';
    end

    if ~isfield(param, 'MSK_IPAR_INTPNT_SCALING')
        param.MSK_IPAR_INTPNT_SCALING = 'MSK_SCALING_NONE';
    end

    if ~isfield(param, 'MSK_IPAR_SIM_SCALING')
        param.MSK_IPAR_SIM_SCALING = 'MSK_SCALING_NONE';
    end
end

% Debug may request infeasibility reporting.  The final print policy can
% still remove this field.
if isfield(param, 'debug') && isequal(double(param.debug), 1)
    param.MSK_IPAR_INFEAS_REPORT_AUTO = 'MSK_ON';
end

if isfield(param, 'strict') && ~isempty(param.strict)
    if ~isfield(param, 'MSK_IPAR_BI_IGNORE_MAX_ITER')
        param.MSK_IPAR_BI_IGNORE_MAX_ITER = 'MSK_OFF';
    end

    if ~isfield(param, 'MSK_IPAR_INTPNT_SOLVE_FORM')
        param.MSK_IPAR_INTPNT_SOLVE_FORM = 'MSK_SOLVE_FREE';
    end

    if ~isfield(param, 'MSK_DPAR_INTPNT_TOL_INFEAS')
        param.MSK_DPAR_INTPNT_TOL_INFEAS = 1e-8;
    end
end

% Apply LP/QP/CLP/EP optimizer choices.
param = applyProblemTypeOptimizerPortfolio(param);

% Historical feasibility-repair logging field.
if ~isfield(param, 'MSK_IPAR_LOG_FEAS_REPAIR') && ...
        isfield(param, 'repairInfeasibility') && ...
        ~isempty(param.repairInfeasibility)
    param.MSK_IPAR_LOG_FEAS_REPAIR = param.repairInfeasibility;
end
end


function param = applySCLPMosekPortfolio(param, profile)
% applySCLPMosekPortfolio
%
% Materialise solveSCLP-owned MOSEK parameter profiles.
%
% This is the ordinary SCLP profile used by CA/BCA/BCQCA/WQCA/QCA/LQCA
% inner solves and inherited by the tight start profiles.

if ~isfield(param, 'timelimit') || isempty(param.timelimit)
    param.timelimit = 600;
end

if ~isfield(param, 'innerMosekTolFactor') || isempty(param.innerMosekTolFactor)
    param.innerMosekTolFactor = 1e-3;
end

if ~isfield(param, 'innerMosekTolFloorFactor') || isempty(param.innerMosekTolFloorFactor)
    param.innerMosekTolFloorFactor = 10;
end

if ~isfield(param, 'innerMosekMuTolFactor') || isempty(param.innerMosekMuTolFactor)
    param.innerMosekMuTolFactor = 1e-5;
end

if ~isfield(param, 'innerMosekMuTolFloorFactor') || isempty(param.innerMosekMuTolFloorFactor)
    param.innerMosekMuTolFloorFactor = 1;
end

innerTol = max( ...
    param.innerMosekTolFactor * param.feasTol, ...
    param.innerMosekTolFloorFactor * param.numTol);

innerMuTol = max( ...
    param.innerMosekMuTolFactor * param.feasTol, ...
    param.innerMosekMuTolFloorFactor * param.numTol);

% Interior-point solve form and conic tolerances.
param.MSK_IPAR_INTPNT_SOLVE_FORM = 'MSK_SOLVE_PRIMAL';

param.MSK_DPAR_INTPNT_CO_TOL_PFEAS   = innerTol;
param.MSK_DPAR_INTPNT_CO_TOL_DFEAS   = innerTol;
param.MSK_DPAR_INTPNT_CO_TOL_REL_GAP = innerTol;
param.MSK_DPAR_INTPNT_CO_TOL_MU_RED  = innerMuTol;

% Presolve profile.
switch profile
    case {'SCLP_normalPresolve', 'SCLP_verbose'}
        param.MSK_IPAR_PRESOLVE_USE = 'MSK_PRESOLVE_MODE_FREE';

    case {'SCLP_noPresolve', 'SCLP_noPresolveVerbose'}
        param.MSK_IPAR_PRESOLVE_USE = 'MSK_PRESOLVE_MODE_OFF';

    otherwise
        error('setMosekParam:badSCLPProfile', ...
            'Unsupported SCLP MOSEK profile: %s', profile);
end

% Presolve and data tolerances are numerical interpretation tolerances, not
% model feasibility targets.
if ~isfield(param, 'mosekPresolveTolXFactor') || isempty(param.mosekPresolveTolXFactor)
    param.mosekPresolveTolXFactor = 100;
end

if ~isfield(param, 'mosekPresolveTolSFactor') || isempty(param.mosekPresolveTolSFactor)
    param.mosekPresolveTolSFactor = 100;
end

if ~isfield(param, 'mosekDataTolXFactor') || isempty(param.mosekDataTolXFactor)
    param.mosekDataTolXFactor = 1;
end

param.MSK_DPAR_PRESOLVE_TOL_PRIMAL_INFEAS_PERTURBATION = 0;
param.MSK_DPAR_PRESOLVE_TOL_X = ...
    param.mosekPresolveTolXFactor * param.numTol;
param.MSK_DPAR_PRESOLVE_TOL_S = ...
    param.mosekPresolveTolSFactor * param.numTol;
param.MSK_DPAR_DATA_TOL_X = ...
    param.mosekDataTolXFactor * param.numTol;
param.MSK_DPAR_INTPNT_CO_TOL_NEAR_REL = 1.0;

% Verbose SCLP profiles request MOSEK logs.  The final print policy may
% still remove them.
if any(strcmp(profile, {'SCLP_verbose', 'SCLP_noPresolveVerbose'}))
    param.MSK_IPAR_LOG = 10;
    param.MSK_IPAR_LOG_INTPNT = 10;
    param.MSK_IPAR_LOG_SIM = 10;
    param.MSK_IPAR_LOG_PRESOLVE = 10;
end

% Time limit.
if ~isfield(param, 'MSK_DPAR_OPTIMIZER_MAX_TIME') && ...
        isfield(param, 'timelimit') && ~isempty(param.timelimit)
    param.MSK_DPAR_OPTIMIZER_MAX_TIME = param.timelimit;
end

% Regularisation for solveSCLP conic subproblems.
if ~isfield(param, 'MSK_IPAR_INTPNT_REGULARIZATION_USE')
    param.MSK_IPAR_INTPNT_REGULARIZATION_USE = 'MSK_ON';
end

% Apply any problemType-specific optimizer choice only if the caller set it.
% This keeps SCLP behaviour compatible with the broader COBRA interface.
param = applyProblemTypeOptimizerPortfolio(param);
end


function param = applyProblemTypeOptimizerPortfolio(param)
% applyProblemTypeOptimizerPortfolio
%
% Apply historical problemType-dependent optimiser selections.

problemType = upper(char(string(param.problemType)));

switch problemType

    case 'LP'
        if isfield(param, 'lpmethod') && ~isempty(param.lpmethod)
            param.MSK_IPAR_OPTIMIZER = normaliseMosekOptimizerName(param.lpmethod);
        end

    case 'QP'
        if isfield(param, 'qpmethod') && ~isempty(param.qpmethod)
            param.MSK_IPAR_OPTIMIZER = normaliseMosekOptimizerName(param.qpmethod);
        end

    case 'CLP'
        if isfield(param, 'clpmethod') && ~isempty(param.clpmethod)
            param.MSK_IPAR_OPTIMIZER = normaliseMosekOptimizerName(param.clpmethod);
        end

        if ~isfield(param, 'MSK_IPAR_INTPNT_REGULARIZATION_USE')
            param.MSK_IPAR_INTPNT_REGULARIZATION_USE = 'MSK_ON';
        end

    case 'EP'
        if isfield(param, 'epmethod') && ~isempty(param.epmethod)
            param.MSK_IPAR_OPTIMIZER = normaliseMosekOptimizerName(param.epmethod);
        end

        if ~isfield(param, 'MSK_IPAR_INTPNT_REGULARIZATION_USE')
            param.MSK_IPAR_INTPNT_REGULARIZATION_USE = 'MSK_ON';
        end

        if ~isfield(param, 'MSK_IPAR_INTPNT_MAX_ITERATIONS')
            param.MSK_IPAR_INTPNT_MAX_ITERATIONS = 400;
        end

    case 'VK'
        % Reserved for VK-specific choices.  No action.

    otherwise
        % Preserve compatibility with callers using unrecognised problemType
        % values.  Do nothing.
end
end


function name = normaliseMosekOptimizerName(value)
% normaliseMosekOptimizerName
%
% Accept either 'INTPNT' or 'MSK_OPTIMIZER_INTPNT'-style input.

name = char(string(value));
name = strtrim(name);

if isempty(name)
    name = 'MSK_OPTIMIZER_INTPNT';
    return
end

if ~contains(name, 'MSK_OPTIMIZER_')
    name = ['MSK_OPTIMIZER_' name];
end
end


function paramOut = removeMosekParameterFields(paramIn)
% removeMosekParameterFields
%
% Remove every actual MOSEK parameter field from a structure.
%
% This is required for true default mode because a MOSEK parameter is
% default only when it is not supplied.

paramOut = paramIn;
fields = fieldnames(paramOut);

for i = 1:numel(fields)
    name = fields{i};

    if strncmp(name, 'MSK_', 4)
        paramOut = rmfield(paramOut, name);
    end
end
end


function paramOut = localMosekParamStrip(paramIn)
% localMosekParamStrip
%
% Return a structure containing only actual MOSEK parameter fields.
%
% This local function replaces any dependency on an external mosekParamStrip
% helper file.

paramOut = struct();

if ~isstruct(paramIn)
    return
end

fields = fieldnames(paramIn);

for i = 1:numel(fields)
    name = fields{i};

    if strncmp(name, 'MSK_', 4)
        value = paramIn.(name);

        % Avoid passing empty values to MOSEK.
        if ~isempty(value)
            paramOut.(name) = value;
        end
    end
end
end


function param = removeFieldsIfPresent(param, fieldsToRemove)
% removeFieldsIfPresent
%
% Remove a list of fields from a structure if they exist.

for i = 1:numel(fieldsToRemove)
    if isfield(param, fieldsToRemove{i})
        param = rmfield(param, fieldsToRemove{i});
    end
end
end


function value = getScalarFieldOrDefault(s, fieldName, defaultValue)
% getScalarFieldOrDefault
%
% Return s.(fieldName) when it is a finite scalar numeric value; otherwise
% return defaultValue.

value = defaultValue;

if isstruct(s) && isfield(s, fieldName) && ~isempty(s.(fieldName))
    value = scalarOrDefault(s.(fieldName), defaultValue);
end
end


function value = scalarOrDefault(candidate, defaultValue)
% scalarOrDefault
%
% Convert a candidate value to a finite scalar double if possible.

value = defaultValue;

if isnumeric(candidate) || islogical(candidate)
    candidate = full(candidate);
    candidate = double(candidate(1));

    if isfinite(candidate)
        value = candidate;
    end
end
end


function value = getTextFieldOrDefault(s, fieldName, defaultValue)
% getTextFieldOrDefault
%
% Return s.(fieldName) as nonempty character text when present; otherwise
% return defaultValue.

value = defaultValue;

if isstruct(s) && isfield(s, fieldName) && ~isempty(s.(fieldName))
    candidate = char(string(s.(fieldName)));
    candidate = strtrim(candidate);

    if ~isempty(candidate)
        value = candidate;
    end
end
end