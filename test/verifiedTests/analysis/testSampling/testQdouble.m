% The COBRAToolbox: testQdouble.m
%
% Purpose:
%     - qdouble is the generated copy of the template CMatrix.m (compileCMatrix replaces the class name; the two files are identical up to the name).
%       An object stores a 2-D matrix of the quad-double (qd_real, 32 bytes per element) as raw bytes: a dense
%       object holds a uint8 array (bytes x rows x columns), a sparse object a cell
%       {logical pattern; uint8 values in column-major order of the nonzeros}; arithmetic,
%       comparisons and conversions go through the MEX file qdoubleMex, which the repository
%       does not ship. The class is QUARANTINED (Constitution III-Defects, quarantine in
%       back-fill campaigns): sparse(i, j, s, ...) stores the values in the order given while
%       the pattern is sorted, so unsorted triplets give a wrong matrix (defect below); no
%       assertion about the class is made.
%
% Function under test:
%     src/analysis/sampling/BarrierRound/CMatrix/include/qdouble.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would build objects from raw uint8 storage (the
%     MEX file qdoubleMex is not shipped, so only the methods that need no MEX can run).
%
% Coverage exemptions:
%     every line - qdouble is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: sparse(i, j, s) pairs the values with the sorted pattern, not with (i, j)
%       SEVERITY: wrong-result
%       TRIGGER: raw = zeros(4, 2, 1, 'uint8'); raw(:, 1) = 10; raw(:, 2) = 20;
%         vals = qdouble(raw); f = full(sparse([2 1], [1 1], vals)); f.x(1, :)
%       OBSERVED: bytes [10 20] at rows 1 and 2 (MATLAB R2025a), while MATLAB's
%         full(sparse([2 1], [1 1], [10 20]))' is [20 10]; the logical pattern A (line 133)
%         is ordered column-major but the values s (lines 135-136) keep the input order.
%         Repeated (i, j) pairs, e.g. sparse([1 1], [1 1], vals), give a 1 x 1 object whose
%         pattern has 1 nonzero but which stores 2 values. The 5- and 6-argument forms
%         share these lines. No MEX file is involved.
%       EXPECTED: S(i(k), j(k)) = s(k) as for MATLAB's sparse (repeated pairs summed or
%         rejected)
%       LINES: 133-136
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testQdouble'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
