function vec = columnVector(vec)
%columnVector Converts a vector to a column vector
%
% vec = columnVector(vec)
%
% Markus Herrgard 

[n,m] = size(vec);

if (n < m)
    vec = vec';
end