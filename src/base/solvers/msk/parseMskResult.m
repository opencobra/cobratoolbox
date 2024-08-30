function [stat,origStat,x,y,yl,yu,z,zl,zu,k,basis,pobjval,dobjval] = parseMskResult(res,solverOnlyParams,printLevel)
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
%  stat:     cobra toolbox status
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
z = [];
zl = [];
zu = [];
k = [];
basis = [];
pobjval =[];
dobjval =[];

if ~exist('printLevel','var')
    printLevel = 0;
end
if ~exist('solverOnlyParams','var')
    solverOnlyParams = struct();
end

% https://docs.mosek.com/8.1/toolbox/data-types.html?highlight=res%20sol%20itr#data-types-and-structures
if isfield(res, 'sol')
    if isfield(res.sol, 'itr')
        origStat = res.sol.itr.solsta;
        %disp(origStat)
        switch origStat
            case {'OPTIMAL','MSK_SOL_STA_OPTIMAL','MSK_SOL_STA_NEAR_OPTIMAL'}
                stat = 1; % optimal solution found
                x=res.sol.itr.xx; % primal solution.
                y=res.sol.itr.y; % dual variable to blc <= A*x <= buc
                yl = res.sol.itr.slc;
                yu = res.sol.itr.suc;
                z=res.sol.itr.slx-res.sol.itr.sux; %dual to blx <= x   <= bux
                zl=res.sol.itr.slx;  %dual to blx <= x
                zu=res.sol.itr.sux; %dual to   x <= bux
                if isfield(res.sol.itr,'doty')
                    % Dual variables to affine conic constraints
                    k = res.sol.itr.doty;
                end
                
                pobjval = res.sol.itr.pobjval;
                dobjval = res.sol.itr.dobjval;
