% The COBRAToolbox: testPlotRelaxedFBA.m
%
% Purpose:
%     - plotRelaxedFBA(sol, model, tol) prints a summary of a relaxedFBA solution: counts of
%       relaxed steady-state constraints (r) and bounds (p lower, q upper), then one table per
%       kind of relaxation (steady state; internal lower; internal upper; external lower;
%       external upper). The output is not suppressed: the command window text is also
%       recorded with diary in a temporary file and checked against counts derived by hand
%       from a hand-built five-reaction model and relaxation vectors. Also checked: the early
%       return for an unsuccessful solution, the default tolerance 100 * LP feasTol (two
%       inputs), relaxations below the tolerance or below 10 * LP optTol treated as zero, the
%       messages when nothing is relaxed, and the warning when S*v - b is not zero.
%
% Function under test:
%     src/analysis/relaxedFBA/plotRelaxedFBA.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a hand-built model of five reactions (createModel); no solver is called, only
%     the LP tolerances are read with getCobraSolverParams.
%
% Coverage exemptions:
%     Line 47: unreachable by any input; it is inside "if 0" (a debugging switch).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The count of external bounds relaxed also counts internal lower bounds
%       SEVERITY: cosmetic
%       TRIGGER: the main section below (R1 internal with p = 2, EX_A with p and q, EX_C with
%         p, EX_B with q): the line "external lower or upper bounds relaxed"
%       OBSERVED: (R2025a, 2026-11-23) "4 external lower or upper bounds relaxed": line 74
%         computes nnz(p | q & ~model.SIntRxnBool), and & binds before |, so every relaxed
%         lower bound counts, also the internal one of R1
%       EXPECTED: 3, i.e. nnz((p | q) & ~model.SIntRxnBool) (EX_A, EX_C and EX_B)
%       LINES: 74
%     - DEFECT: The tables of upper bound relaxations are headed "lower bounds relaxed"
%       SEVERITY: cosmetic
%       TRIGGER: the main section below (R2 internal with q = 3, EX_B external with q = 0.7)
%       OBSERVED: (R2025a, 2026-11-23) the R2 table is headed "1 internal reaction lower
%         bounds relaxed..." and the EX_B table "1 external reaction lower bounds relaxed...";
%         with nothing relaxed the messages are "No internal reaction lower bounds relaxed"
%         and "No external reaction lower bounds relaxed" twice each
%       EXPECTED: "upper bounds" in the headings and messages of lines 117, 128, 151 and 162
%         (the tables select q ~= 0 and p == 0)
%       LINES: 117, 128, 151, 162
%     - DEFECT: The first character of each reaction formula is printed as its character code
%       SEVERITY: cosmetic
%       TRIGGER: the main section below (any table row)
%       OBSERVED: (R2025a, 2026-11-23) the R1 row ends with "65[c]  -> B[c]" instead of
%         "A[c]  -> B[c]": the format '%6g%-100s' gives the formula text to %6g first, which
%         prints the code of its first character (65 for 'A')
%       EXPECTED: the formula as text, e.g. "A[c]  -> B[c]" (one %s conversion)
%       LINES: 106, 123, 140, 157
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-23.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPlotRelaxedFBA'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% getCobraSolverParams reads the solver state, which may create global variables; the new
% ones are removed at the end
globalsBefore = who('global');

% five reactions: R1 and R2 internal, EX_A, EX_C and EX_B external. Bounds chosen so that
% R1 (0 to 10) and EX_C (fixed at 0) have finite bounds (maxUB = 1000, minLB = -1000)
model = createModel({'R1', 'R2', 'EX_A', 'EX_C', 'EX_B'}, {'', '', '', '', ''}, ...
    {'A[c] -> B[c]', 'B[c] -> C[c]', 'A[c] <=> ', 'C[c] <=> ', 'B[c] <=> '}, ...
    'lowerBoundList', [0, 0, -1000, 0, 0], 'upperBoundList', [10, 1000, 1000, 0, 1000], ...
    'printLevel', 0);
