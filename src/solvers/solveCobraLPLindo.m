function [obj,x,y,w,s,solStatus] = solveCobraLPLindo(A,b,c,csense,lb,ub,osense,primalOnlyFlag,oldAPIFlag,verbLevel,method)
%solveCobraLPLindo Solve a LP problem using Lindo
%
% [obj,x,y,w,s,solStatus] =
% solveCobraLPLindo(A,b,c,csense,lb,ub,osense,primalOnlyFlag,oldAPIFlag,verbLevel,method)
%
% oldAPIFLag should be true if Lindo API <2.0 is used and false for newer
% versions of the API
%
% Markus Herrgard 11/8/06

% Handle missing arguments
if nargin < 4
    csense = [];
end
if nargin < 5
    lb = [];
end
if nargin < 6
    ub = [];
end
if nargin < 7
    osense = LS_MIN; % Default is minimization
end;
if nargin < 8
    primalOnlyFlag = true; % Only get the primal soln
end
if nargin < 9
    oldAPIFlag = true; % Use old Lindo API (< 2.0)
end
if nargin < 10
    verbLevel = 0; % Verbose output
end
if nargin < 11
    method = 0; % Default is solver decides
end;

% Initialize
x=[];
y=[];
s=[];
w=[];
obj=[];
solStatus=[];

[m,n] = size(A);

if (~issparse(A))
    A = sparse(A);
end

% if constraint senses are not given, all assumed to be equality
if (isempty(csense))
    clear csense
    csense(1:m) = 'E';
end;

% Newer version of Lindo is used (different API)
if (~oldAPIFlag)

    global MY_LICENSE_FILE
    % Set constants
    lindo;

    % Read license key from a license file
    [MY_LICENSE_KEY,nErr] = mxlindo('LSloadLicenseString',MY_LICENSE_FILE);

    % Create a LINDO environment
    [iEnv,nErr]=mxlindo('LScreateEnv',MY_LICENSE_KEY);
    if nErr ~= LSERR_NO_ERROR
        LMcheckError(iEnv,nErr);
        return;
    end

    % Declare and create a model
    [iModel,nErr]=mxlindo('LScreateModel',iEnv);
    if nErr ~= LSERR_NO_ERROR,
        LMcheckError(iEnv,nErr) ;
        return;
    end

    % Set some options
    [nErr]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_MIP_PRINTLEVEL,1);
    [nErr]=mxlindo('LSsetModelDouParameter',iModel,LS_DPARAM_CALLBACKFREQ,2.5);
    [nErr]=mxlindo('LSsetModelDouParameter',iModel,LS_DPARAM_MIP_RELOPTTOL,0.01);

    % Load LP the data
    [nErr]=mxlindo('LSXloadLPData',iModel,osense,0,c,b,csense,A,lb,ub);
    if nErr ~= LSERR_NO_ERROR
        LMcheckError(iEnv,nErr);
        return;
    end

    if (verbLevel >1 & method==3)
        [nErr] = mxlindo('LSsetLogfunc',iModel,'LMcbLog','Dummy string');
        if nErr ~= LSERR_NO_ERROR, return; end;
    elseif (verbLevel>0)
        fprintf('\n%10s %15s %15s %15s %15s\n','ITER','PRIMAL_OBJ','DUAL_OBJ','PRIMAL_INF','DUAL_INF');
        % Set LMcbLP.m as the callback function
        [nErr] = mxlindo('LSsetCallback',iModel,'LMcbLP','dummy');
        if nErr ~= LSERR_NO_ERROR
            return;
        end
    end

    % Optimize model
    [solStatus,nErr]=mxlindo('LSoptimize',iModel,method);
    if nErr ~= LSERR_NO_ERROR
        return;
    end

    if (solStatus == LS_STATUS_OPTIMAL | solStatus == LS_STATUS_BASIC_OPTIMAL)

        % Primal objective
        [obj, nErr] = mxlindo('LSgetInfo',iModel,LS_DINFO_POBJ);
        if nErr ~= LSERR_NO_ERROR, return; end;

        % Primal solution
        [x,nErr]=mxlindo('LSgetPrimalSolution',iModel);
        if nErr ~= LSERR_NO_ERROR, return; end;

        if (~primalOnlyFlag)

            % Dual solution
            [y,nErr]=mxlindo('LSgetDualSolution',iModel);
            if nErr ~= LSERR_NO_ERROR, return; end;

            % Slacks
            [s,nErr]=mxlindo('LSgetSlacks',iModel);
            if nErr ~= LSERR_NO_ERROR, return; end;

            % Reduced costs
            [w,nErr]=mxlindo('LSgetReducedCosts',iModel);
            if nErr ~= LSERR_NO_ERROR, return; end;

        end

    elseif (solStatus == LS_STATUS_UNBOUNDED)
        
        obj = inf;
        
    end

    % Report some statistics
    if (verbLevel > 0)
        % get solution stats
        [etime, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_ELAPSED_TIME);
        [siter, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_SIM_ITER);
        [biter, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_BAR_ITER);
        [niter, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_NLP_ITER);
        [imethod, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_METHOD);
        [pfeas, nErr] = mxlindo('LSgetInfo',iModel,LS_DINFO_PINFEAS);
        [dfeas, nErr] = mxlindo('LSgetInfo',iModel,LS_DINFO_DINFEAS);
        [dobj, nErr] = mxlindo('LSgetInfo',iModel,LS_DINFO_DOBJ);
        [basstat, nErr] = mxlindo('LSgetInfo',iModel,LS_IINFO_BASIC_STATUS);

        if solStatus~=LS_STATUS_BASIC_OPTIMAL & solStatus~=LS_STATUS_OPTIMAL,
            fprintf('\n\n No optimal solution was found. (status = %d)\n', solStatus);
            return;
        else
            fprintf('\n\n Optimal solution is found. (status = %d)\n\n',solStatus);
            fprintf(' Prim obj value     : %25.12f \n',obj);
            fprintf(' Dual obj value     : %25.12f \n',dobj);
            fprintf(' Primal-Dual gap    : %25.12e \n',abs(dobj-obj)/(1+obj));
            fprintf(' Prim infeas        : %25.12e \n',pfeas);
            fprintf(' Dual infeas        : %25.12e \n',dfeas);
            fprintf(' Simplex iters      : %25d \n',siter);
            fprintf(' Barrier iters      : %25d \n',biter);
            fprintf(' Time               : %25.12f \n',etime);
        end;

    end

    % Close the interface and terminate
    [nErr]=mxlindo('LSdeleteModel',iModel);
    if nErr ~= LSERR_NO_ERROR,
        LMcheckError(iEnv,nErr);
        return;
    end
    [nErr]=mxlindo('LSdeleteEnv',iEnv);
    if nErr ~= LSERR_NO_ERROR,
        LMcheckError(iEnv,nErr);
        return;
    end