%                 % TODO  -work this out with Erling
%                 % override if specific solver selected
%                 if isfield(solverOnlyParams,'MSK_IPAR_OPTIMIZER')
%                     switch solverOnlyParams.MSK_IPAR_OPTIMIZER
%                         case {'MSK_OPTIMIZER_PRIMAL_SIMPLEX','MSK_OPTIMIZER_DUAL_SIMPLEX'}
%                             stat = 1; % optimal solution found
%                             x=res.sol.bas.xx; % primal solution.
%                             y=res.sol.bas.y; % dual variable to blc <= A*x <= buc
%                             z=res.sol.bas.slx-res.sol.bas.sux; %dual to blx <= x   <= bux
%                             if isfield(res.sol.itr,'doty')
%                                 % Dual variables to affine conic constraints
%                                 s = res.sol.itr.doty;
%                             end
%                         case 'MSK_OPTIMIZER_INTPNT'
%                             stat = 1; % optimal solution found
%                             x=res.sol.itr.xx; % primal solution.
%                             y=res.sol.itr.y; % dual variable to blc <= A*x <= buc
%                             z=res.sol.itr.slx-res.sol.itr.sux; %dual to blx <= x   <= bux
%                             if isfield(res.sol.itr,'doty')
%                                 % Dual variables to affine conic constraints
%                                 s = res.sol.itr.doty;
%                             end
%                     end
%                 end
%                 if isfield(res.sol,'bas') && 0
%                     % override
%                     stat = 1; % optimal solution found
%                     x=res.sol.bas.xx; % primal solution.
%                     y=res.sol.bas.y; % dual variable to blc <= A*x <= buc
%                     z=res.sol.bas.slx-res.sol.bas.sux; %dual to blx <= x   <= bux
%                 end
                
            case {'MSK_SOL_STA_PRIM_INFEAS_CER','MSK_SOL_STA_NEAR_PRIM_INFEAS_CER','PRIMAL_INFEASIBLE_CER'}
                stat=0; % infeasible
            case {'MSK_SOL_STA_DUAL_INFEAS_CER','MSK_SOL_STA_NEAR_DUAL_INFEAS_CER','DUAL_INFEASIBLE_CER'}
                stat=2; % Unbounded solution
            case {'UNKNOWN'}
                stat=-1; %some other problem
            otherwise
                warning(['Unrecognised solsta: ' origStat])
                stat=-1; %some other problem
        end
    end
    
    if isfield(res.sol,'bas') && ~isequal(res.sol.bas.solsta,'UNKNOWN') %dont overwite interior point solution 
        origStat = res.sol.bas.solsta;
        switch origStat
            case {'OPTIMAL','MSK_SOL_STA_OPTIMAL','MSK_SOL_STA_NEAR_OPTIMAL'}
                stat = 1; % optimal solution found
                x=res.sol.bas.xx; % primal solution.
                y=res.sol.bas.y; % dual variable to blc <= A*x <= buc
                yl = res.sol.bas.slc; %assuming this exists
                yu = res.sol.bas.suc;
                z=res.sol.bas.slx-res.sol.bas.sux; %dual to blx <= x   <= bux
                zl=res.sol.bas.slx;  %dual to blx <= x
                zu=res.sol.bas.sux; %dual to   x <= bux
                if isfield(res.sol.bas,'s')
                    % Dual variables to affine conic constraints
                    k = res.sol.bas.s;
                end
                %https://docs.mosek.com/10.0/toolbox/advanced-hotstart.html
                bas.skc = res.sol.bas.skc;
                bas.skx = res.sol.bas.skx;
                bas.xc = res.sol.bas.xc;
                bas.xx = res.sol.bas.xx;
                
            case {'PRIMAL_INFEASIBLE_CER','MSK_SOL_STA_PRIM_INFEAS_CER','MSK_SOL_STA_NEAR_PRIM_INFEAS_CER'}
                stat=0; % infeasible
            case {'DUAL_INFEASIBLE_CER','MSK_SOL_STA_DUAL_INFEAS_CER','MSK_SOL_STA_NEAR_DUAL_INFEAS_CER'}
                stat=2; % Unbounded solution
            case {'UNKNOWN'}
                stat=-1; %some other problem
            otherwise
                warning(['Unrecognised solsta: ' origStat])
                stat=-1; %some other problem
        end
    end
    
    if stat==1
        % override if specific solver selected
        if isfield(solverOnlyParams,'MSK_IPAR_OPTIMIZER')
            switch solverOnlyParams.MSK_IPAR_OPTIMIZER
                case {'MSK_OPTIMIZER_PRIMAL_SIMPLEX','MSK_OPTIMIZER_DUAL_SIMPLEX'}
                    stat = 1; % optimal solution found
                    x=res.sol.bas.xx; % primal solution.
                    y=res.sol.bas.y; % dual variable to blc <= A*x <= buc
                    yl = res.sol.bas.slc; %assuming this exists
                    yu = res.sol.bas.suc;
                    z=res.sol.bas.slx-res.sol.bas.sux; %dual to blx <= x   <= bux
                    zl=res.sol.bas.slx;  %dual to blx <= x
                    zu=res.sol.bas.sux; %dual to   x <= bux
                    if isfield(res.sol.bas,'s')
                        % Dual variables to affine conic constraints
                        k = res.sol.bas.s;
                    end
                case 'MSK_OPTIMIZER_INTPNT'
                    stat = 1; % optimal solution found
                    x=res.sol.itr.xx; % primal solution.
                    y=res.sol.itr.y; % dual variable to blc <= A*x <= buc
                    yl = res.sol.itr.slc; %assuming this exists
                    yu = res.sol.itr.suc;
                    z=res.sol.itr.slx-res.sol.itr.sux; %dual to blx <= x   <= bux
                    zl=res.sol.itr.slx;  %dual to blx <= x
                    zu=res.sol.itr.sux; %dual to   x <= bux
                    if isfield(res.sol.itr,'doty')
                        % Dual variables to affine conic constraints
                        k = res.sol.itr.doty;
                    end
            end
        end
    end    
else
    if printLevel>0
        fprintf('%s\n',res.rcode)
        fprintf('%s\n',res.rmsg)
        fprintf('%s\n',res.rcodestr)
    end
    origStat = [];
    stat = -1;
end