model.SIntRxnBool = [true; true; false; false; false];
metA = find(strcmp(model.mets, 'A[c]'));
metB = find(strcmp(model.mets, 'B[c]'));
nRxn = numel(model.rxns);
nMet = numel(model.mets);

% the LP tolerances used by the function (global settings, defaults 1e-6)
feasTol = getCobraSolverParams('LP', 'feasTol');
optTol = getCobraSolverParams('LP', 'optTol');

% record the command window in a temporary file; the previous diary state is restored below
workDir = tempname;
mkdir(workDir);
diaryWasOn = strcmp(get(0, 'Diary'), 'on');
previousDiaryFile = get(0, 'DiaryFile');
if diaryWasOn
    diary('off');
end

%% an unsuccessful relaxedFBA solution: two messages and nothing else

failedSol.stat = 0;
diaryFile = fullfile(workDir, 'failed.txt');
diary(diaryFile);
plotRelaxedFBA(failedSol, model, 1e-3);
diary('off');
printedText = fileread(diaryFile);
assert(contains(printedText, 'relaxedFBA did not complete successfully, nothing to display'));
assert(contains(printedText, 'relaxedFBA problem infeasible, check relaxOption fields'));
assert(~contains(printedText, 'steady state constraints relaxed'));

%% one relaxation of each kind (tol = 1e-3), steady state S*v = b

% r: A relaxed by 0.25; B by 1e-5 < tol (treated as zero)
% p: R1 2 (internal lower), EX_A 0.5 (with q, both bounds), EX_C 0.4 (external lower),
%    EX_B 1e-4 < tol (zero)
% q: R2 3 (internal upper), EX_A 0.6, EX_B 0.7 (external upper)
% v = 0, b = 0: S*v = b, so no warning
sol.stat = 1;
sol.v = zeros(nRxn, 1);
sol.r = zeros(nMet, 1);
sol.r(metA) = 0.25;
sol.r(metB) = 1e-5;
sol.p = [2; 0; 0.5; 0.4; 1e-4];
sol.q = [0; 3; 0.6; 0; 0.7];
lastwarn('');
diaryFile = fullfile(workDir, 'mixed.txt');
diary(diaryFile);
plotRelaxedFBA(sol, model, 1e-3);
diary('off');
printedText = fileread(diaryFile);
assert(isempty(lastwarn));
% totals counted by hand: one steady-state constraint (A); no internal reaction with both
% bounds relaxed; one external (EX_A); finite lower bounds relaxed: R1 and EX_C; fixed
% reactions with a relaxed lower bound: EX_C. The count of line 74 is a documented defect
% and is not checked
assert(numel(strfind(printedText, sprintf('1 steady state constraints relaxed\n'))) == 2);
assert(contains(printedText, '0 internal lower and upper bounds relaxed'));
assert(contains(printedText, '1 external lower and upper bounds relaxed'));
assert(contains(printedText, '2 finite lower bounds relaxed'));
assert(contains(printedText, '1 lower bounds relaxed on fixed reactions (lb=ub=0)'));
% the steady-state table lists A with r = 0.25 and dxdt = b = 0, not B (1e-5 < tol)
assert(~isempty(regexp(printedText, 'A\[c\]\s+0\.25\s+0', 'once')));
assert(isempty(regexp(printedText, 'B\[c\]\s+1e-05', 'once')));
% internal lower bound table: R1 with p = 2, lb = 0, v = 0, ub = 10, q = 0
assert(contains(printedText, '1 internal reaction lower bounds relaxed...'));
assert(~isempty(regexp(printedText, 'R1\s+2\s+0\s+0\s+10\s+0', 'once')));
% internal upper bound table: R2 with p = 0, lb = 0, v = 0, ub = 1000, q = 3
assert(~isempty(regexp(printedText, 'R2\s+0\s+0\s+0\s+1000\s+3', 'once')));
% external lower bound table: EX_C with p = 0.4, lb = 0, v = 0, ub = 0, q = 0
assert(contains(printedText, '1 external reaction lower bounds relaxed...'));
assert(~isempty(regexp(printedText, 'EX_C\s+0\.4\s+0\s+0\s+0\s+0', 'once')));
% external upper bound table: EX_B with q = 0.7 (its p = 1e-4 < tol counts as zero)
assert(~isempty(regexp(printedText, 'EX_B\s+0\.0001\s+0\s+0\s+1000\s+0\.7', 'once')));
% EX_A has both bounds relaxed, so it is in none of the four one-bound tables
assert(isempty(regexp(printedText, 'EX_A\s+0\.5', 'once')));
% the tables come in the order R1, R2, EX_C, EX_B
rowStarts = [regexp(printedText, 'R1\s+2', 'once'), regexp(printedText, 'R2\s+0', 'once'), ...
    regexp(printedText, 'EX_C\s+0\.4', 'once'), regexp(printedText, 'EX_B\s+0\.0001', 'once')];
