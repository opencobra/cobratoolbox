function param = mosekParamSetEFBA(param)
% Creates a structure of pertinent user-defined options for the MOSEK
% solver, adding/overriding the MOSEK-specific integer and double
% parameters used by entropic flux balance analysis
%
% USAGE:
%
%    param = mosekParamSetEFBA(param)
%
% INPUT:
%    param:     Parameter structure to be passed to the MOSEK solver; the
%               following MOSEK-specific fields are set (any other fields
%               already present in `param` are preserved):
%
%                 * .MSK_IPAR_LOG_PRESOLVE - amount of output printed by
%                   the presolve procedure; a higher value logs more
%                   information (MOSEK default: 1; set here to 1)
%                 * .MSK_IPAR_INTPNT_SCALING - how the problem is scaled
%                   before the interior-point optimizer is used
%                   (`MSK_SCALING_NONE`, `MSK_SCALING_MODERATE`,
%                   `MSK_SCALING_AGGRESSIVE`, or `MSK_SCALING_FREE`; MOSEK
%                   default is `MSK_SCALING_FREE`; set here to
%                   `MSK_SCALING_FREE`)
%                 * .MSK_IPAR_INTPNT_REGULARIZATION_USE - whether
%                   regularization is allowed (`MSK_ON`/`MSK_OFF`; MOSEK
%                   default is `MSK_ON`; set here to `MSK_OFF`)
%                 * .MSK_DPAR_INTPNT_CO_TOL_DFEAS - dual feasibility
%                   tolerance used by the interior-point optimizer for
%                   conic problems (MOSEK default: 1.0e-8; set here to
%                   1.0e-11)
%                 * .MSK_DPAR_INTPNT_CO_TOL_PFEAS - primal feasibility
%                   tolerance used by the interior-point optimizer for
%                   conic problems (MOSEK default: 1.0e-8; set here to
%                   1.0e-11)
%                 * .MSK_DPAR_INTPNT_CO_TOL_REL_GAP - relative gap
%                   termination tolerance used by the interior-point
%                   optimizer for conic problems (MOSEK default: 1.0e-8;
%                   set here to 1.0e-11; useful for ensuring dual
%                   feasibility is as good as primal)
%                 * .MSK_IPAR_INTPNT_MAX_ITERATIONS - maximum number of
%                   iterations allowed in the interior-point optimizer
%                   (MOSEK default: 400; set here to 400)
%                 * .MSK_IPAR_BI_IGNORE_MAX_ITER - if
%                   `MSK_IPAR_INTPNT_BASIS` is `MSK_BI_NO_ERROR` and the
%                   interior-point optimizer terminated on the maximum
%                   number of iterations, whether basis identification is
%                   still performed (`MSK_ON`/`MSK_OFF`; MOSEK default is
%                   `MSK_OFF`; set here to `MSK_OFF`)
%                 * .MSK_IPAR_INTPNT_SOLVE_FORM - whether the primal or the
%                   dual problem is solved (`MSK_SOLVE_PRIMAL`,
%                   `MSK_SOLVE_DUAL`, or `MSK_SOLVE_FREE`; MOSEK default is
%                   `MSK_SOLVE_FREE`; set here to `MSK_SOLVE_FREE`)
%                 * .MSK_DPAR_INTPNT_TOL_INFEAS - controls when the
%                   optimizer declares the model primal or dual infeasible;
%                   a smaller value makes the optimizer more conservative
%                   about declaring infeasibility (MOSEK default: 1.0e-8;
%                   set here to 1e-8)
%                 * .MSK_IPAR_LOG_INTPNT - amount of output printed by the
%                   interior-point optimizer; a higher value logs more
%                   information (MOSEK default: 4; set here to 5)
%                 * .MSK_IPAR_INFEAS_REPORT_AUTO - amount of information
%                   presented in an automatically generated infeasibility
%                   report (`MSK_ON`/`MSK_OFF`; MOSEK default is
%                   `MSK_OFF`; set here to `MSK_OFF`)
%                 * .MSK_IPAR_INFEAS_REPORT_LEVEL - amount of information
%                   presented in an infeasibility report; higher values
%                   give more information (MOSEK default: 1; set here to
%                   100)
%
% OUTPUT:
%    param:     `param`, with the MOSEK-specific fields listed under INPUT
%               set/overridden
%

% MSK_IPAR_LOG_PRESOLVE
% Description:Controls amount of output printed by the presolve procedure. A higher level implies that more information is logged.
% Possible Values:Any number between 0 and +inf.
% Default value:1

param.MSK_IPAR_LOG_PRESOLVE =1;

%MSK_IPAR_INTPNT_SCALING 
% Controls how the problem is scaled before the interior-point optimizer is used.
% Possible Values:
%     MSK_SCALING_NONE
%         No scaling is performed. 
%     MSK_SCALING_MODERATE
%         A conservative scaling is performed. 
%     MSK_SCALING_AGGRESSIVE
%         A very aggressive scaling is performed. 
%     MSK_SCALING_FREE
%         The optimizer chooses the scaling heuristic. 
% Default value:
%     MSK_SCALING_FREE
param.MSK_IPAR_INTPNT_SCALING ='MSK_SCALING_FREE';
%param.MSK_IPAR_INTPNT_SCALING ='MSK_SCALING_NONE';

