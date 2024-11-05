function [cmd,mosekParam] = setMosekParam(param)
% set mosek parameters from param fields
% strip any non mosek compatible fields from param and return it as
% mosekParam


%tests if solver correctly interfaced and licence running
if param.printLevel>1 || param.debug
    [~, res] = mosekopt('symbcon');
else
    [~, res] = mosekopt('symbcon echo(0)');
end

% only set the print level if not already set via param structure
if ~isfield(param, 'MSK_IPAR_LOG')
    % Controls the amount of log information.
    % The value 0 implies that all log information is suppressed.
    % A higher level implies that more information is logged.
    switch param.printLevel
        case 0
            echolev = 0;
        case 1
            echolev = 3;
        case 2
            param.MSK_IPAR_WRITE_DATA_PARAM='MSK_ON';
            param.MSK_IPAR_LOG_INTPNT = 1;
            param.MSK_IPAR_LOG_SIM = 1;
            %MSK_IPAR_LOG_PRESOLVE
            % Description:Controls amount of output printed by the presolve procedure. A higher level implies that more information is logged.
            % Possible Values:Any number between 0 and +inf.
            % Default value:1
            param.MSK_IPAR_LOG_PRESOLVE=10;

            %MSK_IPAR_LOG_INTPNT
            % Controls amount of output printed printed by the interior-point optimizer.
            %A higher level implies that more information is logged.
            % Possible Values: Any number between 0 and +inf.
            % Default value: 4
            if ~isfield(param,'MSK_IPAR_LOG_INTPNT')
                param.MSK_IPAR_LOG_INTPNT=5;
            end

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
            if ~isfield(param,'MSK_IPAR_INFEAS_REPORT_AUTO')
                param.MSK_IPAR_INFEAS_REPORT_AUTO='MSK_ON';
            end

            % MSK_IPAR_INFEAS_REPORT_LEVEL
            % Controls the amount of information presented in an infeasibility report. Higher values imply more information.
            % Possible Values:Any number between 0 and +inf.
            % Default value: 1
            %Higher values imply more information.
            if ~isfield(param,'MSK_IPAR_INFEAS_REPORT_LEVEL')
                param.MSK_IPAR_INFEAS_REPORT_LEVEL=1;
            end

            echolev = 3;
        otherwise
            echolev = 0;
    end
    if echolev == 0 && ~param.debug
        param.MSK_IPAR_LOG = 0;
        cmd = ['minimize echo(' int2str(echolev) ')'];
    else
        cmd = 'minimize';
    end
end


if ~isfield(param, 'MSK_DPAR_OPTIMIZER_MAX_TIME') && isfield(param,'timelimit')
    % MSK_DPAR_OPTIMIZER_MAX_TIME
    % Maximum amount of time the optimizer is allowed to spent on the optimization. A negative number means infinity.
    % Default
    % -1.0
    % Accepted
    % [-inf; +inf]
    % Example
    % param.MSK_DPAR_OPTIMIZER_MAX_TIME = -1.0
    % Groups
    % Termination criteria
    param.MSK_DPAR_OPTIMIZER_MAX_TIME = param.timelimit;
end



if ~isfield(param, 'MSK_DPAR_INTPNT_TOL_PFEAS')
    % Primal feasibility tolerance used by the interior-point optimizer for linear problems.
    % Default
    % 1.0e-8
    % Accepted
    % [0.0; 1.0]
    % Example
    % param.MSK_DPAR_INTPNT_TOL_PFEAS = 1.0e-8
    % Groups
    % Interior-point method, Termination criteria
    param.MSK_DPAR_INTPNT_TOL_PFEAS=param.feasTol;
end


if ~isfield(param,'MSK_DPAR_INTPNT_QO_TOL_PFEAS')
    % Primal feasibility tolerance used by the interior-point optimizer for quadratic problems.
    % Default
    % 1.0e-8
    % Accepted
    % [0.0; 1.0]
    % Example
    % param.MSK_DPAR_INTPNT_QO_TOL_PFEAS = 1.0e-8
    % See also
    % MSK_DPAR_INTPNT_QO_TOL_NEAR_REL
    % Groups
    % Interior-point method, Termination criteria
    param.MSK_DPAR_INTPNT_QO_TOL_PFEAS=param.feasTol;
end

if ~isfield(param, 'MSK_DPAR_INTPNT_CO_TOL_PFEAS')
    % Primal feasibility tolerance used by the interior-point optimizer for conic problems.
    % Default
    % 1.0e-8
    % Accepted
    % [0.0; 1.0]
    % Example
    % param.MSK_DPAR_INTPNT_CO_TOL_PFEAS = 1.0e-8
    % See also
    % MSK_DPAR_INTPNT_CO_TOL_NEAR_REL
    % Groups
    % Interior-point method, Termination criteria, Conic interior-point method
    param.MSK_DPAR_INTPNT_CO_TOL_PFEAS=param.feasTol;
end

