% The COBRAToolbox: testInspectMosekProb.m
%
% Purpose:
%     - inspectMosekProb inspects a MOSEK problem structure: it returns per-field numerical
%     statistics, size and sparsity statistics of the matrix fields a and f, and a structure of
%     consistency checks (dimensions, NaN and Inf, inconsistent and fixed bounds, large dynamic
%     range, rank and conditioning), and prints them.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test. MOSEK itself is not needed: the problem
%       structures are built by hand and the printed output is captured with evalc.
%
% Function under test:
%     src/base/solvers/mosek/inspectMosekProb.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Lines 244-245, 250-251, 263-264 and 269-270, the catch handlers around sprank and condest
%     for the matrices a and f. Any numeric matrix those functions reject (for example an
%     integer class) has already stopped the inspection at the norm call of the matrix
%     statistics, so the handlers cannot be reached.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A constraint matrix without rows or columns stops the inspection with an error
%       SEVERITY: error
%       TRIGGER: prob.a or prob.f with zero rows or zero columns, for example zeros(0, 2)
%       OBSERVED: min and max of the empty row count vector are empty, so building the table of
%         matrix statistics fails with "All table variables must have the same number of rows"
%       EXPECTED: a report for the empty matrix, with NaN statistics
%       LINES: 137-153
%     - DEFECT: A matrix field of an integer class stops the inspection with an error
%       SEVERITY: limitation
%       TRIGGER: prob.a or prob.f of class int8 (or another integer class)
%       OBSERVED: norm(M, 1) rejects integer input with "Invalid data type. First input argument
%         must be single or double."
%       EXPECTED: a report, as for a double matrix with the same values
%       LINES: 144
%
% Authors:
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testInspectMosekProb'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons
tol = 1e-10;

% a small, complete and consistent problem shared by the sections below. The variable bound
% bux(2) = -1 is below blx(2) = 0, so one variable bound is inconsistent.
prob = struct('a', [2 1; 1 3], 'c', [1; 2], 'blc', [0; 0], 'buc', [0; 5], ...
              'blx', [0; 0], 'bux', [1; -1], 'f', [1 0; 0 1; 1 1], 'g', [1; 2; 3], ...
              'name', 'tiny', 'flag', true);

%% the report has three parts and the inspection prints them

[report, text] = inspectQuietly(prob);
assert(isequal(fieldnames(report), {'fieldStats'; 'sizeStats'; 'problemChecks'}));
assert(istable(report.fieldStats) && istable(report.sizeStats) && isstruct(report.problemChecks));
% printed headings
assert(contains(text, 'Field statistics'));
assert(contains(text, 'Matrix-specific statistics'));
assert(contains(text, 'Problem checks'));

%% per-field statistics

[report, ~] = inspectQuietly(prob);
fs = report.fieldStats;
assert(isequal(fs.Properties.RowNames, fieldnames(prob)));
% shape and counts of the matrix a = [2 1; 1 3]
assert(fs{'a', 'nRows'} == 2 && fs{'a', 'nCols'} == 2 && fs{'a', 'nElem'} == 4);
assert(fs{'a', 'nnz'} == 4 && fs{'a', 'density'} == 1);
assert(fs{'a', 'nFinite'} == 4 && fs{'a', 'nNaN'} == 0);
assert(fs{'a', 'nPosInf'} == 0 && fs{'a', 'nNegInf'} == 0);
assert(fs{'a', 'min'} == 1 && fs{'a', 'max'} == 3);
assert(abs(fs{'a', 'mean'} - 1.75) < tol);
assert(abs(fs{'a', 'sd'} - std([2 1 1 3])) < tol);
assert(fs{'a', 'minAbsNonzero'} == 1 && fs{'a', 'maxAbs'} == 3 && fs{'a', 'dynamicRange'} == 3);
assert(fs{'a', 'nZero'} == 0 && fs{'a', 'nPos'} == 4 && fs{'a', 'nNeg'} == 0);
% a vector of zeros has no nonzero magnitude and no dynamic range
assert(fs{'blc', 'nnz'} == 0 && fs{'blc', 'density'} == 0);
assert(isnan(fs{'blc', 'minAbsNonzero'}) && fs{'blc', 'maxAbs'} == 0 && isnan(fs{'blc', 'dynamicRange'}));
assert(fs{'blc', 'nZero'} == 2);
% mixed signs
assert(fs{'bux', 'min'} == -1 && fs{'bux', 'max'} == 1 && fs{'bux', 'nPos'} == 1 && fs{'bux', 'nNeg'} == 1);
% a logical field is treated as numeric
assert(fs{'flag', 'nnz'} == 1 && fs{'flag', 'max'} == 1);
% a nonnumeric field only has its size recorded
assert(fs{'name', 'nRows'} == 1 && fs{'name', 'nCols'} == 4 && fs{'name', 'nElem'} == 4);
assert(isnan(fs{'name', 'nnz'}) && isnan(fs{'name', 'min'}));