% % https://docs.mosek.com/8.1/toolbox/data-types.html?highlight=res%20sol%20itr#data-types-and-structures
% if isfield(res, 'sol')
%     if isfield(res.sol, 'itr')
%         origStat = res.sol.itr.solsta;
%         if strcmp(res.sol.itr.solsta, 'OPTIMAL') || ...
%                 strcmp(res.sol.itr.solsta, 'MSK_SOL_STA_OPTIMAL') || ...
%                 strcmp(res.sol.itr.solsta, 'MSK_SOL_STA_NEAR_OPTIMAL')
%             origStat = 1; % optimal solution found
%         elseif strcmp(res.sol.itr.solsta,'MSK_SOL_STA_PRIM_INFEAS_CER') ||...
%                 strcmp(res.sol.itr.solsta,'MSK_SOL_STA_NEAR_PRIM_INFEAS_CER') ||...
%                 strcmp(res.sol.itr.solsta,'MSK_SOL_STA_DUAL_INFEAS_CER') ||...
%                 strcmp(res.sol.itr.solsta,'MSK_SOL_STA_NEAR_DUAL_INFEAS_CER')
%             stat=0; % infeasible
%         end
%     end
%     if isfield(res.sol,'bas')
%         origStat = res.sol.bas.solsta;
%         if strcmp(res.sol.bas.solsta,'OPTIMAL') || ...
%                 strcmp(res.sol.bas.solsta,'MSK_SOL_STA_OPTIMAL') || ...
%                 strcmp(res.sol.bas.solsta,'MSK_SOL_STA_NEAR_OPTIMAL')
%             stat = 1; % optimal solution found
%         elseif strcmp(res.sol.bas.solsta,'MSK_SOL_STA_PRIM_INFEAS_CER') ||...
%                 strcmp(res.sol.bas.solsta,'MSK_SOL_STA_NEAR_PRIM_INFEAS_CER') ||...
%                 strcmp(res.sol.bas.solsta,'MSK_SOL_STA_DUAL_INFEAS_CER') ||...
%                 strcmp(res.sol.bas.solsta,'MSK_SOL_STA_NEAR_DUAL_INFEAS_CER')
%             stat=0; % infeasible
%         end
%     end
%     
% else
%     %try to solve with default solverParamseters
%     [res] = msklpopt(EPproblem.c,EPproblem.A,EPproblem.blc,EPproblem.buc,EPproblem.lb,EPproblem.ub);
%     if isfield(res,'sol')
%         if isfield(res.sol, 'itr')
%             solutionLP2.origStat = res.sol.itr.solsta;
%             if strcmp(res.sol.itr.solsta, 'OPTIMAL') || ...
%                     strcmp(res.sol.itr.solsta, 'MSK_SOL_STA_OPTIMAL') || ...
%                     strcmp(res.sol.itr.solsta, 'MSK_SOL_STA_NEAR_OPTIMAL')
%                 solutionLP2.origStat = 1; % optimal solution found
%             elseif strcmp(res.sol.itr.solsta,'MSK_SOL_STA_PRIM_INFEAS_CER') ||...
%                     strcmp(res.sol.itr.solsta,'MSK_SOL_STA_NEAR_PRIM_INFEAS_CER') ||...
%                     strcmp(res.sol.itr.solsta,'MSK_SOL_STA_DUAL_INFEAS_CER') ||...
%                     strcmp(res.sol.itr.solsta,'MSK_SOL_STA_NEAR_DUAL_INFEAS_CER')
%                 solutionLP2.stat=0; % infeasible
%             end
%         end
%         if isfield(res.sol,'bas')
%             solutionLP2.origStat = res.sol.bas.solsta;
%             if strcmp(res.sol.bas.solsta,'OPTIMAL') || ...
%                     strcmp(res.sol.bas.solsta,'MSK_SOL_STA_OPTIMAL') || ...
%                     strcmp(res.sol.bas.solsta,'MSK_SOL_STA_NEAR_OPTIMAL')
%                 solutionLP2.stat = 1; % optimal solution found
%             elseif strcmp(res.sol.bas.solsta,'MSK_SOL_STA_PRIM_INFEAS_CER') ||...
%                     strcmp(res.sol.bas.solsta,'MSK_SOL_STA_NEAR_PRIM_INFEAS_CER') ||...
%                     strcmp(res.sol.bas.solsta,'MSK_SOL_STA_DUAL_INFEAS_CER') ||...
%                     strcmp(res.sol.bas.solsta,'MSK_SOL_STA_NEAR_DUAL_INFEAS_CER')
%                 solutionLP2.stat=0; % infeasible
%             end
%         end
%         if solutionLP2.stat ==0
%             if problemTypesolverParamss.printLevel>2
%                 disp(res);
%             end
%         end
%     else
%         fprintf('%s\n',res.rcode)
%         fprintf('%s\n',res.rmsg)
%         fprintf('%s\n',res.rcodestr)
%         solutionLP2.stat=-1; %some other problem
%     end
% end

