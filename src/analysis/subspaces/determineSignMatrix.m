function [Shat, Shatabs, mconnect, nconnect, mconnectin, mconnectout] = determineSignMatrix(S, sorted)
% Determine the binaryform of the stoichiometric matrix S and the connectivity vectors
%
% INPUT:
%
%    S:            Stoichiometric matrix of size m x n (m rows, n columns)
%    sorted:       Boolean flag to sort the connectivity vectors (default: false)
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

    if ~exist('sorted', 'var')
        sorted = false;
    end

    Shat = S;  % initialize the binary matrix
    Shat = sign(S);
    % Note:
    % When S_ij > 0, Shat_ij = 1 -- products, produced -> kin
    % When S_ij < 0, Shat_ij = -1 -- reactants, consumed -> kout

    % determine the row connectivity
    Shatabs = abs(Shat);
    if nargout > 2
        mconnect = sum(Shatabs, 2);
        mconnectin = sum(Shat == 1, 2);
        mconnectout = sum(Shat == -1, 2);

        if sorted
            mconnect = sort(mconnect, 'descend');
            mconnectin = sort(mconnectin, 'descend');
            mconnectout = sort(mconnectout, 'descend');
        end
    end

    % determine the column connectivity
    if nargout > 3
        nconnect = sort(sum(Shat, 1), 'descend');
    end
end
