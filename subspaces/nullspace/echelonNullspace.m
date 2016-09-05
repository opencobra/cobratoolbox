function [L0,I,P,L,p] = echelonNullspace(S,side,tol)
% returns the Echelon form of the:
%    left nullspace,     L*S = [-L0 I]*P*S = 0.
% or right nullspace  S*L = S*([-L0 I]*P)' = 0.
%
% % See: Conservation analysis of large biochemical networks
% Ravishankar Rao Vallabhajosyula , Vijay Chickarmane and Herbert M. Sauro
% 
%INPUT
% S             m x n stoichiometric matrix
% 
%OPTIONAL INPUT
% side          {'left','right'} left or right nullspace, left by default.
% tol           upper bound on tolerance of linear independence
%               default no greater than 1e-12
%
%OUTPUT
% if side==left
%      L0       (m-r) x r matrix which forms the non-trivial part of the
%               left nullspace in echelon form i.e. [-L0 I]*P*S = 0.
%      P        m x m row (permutaion matrix
%      I        (m-r) x (m-r) identity matrix 
%      p        row permutation which leaves first 1:rankA rows independent and
%               last rows dependent
%
% if side==right
%      L0       (n-r) x r matrix which forms the non-trivial part of the
%               right nullspace in echelon form i.e. S*([-L0 I]*P)' = 0.
%      P        n x n column permutaion matrix
%      I        (n-r) x (n-r) identity matrix 
%      p        column permutation which leaves first 1:rankA columns 
%               independent and last columns dependent
% 
% Ronan M.T. Fleming


if ~exist('side','var')
    side='left';
end
[nMet,nRxn]=size(S);
if strcmp(side,'left')
    %qr factorisation
    %for full matrix S', produces a permutation matrix P, an upper triangular
    %matrix R with decreasing diagonal elements, and a unitary matrix Q 
    %so that S'*P = Q*R. 
    %The column permutation P is chosen so that abs(diag(R)) is decreasing.
    [Q,R,P]=qr(S');
    
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
    
    [p,q,s] = find(P);
    
    [nlt,mlt]=size(R);
    %all of the rows below the first rankS non-zero rows should contain only
    %zeros and reflect the dependencies in the network
    %R(abs(R)<tol)=0;

    %scale each nonzero row such that there is unity along the main diagonal
    for n=1:rankS
        R(n,:)=R(n,:)/R(n,n);
    end

    %Gauss-Jordan elimination produces a reduced row echelon form
    [IM,rf]=rref(R(1:rankS,:));

    % R =[I M;
    %     0 0]
    R=zeros(nlt,mlt);
    R(1:rankS,:)=IM;

    %separate parts of R
    I=IM(:,1:length(rf));
    M=IM(:,length(rf)+1:end);

    %Reduced left null space?
    L0 = M';

    %identity
    I = speye(nMet-rankS);
    
    L=[-L0 I]*P;
else
    %qr factorisation
    %for full matrix S', produces a permutation matrix P, an upper triangular
    %matrix R with decreasing diagonal elements, and a unitary matrix Q 
    %so that S'*P = Q*R. 
    %The column permutation P is chosen so that abs(diag(R)) is decreasing.
    [Q,R,P]=qr(S);

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

    [p,q,s] = find(P);
    
    [nlt,mlt]=size(R);
    %all of the rows below the first rankS non-zero rows should contain only
    %zeros and reflect the dependencies in the network
    %R(abs(R)<tol)=0;

    %scale each nonzero row such that there is unity along the main diagonal
    for n=1:rankS
        R(n,:)=R(n,:)/R(n,n);
    end

    %Gauss-Jordan elimination produces a reduced row echelon form
    [IM,rf]=rref(R(1:rankS,:));

    % R =[I M;
    %     0 0]
    R=zeros(nlt,mlt);
    R(1:rankS,:)=IM;

    %separate parts of R
    I=IM(:,1:length(rf));
    M=IM(:,length(rf)+1:end);

    %Reduced left null space?
    L0 = M';

    %identity
    I = speye(nRxn-rankS);
    
    L=[-L0 I]*P;
end
    