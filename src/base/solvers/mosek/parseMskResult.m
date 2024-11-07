function [stat,origStat,x,y,yl,yu,z,zl,zu,s,basis,pobjval,dobjval] = parseMskResult(res)
%parse the res structure returned from mosek
% INPUTS:
%  res:        mosek results structure returned by mosekopt
%
% OPTIONAL INPUTS
%  prob:        mosek problem structure passed to mosekopt
%  solverOnlyParams:      Additional parameters provided which are not part
%                     of the COBRA parameters and are assumed to be part
%                     of direct solver input structs. For some solvers, it
%                     is essential to not include any extraneous fields that are 
%                     outside the solver interface specification.
%  printLevel:  
%
% OUTPUTS:
%  stat - Solver status in standardized form:
%   * 0 - Infeasible problem
%   * 1 - Optimal solution
%   * 2 - Unbounded solution
%   * 3 - Almost optimal solution
%   * -1 - Some other problem (timelimit, numerical problem etc)
%  origStat: solver status
%  x:   primal variable vector         
%  y:   dual variable vector to linear constraints (yl - yu)
%  yl:  dual variable vector to lower bound on linear constraints
%  yu:  dual variable vector to upper bound on linear constraints
%  z:   dual variable vector to box constraints (zl - zu)        
%  zl:  dual variable vector to lower bounds       
%  zu:  dual variable vector to upper bounds         
%  k:   dual variable vector to affine conic constraints
%  basis  basis returned by mosekopt
%  pobjval: primal objective value returned by modekopt
%  dobjval: dual objective value returned by modekopt
%
% EXAMPLE:
%  [~,res]=mosekopt('minimize',prob); 
%
% NOTE:
%
% Author(s): Ronan Fleming

% initialise variables
stat =[];
origStat = [];
x = [];
y = [];
yl = [];
yu = [];
z = [];
zl = [];
zu = [];
s = [];
basis = [];
pobjval =[];
dobjval =[];


% prosta (string) – Problem status (prosta).
% prosta
% Problem status keys
% 
% "MSK_PRO_STA_UNKNOWN"
% Unknown problem status.
% 
% "MSK_PRO_STA_PRIM_AND_DUAL_FEAS"
% The problem is primal and dual feasible.
% 
% "MSK_PRO_STA_PRIM_FEAS"
% The problem is primal feasible.
% 
% "MSK_PRO_STA_DUAL_FEAS"
% The problem is dual feasible.
% 
% "MSK_PRO_STA_PRIM_INFEAS"
% The problem is primal infeasible.
% 
% "MSK_PRO_STA_DUAL_INFEAS"
% The problem is dual infeasible.
% 
% "MSK_PRO_STA_PRIM_AND_DUAL_INFEAS"
% The problem is primal and dual infeasible.
% 
% "MSK_PRO_STA_ILL_POSED"
% The problem is ill-posed. For example, it may be primal and dual feasible but have a positive duality gap.
% 
% "MSK_PRO_STA_PRIM_INFEAS_OR_UNBOUNDED"
% The problem is either primal infeasible or unbounded. This may occur for mixed-integer problems.

% solsta (string) – Solution status (solsta).
% Solution status keys
% 
% "MSK_SOL_STA_UNKNOWN"
% Status of the solution is unknown.
% 
% "MSK_SOL_STA_OPTIMAL"
% The solution is optimal.
% 
% "MSK_SOL_STA_PRIM_FEAS"
% The solution is primal feasible.
% 
% "MSK_SOL_STA_DUAL_FEAS"
% The solution is dual feasible.
% 
% "MSK_SOL_STA_PRIM_AND_DUAL_FEAS"
% The solution is both primal and dual feasible.
% 
% "MSK_SOL_STA_PRIM_INFEAS_CER"
% The solution is a certificate of primal infeasibility.
% 
% "MSK_SOL_STA_DUAL_INFEAS_CER"
% The solution is a certificate of dual infeasibility.
% 
% "MSK_SOL_STA_PRIM_ILLPOSED_CER"
% The solution is a certificate that the primal problem is illposed.
% 
% "MSK_SOL_STA_DUAL_ILLPOSED_CER"
% The solution is a certificate that the dual problem is illposed.
% 
% "MSK_SOL_STA_INTEGER_OPTIMAL"
% The primal solution is integer optimal.

