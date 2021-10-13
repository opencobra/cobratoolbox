function [A,b,csense] = lrsReadHalfspace(modelName,param)
% Read in a halfspace representation (*.ine) of a polytope derived from lrs
% See http://cgm.cs.mcgill.ca/~avis/C/lrslib/USERGUIDE.html#file
%     H-representation,
% 
%     m is the number of input rows, each being an inequality or equation.
%     n is the number of input columns and d=n-1 is the dimension of the input.
%     An inequality or equation of the form:
% 
%     b + a_1 x_1 + ... + a_d x_d >=  0
% 
%     b + a_1 x_1 + ... + a_d x_d =  0
% 
%     is input as the line:
% 
%     b  a_1 ... a_d
% 
%     The coefficients can be entered as integers or rationals in the format x/y. To distinguish an equation a linearity option must be supplied before the begin line (see below).
%
%
% INPUT
% modelName     string giving the prefix of a *.ine file
%               It is assumed the file is pwd/*.ine, otherwise provide the 
%               full path
%
% OUTPUT
%    A:             m x n left hand side matrix of linear system:math:`A x <=> (b)`
%    b:             m x 1 right hand side vector of linear system :math:`A x <=> (b)`
%    csense:        m x 1 character array of constraint senses, one for each row in A
%                         must be either ('E', equality, 'G' greater than, 'L' less than).
% 
% EXAMPLE file
% test
% H-representation
% nonnegative 
% begin
% 14 10 integer
% 0 -1 0 0 0 0 0 1 0 0
% 0 1 0 0 0 0 0 -1 0 0
% 0 1 -2 -2 0 0 0 0 0 0
% 0 -1 2 2 0 0 0 0 0 0
% 0 0 1 0 0 -1 -1 0 0 0
% 0 0 -1 0 0 1 1 0 0 0
% 0 0 0 1 -1 1 0 0 0 0
% 0 0 0 -1 1 -1 0 0 0 0
% 0 0 0 0 1 0 1 0 -1 0
% 0 0 0 0 -1 0 -1 0 1 0
% 0 0 1 1 0 0 0 0 0 -1
% 0 0 -1 -1 0 0 0 0 0 1
% 0 0 0 -1 1 -1 0 0 0 0
% 0 0 0 1 -1 1 0 0 0 0
% end

% Ronan Fleming 2021

if ~exist('param','var')
    param = struct();
end
% if ~isfield(param,'positivity')
%     param.positivity  = 0;
% end
% if ~isfield(param,'inequality')
%     param.inequality  = 0;
% end
% if ~isfield(param,'shellScript')
%     param.shellScript  = 0;
% end
% if ~isfield(param,'facetEnumeration')
%     %assume vertex enumeration, unless specified that it is facet enumeration
%     param.facetEnumeration  = 1;
% end
if ~isfield(param,'redund')
    param.redund  = 1;
end
if ~param.redund
    modelName = [modelName '_noR'];
end
if contains(modelName,'ine')
   modelName = strrep(modelName,'.ine','');
end

fid = fopen([modelName '.ine']);
if fid<0
    disp([modelName '.ine'])
    error('Could not open lrs output file.');
end
countRows = 0;
linearityRows=[];
while 1
    tline = fgetl(fid);
    if countRows ~=0
        countRows = countRows + 1;
    end
    if countRows==3
        if isempty(findstr('/', tline))
            scannedLine = sscanf(tline, '%d')';
            nCols = length(scannedLine);
        else
            line = strrep(line, '/', '.');
            scannedLine = sscanf(line, '%f')';
            nCols = length(scannedLine);
        end
    end
    if strcmp(tline, 'begin')
        countRows = 1;
    elseif ~ischar(tline)
        error('Could not read lrs output file.');
    end
    if contains(tline,'linearity')
        tline = strrep(tline,'linearity','');
        linearityRows = sscanf(tline, '%d')';
    end
    if strcmp(tline,'end')
        break
    end
end
nRows = countRows -3;

csense(1:nRows,1) = 'G';
if ~isempty(linearityRows)
    %first index of linearityRows is the number of linear equalities
    for i = 2:length(linearityRows)
        %disp(linearityRows(i))
        csense(linearityRows(i))='E';
    end
end
fclose(fid);

% pwd
fid = fopen([modelName '.ine']);
while 1
    if strcmp(fgetl(fid), 'begin')
        break;
    end
end
%skip the next row
line = fgetl(fid);

% read rows into a matrix
A = sparse(nRows, nCols);

for r = 1:nRows
    line = fgetl(fid);
    if isempty(findstr('/', line))
        scannedLine = sscanf(line, '%d')';  % added transpose here for reading in LP solutions
        if length(scannedLine)~=nCols
            %for some reason the second integer is not always the number of columns
            A = sparse(nRows, length(scannedLine));
            nCols = length(scannedLine);
        end
        A(r, :) = scannedLine;
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

A0 = A;

if nRows ~= nCols || 1
    %the negative of the first row is the right hand side
    b = -A(:,1);
    %the second and subsequent rows are the constraint matrix
    A = A(:,2:end);
else
    b = zeros(size(A,1),1);
end