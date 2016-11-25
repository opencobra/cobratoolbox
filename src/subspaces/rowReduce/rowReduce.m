function [AA,aa,pp,rankA,p] = rowReduce(A,a)
%eliminate dependent rows from A & a where A*x=a
%INPUT
% A
%
%OPTIONAL INPUT
% a
%
%OUTPUT
% AA        row reduced A
% aa        row reduced a i.e. aa = a(pp)
% pp        1:rankA indices of independent rows
% rankA     rank of A    
% p         row permutation which leaves first 1:rankA rows independent and
%           last rows dependent
%
% Ronan Fleming, with linear algebra advice from Michael Saunders
% Dept of Management Science and Engineering (MS&E)
% Stanford University

%create a if not provided
if ~exist('a')
    a=sparse(size(A,1),1);
else
    if size(A,1)~=length(a)
        error('Dimensions of A and a are inconsistent');
    end
end

[mlt,nlt]=size(A);
archstr = computer('arch');
archstr = upper(archstr);
archstr='';%bypass until issue with lusol tolerance sorted.
switch archstr
    case {'GLNX86','GLNXA64'}
        %Eliminate dependent rows
        [AA,aa,p,rankA] = lusolCondense(A,a,1);
        fprintf('%s',['Eliminated ' int2str(mlt-rankA) ' dependent rows, using lusol.']);
        pp=p(1:rankA);
    %case {'MACI','PCWIN','PCWIN64'}
    otherwise
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
        fprintf('%s',['Eliminated ' int2str(mlt-rankA) ' dependent rows, using qr factorisation.']);
end
fprintf('\n')
