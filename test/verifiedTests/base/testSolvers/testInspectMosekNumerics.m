% The COBRAToolbox: testInspectMosekNumerics.m
%
% Purpose:
%     - inspectMosekNumerics reports numerical diagnostics (size, density, magnitude range and
%     dynamic range of the constraint matrix and of the bound and objective vectors, and the
%     number of inconsistent bounds) for a MOSEK problem structure.
%       Characterization test that PINS the current behaviour (feature
%       tier1-test-batch3, Constitution Principle III characterization mode);
%       it must not change the function under test. MOSEK itself is not needed: the problem
%       structures are built by hand.
%
% Function under test:
%     src/base/solvers/mosek/inspectMosekNumerics.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no genome-scale model, no solver, hand-built inputs.
%
% Coverage exemptions:
%     Lines 192-199 of the local function localAbsStats, which handle a vector whose maximum
%     is not finite although it has no positive entry. A vector with an infinite entry always has a
%     positive entry (infinity), and a vector of only NaN gives a NaN maximum that is caught
%     by the all-NaN case, so those lines cannot be reached with any input.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature tier1-test-batch3, 2026-10-12.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testInspectMosekNumerics'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% tolerance for floating-point comparisons
tol = 1e-12;

% constraint matrix shared by the sections below: 2 rows, 3 columns, 4 nonzeros
A = [1 0 -4; 0 0.5 2];

%% a problem without any recognised field gives an empty report

report = inspectMosekNumerics(struct());
assert(isstruct(report) && isempty(fieldnames(report)));

% fields of the wrong class are ignored
report = inspectMosekNumerics(struct('a', 'text', 'c', {{1}}));
assert(isempty(fieldnames(report)));

%% constraint matrix statistics (dense input)

report = inspectMosekNumerics(struct('a', A));
assert(isequal(report.A_size, [2 3]));
assert(report.A_nnz == 4);
assert(abs(report.A_density - 4/6) < tol);
% smallest nonzero and largest absolute entry, and their ratio
assert(report.A_abs_min_nonzero == 0.5);
assert(report.A_abs_max == 4);
assert(abs(report.A_dynamic_range - 8) < tol);
% infinity norms of the rows [4; 2] and of the columns [1; 0.5; 4]
assert(report.A_row_norm_inf_min == 2 && report.A_row_norm_inf_max == 4);
assert(report.A_col_norm_inf_min == 0.5 && report.A_col_norm_inf_max == 4);

%% constraint matrix statistics (sparse input gives the same numbers)

reportDense = inspectMosekNumerics(struct('a', A));
reportSparse = inspectMosekNumerics(struct('a', sparse(A)));
assert(isequal(reportSparse, reportDense));

%% constraint matrix without nonzero entries

report = inspectMosekNumerics(struct('a', zeros(2, 2)));
assert(report.A_nnz == 0 && report.A_density == 0);
assert(isnan(report.A_abs_min_nonzero) && isnan(report.A_abs_max) && isnan(report.A_dynamic_range));
assert(report.A_row_norm_inf_min == 0 && report.A_col_norm_inf_max == 0);

%% constraint matrix without entries

report = inspectMosekNumerics(struct('a', zeros(0, 3)));
assert(isequal(report.A_size, [0 3]));
assert(isnan(report.A_density));
assert(isnan(report.A_abs_min_nonzero));
% no rows: the row statistics are NaN
assert(isnan(report.A_row_norm_inf_min) && isnan(report.A_row_norm_inf_max));

%% infinite matrix entries are excluded from the statistics

% one infinite entry among finite ones
report = inspectMosekNumerics(struct('a', [1 Inf; 2 3]));
assert(report.A_abs_min_nonzero == 1 && report.A_abs_max == 3);
assert(abs(report.A_dynamic_range - 3) < tol);
% the infinite column has an infinite norm and is skipped
assert(report.A_col_norm_inf_min == 2 && report.A_col_norm_inf_max == 2);
assert(report.A_row_norm_inf_min == 3 && report.A_row_norm_inf_max == 3);

% only infinite entries
report = inspectMosekNumerics(struct('a', sparse([Inf 0; 0 Inf])));
assert(isnan(report.A_abs_min_nonzero) && isnan(report.A_abs_max) && isnan(report.A_dynamic_range));
assert(isnan(report.A_row_norm_inf_min) && isnan(report.A_col_norm_inf_max));

%% vector statistics: smallest nonzero, largest value and ratio

report = inspectMosekNumerics(struct('c', [-1; 0; 3]));
assert(report.c_abs_min == 1 && report.c_abs_max == 3);
assert(abs(report.c_dynamic_range - 3) < tol);

% the same fields for every vector the function knows about
names = {'blc', 'buc', 'c', 'blx', 'bux', 'f', 'g'};
prob = struct();
for i = 1:numel(names)
    prob.(names{i}) = [2 -8];
end
report = inspectMosekNumerics(prob);
for i = 1:numel(names)
    assert(report.([names{i} '_abs_min']) == 2);
    assert(report.([names{i} '_abs_max']) == 8);
    assert(abs(report.([names{i} '_dynamic_range']) - 4) < tol);
end

%% vector without entries or without nonzero entries

report = inspectMosekNumerics(struct('c', zeros(0, 1)));
assert(isnan(report.c_abs_min) && isnan(report.c_abs_max) && isnan(report.c_dynamic_range));

% a sparse matrix without nonzeros is empty for this purpose
report = inspectMosekNumerics(struct('f', sparse(2, 2)));
assert(isnan(report.f_abs_min) && isnan(report.f_dynamic_range));

% all zero: the minimum is reported as 0 and there is no ratio
report = inspectMosekNumerics(struct('c', [0; 0]));
assert(report.c_abs_min == 0 && report.c_abs_max == 0);
assert(isnan(report.c_dynamic_range));

%% vectors with infinite or NaN entries

% infinite entries are dropped when finite ones exist
report = inspectMosekNumerics(struct('blx', [-Inf; 2; 8]));
assert(report.blx_abs_min == 2 && report.blx_abs_max == 8);
assert(abs(report.blx_dynamic_range - 4) < tol);

% only infinite entries
report = inspectMosekNumerics(struct('blx', [-Inf; Inf]));
assert(isnan(report.blx_abs_min) && isnan(report.blx_abs_max) && isnan(report.blx_dynamic_range));

% infinite entries and zeros only: the minimum is 0
report = inspectMosekNumerics(struct('blx', [Inf; 0]));
assert(report.blx_abs_min == 0 && report.blx_abs_max == 0);
assert(isnan(report.blx_dynamic_range));

% only NaN
report = inspectMosekNumerics(struct('c', NaN));
assert(isnan(report.c_abs_min) && isnan(report.c_abs_max) && isnan(report.c_dynamic_range));

%% bounds that exclude each other are counted when both are finite

report = inspectMosekNumerics(struct('blx', [0 5 -Inf 4], 'bux', [1 2 3 Inf]));
assert(report.nBadVarBounds == 1);

report = inspectMosekNumerics(struct('blc', [0; 7], 'buc', [1; 6]));
assert(report.nBadConBounds == 1);

% consistent bounds
report = inspectMosekNumerics(struct('blx', [0 1], 'bux', [1 1], 'blc', 0, 'buc', 0));
assert(report.nBadVarBounds == 0 && report.nBadConBounds == 0);

% a lower bound without its upper bound gives no count
report = inspectMosekNumerics(struct('blx', [0 1]));
assert(~isfield(report, 'nBadVarBounds') && ~isfield(report, 'nBadConBounds'));

% change the directory
cd(currentDir)