assert(numel(rowStarts) == 4 && issorted(rowStarts));

%% nothing relaxed: the "No ..." message of each table

noSol.stat = 1;
noSol.v = zeros(nRxn, 1);
noSol.r = zeros(nMet, 1);
noSol.p = zeros(nRxn, 1);
noSol.q = zeros(nRxn, 1);
diaryFile = fullfile(workDir, 'none.txt');
diary(diaryFile);
plotRelaxedFBA(noSol, model, 1e-3);
diary('off');
printedText = fileread(diaryFile);
assert(contains(printedText, '0 steady state constraints relaxed'));
assert(contains(printedText, 'No steady state constraints relaxed'));
% two internal and two external tables, each with its "No ..." line
assert(numel(strfind(printedText, 'No internal reaction lower bounds relaxed')) == 2);
assert(numel(strfind(printedText, 'No external reaction lower bounds relaxed')) == 2);
assert(isempty(regexp(printedText, 'R1\s+\d', 'once')));

%% default tolerance (two inputs): 100 * LP feasTol

% p(R1) is half the default tolerance (treated as zero), q(R2) twice it (relaxed); both are
% above 10 * optTol, so only the tolerance decides
defaultTol = 100 * feasTol;
assert(defaultTol / 2 > 10 * optTol);
defaultSol = noSol;
defaultSol.p(1) = defaultTol / 2;
defaultSol.q(2) = 2 * defaultTol;
diaryFile = fullfile(workDir, 'defaultTol.txt');
diary(diaryFile);
plotRelaxedFBA(defaultSol, model);
diary('off');
printedText = fileread(diaryFile);
% R1 is not listed (its lower bound table says "No ..."), R2 is listed in the upper table
assert(isempty(regexp(printedText, 'R1\s+\d', 'once')));
assert(contains(printedText, 'No internal reaction lower bounds relaxed'));
assert(~isempty(regexp(printedText, 'R2\s+0\s+0\s+0\s+1000\s', 'once')));
assert(contains(printedText, '0 finite lower bounds relaxed'));

%% a flux vector that violates S*v = b raises a warning (not suppressed)

% v(R1) = 1 gives S*v = [-1; 1; 0] for A, B, C, so norm(S*v - b) = sqrt(2) > 10 * optTol
warnSol = noSol;
warnSol.v(1) = 1;
lastwarn('');
diaryFile = fullfile(workDir, 'warning.txt');
diary(diaryFile);
plotRelaxedFBA(warnSol, model, 1e-3);
diary('off');
warningText = lastwarn;
assert(startsWith(warningText, ...
    'relaxedFBA relaxed steady state constraints too much, norm(S*v-b)= 1.4142'));

%% restore the diary state, remove the files and the new global variables

set(0, 'DiaryFile', previousDiaryFile);
if diaryWasOn
    diary('on');
end
rmdir(workDir, 's');
newGlobals = setdiff(who('global'), globalsBefore);
for iGlobal = 1:numel(newGlobals)
    clearvars('-global', newGlobals{iGlobal});
end

% change the directory
cd(currentDir)
