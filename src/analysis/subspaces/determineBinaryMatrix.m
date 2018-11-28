function [Shat, Shatabs, mconnect, nconnect, mconnectin, mconnectout] = determineBinaryMatrix(S)
% Determine the binary form of the stoichiometric matrix S
%
% INPUT:
%
%    S:            Stoichiometric matrix of size m x n (m rows, n columns)
%
% OUTPUTS:
%
%    Shat:         Binary form of the stoichiometric matrix
%    Shatabs:      Absolute value of Shat
%    mconnect:     Compound connectivity (connectivity number; sum of the number of non-zero entries in a row)
%    nconnect:     Reaction participation number (sum of the number of non-zero entries in a column)
%    mconnectin:   Produced compound connectivity
%    mconnectout:  Consumed compound connectivity
%
% .. Author: - Laurent Heirendt, June 2018

    Shat = S; % initialize the binary matrix
    Shat(S > 0) = 1; % products, produced -> kin
    Shat(S < 0) = -1; % reactants, consumed -> kout

    % determine the row connectivity
    Shatabs = abs(Shat);
    if nargout > 2
        mconnect = sort(sum(Shatabs, 2), 'descend');
        mconnectin = sum(Shat == 1, 2);
        mconnectout = sum(Shat == -1, 2);
    end

    % determine the column connectivity
    if nargout > 5
        nconnect = sort(sum(Shat, 1), 'descend');
    end
end