function [gvalue, GR, PR, size1, size2, size3] = step2and3(model, targetMet, givenGvalue)
% step2and3 implements Step 2 and Step 3 of TrimGdel. Step 2 minimizes the
% number of deleted genes while keeping the same reactions repressed. Step 3
% trims unnecessary gene deletions while maintaining GR and PR under
% growth-rate maximization.
%
% USAGE:
%
%    [gvalue, GR, PR, size1, size2, size3] = step2and3(model, targetMet, givenGvalue)
%
% INPUTS:
%    model:          COBRA model structure with the fields:
%
%                * .rxns - reaction identifiers (n x 1 cell array)
%                * .mets - metabolite identifiers (m x 1 cell array)
%                * .genes - gene identifiers (g x 1 cell array)
%                * .grRules - gene-protein-reaction association rules (n x 1 cell array)
%                * .S - stoichiometric matrix (m x n, sparse)
%                * .c - linear objective coefficients (n x 1)
%                * .lb - lower flux bounds (n x 1)
%                * .ub - upper flux bounds (n x 1)
%
%    targetMet:      target metabolite identifier (e.g. 'btn_c')
%    givenGvalue:    the (larger) gene-deletion strategy from Step 1. Column 1
%                    lists the genes; column 2 is a 0/1 vector (0 = gene
%                    deleted, 1 = gene retained)
%
% OUTPUTS:
%    gvalue:    the trimmed (smaller) gene-deletion strategy. Column 1 lists
%               the genes; column 2 is a 0/1 vector (0 = gene deleted,
%               1 = gene retained)
%    GR:        the maximum growth rate when the strategy in gvalue is applied
%    PR:        the minimum production rate of the target metabolite under
%               growth-rate maximization when the strategy in gvalue is applied
%    size1:     the number of gene deletions after Step 1
%    size2:     the number of gene deletions after Step 2
%    size3:     the number of gene deletions after Step 3
%
% .. Author:    - Takeyuki Tamura, Mar 06, 2025
%

sss = sprintf('step2and3.mat');
[model, targetRID, extype] = modelSetting(model, targetMet);

m = size(model.mets, 1);
n = size(model.rxns, 1);
g = size(model.genes, 1);
gid = find(model.c);
pid = targetRID;
model2 = model;

[grRules0] = calculateGR(model, givenGvalue);
lb2 = model.lb;
ub2 = model.ub;

for i=1:n
    if grRules0{i, 4} == 0
        lb2(i) = 0;
        ub2(i) = 0;
    end
end

gm0.obj = -model.c;
gm0.A = sparse(model.S);
gm0.rhs = zeros(m, 1);
gm0.modelsense = 'Min';
gm0.sense = repmat('=', 1, m);
gm0.lb = lb2;
gm0.ub = ub2;
% derives the initial maximum GR.
opt0 = solveGurobiViaCobra(gm0);

GR0 = -opt0.objval;
lb2(gid) = GR0;
ub2(gid) = GR0;
model2.c(gid) = 0;
model2.c(pid) = 1;

gm1.obj = -model2.c;
gm1.A = sparse(model.S);
gm1.rhs = zeros(m, 1);
gm1.modelsense = 'Min';
gm1.sense = repmat('=', 1, m);
gm1.lb = lb2;
gm1.ub = ub2;
% derives the initial minimum PR under the GR maximization.
opt1 = solveGurobiViaCobra(gm1);

GRLB = opt1.x(gid);
PRLB = opt1.x(pid);
[term, ng, nt, nr, nko, reactionKO, reactionKO2term] = readGeneRules(model);
[f, A, b, Aeq, beq, lb, ub, xname] = geneReactionMILP(model, term, ng, nt, nr, nko);

lp.Aeq = Aeq;
lp.beq = [zeros(size(lp.Aeq, 1), 1)];
j = 1;
for i=1:size(model.grRules, 1)
    if isempty(model.grRules{i, :}) == 0
        ind(1,j) = i;
        j = j+1;
    end
end
z1 = -diag(model.ub);
z2 = diag(model.lb);
z3 = eye(n);
lp.A = A;
lp.b = b;
lp.lb = lb;
lp.ub = ub;

