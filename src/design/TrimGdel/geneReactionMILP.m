function [f, A, b, Aeq, beq, lb, ub, xname] = geneReactionMILP(model, term, ng, nt, nr, nko)
% geneReactionMILP is a submodule of gDel_minRN that converts the
% gene-protein-reaction (GPR) relations into the matrices of a
% mixed-integer linear program (MILP).
%
% USAGE:
%
%    [f, A, b, Aeq, beq, lb, ub, xname] = geneReactionMILP(model, term, ng, nt, nr, nko)
%
% INPUTS:
%    model:    COBRA model structure with the field:
%
%                * .genes - gene identifiers (g x 1 cell array)
%
%    term:     struct array of the Boolean-function terms extracted from the
%              GPR rules (as produced by readGeneRules), with the fields:
%
%                * .function - Boolean operator of the term ('and', 'or', 'equal')
%                * .input - input variable name(s) of the term
%                * .output - output variable name of the term
%
%    ng:       number of genes
%    nt:       number of internal terms
%    nr:       number of reactions
%    nko:      number of repressible reactions
%
% OUTPUTS:
%    f:        objective weight vector of the resulting MILP
%    A:        inequality constraint matrix of the MILP (A * x <= b)
%    b:        right-hand side of the inequality constraints (A * x <= b)
%    Aeq:      equality constraint matrix of the MILP (Aeq * x = beq)
%    beq:      right-hand side of the equality constraints (Aeq * x = beq)
%    lb:       lower bounds on the MILP variables (lb <= x <= ub)
%    ub:       upper bounds on the MILP variables (lb <= x <= ub)
%    xname:    variable names in the resulting MILP
%
% .. Author:    - Takeyuki Tamura, Mar 06, 2025
%

n_and = 0; n_or = 0; n_equal = 0;
for i=1:size(term, 2)
    switch char(term(i).function)
        case 'or'
            n_or = n_or+1;
        case 'and'
            n_and = n_and+1;
        case 'equal'
            n_equal = n_equal+1;
    end
end

for i=1:ng
    xname{i,1} = model.genes{i};
end
for i=1:nt+nko
    xname{ng+i, 1} = term(i).output;
end

n_column = ng+nt+nko;
n_row = 2*(n_and + n_or);
A = zeros(n_row, n_column);
b = zeros(n_row, 1);
Aeq = zeros(n_equal, n_column);
beq = zeros(n_equal, 1);
lb = zeros(n_column, 1);
ub = ones(n_column, 1);
intcon = [1:n_column];
f = zeros(n_column, 1);
for i=1:ng+nt
    f(i,1) = 1;
end

jj = 1; kk = 1;
for i=1:size(term, 2)
    
    k = size(term(i).input, 1);    
    x = find(strcmp(xname(:,1), term(i).output));
    switch char(term(i).function)
        case 'or'
            A(jj, x) = -k;
            A(jj+1, x) = 1;
            for j=1:k
                x = find(strcmp(xname(:,1), term(i).input{j}));
                A(jj, x) = 1;
                A(jj+1, x) = -1;
            end
            jj = jj + 2;
                               
        case 'and'
            A(jj, x) = k;
            A(jj+1, x) = -1;
            for j=1:k
                x = find(strcmp(xname(:,1), term(i).input{j}));
                A(jj, x) = -1;
                A(jj+1, x) = 1;
                b(jj+1, 1) = k-1;
            end
            jj = jj + 2;
        case 'equal'
            Aeq(kk, x) = 1;
            x = find(strcmp(xname(:, 1), term(i).input{1}));
            Aeq(kk, x) = -1;
            kk = kk+1;
    end
end
end

