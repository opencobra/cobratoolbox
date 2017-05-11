function retStatus = printMatrix(A, format, file)
% printMatrix Prints matrix into a file or screen
%
% USAGE:
%
%     printMatrix(A, format, file)
%
% INPUTS:
%    A:         Matrix
%    format:    Format string (opt, default '%6.4f\t')
%    file:      File name (opt)
%
% .. Authors:
%     - Original file: Markus Herrgard
%     - Minor changes: Laurent Heirendt January 2017

retStatus = 0;

if nargin < 2
    format = '%6.4f\t';
end
if nargin < 3
    fid = 1;
else
    fid = fopen(file, 'w');
end

[n, m] = size(A);

for i = 1:n
    for j = 1:m
        if ~iscell(A)
            fprintf(fid, format, A(i, j));
        else
            fprintf(fid, format, A{i, j});
        end
    end
    fprintf(fid, '\n');
end

retStatus = 1;