for i=1:ng
    if givenGvalue{i, 2} == 1
        lp.lb(i, 1) = 1;
        lp.ub(i, 1) = 1;
    end
end

[grRules0] = calculateGR(model, givenGvalue);

j = 1;
for i=1:n
    if isempty(model.grRules{i, 1}) == 0
        lp.lb(ng+nt+j, 1) = grRules0{i, 4};
        lp.ub(ng+nt+j, 1) = grRules0{i, 4};
        j = j + 1;
    end
end

lp.f = [-ones(ng, 1); zeros(nt, 1); zeros(nko, 1)];
for i=1:n
    s2 = repelem('B', ng+nt+nko);
    lp.ctype = sprintf('%s%s', s2);
end

gm.obj = lp.f;
gm.A = sparse([lp.A; lp.Aeq]);
gm.rhs = [lp.b; lp.beq];
gm.modelsense = 'Min';
gm.sense = horzcat(repmat('<', 1, size(lp.A,1)), repmat('=', 1, size(lp.Aeq, 1)));
gm.lb = lp.lb;
gm.ub = lp.ub;
gm.vtype = lp.ctype;
% MILP for Step 2
opt = solveGurobiViaCobra(gm);

gvalue = givenGvalue;
if strcmp(opt.status, 'OPTIMAL')
    for i=1:ng
        vg(i, 1) = opt.x(i);
        gvalue{i, 2} = opt.x(i);
    end
    for i=1:nt
        vt(i, 1) = opt.x(ng+i);
    end
    for i=1:nko
        vko(i, 1) = opt.x(ng+nt+i);
    end
end
gvalue0 = gvalue;

trimmed = 1;
model2 = model;
grprlist(1, 1) = opt1.x(gid);
grprlist(1, 2) = opt1.x(pid);
grprlist(1,3) = opt1.x(gid);
grprlist(1,4) = opt1.x(pid);
k = 2;

while trimmed == 1;
    trimmed = 0;
    for i=1:ng
        i
        if gvalue{i, 2} == 0
            gvalue{i, 2} = 1;
            [grRules2] = calculateGR(model, gvalue);
            lb2 = model.lb;
            ub2 = model.ub;

            for j=1:n
                if grRules2{j, 4} == 0
                    lb2(j) = 0;
                    ub2(j) = 0;
                end
            end

            gm2.obj = -model.c;
            gm2.A = sparse(model.S);
            gm2.rhs = zeros(m, 1);
            gm2.modelsense = 'Min';
            gm2.sense = repmat('=', 1, m);
            gm2.lb = lb2;
            gm2.ub = ub2;
            % evaluate the maximum GR when a gene deletion is trimmed.
            opt2 = solveGurobiViaCobra(gm2);
            

            grprlist(k, 1) = opt2.x(gid);
            grprlist(k, 2) = opt2.x(pid);
            GR2 = -opt2.objval;
            lb2(gid) = GR2;
            ub2(gid) = GR2;
            model2.c(gid) = 0;
            model2.c(pid) = 1;

            gm3.obj = model2.c;
            gm3.A = sparse(model.S);
            gm3.rhs = zeros(m, 1);
            gm3.modelsense = 'Min';
            gm3.sense = repmat('=', 1, m);
            gm3.lb = lb2;
            gm3.ub = ub2;
            % evaluate the minimum PR under the GR maximization when a gene
            % is trimmed.
            opt3 = solveGurobiViaCobra(gm3);
            

            grprlist(k, 3) = opt3.x(gid);
            grprlist(k, 4) = opt3.x(pid);
            if  ((opt3.x(gid) < 0.999 * GRLB) || (opt3.x(pid) < 0.999*PRLB))
                gvalue{i, 2} = 0;
                grprlist(k, :) = grprlist(k-1, :);
                
            else
                trimmed = 1;
               
            end
            GR = grprlist(k, 3);
            PR = grprlist(k, 4);
            k = k+1;
        end
    end
end

gvalueList = horzcat(givenGvalue(:, 2), gvalue0(:, 2), gvalue(:, 2));
size1 = size(find(cell2mat(givenGvalue(:, 2)) == 0), 1);
size2 = size(find(cell2mat(gvalue0(:, 2)) == 0), 1);
size3 = size(find(cell2mat(gvalue(:, 2)) == 0), 1);

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

