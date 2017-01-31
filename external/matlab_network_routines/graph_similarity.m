% Computes the similarity matrix between two graphs
% Ref: "A measure of similarity between graph vertices:
% applications to synomym extraction and web searching"
% Blondel, SIAM Review, Vol. 46, No. 4, pp. 647-666
% Inputs: A, B - two graphs adjacency matrices, mxm and nxn
% Outputs: S - similarity matrix, mxn
% Last updated: December 11, 2006

function S=graph_similarity(A,B)

m=size(A,1); n=size(B,1);
S=zeros(n,m); S_new=ones(n,m); % initialize S:

while norm(S_new-S,'fro')>0.001
  S=S_new;
  % do an iteration twice
  S_new=(B*S*transpose(A)+transpose(B)*S*A)/norm(B*S*transpose(A)+transpose(B)*S*A,'fro');
  S_new=(B*S_new*transpose(A)+transpose(B)*S_new*A)/norm(B*S_new*transpose(A)+transpose(B)*S_new*A,'fro');
end

S=S_new;