if ~isfield(param, 'MSK_DPAR_INTPNT_TOL_DFEAS')
    % MSK_DPAR_INTPNT_TOL_DFEAS
    % Dual feasibility tolerance used by the interior-point optimizer for linear problems.
    % Default
    % 1.0e-8
    % Accepted
    % [0.0; 1.0]
    % Example
    % param.MSK_DPAR_INTPNT_TOL_DFEAS = 1.0e-8
    % Groups
    % Interior-point method, Termination criteria
    param.MSK_DPAR_INTPNT_TOL_DFEAS=param.optTol;
end

if ~isfield(param, 'MSK_DPAR_INTPNT_QO_TOL_DFEAS')
    % Dual feasibility tolerance used by the interior-point optimizer for quadratic problems.
    % Default
    % 1.0e-8
    % Accepted
    % [0.0; 1.0]
    % Example
    % param.MSK_DPAR_INTPNT_QO_TOL_DFEAS = 1.0e-8
    % See also
    % MSK_DPAR_INTPNT_QO_TOL_NEAR_REL
    % Groups
    % Interior-point method, Termination criteria
    param.MSK_DPAR_INTPNT_QO_TOL_DFEAS=param.optTol;
end

if ~isfield(param, 'MSK_DPAR_INTPNT_CO_TOL_DFEAS')
    % Dual feasibility tolerance used by the interior-point optimizer for linear problems.
    % Default
    % 1.0e-8
    % Accepted
    % [0.0; 1.0]
    % Example
    % param.MSK_DPAR_INTPNT_TOL_DFEAS = 1.0e-8
    % Groups
    % Interior-point method, Termination criteria
    param.MSK_DPAR_INTPNT_CO_TOL_DFEAS=param.optTol;
end

if isfield(param,'lifted') && param.lifted==1
    % Controls the maximum amount of fill-in that can be created by one pivot in the elimination phase of the presolve.
    % A negative value means the parameter value is selected automatically.
    % Default-1
    % Accepted [-inf; +inf]
    % Example param.MSK_IPAR_PRESOLVE_ELIMINATOR_MAX_FILL = -1
    if ~isfield(param,'MSK_IPAR_PRESOLVE_ELIMINATOR_MAX_NUM_TRIES')
        param.MSK_IPAR_PRESOLVE_ELIMINATOR_MAX_NUM_TRIES = 0;
    end
end

%turn on multiscale if infeasibilities after unscaling
if isfield(param,'multiscale') && param.multiscale==1 && param.lifted==0
    % Controls whether whether a new experimental linear dependency checker is employed.
    % Default
    % "OFF"
    % Accepted
    % "ON", "OFF"
    % Example
    % param.MSK_IPAR_PRESOLVE_LINDEP_NEW = 'MSK_OFF'
    if ~isfield(param,'MSK_IPAR_PRESOLVE_LINDEP_NEW')
        param.MSK_IPAR_PRESOLVE_LINDEP_NEW = 'MSK_OFF';
    end
    
    % MSK_IPAR_INTPNT_SCALING
    % Controls how the problem is scaled before the interior-point optimizer is used.
    % Default
    % "FREE"
    % Accepted
    % "FREE", "NONE"
    % param..MSK_IPAR_INTPNT_SCALING = 'MSK_SCALING_FREE';
    if ~isfield(param,'MSK_IPAR_INTPNT_SCALING')
        param.MSK_IPAR_INTPNT_SCALING='MSK_SCALING_NONE';
    end
    % MSK_IPAR_SIM_SCALING
    % Controls how much effort is used in scaling the problem before a simplex optimizer is used.
    % Default
    % "FREE"
    % Accepted
    % "FREE", "NONE"
    % Example
    % param.MSK_IPAR_SIM_SCALING = 'MSK_SCALING_FREE'
    if ~isfield(param,'MSK_IPAR_SIM_SCALING')
        param.MSK_IPAR_SIM_SCALING='MSK_SCALING_NONE';
    end
end

if isfield(param,'debug') && param.debug==1
    % https://docs.mosek.com/latest/rmosek/debugging-infeas.html
    % Controls whether an infeasibility report is automatically produced after the optimization if the problem is primal or dual infeasible.
    param.MSK_IPAR_INFEAS_REPORT_AUTO='MSK_ON';
end

if isfield(param,'strict')
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
    if ~isfield(param,'MSK_IPAR_BI_IGNORE_MAX_ITER')
        param.MSK_IPAR_BI_IGNORE_MAX_ITER='MSK_OFF';
    end

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
    if ~isfield(param,'MSK_IPAR_INTPNT_SOLVE_FORM')
        param.MSK_IPAR_INTPNT_SOLVE_FORM='MSK_SOLVE_FREE';
        %param.MSK_IPAR_INTPNT_SOLVE_FORM='MSK_SOLVE_PRIMAL';
    end

    %%%%%%% Infeasibility
    % MSK_DPAR_INTPNT_TOL_INFEAS
    % Controls when the optimizer declares the model primal or dual infeasible.
    % A small number means the optimizer gets more conservative about declaring the model infeasible.
    % Possible Values:Any number between 0.0 and 1.0.
    % Default value: 1.0e-8
    if ~isfield(param,'MSK_DPAR_INTPNT_TOL_INFEAS')
        % param.MSK_DPAR_INTPNT_TOL_INFEAS=1e-10;
        param.MSK_DPAR_INTPNT_TOL_INFEAS=1e-8;
    end
