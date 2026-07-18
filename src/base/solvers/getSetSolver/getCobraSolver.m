function [solverName, solverOK] = getCobraSolver(solverType, validate)
% Gets the current solver name given a solver type
%
% USAGE:
%
%    [solverName, solverOK] = getCobraSolver(solverType, validate)
%
% INPUT:
%    solverType:        Solver type, `LP`, `MILP`, `QP`, `MIQP` (opt, default
%                       `LP`, `all`).  'all' attempts to change all applicable
%                       solvers to solverName.  This is purely a shorthand
%                       convenience.
%
% OPTIONAL INPUT:
%    validate:          `true` to validate that the solver can be accessed,
%                       via `changeCobraSolver` (and re-validated verbosely
%                       if the first attempt fails); `false` to skip
%                       validation (default: `false`, and `solverOK` is then
%                       returned as `NaN`)
%
% OUTPUT:
%    solverName:        Solver name
%    solverOK:          `true` if solver can be accessed, `false` if not,
%                       `NaN` if `validate` was not requested

if ~exist('validate','var')
    validate = 0;
    solverOK = NaN;
end

switch solverType
    case 'LP'
        global CBT_LP_SOLVER;
        solverName = CBT_LP_SOLVER;
    case 'QP'
        global CBT_QP_SOLVER;
        solverName = CBT_QP_SOLVER ;
    case 'MILP'
        global CBT_MILP_SOLVER;
        solverName = CBT_MILP_SOLVER;
    case 'MIQP'
        global CBT_MIQP_SOLVER;
        solverName = CBT_MIQP_SOLVER;
    case 'NLP'
        global CBT_NLP_SOLVER;
        solverName = CBT_NLP_SOLVER;
end

if validate
    %validate the solver
    [solverOK, ~] = changeCobraSolver(solverName, solverType, 0, 1);
    if ~solverOK
        %if there is something wrong, do a verbose validation
        [solverOK, ~] = changeCobraSolver(solverName, solverType, 1, 1);
    end
end