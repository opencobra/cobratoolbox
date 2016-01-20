function [Z,rankS]=getNullSpace(S,printLevel,rankS,tol)
%calculate the nullspace of S for full(S) or rank(S)==m
%If full row rank i.e. rank(S)=m, it's much faster to work with a sparse LU.
%
%INPUT
% S         m x n stoichiometric matrix
%
%OPTIONAL INPUT
% printLevel    {0,(1)}, 0 means quiet
% rankS         scalar giving rank of S
% tol           upper bound on tolerance of linear independence,default
%               no greater than 1e-12
%
%OUTPUT
% Z      (right) null space of S (when m <= n, otherwise [])
%
% Ronan Fleming, with linear algebra advice from Michael Saunders
% Dept of Management Science and Engineering (MS&E)
% Stanford University

if ~exist('printLevel','var')
    printLevel=1;
end

[m,n]   = size(S);

%commented this out on July 12th 2012
% if m > n
%     S=S';
% end

if exist('rankS','var')
    if rankS==m
        %If full row rank i.e. rank(S)=m, it's much faster to work with a
        %sparse LU.
        fprintf('%s\n','S is full row rank, using sparse LU to compute the null space');
        AT      = sparse(S');                   % Sparse S!
        thresh  = 0.1;                          % Improve the sparsity of LU
        q       = colamd(AT);                   % q is a column permutation vector
        [L,U,P] = lu(AT(:,q),thresh);           % P*AT(:,q) = L*U, with L lower trapezoidal.
        W       = [sparse(m,n-m); speye(n-m)];  % The last n-m cols of speye(m).
        L       = [L W];                        % makes L strictly triangular.
        
        % P*AT(:,q) = L*U means inv(L)(P*S'*Q) = U
        % where the bottom rows of U are zero: U(m+1:n,:) = 0.
        % This means (Q'*S*P')*inv(L') = U'   has its last columns = 0.
        % Hence,         S*(P'*inv(L') = Q*U' has its last columns = 0.
        % Q has no effect.
        % Hence the null space of S is the last cols of P'*inv(L'):
        
        Z       = P'*((L')\W);        % satisfies S*Z = 0.
    else
        if issparse(S)
            fprintf('%s\n','Attempting to convert to full matrix as this only works on full matrices');
            S=full(S);
        end
        
        fprintf('%s\n','S is row rank deficient, computing the null space using QR');
        %qr factorisation
        [Q,R,P] = qr(S);                     % S*P = Q*R,  R trapezoidal
        
        %if tol not provided, compute the tolerance on non-zero diagonals of R
        if ~exist('tol')
            %from matlab help
            tol = max(size(S))*eps*abs(R(1,1));
            %1e-15 is asking too much
            if tol>1e-12
                tol=1e-12;
            end
        end
        rankS  = length(find(abs(diag(R)) > tol));
    
        K       = [- R(1:rankS,1:rankS) \ R(1:rankS,rankS+1:n); eye(n-rankS)];
        Z       = P*K;
    end
else
    archstr = computer('arch');
    archstr = upper(archstr);
    switch archstr
        case {'GLNX86','GLNXA64'}
            [Z,nullS,rankS] = nullspaceLUSOLtest(sparse(S),printLevel);
            
            %Random vector in null space should should give you a small number.
            v=Z*rand(size(Z,2),1);
            error=norm(S*v,inf);
            if printLevel
                fprintf('%s\n',['Maximum constraint violation of random vector ' num2str(error)]);
            end
            
        otherwise
            if m > n
                Z=null(full(S));
                rankS=n-size(Z,2);
            else
                %TODO
                %adapt this code to suit when m > n
                
                fprintf('%s\n','Attempting to convert to full matrix as this only works on full matrices');
                S=full(S);
                fprintf('%s\n','S is row rank deficient, computing the null space using QR');
                %qr factorisation
                [Q,R,P] = qr(S);                     % S*P = Q*R,  R trapezoidal
                
                %if tol not provided, compute the tolerance on non-zero diagonals of R
                if ~exist('tol')
                    %from matlab help
                    tol = max(size(S))*eps*abs(R(1,1));
                    %1e-15 is asking too much
                    if tol>1e-12
                        tol=1e-12;
                    end
                end
                rankS  = length(find(abs(diag(R)) > tol));
                
                if m <= n
                    K       = [- R(1:rankS,1:rankS) \ R(1:rankS,rankS+1:n); eye(n-rankS)];
                    Z       = P*K;
                end
            end
    end
end