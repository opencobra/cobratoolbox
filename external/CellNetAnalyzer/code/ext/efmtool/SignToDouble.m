%%
% FUNCTION function efms = SignToDouble(mnet, efmIndex, how, tol)
%
%    Returns double value elementary modes (EFMs) from sign EFMs. The 
%    structure mnet must contain the following fields:
%       .stoich               The stoichiometric matrix of the metabolic
%                             network
%       .reactionLowerBounds  The lower bounds for the reactions, used to
%                             determine reversible reactions (negative
%                             lower bound means reversible)
%       .efms                 A matrix with sign value efms in the columns, 
%                             i.e. the value mnet.efms(r, e) contains 
%                             -1/0/1 for reaction flux r of EFM e.
%    Note that such a structure is returned by the CalculateFluxModes 
%    function.
%
% Sample:
%    efms = SignToDouble(mnet, 1:10);
%                             The first ten sign EFMs are converted into
%                             real EFMs with double precision flux values.
%
% Parameters:
%       mnet                  The mentioned structure containing 
%                             stoichiometrix matrix, EFMs and reaction 
%                             lower bounds. Such a structure is returned by
%                             the CalculateFluxModes function.
%       efmIndex              An index or a vector of indices of the EFMs
%                             to process, i.e. indices for columns in 
%                             mnet.efms
%       [how]       optional  This argument defines the method used to
%                             compute the kernel matrix. If 'q' is used
%                             (default), a QR decomposition is used
%                             resulting in normalized EFM vectors with
%                             length one (fastest method). Using 'r' or 'o'
%                             indicates that the standard nullspace method
%                             NULL should be used. With 'r', human friendly
%                             integer-like EFMs are returned (very slow).
%                             With 'o', the nullspace is computed using
%                             singular value decomposition offering the
%                             highest numeric stability.
%       [tol]       optional  Tolerance value to treat as zero,
%                             default is 1e-10
%
% Returns                     A matrix (r, e) with r = size(mnet.stoich, 1),
%                             i.e. r is the number of reactions, and 
%                             e = length(efmIndex), i.e. the number of EFMs
%                             to process
%
% Version:
%	=========================================================================
%	efmtool version 4.7.1, 2009-12-04 18:29:52
%	Copyright (c) 2009, Marco Terzer, Zurich, Switzerland
%	This is free software, !!! NO WARRANTY !!!
%	See LICENCE.txt for redistribution conditions
%	=========================================================================
%
function efms = SignToDouble(mnet, efmIndex, how, tol)

    if (nargin < 4)
        tol = 1e-10;
        if (nargin < 3)
            how = 's';
        end
    else
        tol = abs(tol);
    end
    ixrev = mnet.reactionLowerBounds < 0;
    rcnt  = size(mnet.stoich, 2);
    ecnt  = length(efmIndex);
    tcnt  = rcnt + sum(ixrev);
    
    stoichexp = [mnet.stoich -mnet.stoich(:, ixrev)];

    efms = zeros(rcnt, ecnt);
    for i=1:length(efmIndex)
        efm = double(mnet.efms(:, efmIndex(i)));
        efmpos = efm .* (efm > 0);
        efmneg = efm(ixrev) .* (efm(ixrev) < 0);
        efmbin = [efmpos; efmneg] ~= 0;

        stoichred = stoichexp(:, efmbin);
        if (how == 'q')
            [q,r,e] = qr(stoichred');
            n = nnz(abs(diag(r)) < max(abs(diag(r)))*max(size(r))*tol);
            efmred = q(:,end-n+1:end);
        elseif (how == 'r')
            efmred = null(stoichred, how);
        else
            efmred = null(stoichred);            
        end
        
        % perform some consistency checks
        if (size(efmred, 2) ~= 1)
            error(['non-unique double expansion for efm ' ...
                num2str(efmIndex(i)) ', found ' num2str(size(efmred, 2)) ...
                ' expansions: ' mat2str(efmred)]);
        end
        if (any(efmred < -tol, 1))
            efmred = -efmred;
            if (any(efmred < -tol, 1))
                error(['negative values for double expansion for efm ' ...
                    num2str(efmIndex(i)) ': ' mat2str(efmred)]);
            end
        end
            
        efmexp = zeros(tcnt, 1);
        efmexp(efmbin) = efmred;
        
        efms(1:rcnt, i) = efmexp(1:rcnt);
        efms(ixrev, i)  = efms(ixrev, i) - efmexp(rcnt+1:end);
    end
end