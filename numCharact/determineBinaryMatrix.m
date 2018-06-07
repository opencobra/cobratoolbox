function [Shat, mconnect, nconnect] = determineBinaryMatrix(S)
% Determine the binary form of S
%
% INPUT:
%
%    S:         Stoichiometric matrix of size m x n (m rows, n columns)
%
% OUTPUT:
%
%    Shat:      Binary form of the stoichiometric matrix
%    mconnect:  Compound connectivity (connectivity number; sum of the number of non-zero entries in a row)
%    nconnect:  Reaction participation number (sum of the number of non-zero entries in a column)
%
% .. Author: Laurent Heirendt, June 2018

    % determine the size of S
    [m,n] = size(S);

    % initialize the connectivity vectors
    mconnect = zeros(m,1);
    nconnect = zeros(n,1);

    % initialize the binary matrix
    Shat = zeros(m, n);

    % determine the elements of the binary matrix
    for i = 1:m
        for j = 1:n
            if abs(S(i, j)) > 0
                Shat(i, j) = 1;
            end
        end
    end

    % determine the column connectivity
    if nargout > 2
        for j = 1:n
            nconnect(j) = sum(Shat(:, j));
        end
    end

    % determine the row connectivity
    if nargout > 1
        for i = 1:m
            mconnect(i) = sum(Shat(i, :));
        end
    end

    % sort the connectivity vectors
    if nargout > 2
        nconnect = sort(nconnect, 'descend');
    end

    if nargout > 1
        mconnect = sort(mconnect, 'descend');
    end

end