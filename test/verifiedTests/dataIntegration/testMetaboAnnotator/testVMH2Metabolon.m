% The COBRAToolbox: testVMH2Metabolon.m
%
% Purpose:
%     - VMH2Metabolon reads metabolon_crossmatch_IT_withUpdatedInchiKey.xlsx from the MATLAB
%       search path and, for every table row whose VMH id (or each of several ids separated by
%       ',') is the VMHId of a metabolite, copies the Metabolon CHEM_ID, InChI key, HMDB id,
%       InChI string, CAS number, KEGG id, ChemSpider id and PubChem id of the row into that
%       metabolite (overwriting, documented), each with a dated '<file>:manual:' source; rows
%       with a '/' (unspecified match) or without VMH id are ignored.
%     - Once the defect below is fixed, the test should write a small table by hand into a
%       temporary folder (as testGetSeed2Kegg does), run the function from it and check rows
%       for metabolites present and absent, comma-separated ids, '/' rows, rows without VMH
%       id, empty cells and overwriting, with the values written as expected values.
%       Quarantined: no behaviour of VMH2Metabolon is asserted until the defects below are
%       fixed; this file only opens the test.
%
% Function under test:
%     src/dataIntegration/metaboAnnotator/connect2resources/VMH2Metabolon.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, a hand-built metabolite structure and spreadsheet.
%
% Coverage exemptions:
%     every line - VMH2Metabolon is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A row whose VMH id is not in the structure overwrites the metabolite of the
%         previous matched row
%       SEVERITY: wrong-result
%       TRIGGER: a table (writecell, headers CHEM_ID, INCHIKEY, INCHISTRING, CAS, CHEMSPIDER,
%         HMDB, KEGG, PUBCHEM, VMH ID) with the rows {35, 'KEY1', 'InChI=1S/H2O/h1H2', ...,
%         'h2o'} and {50, 'KEY2', 'InChI=X', ..., 'notInStruct'}, and
%         VMH2Metabolon(struct('VMH_h2o', struct('VMHId', 'h2o', 'metNames', 'Water')))
%       OBSERVED: (R2025a, 2026-11-15) VMH_h2o.metabolon = 50, inchiKey = 'KEY2', inchiString =
%         'InChI=X' and the other identifiers of the second row: when no metabolite matches
%         (line 54), vmhId keeps the value of the previous row and the loop of line 58 writes
%         the row into that metabolite
%       EXPECTED: VMH_h2o keeps the identifiers of its own row (metabolon 35, KEY1); rows
%         without a match change nothing
%       LINES: 53-58
%     - DEFECT: A table whose first row with a VMH id has no matching metabolite stops the
%         function
%       SEVERITY: error
%       TRIGGER: the same table with the two rows swapped, or the shipped table (its first row
%         lists 1pyr5c) with VMH2Metabolon(struct('VMH_h2o', struct('VMHId', 'h2o', 'metNames',
%         'Water')))
%       OBSERVED: (R2025a, 2026-11-15) "Unrecognized function or variable 'vmhId'." (line 58)
%       EXPECTED: the row is skipped and the later matching rows are copied
%       LINES: 53-58
%     - DEFECT: A comma-separated VMH id that is not in the structure stops the function
%       SEVERITY: error
%       TRIGGER: a table row with VMH ID 'h2o,zzz' and a structure holding only h2o
%       OBSERVED: (R2025a, 2026-11-15) "Unable to perform assignment with 0 elements on the
%         right-hand side." (line 47)
%       EXPECTED: the ids found (h2o) receive the row, the others are skipped
%       LINES: 47
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testVMH2Metabolon'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
