% The Laplacian matrix defined for a *simple* graph 
% (the difference b/w the diagonal degree and the adjacency matrices)
% Note: This is not the normalized Laplacian
% INPUTS: adjacency matrix
% OUTPUTs: Laplacian matrix

function L=laplacian_matrix(adj)

L=diag(sum(adj))-adj;


% NORMALIZED Laplacian =============

% n=length(adj);
% deg = sum(adj); % for other than simple graphs, use [deg,~,~]=degrees(adj);

% L=zeros(n);
% edges=find(adj>0);
% 
% for e=1:length(edges)
%     [ii,jj]=ind2sub([n,n],edges(e))
%     if ii==jj; L(ii,ii)=1; continue; end
%     L(ii,jj)=-1/sqrt(deg(ii)*deg(jj));
% end