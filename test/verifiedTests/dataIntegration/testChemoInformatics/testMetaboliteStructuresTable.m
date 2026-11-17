% The COBRAToolbox: testMetaboliteStructuresTable.m
%
% Purpose:
%     - metaboliteStructuresTable reads every MDL MOL file of a folder and builds a table with
%       one row per file: the metabolite name (file name without .mol) and its InChIKey, InChI
%       and SMILES, which it obtains from Open Babel through openBabelConverter; optionally the
%       table is written to <saveDir>/metaboliteStructures.txt.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the independent review (T027/T028) showed, with a stand-in obabel, that
%       the metabolite name of a file is cut wherever a character is followed by mol, so this
%       file makes no assertion about the function. The full version of this test (empty
%       folder, saved header, three MOL files converted by a stand-in obabel shell script with
%       fixed alanine and glycine output, the saved table, and the missing-Open-Babel error;
%       every executable line reached, R2025a 2026-11-17) is kept in
%       specs/20261113-142115-test-backfill-tiers/inventory/review/testMetaboliteStructuresTable.full.m.txt
%       and is the starting point once the defect is fixed (or this test if the entry is
%       regraded cosmetic).
%
% Function under test:
%     src/dataIntegration/chemoInformatics/metabolites/metaboliteStructuresTable.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; Open Babel replaced by a stand-in shell script.
%
% Coverage exemptions:
%     every line - metaboliteStructuresTable is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers, independent review T027/T028). Before the
%     quarantine the test exempted lines 42-54 (Open Babel not run from MATLAB); the full
%     version with the stand-in obabel reaches every line.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A file name containing a character followed by mol loses that part of the metabolite name
%       SEVERITY: wrong-result
%       TRIGGER: metaboliteStructuresTable(metDir) with a MOL file whose name has any character
%         followed by mol before the extension; for example the files amol.mol and
%         xmolecule.mol
%       OBSERVED: (R2025a, 2026-11-17, stand-in obabel) metTable.mets is "" for amol.mol and
%         "ecule" for xmolecule.mol, while the InChIKey, InChI and SMILES of these rows are
%         those of amol.mol and xmolecule.mol: line 39 removes every match of the regular
%         expression '.mol' (any character followed by mol), not only the extension; two
%         such files (amol.mol, bmol.mol) both get the name ""
%       EXPECTED: "amol" and "xmolecule", the file name without the extension .mol, which line
%         39 evidently intends (the column names the metabolite of each row)
%       LINES: 39
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.
%     - Converted to the quarantine layout after the independent review (T027/T028), 2026-11-17.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMetaboliteStructuresTable'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
