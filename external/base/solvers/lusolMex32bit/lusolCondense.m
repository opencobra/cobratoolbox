function [AA,bb,p,rankA] = lusolCondense(A,b,mode,printLevel)
%
%        [AA,bb,p] = lusolCondense(A,b,mode);
% extracts from A a submatrix AA = A(p,:) of full row rank, and
% the corresponding subvector bb = b(p), where A should be sparse
% and have nonzero entries not too much bigger than 1.
%
%INPUT
% A     m x n sparse matrix
% b     m x 1 vector
%
%OPTIONAL INPUT
%    mode:     If mode=1, LUSOL operates on A itself.
%              If mode=2, LUSOL operates on A'.
%
%OUTPUT
% AA        row reduced A
% bb        row reduced B
% p         AA = A(p,:),bb = b(p)
% rankA     rank of A
%

% 27 May 2007: Michael Saunders:
%              First version of lusolCondense, intended as a
%              more efficient substitute for [Q,R,P] = qr(full(A')).
%              Michael Saunders
% 10 Oct  2019: Ronan Fleming
%              64bit linux support

if ~exist('mode','var')
    mode=1; %what is the best default.
end
if ~exist('printLevel','var')
    printLevel=0;
end

if ~issparse(A)
    A=sparse(A);
end


[m,n]   = size(A);
if isempty(b)
    b=sparse(m,1);
end

archstr = computer('arch');
archstr = lower(archstr);
switch archstr
    case {'win32', 'win64'}
        error('%s\n','lusolCondense not compatible with windows OS.')
    case {'glnxa86'}
        
        options = lusolSet;
        options.Pivoting  = 'TRP';
        options.FactorTol = 1.5;
        
        if mode==1   % Factorize A itself
            [L,U,p,q,options] = lusolFactor(A,options);
            inform   = options.Inform;
            rankA    = options.Rank;
            
            if rankA==m
                AA = A;
                bb = b;
                p  = (1:m)';
            else
                AA = A(p(1:rankA),:);
                bb = b(p(1:rankA));
            end
            
        else         % Factorize A'
            [L,U,p,q,options] = lusolFactor(A',options);
            inform  = options.Inform;
            rankA    = options.Rank;
            
            if rankA==m
                AA = A;
                bb = b;
                p  = (1:m)';
            else
                p  = q;
                AA = A(p(1:rankA),:);
                bb = b(p(1:rankA));
            end
        end
        
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
            
            % %modification of default options
            % options.pivot  = 'TRP';
            % options.Ltol1 = 1.5;
            % options.nzinit = 1e7;
            % %factorise
            % mylu = lusol_obj(A',options);
            
            if mode==1   % Factorize A itself
                %factorise
                mylu = lusol_obj(A);
                
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
                rankA=mylu.rank();
                
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
                
                if rankA==m
                    AA = A;
                    bb = b;
                    p  = (1:m)';
                else
                    AA = A(p(1:rankA),:);
                    bb = b(p(1:rankA));
                end
                
            else
                %factorise A'
                mylu = lusol_obj(A');
                
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
                rankA=mylu.rank();
                
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
                
                if rankA==m
                    AA = A;
                    bb = b;
                    p  = (1:m)';
                else
                    p  = q;
                    AA = A(p(1:rankA),:);
                    bb = b(p(1:rankA));
                end
            end
            
        else
            error('%s\n','lusolCondense.m Cannot find lusol_obj.m from lusol interface. Make sure https://github.com/nwh/lusol is intalled and added to the matlab path.')
        end
end
if printLevel>1
    fprintf('%s\n',['lusolCondense: A has dimensions ' int2str(m) ' x ' int2str(n) ' and has rank ' int2str(rankA)])
end
