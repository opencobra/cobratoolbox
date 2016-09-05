function W = nullspaceLUSOLapply2Modes(mode,m,n,V,nullS)
% computes the matrix vector product with the operator nullspace 
% function handle of the form y = pdMat(mode,m,n,x)
% 
% INPUT
% mode       (mode=1)  returns W = Z*V
%            (mode=2)  returns W = Z'*V
% m
% n
% V 
% nullS      structure nullS from the function nullspaceLUSOLform(S);
%            where m x n sparse matrix S (m < n).

% 16 May 2008: (MAS) First version of nullspaceLUSOLapply.m.
%              See nullspaceLUSOLtest.m for testing.
% 13 Mar 2009: (RF) Tried to add matrix vector product of the transpose for
%              use with pdco


if mode==1
    %returns   W = Z*V (mode=1)

    % Second, if V is an (n-m) x k sparse matrix (k >= 1),
    %        W = nullspaceLUSOLapply(nullS,V);
    % computes an n x k sparse matrix W from V such that S*W = 0.
    %
    % This is an operator form of finding an n x (n-m) matrix Z
    % such that S*Z = 0 and then computing W = Z*V.
    % The aim is to obtain W without forming Z explicitly.

    % 16 May 2008: (MAS) First version of nullspaceLUSOLapply.m.
    %              See nullspaceLUSOLtest.m for testing.

    Cinv    = nullS.Cinv; % Column scales
    L       = nullS.L;    % Strictly triangular L
    p       = nullS.p;    % Column permutation for S
    rankS   = nullS.rank; % rank(S)

    [n ,n ] = size(L);
    [mV,nV] = size(V);

    B       = [sparse(rankS,nV)
                V        ];
    Z       = (L')\B;
    W       = Z;
    W(p,:)  = Z;
    W       = Cinv*W;
else
    %returns  W = Z'*V (mode=2).

    % This is an operator form of finding an n x (n-m) matrix Z
    % such that S*Z = 0 and then computing W = Z'*V.
    % The aim is to obtain W without forming Z explicitly.

    % When S is scaled as S = R*A*C, we have Z = Cinv*P'*inv(L')[0;I]
    
    % This was the maths I tried to follow -RF
    %     W   =   A'*V
    %         =   (Cinv*P'*inv(L')[0;I])'*V
    %         =   [0,I]'*inv(L)*P*Cinv'*V
        
        
    Cinv    = nullS.Cinv; % Column scales
    L       = nullS.L;    % Strictly triangular L
    p       = nullS.p;    % Column permutation for S
    rankS   = nullS.rank; % rank(S)

    [n ,n ] = size(L);
    
    V = Cinv'*V;
    
    % I am not sure how to use these permutations
    % e.g. if P*A = B then is it B(p,:)=A or B=A(p,:)
    V(p,:) = V;
%     V(fliplr(p),:) = V;
    
    W = L\V;
    
    W = W(rankS+1:n,:);
    
end

return
