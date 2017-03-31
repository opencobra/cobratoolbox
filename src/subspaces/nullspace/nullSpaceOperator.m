function nullS = nullSpaceOperator(S,scale,printLevel)
% Uses LUSOL to compute a nullspace operator nullS
% nullS = nullSpaceOperator(S,gmscale,printLevel);
% We assume S is m x n with m < n with rank r.
%
% First,
%        nullS = nullSpaceOperator(S);
% computes a structure nullS from an m x n sparse matrix S (m < n).
% Second, if V is an (n-r) x k sparse matrix (k >= 1),
%        W = nullSpaceOperatorApply(nullS,V);
% computes an n x k sparse matrix W from V such that S*W = 0.
%
% This is an operator form of finding an n x (n-r) matrix Z
% such that S*Z = 0 and then computing W = Z*V.
% The aim is to obtain W without forming Z explicitly.
%
% nullS.rank returns the rank of S (r <= m).
% It doesn't matter if rank < m.
%
% INPUT
% S             m x n matrix
% scale       {(1),0} geometric mean scaling of S
% printLevel    {(1),0}
%
% OUTPUT
% nullS         nullspace operator to be used with nullSpaceOperatorApply.m
% nullS.rank    rank of S
%
% REQUIRES
% Requires Nick Henderson's 64 bit LUSOL interface to be intalled and added
% to the matlab path. See https://github.com/nwh/lusol
% see also http://www.stanford.edu/group/SOL/software/lusol.html

% 02 May 2008: First version of nullspaceLUSOLform.m.
%              load iCore_stoich_mu_Stanford.mat   % loads a matrix A;
%              nullS = nullspaceLUSOLform(A);      % forms Z.
%              Michael Saunders                       
% 20 Jan 2015: Updated to use Nick Henderson's 64 bit LUSOL interface
%              Ronan Fleming and renamed nullSpaceOperator


%by default turn on scaling
if ~exist('scale','var')
    scale=1;
end
if ~exist('printLevel','var')
    printLevel=1;
end

[m,n] = size(S);
if printLevel
    fprintf('\nsize(S) = %10g x %10g', m,n);
end

% if m >= n
%   fprintf('\nS must have fewer rows than columns\n')
%   return
% end

if ~issparse(S)
    if printLevel
        disp('Converting dense S to sparse(S)')
    end
    S = sparse(S);
end

if printLevel
    fprintf('\n nnz(S) = %10g\n\n', nnz(S))
end

if scale
    %%%%%%% Scale S
    tic
    iprint  = 1;
    scltol  = 0.9;
    [cscale,rscale] = gmscale(S,sign(printLevel),scltol);
    
    C = spdiags(cscale,0,n,n);   Cinv = spdiags(1./cscale,0,n,n);
    R = spdiags(rscale,0,m,m);   Rinv = spdiags(1./rscale,0,m,m);
    A = Rinv*S*Cinv;
    
    if printLevel
        toc
    else
        t=toc;
    end
    
    %%%%%%% Factorize A = the scaled S
end
tic

archstr = computer('arch');
archstr = lower(archstr);
switch archstr
    case {'win32', 'win64'}
         error('%s\n','Chrr sampler not compatible with windows OS.')
    case {'glnxa86'}
        % REQUIRED: lusolSet.m and lusolFactor.m (which calls the LUSOL mex-file).
        % 02 May 2008: (MAS) First version of nullspaceLUSOLform.m.
        options = lusolSet;
        options.Pivoting  = 'TRP';
        options.FactorTol = 1.5;
        options.nzinit = 1e7;
        
        [L,U,p,q,options] = lusolFactor(A',options);   % Note A'
        rankS = options.Rank;
        L     = L(p,p);      % New L is strictly lower triangular (and square).
        % U     = U(p,q);      % New U would be upper trapezoidal the size of S'.
        
    case {'glnxa64','maci64'}
        if ~isempty(which('lusol_obj'))
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
                mylu = lusol_obj(A',options);
            else
                %factorise
                mylu = lusol_obj(A');
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
            
            L     = L(p,p);      % New L is strictly lower triangular (and square).
            % U     = U(p,q);      % New U would be upper trapezoidal the size of S'.
        
            %return the rank of the matrix
            r=mylu.rank();
            
            %    lu.factorize inform codes:
            switch stats.inform
                case 0
                    if printLevel>0
                        fprintf('%s\n','The LU factors were obtained successfully.')
                    end
                case 1
                    if printLevel>0
                        fprintf('%s\n','U appears to be singular, as judged by lu6chk.');
                    end
                case 3
                    fprintf('%s\n','Some index pair indc(l), indr(l) lies outside the matrix dimensions 1:m , 1:n.');
                case    4
                    fprintf('%s\n','Some index pair indc(l), indr(l) duplicates another such pair.');
                case    7
                    fprintf('%s\n','The arrays a, indc, indr were not large enough.');
                    fprintf('%s\n','Their length "lena" should be increase to at least');
                    fprintf('%s\n','The value "minlen" given in luparm(13).');
                case 8
                    fprintf('%s\n','There was some other fatal error.  (Shouldn''t happen!)');
                case 9
                    fprintf('%s\n','No diagonal pivot could be found with TSP or TDP.');
                    fprintf('%s\n','The matrix must not be sufficiently definite or quasi-definite.');
            end
            
            if stats.inform~=0 && stats.inform~=1
                % solve Ax=b
                b = ones(size(A',1),1);
                x = mylu.solve(b);
                % multiply Ax
                b2 = mylu.mulA(x);
                % check the result
                fprintf('%s\t%g\n','Check norm(b-b2) : ', norm(b-b2))
            end
        else
            error('%s\n','nullspaceLUSOLform Cannot find lusol_obj.m from lusol interface. Make sure https://github.com/nwh/lusol is intalled and added to the matlab path.')
        end
end


if printLevel
    toc
else
    t=toc;
end

% P*S'(:,q) = L*U means inv(L)*P*S'*Q = U, where Q is the perm from q
% and the bottom rows of U are zero: U(rank+1:n,:) = 0.
% This means (Q'*S*P')*inv(L') = U'   has its last columns = 0.
% Hence,         S*(P'*inv(L') = Q*U' has its last columns = 0.
% Q has no effect.
% Hence the null space of S is Z = the last cols of P'*inv(L'):
% When S is scaled as S = R*A*C, we have Z = Cinv*P'*inv(L')[0;I].

nullS.Cinv = Cinv;
nullS.L    = L;
nullS.p    = p;
nullS.q    = q;
nullS.rank = r;

if printLevel
    fprintf('\nnRows(S) = %10g', m)
    fprintf('\nnCols(S) = %10g', n)
    fprintf('\nrank(S) = %10g', r)
    fprintf('\nnnz(L)  = %10g', nnz(L))
    fprintf('\nnnz(U)  = %10g', nnz(U))
    fprintf('\nnull(S) is represented by L, permutation p, and column scaling Cinv\n\n')
end
return
