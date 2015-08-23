% Checks whether a matrix is symmetric (has to be square)
% Check whether mat=mat^T
% INPUTS: adjacency matrix
% OUTPUTS: boolean variable, {0,1}
% GB, October 1, 2009
% 
% Hulda SH  Renamed file to avoid name conflict with built-in matlab
%           function with the exact same functionality

function S = issymmetric(mat)

S = false; % default
if mat == transpose(mat); S = true; end