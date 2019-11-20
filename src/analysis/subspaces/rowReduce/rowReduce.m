function [AA, aa, pp, rankA, p] = rowReduce(A, a, mode, printLevel)
% Eliminates dependent rows from `A` & `a` where :math:`A x = a`
%
% USAGE:
%
%    [AA, aa, pp, rankA, p] = rowReduce(A, a)
%
% INPUT:
%    A:        from :math:`A x = a`
%
% OPTIONAL INPUT:
%    a:        from :math:`A x = a`
%
%    mode:     If mode=1, LUSOL operates on A itself.
%              If mode=2, LUSOL operates on A'.
%
%    printLevel
%
% OUTPUT:
%    AA:       row reduced `A`
%    aa:       row reduced `a` i.e. `aa = a(pp)`
%    pp:       1:rankA indices of independent rows
%    rankA:    rank of `A`
%    p:        row permutation which leaves first `1:rankA` rows independent and
%              last rows dependent
%
% .. Author: - Ronan Fleming, with linear algebra advice from Michael Saunders
%            Dept of Management Science and Engineering (MS&E) Stanford University

if ~exist('a','var') %create a if not provided
    a=sparse(size(A,1),1);
else
    if size(A,1)~=length(a)
        error('Dimensions of A and a are inconsistent');
    end
end

if ~exist('mode','var')
    mode=1;
end

if ~exist('printLevel','var')
    printLevel=1;
end

[mlt,nlt]=size(A);
archstr = computer('arch');
archstr = lower(archstr);
%archstr='';%bypass until issue with lusol tolerance sorted.
switch archstr
    case {'glnx86','glnxa64','maci64'}
        %Eliminate dependent rows
        [AA,aa,p,rankA] = lusolCondense(A,a,mode,printLevel-1);
        if ~(nnz(A)>0 && rankA==0) && printLevel>0
            fprintf('%s',['Eliminated ' int2str(mlt-rankA) ' dependent rows, using lusol.']);
        end
        pp=p(1:rankA);
        %case {'PCWIN','PCWIN64'}
    otherwise
        [AA, aa, pp, rankA, p] = qrRowReduce(A,a, printLevel);
end

if nnz(A)>0 && rankA==0
    %backup in case something has gone wrong with lusolCondense
    [AA, aa, pp, rankA, p] = qrRowReduce(A, a, printLevel);
end

fprintf('\n')
end

function [AA, aa, pp, rankA, p] = qrRowReduce(A, a,  printLevel)
    [mlt,nlt]=size(A);
    A=full(A);
    %Eliminate dependent rows
    [Q,R,P] = qr(A');
    [p,q,s] = find(P);
    s      = diag(R);
    tol    = 1e-8;
    rankA  = length(find(abs(s) > tol));
    % nnz(abs(diag(R))>1.e-15)
    AA = sparse(A(p(1:rankA),:));
    pp = p(1:rankA);
    aa = sparse(a(pp));
    if  printLevel>0
             fprintf('%s',['Eliminated ' int2str(mlt-rankA) ' dependent rows, using qr factorisation.']);
    end
end
