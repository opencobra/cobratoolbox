function tissueModel = call_INIT(model, weights, tol, epsilon, logfile, runtime)
%Use the INIT algorithm (Agren et al., 2012*) to extract a context
%specific model using data. INIT algorithm find the optimal trade-off
%between inluding and removing reactions based on their given weights. If
%desired, accumulation of certain metabolites can be allowed or even
%forced.
%
%INPUTS
%
%   model               input model (COBRA model structure)
%   weights             column with positive and negative weights for each reaction
%                       positive weights are reactions with high expression, negative
%                       weigths for reaction with low expression (must be same length 
%                       as model.rxns)
%   tol                 tolerance by which reaction fluxes are defined inactive after model extraction
%                       (recommended lowest value 1e-8 since solver
%                       tolerance is 1e-9)
%   epsilon             minimum flux threshold for "expressed" reactions
%   logfile             name of the file to save the MILP log (string)
%   runtime             maximum solve time for the MILP (seconds)%% TO SET - default value -set between 3600
%                       and 7200
%
%OUTPUTS
%
%   tissueModel         extracted model
%
%* Agren et al. (2012). Reconstruction of genome-scale active metabolic
%networks for 69 human cell types and 16 cancer types using INIT. PLoS
%Comput. Biol. 8, e1002518.
%
% Implementation adapted from the cobra toolbox (createTissueSpecificModel.m) by S. Opdam and A. Richelle, May 2017


    RHindex = find(weights > 0);
    RLindex = find(weights < 0);
    %Weights of 0 will be handled the same as in iMAT

    S = model.S;
    lb = model.lb;
    ub = model.ub;

    % Creating A matrix
    A = sparse(size(S,1)+2*length(RHindex)+2*length(RLindex),size(S,2)+2*length(RHindex)+length(RLindex));
    [m,n,s] = find(S);
    for i = 1:length(m)
        A(m(i),n(i)) = s(i);
    end

    for i = 1:length(RHindex)
        A(i+size(S,1),RHindex(i)) = 1;
        A(i+size(S,1),i+size(S,2)) = lb(RHindex(i)) - epsilon;
        A(i+size(S,1)+length(RHindex),RHindex(i)) = 1;
        A(i+size(S,1)+length(RHindex),i+size(S,2)+length(RHindex)+length(RLindex)) = ub(RHindex(i)) + epsilon;
    end

    for i = 1:length(RLindex)
        A(i+size(S,1)+2*length(RHindex),RLindex(i)) = 1;
        A(i+size(S,1)+2*length(RHindex),i+size(S,2)+length(RHindex)) = lb(RLindex(i));
        A(i+size(S,1)+2*length(RHindex)+length(RLindex),RLindex(i)) = 1;
        A(i+size(S,1)+2*length(RHindex)+length(RLindex),i+size(S,2)+length(RHindex)) = ub(RLindex(i));
    end

    % Creating csense
    csense1(1:size(S,1)) = 'E';
    csense2(1:length(RHindex)) = 'G';
    csense3(1:length(RHindex)) = 'L';
    csense4(1:length(RLindex)) = 'G';
    csense5(1:length(RLindex)) = 'L';
    csense = [csense1 csense2 csense3 csense4 csense5];

    % Creating lb and ub
    lb_y = zeros(2*length(RHindex)+length(RLindex),1);
    ub_y = ones(2*length(RHindex)+length(RLindex),1);
    lb = [lb;lb_y];
    ub = [ub;ub_y];

    % Creating c
    c_v = zeros(size(S,2),1);
    c_y = ones(2*length(RHindex)+length(RLindex),1);
    c_w = [weights(RHindex);weights(RHindex);abs(weights(RLindex))];
    c = [c_v;c_w.*c_y];

    % Creating b
    b_s = zeros(size(S,1),1);
    lb_rh = lb(RHindex);
    ub_rh = ub(RHindex);
    lb_rl = lb(RLindex);
    ub_rl = ub(RLindex);
    b = [b_s;lb_rh;ub_rh;lb_rl;ub_rl];

    % Creating vartype
    vartype1(1:size(S,2),1) = 'C';
    vartype2(1:2*length(RHindex)+length(RLindex),1) = 'B';
    vartype = [vartype1;vartype2];

    MILPproblem.A = A;
    MILPproblem.b = b;
    MILPproblem.c = c;
    MILPproblem.lb = lb;
    MILPproblem.ub = ub;
    MILPproblem.csense = csense;
    MILPproblem.vartype = vartype;
    MILPproblem.osense = -1;
    MILPproblem.x0 = [];

    solution = solveCobraMILP_loc(MILPproblem, 'timeLimit', runtime, 'logFile', logfile, 'printLevel', 3);
    
    x = solution.cont;
    rxnRemList = model.rxns(abs(x) < tol);
    tissueModel = removeRxns(model,rxnRemList); 
    inactiveRxns = findBlockedReaction(tissueModel); %% TO DO - need to provide a way to modulate the tolerance of this function (set at 10e-10)
    %inactiveRxns = findBlockedReaction(tissueModel,tol)%% should be write
    %like that
    tissueModel = removeRxns(tissueModel,inactiveRxns);
    tissueModel = removeNonUsedGenes(tissueModel);
