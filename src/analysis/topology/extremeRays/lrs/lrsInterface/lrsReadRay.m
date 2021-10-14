function [Q, vertexBool, fileNameOut] = lrsReadRay(modelName,param)
% Read in a vertex representation (*.ext) of a polytope derived from lrs
% See http://cgm.cs.mcgill.ca/~avis/C/lrslib/USERGUIDE.html#file
%
% USAGE:
%
%    [Q, vertexBool, fileNameOut] = lrsReadRay(modelName,param)
%
% INPUT:
% modelName     string giving the prefix of the *.ext file that will contain the vertex representation
%               It is assumed the file is pwd/*.ine, otherwise provide the full path.
%
% OUTPUT:
% Q             m x n integer matrix where each row is a variable and each column is a vertex or ray
% vertexBool         n x 1 Boolean vector indicating which columns of Q are vertices
%                    By default, all columns of Q are assumed to be rays.
%
% Ronan Fleming 2021

if ~exist('param','var')
    param = struct();
end
if ~isfield(param,'positivity')
    param.positivity = 0;
end
if ~isfield(param,'inequality')
    param.positivity = 0;
end
if ~isfield(param,'sh')
    param.sh = 0;
end
if ~exist('modelName','var')
    modelName = 'test';
end

if param.inequality == 0
%     if param.positivity == 0
%         modelName = [modelName '_pos_eq'];
%     else
%         modelName = [modelName '_neg_eq'];
%     end
else
    if param.positivity == 1
        modelName = [modelName '_pos_ineq'];
    else
        modelName = [modelName '_neg_ineq'];
    end
end
fileNameOut = [modelName '.ext'];

fid = fopen(fileNameOut);
if fid<0
    disp(fileNameOut)
    error('Could not open lrs output file.');
end

% pause(eps)
while 1
    tline = fgetl(fid);
    if strcmp(tline, 'begin')
        break;
    elseif ~ischar(tline)
        error('Could not read lrs output file.'); 
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
fid = fopen(fileNameOut);
if fid<0
    disp(fileNameOut)
    error('Could not open lrs output file.');
end


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
P = sparse(nRows, nCols);

for r = 1:nRows
    line = fgetl(fid);
    if ~contains(line,'/')
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
%remove zero vertices
V = V(:,sum(V,1)~=0);

% Each ray is given in the form
% 0   r0   r 1 ...   rn-1
R = P(P(:, 1) == 0, 2:end)';  % not the transpose

% order the rays by the number of nnz
[mlt, nlt] = size(R);
nNonZero = zeros(nlt, 1);
for n = 1:nlt
    nNonZero(n) = nnz(R(:, n));
end
%remove zero rays
R = R(:,nNonZero~=0);
[B, IX] = sort(nNonZero);
R = R(:, IX);

%first vertices then rays
Q = [V, R];
vertexBool = false(size(Q,2),1);
vertexBool(1:size(V,2))=1;