% MSK_IPAR_INTPNT_REGULARIZATION_USE 
% Description:Controls whether regularization is allowed.
% Possible Values: MSK_ON    Switch the option on. 
%                  MSK_OFF   Switch the option off. 
% Default value:   MSK_ON
param.MSK_IPAR_INTPNT_REGULARIZATION_USE='MSK_OFF'; 

%%%%%%%%%%%%% NONLINEAR TERMINATION CRITERIA%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MSK_DPAR_INTPNT_CO_TOL_DFEAS 
%Dual feasibility tolerance used by the interior-point optimizer for conic problems.
%Default:1.0e-8
%Accepted: [0.0; 1.0]
param.MSK_DPAR_INTPNT_CO_TOL_DFEAS = 1.0e-11;

%MSK_DPAR_INTPNT_CO_TOL_PFEAS
%Primal feasibility tolerance used by the interior-point optimizer for conic problems.
%Default: 1.0e-8
% Accepted: [0.0; 1.0]
param.MSK_DPAR_INTPNT_CO_TOL_PFEAS = 1.0e-11;

%MSK_DPAR_INTPNT_CO_TOL_REL_GAP
%Relative gap termination tolerance used by the interior-point optimizer for conic problems.
%Default:1.0e-8
%Accepted: [0.0; 1.0]
param.MSK_DPAR_INTPNT_CO_TOL_REL_GAP = 1.0e-11;
%useful for ensuring dual feasibility is as good as primal

% MSK_IPAR_INTPNT_MAX_ITERATIONS 
% Controls the maximum number of iterations allowed in the interior-point optimizer.
% Possible Values:Any number between 0 and +inf. 
% Default value: 400
param.MSK_IPAR_INTPNT_MAX_ITERATIONS=400;


%%%%%%%%%%%%% NONLINEAR SOLVER INTEGER PARAM %%%%%%%%%%%%%%%%%%%%%%%%%%%%

% MSK_IPAR_BI_IGNORE_MAX_ITER 
% If the parameter MSK_IPAR_INTPNT_BASIS has the value MSK_BI_NO_ERROR and 
% the interior-point optimizer has terminated due to maximum number of 
% iterations, then basis identification is performed if this parameter has
% the value MSK_ON.
% Possible Values:
%     MSK_ON        Switch the option on. 
%     MSK_OFF       Switch the option off. 
% Default value:
%     MSK_OFF 
param.MSK_IPAR_BI_IGNORE_MAX_ITER='MSK_OFF';     


%%%%%%%%%%% Solution Approach
% MSK_IPAR_INTPNT_SOLVE_FORM 
% Controls whether the primal or the dual problem is solved.
% Possible Values:
%     MSK_SOLVE_PRIMAL
%         The optimizer should solve the primal problem. 
%     MSK_SOLVE_DUAL
%         The optimizer should solve the dual problem. 
%     MSK_SOLVE_FREE
%         The optimizer is free to solve either the primal or the dual problem. 
% Default value:MSK_SOLVE_FREE
param.MSK_IPAR_INTPNT_SOLVE_FORM='MSK_SOLVE_FREE';
%param.MSK_IPAR_INTPNT_SOLVE_FORM='MSK_SOLVE_PRIMAL';

%%%%%%% Infeasibility
% MSK_DPAR_INTPNT_TOL_INFEAS 
% Controls when the optimizer declares the model primal or dual infeasible.
% A small number means the optimizer gets more conservative about declaring the model infeasible.
% Possible Values:Any number between 0.0 and 1.0. 
% Default value: 1.0e-8
param.MSK_DPAR_INTPNT_TOL_INFEAS=1e-8; 

%%%%%%%%%%%%%%%%%%%%%%OUTPUT%%%%%%%%%%%%%%%%%%
%MSK_IPAR_LOG_INTPNT
% Controls amount of output printed printed by the interior-point optimizer.
%A higher level implies that more information is logged.
% Possible Values: Any number between 0 and +inf. 
% Default value: 4
param.MSK_IPAR_LOG_INTPNT=5;

%infesibility report
% MSK_IPAR_INFEAS_REPORT_AUTO
%Controls the amount of information presented in an infeasibility report.
% Possible Values:
%     MSK_ON
%         Switch the option on. 
%     MSK_OFF
%         Switch the option off. 
% Default value:
%     MSK_OFF
param.MSK_IPAR_INFEAS_REPORT_AUTO='MSK_OFF'; 

% MSK_IPAR_INFEAS_REPORT_LEVEL 
% Controls the amount of information presented in an infeasibility report. Higher values imply more information.
% Possible Values:Any number between 0 and +inf. 
% Default value: 1
%Higher values imply more information.
param.MSK_IPAR_INFEAS_REPORT_LEVEL=100; 
