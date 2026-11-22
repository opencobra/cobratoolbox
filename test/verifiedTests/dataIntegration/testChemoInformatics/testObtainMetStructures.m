% The COBRAToolbox: testObtainMetStructures.m
%
% Purpose:
%     - obtainMetStructures downloads MDL MOL files from web databases (ChEBI, DrugBank,
%       HMDB, KEGG, LIPID MAPS, PubChem) or converts InChI and SMILES with Open Babel, and
%       reports which structures were obtained per source. Quarantined: no behaviour of
%       obtainMetStructures is asserted until the defects below are fixed. Once fixed, a test
%       can reach the offline lines with empty identifiers, the inchi/smiles sources without
%       Open Babel and a KEGG identifier that starts with neither C nor D; the webread lines
%       need the internet and stay exempt.
%
% Function under test:
%     src/dataIntegration/chemoInformatics/metabolites/obtainMetStructures.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - reporting on a createModel toy model with output in a tempname folder, no
%     solver and no internet.
%
% Coverage exemptions:
%     every line - obtainMetStructures is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A model without an HMDB field stops with an error
%       SEVERITY: error
%       TRIGGER: obtainMetStructures(model, [], outputDir, {'inchi'}) with a createModel
%         model that has no field matching hmdb
%       OBSERVED: error "Unrecognized function or variable 'hmdbIDs'." at line 245 - lines
%         133-136 set hmdbIDs only when the field exists, while every other identifier field
%         gets an empty default (lines 116-183)
%       EXPECTED: an empty HMDB list, as for the other identifier fields, and the requested
%         sources processed
%       LINES: 133-136, 245
%     - DEFECT: The documented source name lipidmass stops with an error
%       SEVERITY: unusable-option
%       TRIGGER: obtainMetStructures(model, [], outputDir, {'lipidmass'}) with model.metHMDBID
%         set to empty entries
%       OBSERVED: error "The VariableNames property must contain one name for each variable
%         in the table." - the code knows only 'lipidmaps' (lines 74, 78, 315), so line 382
%         removes every column of idMatrix while the report table is built with the name
%         lipidmass (lines 391-393)
%       EXPECTED: the LIPID MAPS source used, as the help text lists ("8.- 'lipidmass'")
%       LINES: 78, 382-396
%     - DEFECT: The SMILES source is used only for metabolites that have an InChI
%       SEVERITY: wrong-result
%       TRIGGER: sources {'smiles'} and a metabolite with a SMILES string but no InChI
%       OBSERVED: line 358 tests inchis{idx(1)} instead of smiles{idx(1)}, so such a
%         metabolite is skipped (found by reading; Open Babel cannot run from MATLAB on the
%         reference machine, so the conversion itself was not observed)
%       EXPECTED: the SMILES string converted whenever it is present
%       LINES: 358
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testObtainMetStructures'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
