function [directory,fname]=writeMinosProblem(LPproblem,precision,modelName,directory,printLevel)
% inputs a COBRA LPproblem Matlab structure and outputs
% a file that can be input to an F90 main program
% for solution by SQOPT or MINOS.
%
% INPUT
% LPproblem Structure containing the following fields describing the LP
% problem to be solved
%  A      LHS matrix
%  b      RHS vector
%  c      Objective coeff vector
%  lb     Lower bound vector
%  ub     Upper bound vector
%  osense Objective sense (-1 max, +1 min)
%  csense Constraint senses, a string containting the constraint sense for
%         each row in A ('E', equality, 'G' greater than, 'L' less than).
%
% OPTIONAL INPUT
% precision     ('double') or 'single' precision
% modelName     name is the problem name (a character string)
% directory     the directory where optimization problem file is saved
%
% OUTPUT
% fname         filename of the optimization problem 

% derived from dumpLPfun by Ding Ma and Michael Saunders, Stanford
% University.
% 09 May 2012: First version of this script developed as dumpLP.m
%              Ding Ma and Michael Saunders, Stanford University.
%              c has only one nonzero, so we output that index.
% 15 May 2012: Changed %15.6f to %20.10e for output of real values.
% 16 May 2012: Settled on %8i for integers and %19.12e for reals.
% 06 Aug 2012: Philip Gill mentioned that SQOPT treats an LP as a QP
%              if the objective is kept in cObj (separate from A).
%              We now insert cObj as a new *last* row of A before dumping.
%
% 10 Jan 2013: dumpLP.m modified to handle other FBA data files
%              such as those in ~/Dropbox/linearfba/data .
% 15 Apr 2014: Grabbed a copy for use with quadMinos.
% 19 Apr 2014: Problem name is output as first line of output file.
%              Floating-point values are output using eformat.
%              modelNo, eformat, name must be defined as described below.
%
% 28 Apr 2014: Assume dumpLP.m is in ~/../code/matlab/
%              and FBA data    is in ~/../data/FBA/
% 15 Ocr 2014: Turn script into function to be used with solveCobraLP

%   BEFORE RUNNING writeMinosProblem, DO THIS:
%
%   1. Set modelNo = one of the switch numbers
%   2. Set format  = 1 or 2
%   3. Set name for the chosen modelNo
%      (AT MOST 7 CHARACTERS WITH NO TRAILING BLANKS)
%
%   name is the problem name (a character string).
%   An 's' is appended to name if format==2 (single precision),
%   name.txt is the name of the output file.
%   name     is the first line in the output file.

format1 = '%19.12e\n';   % roughly double precision
format2 = '%12.5e\n';    % roughly single precision

if ~exist('precision','var')
    precision='double';
end

switch precision
    case 'double'
        eformat = format1;
    case 'single'
        eformat = format2;
end

% name must not have trailing blanks.
% Grab at most 7 characters.
% Add 's' if format==2 (single precision).

if ~exist('modelName','var')
    modelName='FBA';
end
fname=modelName(1:min(length(modelName),7));
fname=strrep(fname,' ','_');

if ~exist('directory','var')
    directory=pwd;
end

%filename
longfname = [directory '/' fname '.txt'];

%csense addition code cut from optimizeCbModel.m
if ~isfield(LPproblem,'csense')
    % If csense is not declared in the LPproblem, assume that all
    % constraints are equalities.
    csense(1:size(LPproblem.S,1),1) = 'E';
else
    csense = LPproblem.csense;      % E or L or G
end
if ~isfield(LPproblem,'osense')
    %assume maximisation
    osense=-1;
else
    osense = LPproblem.osense;      % 1=min   (-1=max)
end

% Extract data from LPproblem
A      = LPproblem.A;
b      = LPproblem.b;
c      = LPproblem.c;
xl     = LPproblem.lb;
xu     = LPproblem.ub;

% 06 Aug 2012: Include c as an additional free *last* row of Ax = b
%              so that SQOPT will treat the problem as an LP, not a QP.
%              This is ok for MINOS also.

A     = [      A            % Luckily we only have to do it once
        osense*sparse(c)'];
b     = [b; 0];

[m,n]   = size(A);
nzS     = nnz(A);
[I,J,V] = find(A);          % Sij indices and values
P       = zeros(n+1,1);     % Pointers to start of each column
p       = 1;
for j=1:n
    P(j) = p;
    p    = p + nnz(A(:,j));
end
P(n+1)  = p;

tic
fid = fopen(longfname,'w');        % Open file longfname for writing
fprintf(fid,'%c%c%c%c%c%c%c%c', fname); % First line, up to 8 chars
fprintf(fid,'\n');             % Force a new line
fprintf(fid,'%8i\n'    , m);   % No of rows in A (including obj row)
fprintf(fid,'%8i\n'    , n);   % No of cols in A
fprintf(fid,'%8i\n'    , nzS); % No of nonzeros
fprintf(fid,'%8i\n'    , P);    % Pointers         n+1
fprintf(fid,'%8i\n'    , I);    % Row indices      nzS
fprintf(fid, eformat   , V);    % Values           nzS

bigbnd = 1e+20;                % MINOS and SQOPT's "infinite" bound
sl     = b;                    % Bounds on slacks s = A*x
su     = b;                    % b handles E rows
L      = find(csense=='L');    % Find the L rows (<=)
sl(L)  = -bigbnd;
G      = find(csense=='G');    % Find the G rows (>=)
su(G)  =  bigbnd;

sl(m)  = -bigbnd;              % Free bounds on the objective row
su(m)  =  bigbnd;
bl     = [xl; sl];
bu     = [xu; su];
fprintf(fid, eformat, bl);
fprintf(fid, eformat, bu);
fclose(fid);
if printLevel>0
    toc;
    fprintf('%s\n',['In ' num2str(toc) ' sec, file written to ' longfname]);
end
