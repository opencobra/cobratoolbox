function [minFlux,maxFlux,Vmin,Vmax] = fluxVariability(model,optPercentage,osenseStr,rxnNameList,verbFlag, allowLoops, method)
% Performs flux variablity analysis
%
% USAGE:
%
% [minFlux,maxFlux] = fluxVariability(model,optPercentage,osenseStr,rxnNameList,verbFlag, allowLoops, method)
%
% INPUT:
%    model:             COBRA model structure
%
% OPTIONAL INPUTS:
%    optPercentage:     Only consider solutions that give you at least a certain
%                       percentage of the optimal solution (Default = 100
%                       or optimal solutions only)
%    osenseStr:         Objective sense ('min' or 'max') (Default = 'max')
%    rxnNameList:       List of reactions for which FVA is performed
%                       (Default = all reactions in the model)
%    verbFlag:          Verbose output (opt, default false)
%    allowLoops:        Whether loops are allowed in solution. (Default = true)
%                       See `optimizeCbModel` for description
% method            when Vmin and Vmax are in the output, the flux vector can be
%                   'FBA'    : standards FBA solution
%                   '0-norm' : minimzes the vector  0-norm
%                   '1-norm' : minimizes the vector 1-norm
%                   '2-norm' : minimizes the vector 2-norm
%                   'minOrigSol' : minimizes the euclidean distance of each
%                   vector to the original solution vector
%                   (Default = 2-norm)
% 
% OUTPUTS:
%    minFlux:           Minimum flux for each reaction
%    maxFlux:           Maximum flux for each reaction
%
% OPTIONAL OUTPUT:
%    Vmin:              Matrix of column flux vectors, where each column is a
%                       separate minimization.
%    Vmax:              Matrix of column flux vectors, where each column is a
%                       separate maximization.
%
% .. Authors:
%       - Markus Herrgard  8/21/06 Original code.
%       - Ronan Fleming   01/20/10 Take the extremal flux from the flux vector,
%                         not from the objective since this is invariant
%                         to the value and sign of the coefficient
%       - Ronan Fleming   27/09/10 Vmin, Vmax
% Marouen Ben Guebila 22/02/2017 Vmin,Vmax method

if (nargin < 2)
    optPercentage = 100;
end
if (nargin < 3)
    if isfield(model,'osenseStr')
        osenseStr = model.osenseStr
    else
        osenseStr = 'max';
    end
end
if (nargin < 4)
    rxnNameList = model.rxns;
end
if (nargin < 5)
    verbFlag = false;
end
if (nargin < 6)
    allowLoops = true;
end
if (nargin < 7)
    method = '2-norm';
end
if (isempty(optPercentage))
    optPercentage = 100;
end
if (isempty(osenseStr))
    osenseStr = 'max';
end
if (isempty(rxnNameList))
    rxnNameList = model.rxns;
end
% Set up the problem size
[nMets,nRxns] = size(model.S);
Vmin=[];
Vmax=[];
if nargout > 2
    OutputMatrix = 1;
else
    OutputMatrix = 0;
end

% LP solution tolerance
global CBT_LP_PARAMS
if (exist('CBT_LP_PARAMS', 'var'))
    if isfield(CBT_LP_PARAMS, 'objTol')
        tol = CBT_LP_PARAMS.objTol;
    else
        tol = 1e-6;
    end
    if isfield(CBT_LP_PARAMS, 'minNorm')
        minNorm = CBT_LP_PARAMS.minNorm;
    else
        minNorm = 0;
    end
end

% Determine constraints for the correct space (0-100% of the full space)
if (sum(model.c ~= 0) > 0)
    hasObjective = true;
    optSol = optimizeCbModel(model,osenseStr, 0, allowLoops);
    if (optSol.stat > 0)
        objRxn = model.rxns(model.c~=0);
        if (strcmp(osenseStr,'max'))
            objValue = floor(optSol.f/tol)*tol*optPercentage/100;
        else
            objValue = ceil(optSol.f/tol)*tol*optPercentage/100;
        end
    else
        error('Infeasible problem - no optimal solution!');
    end