% https://docs.mosek.com/latest/toolbox/accessing-solution.html
accessSolution='';
if isfield(res, 'sol')
    if isfield(res.sol,'itr') && isfield(res.sol,'bas')
        if  any(strcmp(res.sol.bas.solsta,{'OPTIMAL','MSK_SOL_STA_OPTIMAL','MSK_SOL_STA_NEAR_OPTIMAL'})) && any(strcmp(res.sol.itr.solsta,{'UNKNOWN'}))
            accessSolution = 'bas';
        elseif any(strcmp(res.sol.itr.solsta,{'OPTIMAL','MSK_SOL_STA_OPTIMAL','MSK_SOL_STA_NEAR_OPTIMAL'})) && any(strcmp(res.sol.bas.solsta,{'UNKNOWN'}))
            accessSolution = 'itr';
        elseif any(strcmp(res.sol.itr.solsta,{'OPTIMAL'})) && any(strcmp(res.sol.bas.solsta,{'OPTIMAL','MSK_SOL_STA_OPTIMAL','MSK_SOL_STA_NEAR_OPTIMAL'}))
            accessSolution = 'itr';
        elseif any(strcmp(res.sol.bas.solsta,{'OPTIMAL'})) && any(strcmp(res.sol.itr.solsta,{'OPTIMAL','MSK_SOL_STA_OPTIMAL','MSK_SOL_STA_NEAR_OPTIMAL'}))
            accessSolution = 'bas';
        else
            origStat = res.sol.itr.solsta;
            accessSolution = 'dontAccess';
        end
    elseif isfield(res.sol,'itr') && ~isfield(res.sol,'bas')
        accessSolution = 'itr';
    elseif ~isfield(res.sol,'itr') && isfield(res.sol,'bas')
        accessSolution = 'bas';
    elseif ~isfield(res.sol,'itr') && ~isfield(res.sol,'bas')
        error('TODO encode parse of mixed integer optimiser solution')
    else
        disp('Report this error to the cobra toolbox google group please')
        error('Unrecognised combination of res.sol.bas.prosta & res.sol.itr.solsta, see https://docs.mosek.com/latest/toolbox/accessing-solution.html')
    end
end

% if strcmp(res.rcodestr,'MSK_RES_TRM_STALL')
%     warning('Mosek stalling, returning solution as it may be almost optimal')
% else
%     stat=-1; %some other problem
% end

switch accessSolution
    case 'itr'
        origStat = res.sol.itr.solsta;
        switch origStat
            case {'OPTIMAL','NEAR_OPTIMAL','INTEGER_OPTIMAL'}
                if any(strcmp(origStat,{'OPTIMAL','INTEGER_OPTIMAL'}))
                    stat = 1; % optimal solution found
                else
                    stat = 3;
                end
                x=res.sol.itr.xx; % primal solution.
                y=res.sol.itr.y; % dual variable to blc <= A*x <= buc
                yl = res.sol.itr.slc;
                yu = res.sol.itr.suc;
                z=res.sol.itr.slx-res.sol.itr.sux; %dual to blx <= x   <= bux
                zl=res.sol.itr.slx;  %dual to blx <= x
                zu=res.sol.itr.sux; %dual to   x <= bux
                if isfield(res.sol.itr,'doty')
                    % Dual variables to affine conic constraints
                    s = res.sol.itr.doty;
                end
                pobjval = res.sol.itr.pobjval;
                dobjval = res.sol.itr.dobjval;
            otherwise
                accessSolution = 'dontAccess';
        end

    case 'bas'
        origStat = res.sol.bas.solsta;
        switch origStat
            case {'OPTIMAL','NEAR_OPTIMAL','INTEGER_OPTIMAL'}
                if any(strcmp(origStat,{'OPTIMAL','INTEGER_OPTIMAL'}))
                    stat = 1; % optimal solution found
                else
                    stat = 3;
                end
                x=res.sol.bas.xx; % primal solution.
                y=res.sol.bas.y; % dual variable to blc <= A*x <= buc
                yl = res.sol.bas.slc; %assuming this exists
                yu = res.sol.bas.suc;
                z=res.sol.bas.slx-res.sol.bas.sux; %dual to blx <= x   <= bux
                zl=res.sol.bas.slx;  %dual to blx <= x
                zu=res.sol.bas.sux; %dual to   x <= bux
                if isfield(res.sol.bas,'s')
                    % Dual variables to affine conic constraints
                    s = res.sol.bas.s;
                end

                %https://docs.mosek.com/10.0/toolbox/advanced-hotstart.html
                basis.skc = res.sol.bas.skc;
                basis.skx = res.sol.bas.skx;
                basis.xc = res.sol.bas.xc;
                basis.xx = res.sol.bas.xx;
                pobjval = res.sol.bas.pobjval;
                dobjval = res.sol.bas.dobjval;
            otherwise
                accessSolution = 'dontAccess';
        end
    otherwise
        accessSolution = 'dontAccess';
        origStat = -1;
end

if strcmp(accessSolution,'dontAccess')
    switch origStat
        case {'PRIMAL_INFEASIBLE_CER','MSK_SOL_STA_PRIM_INFEAS_CER','MSK_SOL_STA_NEAR_PRIM_INFEAS_CER'}
            stat=0; % infeasible
            origStat = [origStat ' & ' res.rcodestr];
        case {'DUAL_INFEASIBLE_CER','MSK_SOL_STA_DUAL_INFEAS_CER','MSK_SOL_STA_NEAR_DUAL_INFEAS_CER'}
            stat=2; % Unbounded solution
            origStat = [origStat ' & ' res.rcodestr];
        case {'UNKNOWN','PRIM_ILLPOSED_CER','DUAL_ILLPOSED_CER','PRIM_FEAS','DUAL_FEAS','PRIM_AND_DUAL_FEAS','DUAL_FEASIBLE'}
            stat=-1; %some other problem
            origStat = [origStat ' & ' res.rcodestr];
        otherwise
            warning(['Unrecognised res.sol.bas.solsta or res.sol.itr.solsta: ' origStat])
            stat=-1; %some other problem
            fprintf('%s\n',res.rcode)
            fprintf('%s\n',res.rmsg)
            fprintf('%s\n',res.rcodestr)
            if strcmp(origStat,'UNKNOWN')
                origStat = [origStat ' & ' res.rcodestr];
            end
    end
end


% https://themosekblog.blogspot.com/2014/06/what-if-solver-stall.html