else % Old Lindo

    global LINDOAPIHOME;
    
    iEnv = 0;
    iModel = 0;

    % Hook to the LINDO environment
    nErr=mxlindo('LScreateEnv',iEnv,LINDOAPIHOME);
    if nErr ~= 0
        error(['Problem with Lindo: ' num2str(nErr)]);
    end

    % Declare and create a model
    nErr=mxlindo('LScreateModel',iModel);
    if nErr ~= 0
        error(['Problem with Lindo: ' num2str(nErr)]);
    end

    % Load the data
    nErr=mxlindo('LSXloadLPData',iModel,osense,0,c,b,csense,A,lb,ub);
    if nErr ~= 0
        error(['Problem with Lindo: ' num2str(nErr)]);
    end

    if (verbLevel > 1)
        [status] = mxlindo('LSsetLogfunc',iModel,'Default Log','Dummy string');
    elseif (verbLevel > 0)
        fprintf('\n%10s %15s %15s %15s %15s\n','iter','obj','dobj','pinf','dinf');
        status = mxlindo('LSsetCallback',iModel,'LMcback','Dummy string');
    end;

    LS_IPARAM_LP_PRINTLEVEL = 39;
    [setstatus]=mxlindo('LSsetModelIntParameter',iModel,LS_IPARAM_LP_PRINTLEVEL,verbLevel);

    % Solve as LP
    [optstat]=mxlindo('LSoptimize',iModel,method);

    % Check solution status
    [solStatus,status]=mxlindo('LSgetModelIntParameter',iModel,0);

    if (solStatus == 3) % Solved successfully

        % Get the objective value
        [obj,status]=mxlindo('LSgetObjective',iModel);

        % Get the primal and dual solution
        [x,status]=mxlindo('LSgetPrimalSolution',iModel);

        if (~primalOnlyFlag)
            % Get dual, reduced costs & slacks
            [y,status]=mxlindo('LSgetDualSolution',iModel);
            [w,status]=mxlindo('LSgetReducedCosts',iModel);
            [s,status]=mxlindo('LSgetSlacks',iModel);
        else
            y = [];
            w = [];
            s = [];
        end

    elseif (solStatus == 6 | solStatus == 5)

        obj = Inf;
        
    end
    
    % Close the interface and terminate
    delStatus = mxlindo('LSdeleteModel',iModel);
    delStatus = mxlindo('LSdeleteEnv',iEnv);
    
end