else
    hasObjective = false;
end

if (verbFlag == 1)
    showprogress(0,'Flux variability analysis in progress ...');
end
if (verbFlag > 1)
    fprintf('%4s\t%4s\t%10s\t%9s\t%9s\n','No','Perc','Name','Min','Max');
end

if (~isfield(model,'b'))
    model.b = zeros(size(model.S,1),1);
end
% Set up the general problem
rxnListFull = model.rxns;
LPproblem.c = model.c;
LPproblem.lb = model.lb;
LPproblem.ub = model.ub;
LPproblem.csense(1:nMets) = 'E';
LPproblem.csense = LPproblem.csense';
if hasObjective
    LPproblem.A = [model.S;columnVector(model.c)'];
    LPproblem.b = [model.b;objValue];
    if (strcmp(osenseStr,'max'))
        LPproblem.csense(end+1) = 'G';
    else
        LPproblem.csense(end+1) = 'L';
    end
else
    LPproblem.A = model.S;
    LPproblem.b = model.b;
end

LPproblem.S = LPproblem.A;%needed for sparse optimisation

%solve to generate initial basis
LPproblem.osense = -1;
tempSolution = solveCobraLP(LPproblem);
LPproblem.basis = tempSolution.basis;

% Loop through reactions
maxFlux = zeros(length(rxnNameList), 1);
minFlux = zeros(length(rxnNameList), 1);

if length(minNorm)> 1 || minNorm > 0
    %minimizing the Euclidean norm gets rid of the loops, so there
    %is no need for a second slower MILP approach
    allowLoops=1;
end

solutionPool = zeros(length(model.lb), 0);

v=ver;
PCT = 'Parallel Computing Toolbox';
if  any(strcmp(PCT,{v.Name}))&&license('test','Distrib_Computing_Toolbox')    
    p = gcp('nocreate');
    if isempty(p)
        poolsize = 0;
    else
        poolsize = p.NumWorkers
    end
    PCT_status=1;
else
     PCT_status=0;  % Parallel Computing Toolbox not found.
end

if ~PCT_status &&(~exist('parpool') || poolsize == 0)  %aka nothing is active
    m = 0;
    for i = 1:length(rxnNameList)
        if mod(i,10) == 0, clear mex, end
        if (verbFlag == 1),fprintf('iteration %d.  skipped %d\n', i, round(m));end
        LPproblem.c = zeros(nRxns,1);
        LPproblem.c(i) = 1; %no need to set this more than 1
        % do LP always
        LPproblem.osense = -1;
        LPsolution = solveCobraLP(LPproblem);
        %take the maximum flux from the flux vector, not from the obj -Ronan
        if LPsolution.full(LPproblem.c~=0)<LPproblem.lb(i) %takes out tolerance issues 
            maxFlux(i) = LPproblem.lb(i);
        elseif LPsolution.full(LPproblem.c~=0)>LPproblem.ub(i)
            maxFlux(i) = LPproblem.ub(i);
        else
            maxFlux(i) = LPsolution.full(LPproblem.c~=0);
        end
        
        if OutputMatrix && isequal(method,'2-norm') && length(minNorm)==1
            minNorm=ones(nRxns,1)*minNorm;
        end
    
        %minimise the Euclidean norm of the optimal flux vector to remove
        %loops -Ronan
        if OutputMatrix && isequal(method,'2-norm') && (length(minNorm)> 1 || minNorm > 0 )
            QPproblem=LPproblem;
            QPproblem.lb(LPproblem.c~=0)=maxFlux(i)-1e-12;
            QPproblem.ub(LPproblem.c~=0)=maxFlux(i)+1e12;
            QPproblem.c(:)=0;
            %Minimise Euclidean norm using quadratic programming
            if length(minNorm)==1
                minNorm=ones(nRxns,1)*minNorm;
            end
            QPproblem.F = spdiags(minNorm,0,nRxns,nRxns);
            %quadratic optimization
            solution = solveCobraQP(QPproblem);
            Vmax(:,i)=solution.full(1:nRxns,1);
        elseif (OutputMatrix && isequal(method,'1-norm'))
            i
            vSparse = sparseFBA(LPproblem,'max',0,0,'l1');
            Vmax(:,i) = vSparse;
        elseif (OutputMatrix && isequal(method,'0-norm'))
            vSparse = sparseFBA(LPproblem,'max',0,0);
            Vmax(:,i) = vSparse;
        elseif (OutputMatrix && isequal(method,'FBA'))
            Vmax(:,i) = LPsolution.full;
        elseif (OutputMatrix && isequal(method,'minOrigSol'))
            LPproblemMOMA = LPproblem;
            LPproblemMOMA=rmfield(LPproblemMOMA,'csense');
            LPproblemMOMA.A = model.S;
            LPproblemMOMA.S = LPproblemMOMA.A;
            LPproblemMOMA.b = model.b;
            LPproblemMOMA.lb(find(model.c)) = objValue;
            LPproblemMOMA.lb(i) = maxFlux(i);
            LPproblemMOMA.ub(i) = maxFlux(i);
            LPproblemMOMA.rxns = model.rxns;
            momaSolution = linearMOMA(model,LPproblemMOMA);
            Vmax(:,i)=momaSolution.x;
        end

        LPproblem.osense = 1;
        LPsolution = solveCobraLP(LPproblem);
        %take the maximum flux from the flux vector, not from the obj -Ronan
        if LPsolution.full(LPproblem.c~=0)<LPproblem.lb(i) %takes out tolerance issues 
            minFlux(i) = LPproblem.lb(i);
        elseif LPsolution.full(LPproblem.c~=0)>LPproblem.ub(i)
            minFlux(i) = LPproblem.ub(i);
        else
            minFlux(i) = LPsolution.full(LPproblem.c~=0);
        end
        

        %minimise the Euclidean norm of the optimal flux vector to remove
        %loops
        if OutputMatrix && isequal(method,'2-norm') && (length(minNorm)> 1 || minNorm > 0)
            QPproblem=LPproblem;
            QPproblem.lb(LPproblem.c~=0)=maxFlux(i)-1e-12;
            QPproblem.ub(LPproblem.c~=0)=maxFlux(i)+1e12;
            QPproblem.c(:)=0;
            QPproblem.F = spdiags(minNorm,0,nRxns,nRxns);
            %Minimise Euclidean norm using quadratic programming
            if length(minNorm)==1
               minNorm=ones(nRxns,1)*minNorm;
            end
            QPproblem.F = spdiags(minNorm,0,nRxns,nRxns);
            %quadratic optimization
            solution = solveCobraQP(QPproblem);
            Vmin(:,i)=solution.full(1:nRxns,1);
        elseif (OutputMatrix && isequal(method,'1-norm'))
            vSparse = sparseFBA(LPproblem,'min',0,0,'l1');
            Vmin(:,i) = vSparse;
        elseif (OutputMatrix && isequal(method,'0-norm'))
            vSparse = sparseFBA(LPproblem,'min',0,0);
            Vmin(:,i) = vSparse;
        elseif (OutputMatrix && isequal(method,'FBA'))
            Vmin(:,i)=LPsolution.full;
        elseif (OutputMatrix && isequal(method,'minOrigSol'))
                LPproblemMOMA = LPproblem;
                LPproblemMOMA=rmfield(LPproblemMOMA,'csense');
                LPproblemMOMA.A = model.S;
                LPproblemMOMA.S = LPproblemMOMA.A;
                LPproblemMOMA.b = model.b;
                LPproblemMOMA.lb(find(model.c)) = objValue;
                LPproblemMOMA.lb(i) = minFlux(i);
                LPproblemMOMA.ub(i) = minFlux(i);
                LPproblemMOMA.rxns = model.rxns;
                momaSolution = linearMOMA(model,LPproblemMOMA);
                Vmin(:,i)=momaSolution.x;
        end

        if ~allowLoops
            if any( abs(LPproblem.c'*solutionPool - maxFlux(i)) < tol) % if any previous solutions are good enough.
                % no need to do anything.
                m = m+.5;
            else
                LPproblem.osense = -1;
                LPsolution = solveCobraMILP(addLoopLawConstraints(LPproblem, model));
                maxFlux(i) = LPsolution.obj/1000;
            end
            if any( abs(LPproblem.c'*solutionPool - minFlux(i)) < tol)
                m = m+.5;
                % no need to do anything.
            else
                LPproblem.osense = 1;
                LPsolution = solveCobraMILP(addLoopLawConstraints(LPproblem, model));
                minFlux(i) = LPsolution.obj/1000;
            end
        end
        if (verbFlag == 1)
            showprogress(i/length(rxnNameList));
        end
        if (verbFlag > 1)
            fprintf('%4d\t%4.0f\t%10s\t%9.3f\t%9.3f\n',i,100*i/length(rxnNameList),rxnNameList{i},minFlux(i),maxFlux(i));
        end
    end
else % parallel job.  pretty much does the same thing.
    
    global CBT_LP_SOLVER;
    solver = CBT_LP_SOLVER;

    if OutputMatrix && isequal(method,'2-norm') && length(minNorm)==1
        minNorm=ones(nRxns,1)*minNorm;
    end
                        
    parfor i = 1:length(rxnNameList)
        changeCobraSolver(solver,'QP',0);
        %if mod(i,10) == 0, clear mex, end
        %if (verbFlag == 1),fprintf('iteration %d.  skipped %d\n', i, round(m));end
        c = zeros(nRxns,1);
        c(strcmp(rxnListFull,rxnNameList{i})) = 1000;
        if allowLoops % do LP
            LPsolution = solveCobraLP(struct(...
                'A', LPproblem.A,...
                'b', LPproblem.b,...
                'lb', LPproblem.lb,...
                'ub', LPproblem.ub,...
                'csense', LPproblem.csense,...
                'c',c,...
                'osense',-1, ...
                'basis', LPproblem.basis ...
            ),'solver',solver);
        
            %take the maximum flux from the flux vector, not from the obj -Ronan           
            if LPsolution.full(c~=0)<LPproblem.lb(i) %takes out tolerance issues 
                maxFlux(i) = LPproblem.lb(i);
            elseif LPsolution.full(c~=0)>LPproblem.ub(i)
                maxFlux(i) = LPproblem.ub(i);
            else
                maxFlux(i) = LPsolution.full(c~=0);
            end
            
            %copies of the original model for each worker
            parModel = model;
            
            if OutputMatrix && isequal(method,'2-norm') && (length(minNorm)> 1 || minNorm > 0)
               QPproblem=LPproblem;
               QPproblem.lb(LPproblem.c~=0)=maxFlux(i)-1e-12;
               QPproblem.ub(LPproblem.c~=0)=maxFlux(i)+1e12;
               QPproblem.c(:)=0;
               %Minimise Euclidean norm using quadratic programming
               QPproblem.F = spdiags(minNorm,0,nRxns,nRxns);
               %quadratic optimization
               solution = solveCobraQP(QPproblem);
               Vmax(:,i)=solution.full(1:nRxns,1);
            elseif (OutputMatrix && isequal(method,'1-norm'))
                vSparse = sparseFBA(LPproblem,'max',0,0,'l1');
                Vmax(:,i) = vSparse;
            elseif (OutputMatrix && isequal(method,'0-norm'))
                vSparse = sparseFBA(LPproblem,'max',0,0);
                Vmax(:,i) = vSparse;
            elseif (OutputMatrix && isequal(method,'FBA'))
                Vmax(:,i) = LPsolution.full;
            elseif (OutputMatrix && isequal(method,'minOrigSol'))
                LPproblemMOMA = parModel;
                LPproblemMOMA.c = zeros(nRxns,1);
                LPproblemMOMA.c(i) = 1;
                LPproblemMOMA.osense = -1;
                LPproblemMOMA.A = parModel.S;
                LPproblemMOMA.S = LPproblemMOMA.A;
                LPproblemMOMA.b = parModel.b;
                LPproblemMOMA.lb(find(parModel.c)) = objValue;
                LPproblemMOMA.rxns = parModel.rxns;
                momaSolution = linearMOMA(parModel,LPproblemMOMA);
                momaSolution
                Vmax(:,i)=momaSolution.x;
            end
                        
            %LPproblemb.osense = 1;
            LPsolution = solveCobraLP(struct(...
                'A', LPproblem.A,...
                'b', LPproblem.b,...
                'lb', LPproblem.lb,...
                'ub', LPproblem.ub,...
                'csense', LPproblem.csense,...
                'c',c,...
                'osense',1, ... %only part that's different.
                'basis', LPproblem.basis ...
            ),'solver',solver);
        
            if LPsolution.full(c~=0)<LPproblem.lb(i) %takes out tolerance issues 
                minFlux(i) = LPproblem.lb(i);
            elseif LPsolution.full(c~=0)>LPproblem.ub(i)
                minFlux(i) = LPproblem.ub(i);
            else
                minFlux(i) = LPsolution.full(c~=0);
            end
            
            %minimise the Euclidean norm of the optimal flux vector to remove
            %loops
            if OutputMatrix && isequal(method,'2-norm') && (length(minNorm)> 1 || minNorm > 0)
                QPproblem=LPproblem;
                QPproblem.lb(LPproblem.c~=0)=maxFlux(i)-1e-12;
                QPproblem.ub(LPproblem.c~=0)=maxFlux(i)+1e12;
                QPproblem.c(:)=0;
                QPproblem.F = spdiags(minNorm,0,nRxns,nRxns);
                %Minimise Euclidean norm using quadratic programming
                QPproblem.F = spdiags(minNorm,0,nRxns,nRxns);
                %quadratic optimization
                solution = solveCobraQP(QPproblem);
                Vmin(:,i)=solution.full(1:nRxns,1);
            elseif (OutputMatrix && isequal(method,'1-norm'))
                vSparse = sparseFBA(LPproblem,'min',0,0,'l1');
                Vmin(:,i) = vSparse;
            elseif (OutputMatrix && isequal(method,'0-norm'))
                vSparse = sparseFBA(LPproblem,'min',0,0);
                Vmin(:,i) = vSparse;
            elseif (OutputMatrix && isequal(method,'FBA'))
                Vmin(:,i)=LPsolution.full;
            elseif (OutputMatrix && isequal(method,'minOrigSol'))
                LPproblemMOMA   = LPproblem;
                LPproblemMOMA.c = zeros(nRxns,1);
                LPproblemMOMA.c(i)   = 1;
                LPproblemMOMA.osense = +1;
                LPproblemMOMA.A = parModel.S;
                LPproblemMOMA.S = LPproblemMOMA.A;
                LPproblemMOMA.b = parModel.b;
                LPproblemMOMA.lb(find(parModel.c)) = objValue;
                LPproblemMOMA.rxns = parModel.rxns;
                momaSolution = linearMOMA(parModel,LPproblemMOMA);
                momaSolution
                Vmin(:,i)=momaSolution.x;
            end
        
        else
            LPsolution = solveCobraMILP(addLoopLawConstraints(struct(...
                'A', LPproblem.A,...
                'b', LPproblem.b,...
                'lb', LPproblem.lb,...
                'ub', LPproblem.ub,...
                'csense', LPproblem.csense,...
                'c',c,...
                'osense',-1 ...
            ), model));
            maxFlux(i) = LPsolution.obj/1000;

            LPsolution = solveCobraMILP(addLoopLawConstraints(struct(...
                'A', LPproblem.A,...
                'b', LPproblem.b,...
                'lb', LPproblem.lb,...
                'ub', LPproblem.ub,...
                'csense', LPproblem.csense,...
                'c',c,...
                'osense',1 ...
            ), model));%
            minFlux(i) = LPsolution.obj/1000;
        end
    end
end

maxFlux = columnVector(maxFlux);
minFlux = columnVector(minFlux);
