% The COBRAToolbox: testCorrelateFluxWithTaxonAbundance.m
%
% Purpose:
%     - correlateFluxWithTaxonAbundance sums the organism abundances of each sample on the
%       taxon levels Phylum to Species (taxonomy from infoFilePath or AGORA_infoFile.xlsx),
%       correlates them with the fluxes of each reaction (Pearson, Kendall or Spearman),
%       keeps the correlations above 0.3, translates the flux labels to metabolite names,
%       writes the results to the folder Taxon_Flux_Correlations and plots them. The
%       function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): every call stops with an error before the results are returned (defect
%       below), so no assertion about the function is made.
%
% Function under test:
%     src/analysis/multiSpecies/microbiomeModelingToolbox/additionalAnalysis/correlateFluxWithTaxonAbundance.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use small table files and a VMH database
%     written to a temporary folder.
%
% Coverage exemptions:
%     every line - correlateFluxWithTaxonAbundance is quarantined for the defect below
%     (feature 20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Every call stops with an error when the taxonomy is prepared for export
%       SEVERITY: error
%       TRIGGER: any input that reaches line 262, for example abundance file 'ID,S1,S2,S3,S4,S5'
%         with Bact_a 0.1..0.5, Bact_b 0.5..0.1, Esch_c 0.4 in every sample; taxonomy file
%         'MicrobeID,Phylum,Class,Order,Family,Genus,Species' with Bact_a P1,C1,O1,F1,G1,Sp1,
%         Bact_b P1,C1,O1,F1,G1,Sp2, Esch_c P2,C2,O2,F2,G2,Sp3; flux file 'ID,EX_ac[fe],EX_but[fe]'
%         with samples S1-S5 as rows; correlateFluxWithTaxonAbundance(abundancePath,
%         fluxPath, infoFilePath)
%       OBSERVED: MATLAB:colon:operandsNotRealScalar, Colon operands must be real scalars.
%         Line 260 sets taxonCol = 'Phylum' and line 262 indexes taxonomy(:, taxonCol+1:end)
%         with a character vector as colon operand (MATLAB R2025a). The folder
%         Taxon_Flux_Correlations is already created in the current folder.
%       EXPECTED: the correlations, p-values and taxonomy information returned and written to
%         Taxon_Flux_Correlations
%       LINES: 260-262
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCorrelateFluxWithTaxonAbundance'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
