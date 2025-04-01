function [f, A, b, Aeq, beq, lb, ub, xname] = geneReactionMILP(model, term, ng, nt, nr, nko)
% geneReactionMILP is a submodule to convert GPR relations to MILP.
%
% USAGE:
%
%    function [f, A, b, Aeq, beq, lb, ub, xname] 
%               = geneReactionMILP(model, term, ng, nt, nr, nko)
%
% INPUTS:
%    model:     COBRA model structure containing the following required fields to perform gDel_minRN.
%
%        *.rxns:        Rxns in the model
%        *.mets:        Metabolites in the model
%        *.genes:       Genes in the model
%        *.grRules:     Gene-protein-reaction relations in the model
%        *.S:           Stoichiometric matrix (sparse)
%        *.b:           RHS of Sv = b (usually zeros)
%        *.c:           Objective coefficients
%        *.lb:          Lower bounds for fluxes
%        *.ub:          Upper bounds for fluxes
%        *.rev:         Reversibility of fluxes
%
%    term:    the list of Boolean functions extracted from the gene-protein-reaction relations
%    ng:      the number of genes
%    nt:      the number of internal terms
%    nr:      the number of reactions
%    nko:     the number of repressible reactions
% 
% OUTPUTS:
%    f:    the weighted vector for the objective function of the resulting MILP.
%    A, b, Aeq, beq, lb, ub:    correspond to each matrix included in the
%                               following part of the MILP constraints.
%
%                                   A*x <= b
%                                   Aeq*x=beq
%                                   lb <= x <= ub
% 
%    xname:    variable names in the resulting MILP. 
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

