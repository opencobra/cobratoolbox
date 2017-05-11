function [A, B] = convertHypergraphToBipartiteGraph(S, printLevel)
% convert a hypergraph into an undirected bipartite graph
%
% INPUT
% S         m x n matrix with m nodes and n hyperedges
%
% OUTPUT
% A         m+n x m+n adjacency matrix for an undirected graph (symmetric)
% B         m+n x nnz(S) incidence matrix for a directed graph
%
% Ronan Fleming 2013

if ~exist('printLevel', 'var')
    printLevel = 0;
end

[nMet, nRxn] = size(S);

if printLevel
    tic
end

S = sparse(S);
nnzS = nnz(S);

[row, col, v] = find(S);
numbers = 1:nnzS;
rowIndices = zeros(2 * nnzS, 1);
colIndices = zeros(2 * nnzS, 1);

values = zeros(2 * nnzS, 1);
rowIndices(1:2:end) = row;
colIndices(1:2:end) = numbers;
values(1:2:end) = v;

rowIndices(2:2:end) = nMet + col;
colIndices(2:2:end) = numbers;
values(2:2:end) = sign(v) * -1;

% incidence matrix for a bipartite graph
B = sparse(rowIndices, colIndices, values);
if printLevel
    toc
end

if printLevel
    tic
end

% create the adjacency matrix from undirected incidence matrix
A = inc2adj(B ~= 0);
if printLevel
    toc
end

% sanity check
assert(all(sum(B ~= 0, 1) == 2))
end

% old code
% %converts to bipartite hypergraph
% A=sparse(nMet+nRxn,nMet+nRxn);
%
% for j=1:nRxn
%     for i=1:nMet
%         if S(i,j)~=0
%             A(i,nMet+j)=1;
%             A(nMet+j,i)=1;
%         end
%     end
% end

% old methods
% switch method
% case 1
%     %incidence matrix for a bipartite graph
%     B=sparse(nMet+nRxn,nnzS);
%     k=1;
%     for j=1:nRxn
%         for i=1:nMet
%             if S(i,j)~=0
%                 if S(i,j)<0
%                     B(i,k)=S(i,j);
%                     B(nMet+j,k)=1;
%                 else
%                     B(i,k)=S(i,j);
%                     B(nMet+j,k)=-1;
%                 end
%                 k=k+1;
%
%             end
%         end
%     end
% case 2
%     rowIndices=zeros(2*nnzS,1);
%     colIndices=zeros(2*nnzS,1);
%     values=zeros(2*nnzS,1);
%     k=1;
%     p=1;
%     for j=1:nRxn
%         for i=1:nMet
%             if S(i,j)~=0
%                 if S(i,j)<0
%                     rowIndices(p)=i;
%                     colIndices(p)=k;
%                     values(p)=S(i,j);
%                     p=p+1;
%                     rowIndices(p)=nMet+j;
%                     colIndices(p)=k;
%                     values(p)=1;
%                     p=p+1;
%                 else
%                     rowIndices(p)=i;
%                     colIndices(p)=k;
%                     values(p)=S(i,j);
%                     p=p+1;
%                     rowIndices(p)=nMet+j;
%                     colIndices(p)=k;
%                     values(p)=-1;
%                     p=p+1;
%                 end
%                 k=k+1;
%             end
%         end
%     end

