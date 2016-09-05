function [rankA,p,q] = getRankLUSOL(A,printLevel)
%Get the rank of a matrix using treshold rook pivoting
%
% uses lusolFactor computes the sparse factorization A = L*U
% for a square or rectangular matrix A.  The vectors p, q
% are row and column permutations giving the pivot order.
%
% Requires a 64 bit implementation of lusol, available from
% https://github.com/nwh/lusol
%
%INPUT
% A     m x n rectangular matrix
%
%OUTPUT
% rankA     rank of A
% p         row permutations giving the pivot order
%           Note: p(1:rankA) gives indices of independent rows
%                 p(rankA+1:size(A,1)) gives indices of dependent rows
% q         column permutations giving the pivot order
%           Note: q(1:rankA) gives indices of independent columns
%                 q(rankA+1:size(A,2)) gives indices of dependent columns

% Michael Saunders, LUSOL Fortran code, May 2015
% Nick Henderson, LUSOL Matlab interface, May 2015
% Ronan Fleming, COBRA Toolbox interface, May 2015

if ~exist('printLevel','var')
    printLevel=0;
end

%Bug in LUSOL: it gives incorrect rank for a matrix with zero columns
bool=(sum(A~=0,1)==0);
if any(bool)
    [mlt,nlt]=size(A);
    A=A(:,~bool);
end

if ~isempty(which('lusol_obj'))
    
    archstr = computer('arch');
    archstr = lower(archstr);
    switch archstr
        case {'glnxa64','maci64'}
            % generate default options
            options = lusol_obj.luset();
            % |--------+----------+----------------------------------------------------|
            % | param  |  default | description                                        |
            % |--------+----------+----------------------------------------------------|
            %
            % lusol_obj options
            % |--------+----------+----------------------------------------------------|
            % | nzinit |        0 | minimum length for storage arrays                  |
            % |--------+----------+----------------------------------------------------|
            %
            % LUSOL integer parameters
            % |--------+----------+----------------------------------------------------|
            % | maxcol |        5 | max num cols searched for piv element              |
            % | pivot  |    'TPP' | pivoting method {'TPP','TRP','TCP','TSP'}          |
            % | keepLU |        1 | keep the nonzeros, if 0, permutations are computed |
            % |--------+----------+----------------------------------------------------|
            %
            % LUSOL real parameters
            % |--------+----------+----------------------------------------------------|
            % | Ltol1  |     10.0 | max Lij allowed, default depends on pivot method   |
            % | Ltol2  |     10.0 | max Lij allowed during updates                     |
            % | small  |  eps^0.8 | absolute tolerance for treating reals as zero      |
            % | Utol1  | eps^0.67 | absolute tol for flagging small diags of U         |
            % | Utol2  | eps^0.67 | rel tol for flagging small diags of U              |
            % | Uspace |      3.0 |                                                    |
            % | dens1  |      0.3 |                                                    |
            % | dens2  |      0.5 |                                                    |
            % |--------+----------+----------------------------------------------------|
            
            if 0
                %modification of default options
                options.pivot  = 'TRP';
                options.Ltol1 = 1.5;
                options.nzinit = 1e7;
                %factorise
                mylu = lusol_obj(A,options);
            else
                %factorise
                mylu = lusol_obj(A);
            end
            
            %extract results
            stats = mylu.stats();
            options.Inform = stats.inform;
            options.Nsing  = stats.nsing;
            options.Growth = stats.growth;
            
            %matrices
            L = mylu.L0();
            U = mylu.U();
            % row permutation
            p = mylu.p();
            % column permutation
            q = mylu.q();
            %return the rank of the matrix
            rankA=mylu.rank();
            
            %    lu.factorize inform codes:
            switch stats.inform
                case 0
                    if printLevel>0
                        fprintf('%s\n','getRankLUSOL: The LU factors were obtained successfully.')
                    end
                case 1
                    if printLevel>0
                        fprintf('%s\n','getRankLUSOL: U appears to be singular, as judged by lu6chk.');
                    end
                case 3
                    fprintf('%s\n','getRankLUSOL: Some index pair indc(l), indr(l) lies outside the matrix dimensions 1:m , 1:n.');
                case    4
                    fprintf('%s\n','getRankLUSOL: Some index pair indc(l), indr(l) duplicates another such pair.');
                case    7
                    fprintf('%s\n','getRankLUSOL: The arrays a, indc, indr were not large enough.');
                    fprintf('%s\n','getRankLUSOL: Their length "lena" should be increase to at least');
                    fprintf('%s\n','getRankLUSOL: The value "minlen" given in luparm(13).');
                case 8
                    fprintf('%s\n','getRankLUSOL: There was some other fatal error.  (Shouldn''t happen!)');
                case 9
                    fprintf('%s\n','getRankLUSOL: No diagonal pivot could be found with TSP or TDP.');
                    fprintf('%s\n','getRankLUSOL: The matrix must not be sufficiently definite or quasi-definite.');
            end
            
            if stats.inform~=0 && stats.inform~=1
                % solve Ax=b
                b = ones(size(A,1),1);
                x = mylu.solve(b);
                % multiply Ax
                b2 = mylu.mulA(x);
                % check the result
                fprintf('%s\t%g\n','getRankLUSOL: Check norm(b-b2) : ', norm(b-b2))
            end
            
    end
else
    fprintf('%s\n','Cannot find lusol_obj.m from lusol interface, calling matlab LU implementation (slower)')
    [L,U,p,q] = lu(A,'vector');
    p=p';
    q=q';
    rankA=rank(full(A));
end

%pad out q in case some columns are dropped
if any(bool)
    ind=(1:length(bool))';
    q=[q;ind(bool)];
end