%% matrix statistics for a and f

[report, ~] = inspectQuietly(prob);
ss = report.sizeStats;
assert(isequal(ss.Properties.RowNames, {'a'; 'f'}));
% a: every row and column holds two nonzeros
assert(ss{'a', 'nRows'} == 2 && ss{'a', 'nCols'} == 2 && ss{'a', 'nnz'} == 4 && ss{'a', 'density'} == 1);
assert(ss{'a', 'minRowNnz'} == 2 && ss{'a', 'maxRowNnz'} == 2 && ss{'a', 'meanRowNnz'} == 2);
assert(ss{'a', 'minColNnz'} == 2 && ss{'a', 'maxColNnz'} == 2);
% 1-norm (largest column sum) and infinity norm (largest row sum) of [2 1; 1 3]
assert(ss{'a', 'norm1'} == 4 && ss{'a', 'normInf'} == 4);
assert(ss{'a', 'minAbsNonzero'} == 1 && ss{'a', 'maxAbs'} == 3);
% f = [1 0; 0 1; 1 1]: row counts [1 1 2], column counts [2 2]
assert(ss{'f', 'nRows'} == 3 && ss{'f', 'nCols'} == 2 && ss{'f', 'nnz'} == 4);
assert(abs(ss{'f', 'density'} - 4/6) < tol);
assert(ss{'f', 'minRowNnz'} == 1 && ss{'f', 'maxRowNnz'} == 2);
assert(abs(ss{'f', 'meanRowNnz'} - 4/3) < tol);
assert(ss{'f', 'minColNnz'} == 2 && ss{'f', 'maxColNnz'} == 2);
assert(ss{'f', 'norm1'} == 2 && ss{'f', 'normInf'} == 2);

% only matrices that are present get a row; sparse input gives the same numbers
p = struct('a', sparse([2 1; 1 3]));
[report, ~] = inspectQuietly(p);
assert(isequal(report.sizeStats.Properties.RowNames, {'a'}));
assert(report.sizeStats{'a', 'norm1'} == 4);

% no matrix fields: the matrix table stays empty and is not printed
[report, text] = inspectQuietly(struct('c', [1; 2]));
assert(isempty(report.sizeStats));
assert(~contains(text, 'Matrix-specific statistics'));

% a nonnumeric matrix field is skipped
[report, ~] = inspectQuietly(struct('a', 'abc'));
assert(isempty(report.sizeStats));

% a matrix with only infinite entries has no finite statistics
[report, ~] = inspectQuietly(struct('f', [Inf Inf; Inf Inf]));
assert(isnan(report.sizeStats{'f', 'minAbsNonzero'}) && isnan(report.sizeStats{'f', 'maxAbs'}));

% a matrix of finite zeros and infinite entries: no nonzero finite magnitude
[report, ~] = inspectQuietly(struct('f', [Inf 0; 0 0]));
assert(isnan(report.sizeStats{'f', 'minAbsNonzero'}) && report.sizeStats{'f', 'maxAbs'} == 0);

%% consistency checks on a consistent-size problem

[report, ~] = inspectQuietly(prob);
pc = report.problemChecks;
assert(pc.a_num_cols_matches_c && pc.a_num_rows_matches_blc && pc.a_num_rows_matches_buc);
assert(pc.f_num_cols_matches_c && pc.f_num_rows_matches_g);
assert(pc.blx_matches_c && pc.bux_matches_c);
assert(~pc.hasNaN && ~pc.hasInf);
% bux(2) < blx(2)
assert(pc.nBadVariableBounds == 1 && pc.nBadLinearBounds == 0);
% blc(1) == buc(1) = 0 is an equality constraint; no variable is fixed
assert(pc.nEqualityConstraints == 1 && pc.nFixedVariables == 0);
assert(isempty(pc.warningFieldsDynamicRangeOver1e8) && isempty(pc.warningFieldsDynamicRangeOver1e12));
% a is square, nonsingular, with rank 2 and 1-norm condition number 3.2 (4 * 4/5)
assert(pc.a_is_square && pc.a_sprank == 2);
assert(abs(pc.a_condest - 3.2) < tol);
% f has 3 rows and 2 columns
assert(~pc.f_is_square && pc.f_sprank == 2 && isnan(pc.f_condest));

