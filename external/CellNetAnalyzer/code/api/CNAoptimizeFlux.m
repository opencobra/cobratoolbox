function [flux_vec, success, status]= CNAoptimizeFlux(cnap, constraints, c_macro, solver, dispval)

% CellNetAnalyzer API function 'CNAoptimizeFlux'
% ---------------------------------------------
% --> flux optimization: ojective function cnap.objFunc is minimized
%       by linear programming (LP)
%
% Usage: [flux_vec, success, status]= CNAoptimizeFlux(cnap, constraints, c_macro, solver, dispval)
% 
% cnap is a CellNetAnalyzer (mass-flow) project variable and mandatory argument. 
% The function accesses the following fields in cnap (see also manual):
%   cnap.stoichmat: the stoichiometric matrix of the network
%   cnap.objFunc: vector containing the coefficients of the reactions in
%     the linear objective function 
%   cnap.numr: number of reactions (columns in cnap.stoichMat)
%   cnap.numis: number of internal species
%   cnap.mue: index of the biosynthesis reaction; can be empty
%   cnap.macroComposition: matrix defining the stoichiometry of
%     the macromolecules with respect to the metabolites (species); matrix
%     element macroComposition(i,j) stores how much of metabolite i (in mmol)
%     is required to synthesize 1 gram of macromolecule j
%   cnap.specInternal: vector with the indices of the internal species
%   cnap.macroDefault: default concentrations of the macromolecules
%   cnap.reacMin: lower boundaries of reaction rates
%       (if reacMin(i)=0 --> reaction i is irreversible)
%   cnap.reacMax: upper boundaries of reaction rates
%
% The other arguments are optional:  
%
%   constraints: constraints is a (numrx1) or empty vetor; if the value 
%     constraints(i) is a number then the flux through reaction i
%     is kept at the given rate during optimization; if the value
%     constraints(i) is NaN then the flux through reaction i is determined
%     by the LP solver (within the bounds given by cnap.reacMin and cnap.reacMax); 
%     if constraints is an empty vector all reaction rates are determined by the LP solver
%     (default: [])
%
%   c_macro: vector containing the macromolecule values (concentrations); 
%     can be empty when cnap.mue or cnap.macroComposition is empty
%     (default: cnap.macroDefault)
%
%   solver: selects the LP solver
%     0: GLPK (glpklp)
%     1: Matlab Optimization Toolbox (linprog)
%     2: CPLEX (cplexlp)
%     (default: 0)
%
%   dispval: controls the output printed to the console
%     0: no output
%     1: regular output
%     2: if solver == 1 then the LP is run a second time starting from random values;
%        when the second result is sufficiently different from the first it
%        can be concluded that the solution is probably not unique
%     (default: 0)
%
% The following results are returned:
%
%   flux_vec: when success == true: result of the optimization
%     when succes == false: NaN if system is not underdetermined or the
%     result returned by the LP solver (may not be meaningful)
%
%   success: flag indicating whether the optimization was successful
%
%   status: solver status; for interpretation check the documentation of
%     the selected LP solver

error(nargchk(1, 5, nargin));

flux_vec= NaN;
success= false;
status= NaN;

%A# default parameters:
cnap.local.rb= zeros(0, 2);
cnap.local.c_makro= cnap.macroDefault;
cnap.local.takelp= 0; %A# GLPK as default because it comes with CNA
cnap.local.dispval= 0;

if(nargin<5)
	dispval=0;
else
	cnap.local.dispval= dispval;
end
if(nargin<4)
	solver=0;
else
      if(~ismember(solver,[0,1,2]))
	   disp('Solver must be 0, 1, or 2.');
           return;
      end
      cnap.local.takelp= solver;
end
if(nargin>2)
    cnap.local.c_makro= c_macro;
end

if nargin > 1
  constraints= reshape(constraints, length(constraints), 1);
  cnap.local.rb= find(~isnan(constraints));
  cnap.local.rb(:, 2)= constraints(cnap.local.rb);
else
  constraints=[];
end

LPavail=LP_solver_availability(true);
if(LPavail(solver+1)==false)
       	solvers={'GLPK (glpk)','MATLAB (linprog)','CPLEX (cplexlp)'};
       	disp(['Solver ',solvers{solver+1},' not found. Please check whether you have porperly installed the toolbox and added the path!']);
       	return;
end

cnap= optimize_flux(cnap);

if numel(cnap.local.erg) == 1 && isnan(cnap.local.erg) %A# system is not underdetermined
  flux_vec= NaN;
  success= false;
  status= NaN;
else
  flux_vec= cnap.local.r_fertig;
  success= cnap.local.LP_success;
  status= cnap.local.LP_status;
end
