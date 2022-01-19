function [stat,origStat,x,y,z,s,doty] = parseMskResult(res,A,blc,buc,printLevel,param)
%parse the res structure returned from mosek

% initialise variables
stat =[];
origStat = [];
x = [];
y = [];
z = [];
s = [];
doty = [];

if ~exist('printLevel','var')
    printLevel = 0;
end
if ~exist('param','var')
    param = struct();
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
                z=res.sol.itr.slx-res.sol.itr.sux; %dual to bux <= x   <= bux
                if isfield(res.sol.itr,'doty')
                    % Dual variables to affine conic constraints
                    doty = res.sol.itr.doty;
                end
                
%                 % TODO  -work this out with Erling
%                 % override if specific solver selected
%                 if isfield(param,'MSK_IPAR_OPTIMIZER')
%                     switch param.MSK_IPAR_OPTIMIZER
%                         case {'MSK_OPTIMIZER_PRIMAL_SIMPLEX','MSK_OPTIMIZER_DUAL_SIMPLEX'}
%                             stat = 1; % optimal solution found
%                             x=res.sol.bas.xx; % primal solution.
%                             y=res.sol.bas.y; % dual variable to blc <= A*x <= buc
%                             z=res.sol.bas.slx-res.sol.bas.sux; %dual to bux <= x   <= bux
%                             if isfield(res.sol.itr,'doty')
%                                 % Dual variables to affine conic constraints
%                                 doty = res.sol.itr.doty;
%                             end
%                         case 'MSK_OPTIMIZER_INTPNT'
%                             stat = 1; % optimal solution found
%                             x=res.sol.itr.xx; % primal solution.
%                             y=res.sol.itr.y; % dual variable to blc <= A*x <= buc
%                             z=res.sol.itr.slx-res.sol.itr.sux; %dual to bux <= x   <= bux
%                             if isfield(res.sol.itr,'doty')
%                                 % Dual variables to affine conic constraints
%                                 doty = res.sol.itr.doty;
%                             end
%                     end
%                 end
%                 if isfield(res.sol,'bas') && 0
%                     % override
%                     stat = 1; % optimal solution found
%                     x=res.sol.bas.xx; % primal solution.
%                     y=res.sol.bas.y; % dual variable to blc <= A*x <= buc
%                     z=res.sol.bas.slx-res.sol.bas.sux; %dual to bux <= x   <= bux
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
                z=res.sol.bas.slx-res.sol.bas.sux; %dual to bux <= x   <= bux
                if isfield(res.sol.bas,'doty')
                    % Dual variables to affine conic constraints
                    doty = res.sol.bas.doty;
                end
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
        if isfield(param,'MSK_IPAR_OPTIMIZER')
            switch param.MSK_IPAR_OPTIMIZER
                case {'MSK_OPTIMIZER_PRIMAL_SIMPLEX','MSK_OPTIMIZER_DUAL_SIMPLEX'}
                    stat = 1; % optimal solution found
                    x=res.sol.bas.xx; % primal solution.
                    y=res.sol.bas.y; % dual variable to blc <= A*x <= buc
                    z=res.sol.bas.slx-res.sol.bas.sux; %dual to bux <= x   <= bux
                    if isfield(res.sol.bas,'doty')
                        % Dual variables to affine conic constraints
                        doty = res.sol.bas.doty;
                    end
                case 'MSK_OPTIMIZER_INTPNT'
                    stat = 1; % optimal solution found
                    x=res.sol.itr.xx; % primal solution.
                    y=res.sol.itr.y; % dual variable to blc <= A*x <= buc
                    z=res.sol.itr.slx-res.sol.itr.sux; %dual to bux <= x   <= bux
                    if isfield(res.sol.itr,'doty')
                        % Dual variables to affine conic constraints
                        doty = res.sol.itr.doty;
                    end
            end
        end
    end
    
    if stat ==1 && exist('A','var')
        %slack for blc <= A*x <= buc
        s = zeros(size(A,1),1);
        %slack for blc = A*x = buc
        s(blc==buc) = abs(A(blc==buc,:)*x - blc(blc==buc));
        %slack for blc <= A*x
        s(~isfinite(blc)) = A(~isfinite(blc),:)*x - blc(~isfinite(blc));
        %slack for A*x <= buc
        s(~isfinite(buc)) = buc(~isfinite(buc)) - A(~isfinite(buc),:)*x;
        
        %debugging
        % if printLevel>2
        %     res1=A*x + s -b;
        %     norm(res1(csense == 'G'),inf)
        %     norm(s(csense == 'G'),inf)
        %     norm(res1(csense == 'L'),inf)
        %     norm(s(csense == 'L'),inf)
        %     norm(res1(csense == 'E'),inf)
        %     norm(s(csense == 'E'),inf)
        %     res1(~isfinite(res1))=0;
        %     norm(res1,inf)
        
        %     norm(osense*c -A'*y -z,inf)
        %     y2=res.sol.itr.slc-res.sol.itr.suc;
        %     norm(osense*c -A'*y2 -z,inf)
        % end
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
%     %try to solve with default parameters
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
%             if problemTypeParams.printLevel>2
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
%     %try to solve with default parameters
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
%             if problemTypeParams.printLevel>2
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