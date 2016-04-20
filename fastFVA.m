function [minFlux,maxFlux,optsol,ret] = fastFVA(model,optPercentage,objective,solver,matrixAS,cpxControl)
%fastFVA Flux variablity analysis optimized for the GLPK and CPLEX solvers.
%
% [minFlux,maxFlux] = fastFVA(model,optPercentage,objective, solver)
%
% Solves LPs of the form for all v_j: max/min v_j
%                                     subject to S*v = b
%                                     lb <= v <= ub
% Inputs:
%   model             Model structure
%     Required fields
%       S            Stoichiometric matrix
%       b            Right hand side = 0
%       c            Objective coefficients
%       lb           Lower bounds
%       ub           Upper bounds
%     Optional fields
%       A            General constraint matrix
%       csense       Type of constraints, csense is a vector with elements
%                    'E' (equal), 'L' (less than) or 'G' (greater than).
%     If the optional fields are supplied, following LPs are solved
%                    max/min v_j
%                    subject to Av {'<=' | '=' | '>='} b
%                                lb <= v <= ub
%
%   optPercentage    Only consider solutions that give you at least a certain
%                    percentage of the optimal solution (default = 100
%                    or optimal solutions only)
%   objective        Objective ('min' or 'max') (default 'max')
%   solver           'cplex' or 'glpk' (default 'glpk')
%   matrixAS         'A' or 'S' - choice of the model matrix, coupled (A) or uncoupled (S)
%   numThread        Number of the thread, appended to the CPLEX logFile for debugging
%
% Outputs:
%   minFlux   Minimum flux for each reaction
%   maxFlux   Maximum flux for each reaction
%   optsol    Optimal solution (of the initial FBA)
%   ret       Zero if success
%
% Example:
%    load modelRecon1Biomass.mat % Human reconstruction network
%    SetWorkerCount(4) % Only if you have the parallel toolbox installed
%    [minFlux,maxFlux] = fastFVA(model, 90);
%
% Reference: "Computationally efficient Flux Variability Analysis"

% Author: Steinn Gudmundsson.
% Contributor: Laurent Heirendt, LCSB.
% Last updated: April 2016

verbose=1;
if nargin<6, cpxControl     = struct([]); end
if nargin<5, matrixAS       = 'S';        end
if nargin<4, solver         = 'glpk';     end
if nargin<3, objective      = 'max';      end
if nargin<2, optPercentage  = 100;        end

% Define the objective
if strcmpi(objective,'max')
   obj=-1;
elseif strcmpi(objective,'min')
   obj=1;
else
   error('Unknown objective')
end;

% Define the solver
if strmatch('glpk',solver)
   FVAc=@glpkFVAcc;
elseif strmatch('cplex',solver)
   FVAc=@cplexFVAc;
else
   error(sprintf('Solver %s not supported', solver))
end;

% Define the CPLEX parameter set and the associated values - split the struct
namesCPLEXparams    = fieldnames(cpxControl);
nCPLEXparams        = length(namesCPLEXparams);
valuesCPLEXparams   = zeros(nCPLEXparams,1);
for i =1:nCPLEXparams
  valuesCPLEXparams(i) = getfield(cpxControl, namesCPLEXparams{i});
end

% Define the stoichiometric matrix to be solved
if isfield(model,'A') && (matrixAS == 'A')
   % "Generalized FBA"
   A = model.A;
   csense = model.csense(:);
   b = model.b;
   fprintf(' >> Generalized FBA - Solving Model.A. (coupled) \n')
else
   % Standard FBA
   A = model.S;
   csense = char('E'*ones(size(A,1),1));
   b = model.b;
   b = b(1:size(A,1));
   fprintf(' >> Standard FBA - Solving Model.S. (uncoupled) \n')
end

[m,n]=size(A);
fprintf(' >> Size of stoichiometric matrix: (%d,%d)\n', m,n)

% Create a MATLAB parallel pool
poolobj = gcp('nocreate'); % If no pool, do not create new one.
if isempty(poolobj)
    nworkers = 0;
else
    nworkers = poolobj.NumWorkers;
end;

if nworkers<=1
   % Sequential version
   [minFlux,maxFlux,optsol,ret]=FVAc(model.c,A,b,csense,model.lb,model.ub, ...
                                     optPercentage,obj,(1:n)');

   if ret ~= 0 && verbose
      fprintf('Unable to complete the FVA, return code=%d\n', ret);
   end;
else
   % Divide the reactions amongst workers
   %
   % The load balancing can be improved for certain problems, e.g. in case
   % of problems involving E-type matrices, some workers will get mostly
   % well-behaved LPs while others may get many badly scaled LPs.

   nrxn=repmat(fix(n/nworkers),nworkers,1);
   i=1;
   while sum(nrxn) < n
      nrxn(i)=nrxn(i)+1;
      i=i+1;
   end
   assert(sum(nrxn)==n);
   istart=1; iend=nrxn(1);
   for i=2:nworkers
      istart(i)=iend(i-1)+1;
      iend(i)=istart(i)+nrxn(i)-1;
   end

   minFlux = zeros(n,1); maxFlux=zeros(n,1);
   iopt = zeros(nworkers,1);
   iret = zeros(nworkers,1);

   fprintf('\n -- Starting to loop through the %d workers. -- \n', nworkers);

   out = parfor_progress(nworkers);

   parfor i = 1:nworkers

      t = getCurrentTask();

      fprintf('\n----------------------------------------------------------------------------------\n');
      fprintf(' --  TaskID: %d / %d (LoopID = %d) <> [%d, %d] / [%d, %d]\n', ...
              t.ID, nworkers, i, istart(i), iend(i), m, n);

      tstart = tic;

      [minf,maxf,iopt(i),iret(i)] = FVAc(model.c,A,b,csense,model.lb,model.ub, ...
                                         optPercentage,obj,(istart(i):iend(i))', ...
                                         t.ID, cpxControl, valuesCPLEXparams);

      fprintf(' >> Time spent in FVAc: %1.1f seconds.', toc(tstart));

      % Storing the matrix
      outArray0(i) = i;
      %outArray1(i) = t.iD;
      outArray2(i) = istart(i);
      outArray3(i) = iend(i);
      outArray4(i) = iopt(i);

      if iret(i) ~= 0 && verbose
         fprintf('Problems solving partition %d, return code=%d\n', i, iret(i))
      end

      minFlux=minFlux+minf;
      maxFlux=maxFlux+maxf;

      %responsiveWorkers(i) = 1;

      fprintf('\n----------------------------------------------------------------------------------\n');


      % print out the percentage of the progress
      percout =   parfor_progress;

      if(percout < 100)
        fprintf(' ==> %1.1f%% done. Please wait ...\n', percout);
      else
        fprintf(' ==> 100%% done. Analysis completed.\n', percout);
      end

   end;

   out = parfor_progress(0);

   %outputData = struct('outArray0',outArray0,'outArray2',outArray2,'outArray3',outArray3,'outArray4',outArray4)

   optsol=iopt(1);
   ret=max(iret);
end;
