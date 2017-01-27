function vecT = columnVector(vec)
% columnVector Converts a vector to a column vector
%
% vecT = columnVector(vec)
%
% Authors:
%     - Original file: Markus Herrgard
%     - Minor changes: Laurent Heirendt January 2017

[n, m] = size(vec);

if n < m
    vecT = vec';
else
    vecT = vec;
end
