% The COBRAToolbox: testGetStatsOrganComp.m
%
% Purpose:
%     - getStatsOrganComp(female, male, OrganCompendium_female, OrganCompendium_male, violinPlots)
%       compiles statistics on the organs of the female and male whole-body models: property
%       tables per organ, the reaction, metabolite and gene presence matrices per organ, and the
%       core / organ-specific / other / absent counts. The function is QUARANTINED (Constitution
%       III-Defects, quarantine in back-fill campaigns): the metabolite presence matrices
%       (outputs TableMetsNum_female and TableMetsNum_male) keep entries of an earlier,
%       differently ordered metabolite list; no assertion about the function is made.
%
% Function under test:
%     src/analysis/wholeBody/PSCMToolbox/getStatsOrganComp.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no solver; a test would pass hand-built model structs and organ compendia (the
%     function itself loads Recon3D_Harvey_Used_in_Script_120502.mat and the 270 MB
%     microbiota_model_samp_SRS011239.mat of the papers submodule).
%
% Coverage exemptions:
%     every line - getStatsOrganComp is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The metabolite presence matrices keep entries of the compartment-free metabolite list
%       SEVERITY: wrong-result
%       TRIGGER: mk = @(r, m, g) struct('modelAllComp', struct('rxns', {r}, 'mets', {m}, 'genes',
%         {g}, 'grRules', {repmat({'g1'}, numel(r), 1)}, 'S', sparse(numel(m), numel(r)),
%         'subSystems', {repmat({'s'}, numel(r), 1)})); OC.sex = 'male';
%         OC.Liver = mk({'Liver_R1'; 'Liver_EX_glc(e)_[bc]'}, {'a[c]'; 'b[c]'}, {'1.1'; '2.1'});
%         OC.Brain = mk({'Brain_R2'}, {'b[m]'}, {'2.1'}); wbm.mets = {'a[bc]'; 'b[u]'; 'slack_1';
%         'c[bp]'; 'd[bd]'; 'e[csf]'; 'f[d]'; 'g[fe]'; 'h[sw]'; 'i[a]'; 'j[mi]'};
%         wbm.rxns = {'R1'; 'R2'}; wbm.genes = {'1.1'}; wbm.subSystems = {'s'; 't'};
%         [~, ~, ~, TMf, TMm] = getStatsOrganComp(wbm, wbm, OC, OC)
%       OBSERVED: (R2025a, 2026-11-15) TMm = TMf = [0 1 0; 0 1 1; 0 0 1] for the metabolites
%         {'a[c]'; 'b[c]'; 'b[m]'} and the columns sex, Liver, Brain: b[c] is marked present in
%         Brain. The matrix is first filled for the compartment-free list {'a'; 'b'} (lines 600,
%         1287) and is not cleared before it is filled again for the list with compartments
%         (line 627 clears only TableMets_male, the female section clears nothing), so row 2
%         keeps the Brain entry of 'b'
%       EXPECTED: [0 1 0; 0 1 0; 0 0 1] - b[c] is a metabolite of the Liver only; the
%         metabolite counts in TableGRM (core / organ-specific / others) derive from it too
%       LINES: 600, 627, 646, 654-672, 1287, 1315-1337
%     - DEFECT: The results file named in the help text is never written
%       SEVERITY: cosmetic
%       TRIGGER: any call, e.g. the call above
%       OBSERVED: (R2025a, 2026-11-15) no Results_StatsOrganComp.mat is created: the save is
%         inside "if 0" (lines 1508-1515); the call only sets the global resultsPath
%       EXPECTED: Results_StatsOrganComp.mat "created at the end of this function", as the help
%         text says, or a help text that does not announce it
%       LINES: 1508-1515
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetStatsOrganComp'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
