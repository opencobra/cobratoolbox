function [PR, PN, PC, PL] = subspaceProjector(model, printLevel, sub_space, fullS)
% return the matrix for projection onto the sub_space of the internal
% reaction stoichiometric matrix specified by sub_space
% If sub_space is 'all' then all are returned

% Let M denote the Moore-Penrose pseudoinverse of the internal reaction
% stoichiometric matrix and the subscripts are the following
% _R row space
% _N nullspace
% _C column space
% _L left nullspace
%
% Let v = v_R + v_N
%
% v_R = M*S*v = PR*v
%
% v_N = (I - M*S)*v = PN*v
%
% Let u = u_C + u_L
%
% u_C = S*M*u = PC*u
%
% u_L = (I - S*M)*u = PL*u
%
% Examples:
%    Given S*v=b, then v_R = M*b
%    Given S'*u=q, then u_C = M'*q
%
% 10 July 2009 : Ronan Fleming. First Version.
% 10 Aug  2009 : Changed to use Micheal Saunders faster approach
%
% INPUT
% model.S               m x n Stoichiometric matrix
% model.SIntRxnBool     n x 1 Boolean of reactions though to be mass balanced.
%                       By default, projectors only provided for the
%                       matrix: model.S(:,model.SIntRxnBool)
%
% OPTIONAL INPUT
% printLevel            {(1),0} 1=print diagnostics, 0 = silent
% sub_space              return projection matrices onto all or one select
%                       sub_space
%                       'all'
%                       'R' row space
%                       'N' nullspace
%                       'C' column space
%                       'L' left nullspace
% fullS                 0 = uses only those columns given by model.SIntRxnBool
%                       1 = uses full m x n Stoichiometric matrix (all columns)


if ~exist('printLevel','var')
    printLevel=1;
end

if ~exist('sub_space','var')
    sub_space='all';
end

if ~exist('fullS','var')
    S=model.S(:,model.SIntRxnBool);
else
    if fullS==0
        %mass balanced reactions of stoichiometric matrix
        S=model.S(:,model.SIntRxnBool);
    else
        %full Stoichiometric matrix
        S=model.S;
    end
end

[nMet,nRxn]=size(S);

archstr = computer('arch');
switch archstr
    case {'glnx86','glnxa64'}
        %S = U1*D1*V1'
        if printLevel
            fprintf('%s','Calculating SVD ...');
            tic
        end
        %Michael Saunders code
        [U1,D1,V1,r] = subspaceSVD(S);
        if printLevel
            fprintf('%s\n',[' finished. toc = ' num2str(toc)]);
        end
        PR=[];PN=[];PC=[];PL=[];
        if strcmp(sub_space,'R')
            PR=V1*V1';
        elseif strcmp(sub_space,'N')
            PN=eye(nRxn) - V1*V1';
        elseif strcmp(sub_space,'C')
            PC=U1*U1';
        elseif strcmp(sub_space,'L')
            PL=eye(nMet) - U1*U1';
        elseif strcmp(sub_space,'all')
            PR=V1*V1';
            PN=eye(nRxn) - V1*V1';
            PC=U1*U1';
            PL=eye(nMet) - U1*U1';
        end
    otherwise
        %for other architectures calculate the Moore-Penrose Pseudoinverse
        if printLevel
            fprintf('%s','Calculating the Moore-Penrose Pseudoinverse...');
            tic
        end
        M=pinv(full(S));
        if printLevel
            fprintf('%s\n',[' finished. toc = ' num2str(toc)]);
        end

        PR=[];PN=[];PC=[];PL=[];
        if strcmp(sub_space,'R')
            PR=M*S;
        elseif strcmp(sub_space,'N')
            PN=eye(nRxn)-M*S;
        elseif strcmp(sub_space,'C')
            PC=S*M;
        elseif strcmp(sub_space,'L')
            PL=eye(nMet)-S*M;
        elseif strcmp(sub_space,'all')
            PR=M*S;
            PN=eye(nRxn)-M*S;
            PC=S*M;
            PL=eye(nMet)-S*M;
        end
end


% To check old code vs new
% [U1,D1,V1,r] = subspaceSVD(modelT.S(:,modelT.SIntRxnBool));
% q=rand(74,1)*1000;
% qR=PR*q;
% qR2=V1*(V1'*q);
% plot(abs(qR-qR2),'.')
