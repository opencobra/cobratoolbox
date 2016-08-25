function printMatrix(A,format,file)
%printMatrix Prints matrix into a file or screen
%
% printMatrix(A,format,file)
%
% A         Matrix
% format    Format string (opt,default '%6.4f\t')
% file      File name (opt)
%
% Markus Herrgard

if (nargin < 2)
    format = '%6.4f\t';
end
if (nargin < 3)
    fid = 1;
else
    fid = fopen(file,'w');
end

[n,m] = size(A);

for i = 1:n
    for j = 1:m
        if (~iscell(A))
            fprintf(fid,format,A(i,j));
        else
            fprintf(fid,format,A{i,j});
        end
    end
    fprintf(fid,'\n');
end