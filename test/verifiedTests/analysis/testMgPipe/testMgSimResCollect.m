% The COBRAToolbox: testMgSimResCollect.m
%
% Purpose:
%     - mgSimResCollect computes, for each diet simulated by mgPipe (rich, input and
%       personalised), the net secretion |min diet flux + max fecal flux| and the net uptake
%       |max diet flux + min fecal flux| of every exchange in every sample from the FVA
%       results netProduction and netUptake, writes them to <diet>_net_secretion_fluxes.csv
%       and <diet>_net_uptake_fluxes.csv, plots a PCoA of the secretion profiles and writes
%       the metabolite names and subsystems. The function is QUARANTINED (Constitution
%       III-Defects, quarantine in back-fill campaigns): uptake values of an exchange that is
%       missing from a sample are copied from the previous sample (defect below), so no
%       assertion about the function is made.
%
% Function under test:
%     src/analysis/multiSpecies/microbiomeModelingToolbox/mgPipe/mgSimResCollect.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use hand-built FVA result cells, a VMH
%     database and a results folder in a temporary folder.
%
% Coverage exemptions:
%     every line - mgSimResCollect is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Uptake of an exchange missing from a sample is copied from the previous sample
%       SEVERITY: wrong-result
%       TRIGGER: exchanges = {'EX_ac[fe]'; 'EX_glc_D[fe]'}; netProduction = cell(3, 3);
%         netUptake = cell(3, 3); netProduction{2,1} = {'EX_ac[fe]', -1, 3; 'EX_glc_D[fe]',
%         -2, 5}; netUptake{2,1} = {'EX_ac[fe]', 4, -1; 'EX_glc_D[fe]', 7, -1};
%         netProduction{2,2} = {'EX_ac[fe]', -1, 2; 'EX_glc_D[fe]', [], []}; netUptake{2,2}
%         = {'EX_ac[fe]', 6, -1; 'EX_glc_D[fe]', [], []}; netProduction{2,3} = {'EX_ac[fe]',
%         -1, 9; 'EX_glc_D[fe]', -2, 1}; netUptake{2,3} = {'EX_ac[fe]', 2, -1;
%         'EX_glc_D[fe]', 3, -1}; [sec, upt] = mgSimResCollect([resDir filesep], {'S1';
%         'S2'; 'S3'}, exchanges, 0, 0, '', netProduction, netUptake, '-dpng')
%       OBSERVED: upt{3,3} (EX_glc_D[fe] in S2, absent from that sample) is 6, the value
%         |7 + -1| of S1, while sec{3,3} is 0. Only sp is reset for each sample (line 81);
%         up keeps the values of the previous sample where the FVA value is empty.
%       EXPECTED: 0 for the missing exchange, as for the net secretion
%       LINES: 81, 95-97
%     - DEFECT: The feasibility of every diet is read from the last diet
%       SEVERITY: wrong-result
%       TRIGGER: rDiet = 1, pDiet = 0, three samples with rich-diet and input-diet results,
%         except netProduction{2,3} = {} and netUptake{2,3} = {} (input diet infeasible for
%         S3); mgSimResCollect([resDir filesep], {'S1'; 'S2'; 'S3'}, exchanges, 1, 0, '',
%         netProduction, netUptake, '-dpng')
%       OBSERVED: rich_net_secretion_fluxes.csv holds NaN for S3 although netProduction{1,3}
%         holds its rich-diet results: line 72 tests isempty(netProduction{fl,k}) (the last
%         diet) instead of netProduction{j,k}. With the opposite pattern (last diet filled,
%         an earlier diet empty) line 83 indexes an empty cell.
%       EXPECTED: the rich-diet values of S3
%       LINES: 72
%     - DEFECT: Two samples stop with an error in the PCoA
%       SEVERITY: error
%       TRIGGER: the first call above with two samples {'S1'; 'S2'} (cells of S1 and S2 only)
%       OBSERVED: cobraCmdscale: D must have a zero diagonal (or ones for a similarity
%         matrix). cobraPdist of two samples returns one distance, a scalar that is read as
%         a 1-by-1 matrix; the check on line 125 ("too few individuals to plot") is not
%         reached.
%       EXPECTED: no PCoA, as for too few individuals, and the flux tables written. Severity
%         audit 2026-11-15: sampNames is documented as "nx1 cell array ... names of
%         individuals" with no minimum, and the comment "catch if there are too few
%         individuals to plot" (line 124) shows few individuals are intended; n = 2 stops with
%         an error in cobraCmdscale (lines 119-120) before that check - a documented input that
%         fails when used
%       LINES: 119-120
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMgSimResCollect'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
