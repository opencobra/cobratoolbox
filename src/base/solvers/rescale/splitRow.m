function [A, evars, evarlb, evarub, evarc, b, dsense, ctrs] = splitRow(A, ri, evars, evarlb, evarub, evarc, b, dsense, ctrs)
    %   Takes row ri of the constraint matrix A (e.g. -1e6*v1 -v2 + v3 < 0),
    %   identifies the coefficient with largest absolute value, and replaces the row by:
    %     1) a constraint containing only that largest coefficient and a new variable z
    %        (e.g. -1e6*v1 + z < 0)
    %     2) an equality constraint defining z as a combination of the remaining
    %        variables (e.g. z +v2 - v3 = 0)
    %
    %   Inputs:
    %     A        k x n constraint matrix.
    %     ri       Index of the row of A to split
    %     evars    Cell array of existing extra variable IDs
    %     evarlb   Lower bounds of extra variables
    %     evarub   Upper bounds of extra variables
    %     evarc    Objective coefficients of extra variables
    %     b        Right-hand side vector of constraints
    %     dsense   Constraint senses (L,E,G)
    %     ctrs     Cell array of constraint IDs
    %
    %   Outputs:
    %     A        Updated constraint matrix with one extra column and one extra row.
    %     evars    Updated extra variable IDs including the new z variable
    %     evarlb   Updated lower bounds (new z has -Inf)
    %     evarub   Updated upper bounds (new z has Inf)
    %     evarc    Updated objective coefficients (new z has 0)
    %     b        Updated RHS including 0 for the z-definition equality
    %     dsense   Updated senses including 'E' for the z-definition equality
    %     ctrs     Updated constraint IDs with a _splitN suffix for the new row

    r = A(ri, :); % select row to split into other rows, e.g. -v1 -1e6v2 + u2 < 0     
    [~, bigElIdx] = max(abs(r));
    allIdx = find(abs(r)>0); 
    otherIdx = setdiff(allIdx, bigElIdx); % index of all other non-zero elements of that row besides the biggest element 
    other = r(otherIdx);
    A = [A, zeros(size(A, 1), 1)]; % introduce new variable z, for now empty
    evars = [evars; {sprintf('z_%d', sum(startsWith(evars, 'z_')) + 1)}];
    evarlb = [evarlb; -Inf];
    evarub = [evarub; Inf];
    evarc = [evarc; 0];
    % change original row,
    % for e.g. above, change to -1e6*v2 + z < 0:
    A(ri, :) = zeros(1, size(A, 2)); % reset original row
    A(ri, bigElIdx) = r(bigElIdx); % introduce again the biggest element in original row
    A(ri, end) = 1; % add z to original row
    % add additional row that defines the replacemnt variable z,
    % in e.g. above z = u2 -v1 <=> z -u2 + v1 = 0:
    A(end+1, :) = zeros(1, size(A, 2));
    A(end, end) = 1;
    A(end, otherIdx) = -1*other;
    b = [b; 0];
    dsense = [dsense; 'E']; % definition of replacement variable is equality 
    ctrs = [ctrs; {sprintf('%s_split%d', ctrs{ri}, sum(startsWith(ctrs, ctrs{ri})))}];
end

