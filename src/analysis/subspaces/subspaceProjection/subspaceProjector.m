function [PR, PN, PC, PL] = subspaceProjector(A, printLevel, sub_space)
% Returns the matrix for projection onto the sub_space of the internal
% reaction stoichiometric matrix specified by `sub_space`
% If `sub_space` is 'all' then all are returned
%
% Let M denote the Moore-Penrose pseudoinverse of the internal reaction
% stoichiometric matrix S and the subscripts are the following
% `_R` row space        i.e. range(A')
% `_N` nullspace        i.e. null(A)
% `_C` column space     i.e. range(A)
% `_L` left nullspace   i.e. null(A')
%
% Let
%
% .. math::
%    v   &= v_R + v_N \\
%    v_R &= M A v = PR v \\
%    v_N &= (I - M A) v = PN v
%
% Let
%
% .. math::
%    u   &= u_C + u_L \\
%    u_C &= A M u = PC u \\
%    u_L &= (I - A M) u = PL u
%
% Examples:
%
% Given :math:`A v = b`, then :math:`v_R = M b`
%
% Given :math:`A^Tu = q`, then :math:`u_C = M^T q`
%
% USAGE:
%
%    [PR, PN, PC, PL] = subspaceProjector(model, printLevel, sub_space)
%
% INPUT:
%    A          `m x n` matrix
%
% OPTIONAL INPUTS:
%    printLevel:          {(1), 0}, 1 = print diagnostics, 0 = silent
%    sub_space:           returns projection matrices onto all or one select
%
%                           * sub_space
%                           * 'all'
%                           * 'R' row space
%                           * 'N' nullspace
%                           * 'C' column space
%                           * 'L' left nullspace
%
% OUTPUTS:
%    [PR, PN, PC, PL]:    matrices for projection onto the row, null, 
%                         column and left nullspace of A, respectively
%
% .. Author:
%       - 10 July 2009 : Ronan Fleming. First Version.
%       - 10 Aug  2009 : Changed to use Micheal Saunders faster approach
%       -    Jan  2018 : Changed to take a matrix A 

if ~exist('printLevel','var')
    printLevel=1;
end

if ~exist('sub_space','var')
    sub_space='all';
end

[nMet,nRxn]=size(A);

archstr = computer('arch');
switch archstr
    case {'glnx86','glnxa64'}
        %A = U1*D1*V1'
        if printLevel
            fprintf('%s','Calculating SVD ...');
            tic
        end
        %Michael Saunders code
        [U1,D1,V1,r] = subspaceSVD(A);
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
        M=pinv(full(A));
        if printLevel
            fprintf('%s\n',[' finished. toc = ' num2str(toc)]);
        end

        PR=[];PN=[];PC=[];PL=[];
        if strcmp(sub_space,'R')
            PR=M*A;
        elseif strcmp(sub_space,'N')
            PN=eye(nRxn)-M*A;
        elseif strcmp(sub_space,'C')
            PC=A*M;
        elseif strcmp(sub_space,'L')
            PL=eye(nMet)-A*M;
        elseif strcmp(sub_space,'all')
            PR=M*A;
            PN=eye(nRxn)-M*A;
            PC=A*M;
            PL=eye(nMet)-A*M;
        end
end