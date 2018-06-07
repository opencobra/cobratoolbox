function [Shat, mconnect, mconnectin, mconnectout, nconnect] = determineBinaryMatrix(S)
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
    mconnectin = zeros(m,1);
    mconnectout = zeros(m,1);
    nconnect = zeros(n,1);

    % initialize the binary matrix
    %{
        Shat = zeros(m, n);

    % determine the elements of the binary matrix
    for i = 1:m
        for j = 1:n
            if S(i, j) > 0
                Shat(i, j) = 1;
            elseif S(i, j) < 0
                Shat(i, j) = -1;
            end
        end
    end
    %}
    Shat = S;
    Shat(S > 0) = 1;
    Shat(S < 0) = -1;

    % determine the row connectivity
    if nargout > 1
        for i = 1:m
            mconnect(i) = sum(abs(Shat(i, :)));
            for j = 1:n
                if Shat(i, j) == 1
                    mconnectin(i) = mconnectin(i) + 1;
                elseif Shat(i,j) == -1
                    mconnectout(i) = mconnectout(i) + 1;
                end
            end
        end
    end

    % determine the column connectivity
    if nargout > 5
        for j = 1:n
            nconnect(j) = sum(Shat(:, j));
        end
    end

    % sort the connectivity vectors
    if nargout > 5
        nconnect = sort(nconnect, 'descend');
    end

    if nargout > 1
        mconnect = sort(mconnect, 'descend');
    end

    % return a true binary matrix
    Shat = abs(Shat);

end