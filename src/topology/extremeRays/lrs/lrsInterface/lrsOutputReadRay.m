function [R, V] = lrsOutputReadExt(filename)
% reads into matlab a vertex representation output from lrs
%
% INPUT
% filename  name of .ext file from lrs
%
% OUTPUT
% R       nDim by nRay matrix of extreme rays
% V       nDim by nVertex matrix of vertices

fid = fopen(filename);

% pause(eps)
while 1
    if strcmp(fgetl(fid), 'begin')
        break;
    end
end

% find the number of columns
C = textscan(fid, '%s %f %s', 1);
nCols = C{2};

% move on pointer one line
fgetl(fid);

% count the number of rows in the file
nRows = 0;
while 1
    if ~strcmp(fgetl(fid), 'end')
        nRows = nRows + 1;
    else
        break;
    end
end

fclose(fid);


% pwd
fid = fopen(filename);

while 1
    if strcmp(fgetl(fid), 'begin')
        break;
    end
end

% find the number of columns
C = textscan(fid, '%s %f %s', 1);
nCols = C{2};

% move on pointer one line
fgetl(fid);

% read rows into a matrix
P = sparse(nRows, nCols)

for r = 1:nRows
    line = fgetl(fid);
    if isempty(findstr('/', line))
        scannedLine = sscanf(line, '%d')';  % added transpose here for reading in LP solutions
        P(r, :) = scannedLine;
    else
        line = strrep(line, '/', '.');
        scannedLine = sscanf(line, '%f')';
        for c = 1:nCols
            M = mod(scannedLine(c), 1);
            if M ~= 0
                F = fix(scannedLine(c));
                scannedLine(c) = F / M;
            else
                scannedLine(c) = int16(scannedLine(c));
            end
        end
        % pause(eps);
    end
end
fclose(fid);

% Each vertex is given in the form
% 1   v0   v 1 ...   vn-1
V = P(P(:, 1) ~= 0, 2:end)';

% Each ray is given in the form
% 0   r0   r 1 ...   rn-1
R = P(P(:, 1) == 0, 2:end)';  % not the transpose

% order the vertices by the number of nnz
[mlt, nlt] = size(R);
nNonZero = zeros(nlt, 1);
for n = 1:nlt
    nNonZero(n) = nnz(R(:, n));
end
[B, IX] = sort(nNonZero);
R = R(:, IX);
