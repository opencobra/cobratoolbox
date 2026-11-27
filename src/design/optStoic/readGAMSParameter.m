function [keys, values] = readGAMSParameter(fileName)
% Reads the entries of a one- or two-dimensional GAMS parameter from an
% include file with lines of the form `'key1'.'key2'  value` or
% `'key1'  value`. GAMS comments (lines starting with `*` and inline
% comments `/* ... */`) are ignored.
%
% USAGE:
%
%    [keys, values] = readGAMSParameter(fileName)
%
% INPUT:
%    fileName:     (string) path to the GAMS include file
%
% OUTPUTS:
%    keys:         (cell array) n x d cell array with the keys of each
%                  entry (d = 1 or 2; for one-dimensional entries the second
%                  column is empty when the file mixes dimensions)
%    values:       (double) n x 1 vector with the values
%
% EXAMPLE:
%
%    [keys, values] = readGAMSParameter('data/Sij_modified.txt');
%    % keys(:, 1): metabolites, keys(:, 2): reactions, values: coefficients
%
% .. Author: - Sebastián N. Mendoza, 13/10/2026, MATLAB implementation of the data reading of optStoic-GAMS

if nargin < 1 || ~(ischar(fileName) || isstring(fileName))
    error('fileName must be a string.');
end
fileName = char(fileName);
if ~exist(fileName, 'file')
    error('File %s not found.', fileName);
end
txt = fileread(fileName);
txt = regexprep(txt, '/\*.*?\*/', '');
% remove comment lines
txt = regexprep(txt, '(?m)^\s*\*[^\n]*', '');
% the second key is captured with its dot and quotes (MATLAB does not return
% tokens nested in optional non-capturing groups)
tokens = regexp(txt, '(?m)^\s*''([^'']+)''(\s*\.\s*''[^'']+'')?\s+([-+]?\d*\.?\d+(?:[eE][-+]?\d+)?)', 'tokens');
n = numel(tokens);
key1 = cell(n, 1);
key2 = cell(n, 1);
values = zeros(n, 1);
for i = 1:n
    key1{i} = strtrim(tokens{i}{1});
    key2{i} = '';
    if numel(tokens{i}) == 3
        key2{i} = strtrim(regexprep(tokens{i}{2}, '^\s*\.\s*''|''$', ''));
    end
    values(i) = str2double(tokens{i}{end});
end
if all(cellfun(@isempty, key2))
    keys = key1;
else
    keys = [key1, key2];
end
end
