% The COBRAToolbox: testReadMinosSolution.m
%
% Purpose:
%     - readMinosSolution reads the solution file that MINOS and quadMINOS write with the
%       option Report file 81: three header lines (inform m n; osense iobj obj; 0 ninf sinf)
%       and one line hs xn rc per variable and slack. It returns the header values, x, rc and
%       the states of x as stored, and converts the MINOS slacks to the SNOPT convention
%       (s = -xn of the slacks, slack state 0 <-> 1 swapped, other states kept; y = rc of the
%       slacks). The test writes such files by hand in the documented Fortran format
%       (i2, es24.14, es24.14) into a tempname folder; expected values follow from the help
%       text. MINOS itself is not needed.
%
% Function under test:
%     src/base/solvers/minos/readMinosSolution.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; hand-written solution files in a tempname folder.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testReadMinosSolution'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

tmpPath = tempname;
mkdir(tmpPath);

% a problem with m = 2 rows and n = 3 columns, so nb = 5 lines after the header
header = [0, 2, 3; 1, 2, -4.5; 0, 1, 2.5e-3];
hsAll = [3; 0; 2; 0; 1];                % states of x (3) and of the MINOS slacks (2)
xnAll = [1.5; -2; 0; 4; -0.25];         % values of x and of the MINOS slacks
rcAll = [0; 1e-3; -2; 0.5; -1.25];      % reduced gradients of x and duals of the rows
data = [header; hsAll, xnAll, rcAll];

%% a fort.81 file is read and converted

solFile = fullfile(tmpPath, 'fort.81');
fid = fopen(solFile, 'w');
fprintf(fid, '%2d%24.14E%24.14E\n', data');
fclose(fid);

sol = readMinosSolution(solFile);
% header values are integers or numbers written with 15 significant digits, so the read
% values equal the written doubles to 1e-12 relative accuracy; integers are exact
assert(sol.inform == 0);
assert(sol.m == 2);
assert(sol.n == 3);
assert(sol.osense == 1);
assert(sol.objrow == 2);
tol = 1e-12;
assert(abs(sol.obj - (-4.5)) < tol);
assert(sol.numinf == 1);
assert(abs(sol.suminf - 2.5e-3) < tol);
% the variables are returned as stored
assert(isequal(sol.xstate, [3; 0; 2]));
assert(max(abs(sol.x - [1.5; -2; 0])) < tol);
assert(max(abs(sol.rc - [0; 1e-3; -2])) < tol);
% the slacks change sign, the slack states 0 and 1 are swapped, y are the slack duals
assert(isequal(sol.sstate, [1; 0]));
assert(max(abs(sol.s - [-4; 0.25])) < tol);
assert(max(abs(sol.y - [0.5; -1.25])) < tol);
% the output has exactly the documented fields
assert(isequal(sort(fieldnames(sol)), sort({'inform'; 'm'; 'n'; 'osense'; 'objrow'; 'obj'; ...
    'numinf'; 'suminf'; 'xstate'; 'sstate'; 'x'; 's'; 'rc'; 'y'})));

%% a .sol file with other slack states (2 and 3 are kept)

data2 = [1, 1, 1; -1, 1, 7; 0, 0, 0; 1, 0.5, 0; 3, 2, -1];
solFile2 = fullfile(tmpPath, 'qFBA.sol');
fid = fopen(solFile2, 'w');
fprintf(fid, '%2d%24.14E%24.14E\n', data2');
fclose(fid);

sol = readMinosSolution(solFile2);
assert(sol.inform == 1);
assert(sol.osense == -1);
assert(abs(sol.obj - 7) < tol);
assert(sol.xstate == 1);
assert(abs(sol.x - 0.5) < tol);
% slack state 3 (superbasic) is neither 0 nor 1, so it is kept
assert(sol.sstate == 3);
assert(abs(sol.s - (-2)) < tol);
assert(abs(sol.y - (-1)) < tol);

% remove the temporary folder
rmdir(tmpPath, 's');

% change the directory
cd(currentDir)
