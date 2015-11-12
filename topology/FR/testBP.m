% decompose B into F and R
[row,col] = find(B<0);
F = sparse(row,col,1);

[row,col] = find(B>0);
R = sparse(row,col,1);

FR = [F,R];

% remove all columns of FR with all zeros or a single nonzero entry
J = find(sum(FR,1)>1);
FR = FR(:,J);

% create graph whose incidence matrix is FR
A = inc2adj(FR');
A(find(A>1))=1;

% find all connected components of A
[ci sizes] = components(A);

%ignore connected components with 1 or 2 nodes
K = find(sizes>2);

% test each connected component for bipartiteness
for i = 1:length(K)

    % find nodes in the i-th component
    I = find(ci==K(i));
    
    % NOTE: adj2adjL is slow for large components
    % test only relatively small components
    if numel(I)<100
      if isbipartite(adj2adjL(A(I,I)))
        disp('bipartite component:'); disp(I')
      end
    end
    
end

