function vecT = columnVector(vec)
% Converts a vector to a column vector
%
% USAGE:
%
%   vecT = columnVector(vec)
%
% INPUT:
%   vec:  a vector
%
% OUTPUT:
%   vecT: a column vector
%
% .. Authors:
%     - Original file: Markus Herrgard
%     - Minor changes: Laurent Heirendt January 2017

[n, m] = size(vec);

if n < m
    vecT = vec';
else
    vecT = vec;
end
