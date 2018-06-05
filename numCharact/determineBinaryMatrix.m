function Shat = determineBinaryMatrix(S)
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

    % initialize the binary matrix
    Shat = zeros(m, n);

    for i = 1:m
        for j = 1:n
            if abs(S(i, j)) > 0
                Shat(i, j) = 1;
            end
        end
    end
end