% % https://docs.mosek.com/8.1/toolbox/data-types.html?highlight=res%20sol%20itr#data-types-and-structures
% if isfield(res, 'sol')
%     if isfield(res.sol, 'itr')
%         solutionLP.origStat = res.sol.itr.solsta;
%         if strcmp(res.sol.itr.solsta, 'OPTIMAL') || ...
%                 strcmp(res.sol.itr.solsta, 'MSK_SOL_STA_OPTIMAL') || ...
%                 strcmp(res.sol.itr.solsta, 'MSK_SOL_STA_NEAR_OPTIMAL')
%             solutionLP.stat = 1; % optimal solution found
%         elseif strcmp(res.sol.itr.solsta,'PRIMAL_INFEASIBLE_CER') ||...
%                 strcmp(res.sol.itr.solsta,'MSK_SOL_STA_PRIM_INFEAS_CER') ||...
%                 strcmp(res.sol.itr.solsta,'MSK_SOL_STA_NEAR_PRIM_INFEAS_CER') ||...
%                 strcmp(res.sol.itr.solsta,'MSK_SOL_STA_DUAL_INFEAS_CER') ||...
%                 strcmp(res.sol.itr.solsta,'MSK_SOL_STA_NEAR_DUAL_INFEAS_CER')
%             solutionLP.stat=0; % infeasible
%         end
%     end
%     if isfield(res.sol,'bas')
%         solutionLP.origStat = res.sol.bas.solsta;
%         if strcmp(res.sol.bas.solsta,'OPTIMAL') || ...
%                 strcmp(res.sol.bas.solsta,'MSK_SOL_STA_OPTIMAL') || ...
%                 strcmp(res.sol.bas.solsta,'MSK_SOL_STA_NEAR_OPTIMAL')
%             solutionLP.stat = 1; % optimal solution found
%         elseif strcmp(res.sol.bas.solsta,'PRIMAL_INFEASIBLE_CER') ||...
%                 strcmp(res.sol.bas.solsta,'MSK_SOL_STA_PRIM_INFEAS_CER') ||...
%                 strcmp(res.sol.bas.solsta,'MSK_SOL_STA_NEAR_PRIM_INFEAS_CER') ||...
%                 strcmp(res.sol.bas.solsta,'MSK_SOL_STA_DUAL_INFEAS_CER') ||...
%                 strcmp(res.sol.bas.solsta,'MSK_SOL_STA_NEAR_DUAL_INFEAS_CER')
%             solutionLP.stat=0; % infeasible
%         end
%     end
% else
%     %try to solve with default solverParamseters
%     [res] = msklpopt(EPproblem.c,EPproblem.A,EPproblem.blc,EPproblem.buc,EPproblem.lb,EPproblem.ub);
%     if isfield(res,'sol')
%         if isfield(res.sol, 'itr')
%             solutionLP.origStat = res.sol.itr.solsta;
%             if strcmp(res.sol.itr.solsta, 'OPTIMAL') || ...
%                     strcmp(res.sol.itr.solsta, 'MSK_SOL_STA_OPTIMAL') || ...
%                     strcmp(res.sol.itr.solsta, 'MSK_SOL_STA_NEAR_OPTIMAL')
%                 solutionLP.stat = 1; % optimal solution found
%             elseif strcmp(res.sol.itr.solsta,'MSK_SOL_STA_PRIM_INFEAS_CER') ||...
%                     strcmp(res.sol.itr.solsta,'MSK_SOL_STA_NEAR_PRIM_INFEAS_CER') ||...
%                     strcmp(res.sol.itr.solsta,'MSK_SOL_STA_DUAL_INFEAS_CER') ||...
%                     strcmp(res.sol.itr.solsta,'MSK_SOL_STA_NEAR_DUAL_INFEAS_CER')
%                 solutionLP.stat=0; % infeasible
%             end
%         end
%         if isfield(res.sol,'bas')
%             solutionLP.origStat = res.sol.bas.solsta;
%             if strcmp(res.sol.bas.solsta,'OPTIMAL') || ...
%                     strcmp(res.sol.bas.solsta,'MSK_SOL_STA_OPTIMAL') || ...
%                     strcmp(res.sol.bas.solsta,'MSK_SOL_STA_NEAR_OPTIMAL')
%                 solutionLP.stat = 1; % optimal solution found
%             elseif strcmp(res.sol.bas.solsta,'MSK_SOL_STA_PRIM_INFEAS_CER') ||...
%                     strcmp(res.sol.bas.solsta,'MSK_SOL_STA_NEAR_PRIM_INFEAS_CER') ||...
%                     strcmp(res.sol.bas.solsta,'MSK_SOL_STA_DUAL_INFEAS_CER') ||...
%                     strcmp(res.sol.bas.solsta,'MSK_SOL_STA_NEAR_DUAL_INFEAS_CER')
%                 solutionLP.stat=0; % infeasible
%             end
%         end
%         if solutionLP.stat ==0
%             if problemTypesolverParamss.printLevel>2
%                 disp(res);
%             end
%         end
%     else
%         solution.origStat = res.rcodestr;
%         fprintf('%s\n',res.rcode)
%         fprintf('%s\n',res.rmsg)
%         fprintf('%s\n',res.rcodestr)
%         solutionLP.stat=-1; %some other problem
%     end
% end