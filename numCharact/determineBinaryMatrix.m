function [Shat, nconnect, mconnect] = determineBinaryMatrix(S)
% Determine the binary form of S
%
% INPUT:
%
%    S:         Stoichiometric matrix
%
% OUTPUT:
%
%    Shat:      Binary form of the stoichiometric matrix
%
% .. Author: Laurent Heirendt, June 2018

    % determine the size of S
    [m,n] = size(S);

    % initialize the connectivity vectors
    nconnect = zeros(n,1);
    mconnect = zeros(m,1);

    % initialize the binary matrix
    Shat = zeros(m, n);

    for i = 1:m
        for j = 1:n
            if abs(S(i, j)) > 0
                Shat(i, j) = 1;
            end
        end
    end

    % determine the column connectivity
    for j = 1:n
        nconnect(j) = sum(Shat(:, j));
    end

    % determine the row connectivity
    for i = 1:m
        mconnect(i) = sum(Shat(i, :));
    end

    % sort the connectivity vectors
    mconnect = sort(mconnect, 'descend');
    nconnect = sort(nconnect, 'descend');

end