end

%Use a modified version to return solution when time limit is reached and
%save the log file
function solution = solveCobraMILP_loc(MILPproblem,varargin)
    %solveCobraMILP Solve constraint-based MILP problems
    %
    % solution = solveCobraMILP(MILPproblem,parameters)
    %
    %INPUT
    % MILPproblem
    %  A      LHS matrix
    %  b      RHS vector
    %  c      Objective coeff vector
    %  lb     Lower bound vector
    %  ub     Upper bound vector
    %  osense Objective sense (-1 max, +1 min)
    %  csense Constraint senses, a string containting the constraint sense for
    %         each row in A ('E', equality, 'G' greater than, 'L' less than).
    %  vartype Variable types ('C' continuous, 'I' integer, 'B' binary)
    %  x0      Initial solution
    %
    %OPTIONAL INPUTS
    % Optional parameters can be entered using parameters structure or as
    % parameter followed by parameter value: i.e. ,'printLevel',3)
    %
    % parameters    Structure containing optional parameters.
    %  timeLimit    Global solver time limit
    %  intTol       Integrality tolerance
    %  relMipGapTol Relative MIP gap tolerance
    %  logFile      Log file (for CPLEX)
    %  printLevel    Printing level
    %               = 0    Silent (Default)
    %               = 1    Warnings and Errors
    %               = 2    Summary information 
    %               = 3    More detailed information
    %  saveInput    Saves LPproblem to filename specified in field. 
    %               i.e. parameters.saveInput = 'LPproblem.mat';
    %               Setting parameters = 'default' uses default setting set in
    %               getCobraSolverParameters.
    %
    % The solver is defined in the CBT_MILP_SOLVER global variable
    % (set using changeCobraSolver). Solvers currently available are 
    % 'tomlab_cplex' and 'glpk'
    %
    %OUTPUT
    % solution Structure containing the following fields describing a MILP
    %          solution
    %  cont     Continuous solution
    %  int      Integer solution
    %  full     Full MILP solution vector
    %  obj      Objective value
    %  solver   Solver used to solve MILP problem
    %  stat     Solver status in standardized form (see below)
    %            1  Optimal solution found
    %            2  Unbounded solution
    %            0  Infeasible MILP
    %           -1  No integer solution exists
    %            3  Other problem (time limit etc, but integer solution exists)
    %  origStat Original status returned by the specific solver 
    %  time     Solve time in seconds
    %
    %
    % Markus Herrgard 1/23/07
    % Tim Harrington  05/18/12 Added support for the Gurobi 5.0 solver

    %% Process options

    global CBT_MILP_SOLVER

    if (~isempty(CBT_MILP_SOLVER))
        solver = CBT_MILP_SOLVER;
    else
        error('No solver found.  Run changeCobraSolver');
    end

    optParamNames = {'intTol', 'relMipGapTol', 'timeLimit', ...
        'logFile', 'printLevel', 'saveInput', 'DATACHECK', 'DEPIND', ...
        'feasTol', 'optTol', 'absMipGapTol', 'NUMERICALEMPHASIS', 'EleNames', ... 
        'EqtNames', 'VarNames', 'EleNameFun', 'EqtNameFun', 'VarNameFun', ...
        'PbName', 'MPSfilename'};
    parameters = '';
    if nargin ~=1
        if mod(length(varargin),2)==0
            for i=1:2:length(varargin)-1
                if ismember(varargin{i},optParamNames)
                    parameters.(varargin{i}) = varargin{i+1};
                else
                    error([varargin{i} ' is not a valid optional parameter']);
                end
            end
        elseif strcmp(varargin{1},'default')
            parameters = 'default';
        elseif isstruct(varargin{1})
            parameters = varargin{1};
        else
            display('Warning: Invalid number of parameters/values')
            solution=[];
            return;
        end
    end

    %optional parameters
    [solverParams.intTol, solverParams.relMipGapTol, solverParams.timeLimit, ...
        solverParams.logFile, solverParams.printLevel, saveInput, ...
        solverParams.DATACHECK, solverParams.DEPIND, solverParams.feasTol, ...
        solverParams.optTol, solverParams.absMipGapTol, ...
        solverParams.NUMERICALEMPHASIS] = ...
        getCobraSolverParams('MILP',optParamNames(1:12), parameters);

    %Save Input if selected
    if ~isempty(saveInput)
        fileName = parameters.saveInput;
        if ~find(regexp(fileName,'.mat'))
            fileName = [fileName '.mat'];
        end
        display(['Saving MILPproblem in ' fileName]);
        save(fileName,'MILPproblem')
    end

    % Defaults in case the solver does not return anything
    %x = [];
    xInt = [];
    xCont = [];
    %stat = -99;
    %solStat = -99;

    [A,b,c,lb,ub,csense,osense,vartype,x0] = ...
        deal(MILPproblem.A,MILPproblem.b,MILPproblem.c,MILPproblem.lb,MILPproblem.ub,...
        MILPproblem.csense,MILPproblem.osense,MILPproblem.vartype,MILPproblem.x0);

    if any(~(vartype == 'C' | vartype == 'B' | vartype == 'I'))
        display ('vartype not C or B or I:  Assuming C');
        vartype(vartype ~= 'C' & vartype ~= 'I'& vartype ~= 'B') = 'C';
    end

    t_start = clock;
    switch solver

        case 'glpk'
    %% glpk

            % Set up problem
            if (isempty(csense))
                clear csense
                csense(1:length(b),1) = 'S';
            else
                csense(csense == 'L') = 'U';
                csense(csense == 'G') = 'L';
                csense(csense == 'E') = 'S';
                csense = columnVector(csense);
            end
            params.msglev = solverParams.printLevel;
            params.tmlim = solverParams.timeLimit;

            %whos csense vartype
            csense = char(csense);
            vartype = char(vartype);
            %whos csense vartype

            % Solve problem
            [x,f,stat,extra] = glpk(c,A,b,lb,ub,csense,vartype,osense,params);
            % Handle solution status reports
            if (stat == 5)
                solStat = 1; % optimal
            elseif (stat == 6)
                solStat = 2; % unbounded
            elseif (stat == 4) 
                solStat = 0; % infeasible

            elseif (stat == 171)
                solStat = 1; % Opt integer within tolerance
            elseif (stat == 173)
                solStat = 0; % Integer infeas
            elseif (stat == 184)
                solStat = 2; % Unbounded
            elseif (stat == 172)
                solStat = 3; % Other problem, but integer solution exists
            else
                solStat = -1; % No integer solution exists
            end

       case 'gurobi'
            % Free academic licenses for the Gurobi solver can be obtained from
            % http://www.gurobi.com/html/academic.html
            %
            % The code below uses Gurobi Mex to interface with Gurobi. It can be downloaded from
            % http://www.convexoptimization.com/wikimization/index.php/Gurobi_Mex:_A_MATLAB_interface_for_Gurobi

            clear opts % Use the default parameter settings
            if solverParams.printLevel == 0
               % Version v1.10 of Gurobi Mex has a minor bug. For complete silence
               % Remove Line 736 of gurobi_mex.c: mexPrintf("\n"); 
               opts.Display = 0;
               opts.DisplayInterval = 0;
            else
               opts.Display = 1;
            end

            %minimum intTol for gurobi = 1e-9
            if solverParams.intTol<1e-9, solverParams.intTol=1e-9; end

            opts.TimeLimit=solverParams.timeLimit;
            opts.MIPGap = solverParams.relMipGapTol;
            opts.IntFeasTol = solverParams.intTol;
            opts.FeasibilityTol = solverParams.feasTol;
            opts.OptimalityTol = solverParams.optTol;

            if (isempty(csense))
                clear csense
                csense(1:length(b),1) = '=';
            else
                csense(csense == 'L') = '<';
                csense(csense == 'G') = '>';
                csense(csense == 'E') = '=';
                csense = csense(:);
            end
            %gurobi_mex doesn't automatically cast logicals to doubles
        c = double(c);
            [x,f,stat,output] = gurobi_mex(c,osense,sparse(A),b, ...
                                                 csense,lb,ub,vartype,opts);
            if stat == 2
               solStat = 1; % Optimal solutuion found
            elseif stat == 3
               solStat = 0; % Infeasible
            elseif stat == 5
               solStat = 2; % Unbounded
            elseif stat == 4
               solStat = 0; % Gurobi reports infeasible *or* unbounded
            else
               solStat = -1; % Solution not optimal or solver problem
            end

     case 'gurobi5'
            %% gurobi 5
            % Free academic licenses for the Gurobi solver can be obtained from
            % http://www.gurobi.com/html/academic.html
            resultgurobi = struct('x',[],'objval',[]);
            MILPproblem.A = deal(sparse(MILPproblem.A));
            clear params            % Use the default parameter settings

            if solverParams.printLevel == 0 
               params.OutputFlag = 0;
               params.DisplayInterval = 1;
            else
               params.OutputFlag = 1;
               params.DisplayInterval = 5;
            end

            % Write log file for gurobi
            if isfield(solverParams, 'logFile')
                params.LogFile = solverParams.logFile;
            end
            
            params.TimeLimit = solverParams.timeLimit;
            params.MIPGap = solverParams.relMipGapTol;

            if solverParams.intTol <= 1e-09
                params.IntFeasTol = 1e-09;
            else
                params.IntFeasTol = solverParams.intTol;
            end

            params.FeasibilityTol = solverParams.feasTol;
            params.OptimalityTol = solverParams.optTol;

            if (isempty(csense))
                clear csense
                csense(1:length(b),1) = '=';
            else
                csense(csense == 'L') = '<';
                csense(csense == 'G') = '>';
                csense(csense == 'E') = '=';
                MILPproblem.csense = csense(:);
            end

            if osense == -1
                MILPproblem.osense = 'max';
            else
                MILPproblem.osense = 'min';
            end

            MILPproblem.vtype = vartype;
            MILPproblem.modelsense = MILPproblem.osense;
            [MILPproblem.A,MILPproblem.rhs,MILPproblem.obj,MILPproblem.sense] = deal(sparse(MILPproblem.A),MILPproblem.b,double(MILPproblem.c),MILPproblem.csense);
            resultgurobi = gurobi(MILPproblem,params);

            stat = resultgurobi.status;
            if strcmp(resultgurobi.status,'OPTIMAL')
               solStat = 1; % Optimal solution found
               [x,f] = deal(resultgurobi.x,resultgurobi.objval);
            elseif strcmp(resultgurobi.status,'INFEASIBLE')
               solStat = 0; % Infeasible
            elseif strcmp(resultgurobi.status,'UNBOUNDED')
               solStat = 2; % Unbounded
            elseif strcmp(resultgurobi.status,'INF_OR_UNBD')
               solStat = 0; % Gurobi reports infeasible *or* unbounded
            elseif strcmp(resultgurobi.status,'TIME_LIMIT')
                solStat = 3; % Time limit reached
                warning('Time limit reached, solution might not be optimal (gurobi)')
               [x,f] = deal(resultgurobi.x,resultgurobi.objval);
            else
               solStat = -1; % Solution not optimal or solver problem
            end

        case 'tomlab_cplex'
    %% CPLEX through tomlab
            if (~isempty(csense))
                b_L(csense == 'E') = b(csense == 'E');
                b_U(csense == 'E') = b(csense == 'E');
                b_L(csense == 'G') = b(csense == 'G');
                b_U(csense == 'G') = inf;
                b_L(csense == 'L') = -inf;
                b_U(csense == 'L') = b(csense == 'L');
            elseif isfield(MILPproblem, 'b_L') && isfield(MILPproblem, 'b_U')
                b_L = MILPproblem.b_L;
                b_U = MILPproblem.b_U;
            else
                b_L = b;
                b_U = b;
            end
            intVars = (vartype == 'B') | (vartype == 'I');
            %intVars
            %pause;
            tomlabProblem = mipAssign(osense*c,A,b_L,b_U,lb,ub,x0,'CobraMILP',[],[],intVars);

            % Set parameters for CPLEX
            tomlabProblem.MIP.cpxControl.EPINT = solverParams.intTol;
            tomlabProblem.MIP.cpxControl.EPGAP = solverParams.relMipGapTol;
            tomlabProblem.MIP.cpxControl.TILIM = solverParams.timeLimit;
            tomlabProblem.CPLEX.LogFile = solverParams.logFile;
            tomlabProblem.PriLev = solverParams.printLevel;
            tomlabProblem.MIP.cpxControl.THREADS = 1; % by default use only one thread


            % Strict numerical tolerances
            tomlabProblem.MIP.cpxControl.DATACHECK = solverParams.DATACHECK;
            tomlabProblem.MIP.cpxControl.DEPIND = solverParams.DEPIND;
            tomlabProblem.MIP.cpxControl.EPRHS = solverParams.feasTol;
            tomlabProblem.MIP.cpxControl.EPOPT = solverParams.optTol;
            tomlabProblem.MIP.cpxControl.EPAGAP = solverParams.absMipGapTol;
            tomlabProblem.MIP.cpxControl.NUMERICALEMPHASIS = solverParams.NUMERICALEMPHASIS;
            % Set initial solution
            tomlabProblem.MIP.xIP = x0;

            % Set up callback to print out intermediate solutions
            % only set this up if you know that you actually need these
            % results.  Otherwise do not specify intSolInd and contSolInd
            global cobraIntSolInd;
            global cobraContSolInd;
            if(~isfield(MILPproblem, 'intSolInd'))
                MILPproblem.intSolInd = [];
            else
                tomlabProblem.MIP.callback(14) = 1;
            end
            cobraIntSolInd = MILPproblem.intSolInd;
            if(~isfield(MILPproblem, 'contSolInd'))
                MILPproblem.contSolInd = [];
            end
            cobraContSolInd = MILPproblem.contSolInd;
            tomlabProblem.MIP.callbacks = [];
            tomlabProblem.PriLevOpt = 0;        


            % Solve problem
            Result = tomRun('cplex', tomlabProblem);

            % Get results
            x = Result.x_k;
            f = osense*Result.f_k;
            stat = Result.Inform;
            if (stat == 101 || stat == 102)
                solStat = 1; % Opt integer within tolerance
            elseif (stat == 103)
                solStat = 0; % Integer infeas
            elseif (stat == 118 || stat == 119)
                solStat = 2; % Unbounded
            elseif (stat == 106 || stat == 106 || stat == 108 || stat == 110 || stat == 112 || stat == 114 || stat == 117)
                solStat = -1; % No integer solution exists
            else
                solStat = 3; % Other problem, but integer solution exists
            end
        case 'mps'
            %% BuildMPS
            % This calls buildMPS and generates a MPS format description of the
            % problem as the result
            % Build MPS Author: Bruno Luong
            % Interfaced with CobraToolbox by Richard Que (12/18/09)
            display('Solver set to MPS. This function will output an MPS matrix string for the MILP problem');
            %Get optional parameters
            [EleNames,EqtNames,VarNames,EleNameFun,EqtNameFun,VarNameFun,PbName,MPSfilename] = ...
                getCobraSolverParams('LP',{'EleNames','EqtNames','VarNames','EleNameFun','EqtNameFun','VarNameFun','PbName','MPSfilename'},parameters);
            %split A matrix for L and E csense
            Ale = A(csense=='L',:);
            ble = b(csense=='L');
            Aeq = A(csense=='E',:);
            beq = b(csense=='E');
            %create index of integer and binary variables
            intIndex = find(vartype=='I');
            binaryIndex = find(vartype=='B');

            %%%%Adapted from BuildMPS%%%%%
            [neq nvar]=size(Aeq);
            nle=size(Ale,1);
            if isempty(EleNames)
                EleNames=arrayfun(EleNameFun,(1:nle),'UniformOutput', false);
            end
            if isempty(EqtNames)
                EqtNames=arrayfun(EqtNameFun,(1:neq),'UniformOutput', false);
            end
            if isempty(VarNames)
                VarNames=arrayfun(VarNameFun,(1:nvar),'UniformOutput', false);
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            [solution] = BuildMPS(Ale, ble, Aeq, beq, c, lb, ub, PbName,'MPSfilename',MPSfilename,'EqtNames',EqtNames,'VarNameFun',VarNameFun,'Integer',intIndex,'Binary',binaryIndex);

            return
        otherwise
            error(['Unknown solver: ' solver]);
    end
    t = etime(clock, t_start);

    %% Store results
    if ~strcmp(solver,'mps')
        if (~isempty(x))
            %xInt = x(MILPproblem.intSolInd);
            %xCont = x(MILPproblem.contSolInd);
            xInt = x(vartype == 'B' | vartype == 'I');
            xCont = x(vartype == 'C');
        end

        solution.cont = xCont;
        solution.int = xInt;
        solution.obj = f;
        solution.solver = solver;
        solution.stat = solStat;
        solution.origStat = stat;
        solution.time = t;
        solution.full = x;
        if(isfield(MILPproblem, 'intSolInd'))
            solution.intInd = MILPproblem.intSolInd;
        end
    end
end