end

%backward compatibility
if isfield(param,'method')
    if isempty(param.method)
        param = rmfield(param,'method');
    else
        if ~isfield(param,[lower(param.problemType) 'method'])
            param.([lower(param.problemType) 'method'])=param.method;
        end
    end
end

switch param.problemType
    case {'LP'}
        if isfield(param,'lpmethod')
            if contains(param.lpmethod,'MSK_OPTIMIZER_')
                param.MSK_IPAR_OPTIMIZER=param.lpmethod;
            else
                param.MSK_IPAR_OPTIMIZER=['MSK_OPTIMIZER_' param.lpmethod];
            end
        end
    case {'QP'}
        if isfield(param,'qpmethod')
            if contains(param.qpmethod,'MSK_OPTIMIZER_')
                param.MSK_IPAR_OPTIMIZER=param.qpmethod;
            else
                param.MSK_IPAR_OPTIMIZER=['MSK_OPTIMIZER_' param.qpmethod];
            end
        end
    case {'CLP'}
        if isfield(param,'clpmethod')
            if contains(param.qpmethod,'MSK_OPTIMIZER_')
                param.MSK_IPAR_OPTIMIZER=param.clpmethod;
            else
                param.MSK_IPAR_OPTIMIZER=['MSK_OPTIMIZER_' param.clpmethod];
            end
        end

        % MSK_IPAR_INTPNT_REGULARIZATION_USE
        % Description:Controls whether regularization is allowed.
        % Possible Values: MSK_ON    Switch the option on.
        %                  MSK_OFF   Switch the option off.
        % Default value:   MSK_ON
        if ~isfield(param,'MSK_IPAR_INTPNT_REGULARIZATION_USE')
            param.MSK_IPAR_INTPNT_REGULARIZATION_USE='MSK_ON';
        end

    case {'EP'}
        if isfield(param,'epmethod')
            if contains(param.epmethod,'MSK_OPTIMIZER_')
                param.MSK_IPAR_OPTIMIZER=param.epmethod;
            else
                param.MSK_IPAR_OPTIMIZER=['MSK_OPTIMIZER_' param.epmethod];
            end
        end
        % MSK_IPAR_INTPNT_REGULARIZATION_USE
        % Description:Controls whether regularization is allowed.
        % Possible Values: MSK_ON    Switch the option on.
        %                  MSK_OFF   Switch the option off.
        % Default value:   MSK_ON
        if ~isfield(param,'MSK_IPAR_INTPNT_REGULARIZATION_USE')
            param.MSK_IPAR_INTPNT_REGULARIZATION_USE='MSK_ON';
        end



        % MSK_IPAR_INTPNT_MAX_ITERATIONS
        % Controls the maximum number of iterations allowed in the interior-point optimizer.
        % Possible Values:Any number between 0 and +inf.
        % Default value: 400
        if ~isfield(param,'MSK_IPAR_INTPNT_MAX_ITERATIONS')
            param.MSK_IPAR_INTPNT_MAX_ITERATIONS=400;
        end

        %%%%%%%%%%%%% NONLINEAR SOLVER INTEGER PARAM %%%%%%%%%%%%%%%%%%%%%%%%%%%%

    case {'VK'}

        % MSK_IPAR_SIM_SCALING_METHOD
        % Controls how the problem is scaled before a simplex optimizer is used.
        % Default
        % "POW2"
        % Accepted
        % "POW2", "FREE"
        % Example
        % param.MSK_IPAR_SIM_SCALING_METHOD = 'MSK_SCALING_METHOD_POW2'
        % param.MSK_IPAR_SIM_SCALING_METHOD='MSK_SCALING_METHOD_FREE';
end


if ~isfield(param,'MSK_IPAR_LOG_FEAS_REPAIR') && isfield(param,'repairInfeasibility')
    % MSK_IPAR_LOG_FEAS_REPAIR
    % Controls the amount of output printed when performing feasibility repair. A value higher than one means extensive logging.
    % Default
    % 1
    % Accepted
    % [0; +inf]
    % Example
    % MSK_putintparam(task, MSK_IPAR_LOG_FEAS_REPAIR, 1)
    % Groups
    % Output information, Logging
    param.MSK_IPAR_LOG_FEAS_REPAIR = param.repairInfeasibility;
end

% Remove outer function specific parameters to avoid crashing solver interfaces
mosekParam = mosekParamStrip(param);
if 0
    disp(mosekParam)
end
