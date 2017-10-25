function [sol, newActives] = mdFBA(model, varargin)
% Solves an metabolic dilution FBA problem based on the given model
%
% USAGE:
%
%    [sol, newActives] = buildMDFBAProblem(model, varargin)
%
% INPUT:
%    model:         A COBRA style model with the following fields:
%
%                     * S       - Stoichiometric Matrix
%                     * lb      - lower bounds
%                     * ub      - upper bounds
%                     * b       - metabolic constraints
%                     * c       - objective coefficients
%                     * csense  - Constraint senses (optional, default Equality)
%                     * osense  - Optimisation sense (optional, default maximisation)
%
% OPTIONAL INPUTS:
%    varargin:      Variable arguments as parameter/value pairs
%
%                     * 'ignoredMets' - Metabolites that do not need to be
%                       produced, even if used.
%                     * 'minProd' - the minimal production, if a
%                       metabolite is used, default(max(ub,abs(lb))/10000)
%                     * 'getInvalidSolution' - whether to return an invalid
%                       solution, or retrieve an invalid solution that was
%                       obtained in an earlier run. If there is a solution
%                       from a previous run, no calculation will be performed!  (default false)
%
% OUTPUT:
%    sol:           The solution of the MDFBA MILP with the following fields:
%
%                     * obj       - objective value
%                     * solver    - solver used
%                     * stat      - the COBRA status
%                     * origStat  - the original solver status
%                     * time      - the time needed to solve the problem
%                     * full      - the solution of the problem
%                     * additional field depending on the solver used, and
%                       whether an invalid solution is returned.
%
% OPTIONAL OUTPUT:
%    newActives:    Reactions that are only active in mdFBA
%
%
% NOTE:
%
%    Implementation based on description in:
%    `Benyamini et al. "Flux balance analysis accounting for metabolite
%    dilution." Genome Biol. 2010;11(4):R43. doi: 10.1186/gb-2010-11-4-r43`
%
% .. Author:   - Thomas Pfau (June 2017)

persistent ressol

parser = inputParser();
parser.addRequired('model',@isstruct)
parser.addParamValue('ignoredMets',{},@(x) iscell(x) && all(ismember(x,model.mets)));
parser.addParamValue('minProd',max([abs(model.lb);model.ub])/10000,@isnumeric);
parser.addParamValue('getDiffToFBA',false,@(x) isnumeric(x) || islogical(x));
parser.addParamValue('getInvalidSolution',false,@(x) isnumeric(x) || islogical(x));


parser.parse(model,varargin{:});
ignoredMets = parser.Results.ignoredMets;
minprod = parser.Results.minProd;
getInvalidSolution = parser.Results.getInvalidSolution;

if ~isempty(ressol) || getInvalidSolution
    sol = ressol;
    newActives = {};
    return
end
%Create the MILP
mdfbamodel = buildMDFBAProblem(model,'ignoredMets',ignoredMets,'minProd',minprod);
%solve the problem
sol = solveCobraMILP(mdfbamodel);

if sol.stat == 1 || getInvalidSolution
    sol.full = sol.full(1:numel(model.rxns));
    sol = rmfield(sol,'cont');
    sol = rmfield(sol,'int');
else
    ressol = sol;
    error('Could not solve the problem. if you want to get the invalid solution object, run mdFBA(model,''getInvalidSolution'',true)');
end

if nargout == 2
    sol2 = optimizeCbModel(model);
    milptol = getCobraSolverParams('MILP','feasTol');
    lptol = getCobraSolverParams('LP','feasTol');
    newActives = model.rxns(abs(sol2.x <= lptol) & ~abs(sol.full <= milptol));
end
