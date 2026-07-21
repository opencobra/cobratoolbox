function [GR, PR] = GRPRchecker(model, targetMet, gvalue)
% GRPRchecker computes the maximum growth rate (GR) and the minimum
% production rate (PR) under GR maximization for a given constraint-based
% model, target metabolite, and gene-deletion strategy.
%
% USAGE:
%
%    [GR, PR] = GRPRchecker(model, targetMet, gvalue)
%
% INPUTS:
%    model:        COBRA model structure with the fields:
%
%                * .rxns - reaction identifiers (n x 1 cell array)
%                * .mets - metabolite identifiers (m x 1 cell array)
%                * .genes - gene identifiers (g x 1 cell array)
%                * .S - stoichiometric matrix (m x n, sparse)
%                * .c - linear objective coefficients (n x 1)
%                * .lb - lower flux bounds (n x 1)
%                * .ub - upper flux bounds (n x 1)
%
%    targetMet:    target metabolite identifier (e.g. 'btn_c')
%    gvalue:       gene-deletion strategy. Column 1 lists the genes; column 2
%                  is a 0/1 vector (0 = gene deleted, 1 = gene retained)
%
% OUTPUTS:
%    GR:    the maximum growth rate for the given gene-deletion strategy
%    PR:    the minimum target-metabolite production rate under growth-rate
%           maximization for the given gene-deletion strategy
%
% .. Author:    - Takeyuki Tamura, Mar 06, 2025
%

[model, targetRID, extype] = modelSetting(model, targetMet);

m = size(model.mets, 1);
n = size(model.rxns, 1);
g = size(model.genes, 1);
gid = find(model.c);
pid = targetRID;


model2 = model;
[grRules0] = calculateGR(model, gvalue);
lb2 = model.lb;
ub2 = model.ub;

for i=1:n
    if grRules0{i, 4} == 0
        lb2(i) = 0;
        ub2(i) = 0;
    end
end

gm.A = sparse(model.S);
gm.obj = -model.c;
gm.modelsense = 'Min';
gm.sense = repmat('=', 1, size(model.S, 1));
gm.lb = lb2;
gm.ub = ub2;
opt0 = solveGurobiViaCobra(gm);

[opt0.x(gid) opt0.x(pid)]

GR0 = -opt0.objval;
lb2(gid) = GR0;
ub2(gid) = GR0;
model2.c(gid) = 0;
model2.c(pid) = 1;

gm2.A = sparse(model.S);
gm2.obj = model2.c;
gm2.modelsense = 'Min';
gm2.sense = repmat('=', 1, size(model.S, 1));
gm2.lb = lb2;
gm2.ub = ub2;
opt1 = solveGurobiViaCobra(gm2);

GR = GR0
PR = opt1.x(pid)
[GR PR]

return;
end

function result = solveGurobiViaCobra(gurobiProblem, varargin)
% Route a Gurobi-style problem struct through the COBRA solver abstraction
% (solveCobraLP for a continuous problem, solveCobraMILP when .vtype is
% present) so TrimGdel honours changeCobraSolver. Returns a struct exposing
% the Gurobi result fields consumed here: .status ('OPTIMAL' when optimal),
% .objval, and .x. (feature 015-solver-spine-hardening)

problem.A = gurobiProblem.A;
problem.c = gurobiProblem.obj;
if isfield(gurobiProblem, 'rhs') && ~isempty(gurobiProblem.rhs)
    problem.b = gurobiProblem.rhs;
else
    problem.b = zeros(size(gurobiProblem.A, 1), 1);   % Gurobi defaults rhs to 0
end
problem.lb = gurobiProblem.lb;
problem.ub = gurobiProblem.ub;
if isfield(gurobiProblem, 'modelsense') && strcmpi(gurobiProblem.modelsense, 'Max')
    problem.osense = -1;
else
    problem.osense = 1;   % 'Min' (Gurobi default)
end
csense = gurobiProblem.sense(:);
csense(csense == '<') = 'L';
csense(csense == '>') = 'G';
csense(csense == '=') = 'E';
problem.csense = csense;

if isfield(gurobiProblem, 'vtype')
    problem.vartype = gurobiProblem.vtype(:);
    solution = solveCobraMILP(problem, varargin{:});
else
    solution = solveCobraLP(problem, varargin{:});
end

if isnumeric(solution.stat) && solution.stat == 1
    result.status = 'OPTIMAL';
else
    result.status = 'NOT_OPTIMAL';
end
result.objval = solution.obj;
result.x = solution.full;
end