%% consistency checks that detect mismatches

p = struct('a', [1 2 3; 4 5 6], 'c', [1; 2], 'blc', [0; 0; 0], 'buc', [0; 1; 2], 'blx', [0; 0; 0], ...
           'bux', [1; 1; 1], 'f', [1 0], 'g', [1; 2]);
[report, ~] = inspectQuietly(p);
pc = report.problemChecks;
assert(~pc.a_num_cols_matches_c);
assert(~pc.a_num_rows_matches_blc);
assert(~pc.a_num_rows_matches_buc);
assert(pc.f_num_cols_matches_c);
assert(~pc.f_num_rows_matches_g);
assert(~pc.blx_matches_c);
assert(~pc.bux_matches_c);
% a is 2-by-3, not square: no condition estimate
assert(~pc.a_is_square && isnan(pc.a_condest) && pc.a_sprank == 2);

%% fixed variables and consistent bounds

p = struct('blx', [1; 0; -Inf], 'bux', [1; 5; 2], 'blc', [3; 4], 'buc', [3; 9]);
[report, ~] = inspectQuietly(p);
pc = report.problemChecks;
% variable 1 is fixed; the infinite bound is ignored
assert(pc.nFixedVariables == 1 && pc.nBadVariableBounds == 0);
assert(pc.nEqualityConstraints == 1 && pc.nBadLinearBounds == 0);

% inconsistent linear bounds
[report, ~] = inspectQuietly(struct('blc', [5; 0], 'buc', [4; 1]));
assert(report.problemChecks.nBadLinearBounds == 1);

%% NaN and Inf are reported by the field statistics and by the checks

p = struct('c', [NaN; 1; 2], 'blx', [-Inf; 0; 0], 'bux', [Inf; 1; 1]);
[report, ~] = inspectQuietly(p);
fs = report.fieldStats;
assert(fs{'c', 'nNaN'} == 1 && fs{'c', 'nFinite'} == 2);
assert(fs{'blx', 'nNegInf'} == 1 && fs{'blx', 'nPosInf'} == 0);
assert(fs{'bux', 'nPosInf'} == 1 && fs{'bux', 'nNegInf'} == 0);
% finite statistics ignore the NaN and Inf entries
assert(fs{'c', 'min'} == 1 && fs{'c', 'max'} == 2);
assert(report.problemChecks.hasNaN && report.problemChecks.hasInf);

% only NaN: no finite statistic can be computed
[report, ~] = inspectQuietly(struct('c', [NaN; NaN]));
assert(isnan(report.fieldStats{'c', 'min'}) && report.fieldStats{'c', 'nFinite'} == 0);

%% large dynamic range flags

p = struct('c', [1; 2e8], 'g', [1; 1e13], 'blc', [1; 10]);
[report, ~] = inspectQuietly(p);
pc = report.problemChecks;
% c has range 2e8 (> 1e8), g has range 1e13 (> 1e8 and > 1e12), blc has range 10
assert(isequal(pc.warningFieldsDynamicRangeOver1e8, {'c'; 'g'}));
assert(isequal(pc.warningFieldsDynamicRangeOver1e12, {'g'}));

%% a constraint matrix with NaN entries

p = struct('a', [1 NaN; 0 1]);
[report, ~] = inspectQuietly(p);
assert(report.problemChecks.hasNaN);
assert(report.problemChecks.a_is_square);
% the NaN entry is not counted as finite
assert(report.fieldStats{'a', 'nFinite'} == 3);

%% a singular square matrix

[report, ~] = inspectQuietly(struct('a', [1 2; 2 4]));
assert(report.problemChecks.a_sprank == 2);
% the structural rank is 2 but the numerical rank is 1: the 1-norm condition estimate is infinite
assert(isinf(report.problemChecks.a_condest));

%% a square f matrix gets a condition estimate

[report, ~] = inspectQuietly(struct('f', eye(2)));
assert(report.problemChecks.f_is_square);
assert(abs(report.problemChecks.f_condest - 1) < tol);

% change the directory
cd(currentDir)


function [report, text] = inspectQuietly(prob)
% Run inspectMosekProb and return the text it prints, so the test output stays clean.
text = evalc('report = inspectMosekProb(prob);');
end
