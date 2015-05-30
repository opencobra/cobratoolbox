function [N,R,L,C,p,q,rankS]=fourFundamentalSubpaces(S,printLevel)
% calculate linearly independent bases the four fundamental subspaces of S 
% using LUSOL or SVD
%
% INPUT
% S     m x n stoichiometric matrix defined to be of rank r.
%
% OUTPUT
% N     n x (n-r) null space basis 
%       The null space of S contains all the steady-state flux distributions
%       allowable in the network. The steady-state is of much interest since
%       most homeostatic states are close to being steady-states.
%
% R     n x r row space basis: 
%       The row space of S contains all the dynamic flux distributions
%       of a network, and thus the thermodynamic driving forces that change the
%       rate of reaction activity.
%
% L     m x (m-r) left null space basis:
%       The left null space of S contains all the conservation
%       relationships, or time-invariants, that a network contains. The sum of
%       conserved metabolites or conserved metabolic pools do not change with
%       time and are combinations of concentration variables.
%
% C     m  x r column space basis: 
%       The column space of S contains all the possible time
%       derivatives of the concentration vector, and thus how the thermodynamic
%       driving forces move the concentration state of the network.
%
% rankS r, rank of the stoichiometric matrix      
%
% p     p(1:rankS) gives indices to the linearly independent columns of S
%       p(rankS+1:end) gives indices to the linearly dependent columns of S
%
% q     q(1:rankS) gives indices to the linearly independent rows of S
%       q(rankS+1:end) gives indices to the linearly dependent rows of S

if ~exist('printLevel','var')
    printLevel=1;
end
[m,n]=size(S);

archstr = computer('arch');
%archstr='';
switch archstr
    case {'glnx86','glnxa64'}
        %geometric mean scaling of S by default
        gmscale=1;
        
        %lusol
        nullS   = nullspaceLUSOLform(S,gmscale,printLevel);
        p       = nullS.p;
        q       = nullS.q;
        rankS   = nullS.rank;
        
        %nullspace basis
        V     = speye(n-rankS,n-rankS);       % is a sparse I of order n-rankS.
        N     = nullspaceLUSOLapply(nullS,V); % satisfies S*Z = 0.
        
        %rowspace basis
        R = S(q(1:rankS),:)';
        
        
        %left nullspace basis
        %TODO -Michael
        L = [];
        
        %columnspace basis
        C = S(:,p(1:rankS))';
       
    otherwise
            [U,E,V] = svd(full(S));
            p=[];
            q=[];
            
            eig = diag(E,0);
            tol = max(size(S))*eps(max(eig));
            rankS = sum(eig > tol);
            
            N=V(:,rankS+1:n);
            R=V(:,1:rankS);
            C=U(:,1:rankS)';
            L=U(:,rankS+1:m)';
end