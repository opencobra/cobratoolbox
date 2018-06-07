function [Shatabs, mconnect, mconnectin, mconnectout, nconnect] = determineBinaryMatrix(S)
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

    % initialize the binary matrix
    Shat = S;
    Shat(S > 0) = 1;
    Shat(S < 0) = -1;

    % determine the row connectivity
    Shatabs = abs(Shat);
    if nargout > 1
        mconnect = sort(sum(Shatabs, 2), 'descend');
        mconnectin = sum(Shat == 1, 2);
        mconnectout = sum(Shat == -1, 2);
    end

    % determine the column connectivity
    if nargout > 5
        nconnect = sort(sum(Shat, 1), 'descend');
    end
end