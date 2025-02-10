function [f, intcon, A, b, Aeq, beq, lb, ub, xname] = geneReactionMILP(model, term, ng, nt, nr, nko, reactionKO)
% geneReactionMILP is a submodule to convert GPR relations to MILP.
% Feb. 10, 2025  Takeyuki TAMURA

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

