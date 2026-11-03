function [rankA, p, q] = getRankLUSOL(A, printLevel)
% Get the rank of a matrix using treshold rook pivoting.
% Uses `lusolFactor` computes the sparse factorization :math:`A = L U`
% for a square or rectangular matrix `A`.  The vectors `p`, `q`
% are row and column permutations giving the pivot order.
%
% USAGE:
%
%    [rankA, p, q] = getRankLUSOL(A, printLevel)
%
% INPUT:
%    A:             `m x n` rectangular matrix
%
% OPTIONAL INPUT:
%    printLevel:    default = 0, prints nothing (but see NOTE on the fallback warning);
%                   > 0 explains the LUSOL outcome and any fallback to MATLAB's LU
%
% OUTPUTS:
%    rankA:         rank of `A`
%    p:             row permutations giving the pivot order
%
%                   Note: `p(1:rankA)` gives indices of independent rows
%                   `p(rankA+1:size(A, 1))` gives indices of dependent rows
%    q:             column permutations giving the pivot order
%
%                   Note: `q(1:rankA)` gives indices of independent columns
%                   `q(rankA+1:size(A, 2))` gives indices of dependent columns
%
% .. Authors:
%       - Michael Saunders, LUSOL Fortran code, May 2015
%       - Nick Henderson, LUSOL Matlab interface, May 2015
%       - Ronan Fleming, COBRA Toolbox interface, May 2015
%
% NOTE:
%
%    Requires a 64 bit implementation of lusol, available from
%    https://github.com/nwh/lusol
%
%    When LUSOL fails, or `lusol_obj.m` is not on the path, the rank is computed with
%    MATLAB's LU and `rank` instead, and the warning `getRankLUSOL:lusolFallback` (with
%    the cause, and the file and line where the error was raised) is shown once per
%    MATLAB session (until `clear getRankLUSOL`, `clear functions` or `clear all`).
%
%    CHANGE OF DEFAULT DIAGNOSTIC OUTPUT, October 2026, feature
%    20261026-220121-fix-ci-test-failures: at printLevel 0 the fallback messages and the
%    LUSOL error-code explanations are no longer printed; before, they were printed at
%    every printLevel and the fallback warning was repeated on every call. The returned
%    rank and permutations are unchanged.

if ~exist('printLevel','var')
    printLevel=0;
end

if isempty(A)
    rankA=0;
    p=[];
    q=[];
    return
end

%Bug in LUSOL: it gives incorrect rank for a matrix with zero columns
bool=(sum(A~=0,1)==0);
if any(bool)
    [mlt,nlt]=size(A);
    A=A(:,~bool);
end

if ~isempty(which('lusol_obj'))
    try
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
                
                % %modification of default options
                % options.pivot  = 'TRP';
                % options.Ltol1 = 1.5;
                % options.nzinit = 1e7;
                % %factorise
                % mylu = lusol_obj(A,options);
                
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
                %return the rank of the matrix
                rankA=mylu.rank();
                
                %    lu.factorize inform codes, explained only when printLevel > 0
                if printLevel>0
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
                end
                
                if stats.inform~=0 && stats.inform~=1
                    % solve Ax=b
                    b = ones(size(A,1),1);
                    x = mylu.solve(b);
                    % multiply Ax
                    b2 = mylu.mulA(x);
                    % check the result
                    if printLevel>0
                        fprintf('%s\t%g\n','getRankLUSOL: Check norm(b-b2) : ', norm(b-b2))
                    end
                end
                
        end
        
        
    catch ME
        if isempty(ME.stack)
            errorLocation = '(no stack)';
        else
            errorLocation = sprintf('(%s line %d)', ME.stack(1).file, ME.stack(1).line);
        end
        warnLusolFallback(sprintf('%s %s', ME.message, errorLocation));
        if printLevel>0
            fprintf('%s\n','Caught error using lusol interface. Proceeding with matlab LU implementation (slower)')
        end
        [L,U,p,q] = lu(sparse(A),'vector');
        p=p';
        q=q';
        rankA=rank(full(A));
    end
else
    warnLusolFallback('lusol_obj.m not found on the MATLAB path');
    if printLevel>0
        fprintf('%s\n','Cannot find lusol_obj.m from lusol interface, calling matlab LU implementation (slower)')
    end
    [L,U,p,q] = lu(sparse(A),'vector');
    p=p';
    q=q';
    rankA=rank(full(A));
end

%pad out q in case some columns are dropped
if any(bool)
    ind=(1:length(bool))';
    q=[q;ind(bool)];
end

function warnLusolFallback(cause)
% warns once per MATLAB session that LUSOL is unavailable, whatever the printLevel, so
% that a broken LUSOL stays visible without repeating the warning on every call
persistent warned
if isempty(warned)
    warning('getRankLUSOL:lusolFallback', ...
        'getRankLUSOL: LUSOL unavailable, using MATLAB LU instead (shown once per session). Cause: %s', cause);
    warned = true;
end
