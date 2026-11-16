% The COBRAToolbox: testReadSimPhenyCMPD.m
%
% Purpose:
%     - readSimPhenyCMPD reads a SimPheny compound file: one metabolite per line of nine
%       double-quoted, comma-separated fields (ID, name, formula, -, charge, CAS number,
%       neutral formula, alternative names separated by '/', KEGG ID). Lines with another
%       number of fields are skipped. It returns one structure per metabolite (ID, name,
%       formula, charge as a number, casNumber, neutralFormula, altNames as a cell array
%       without trailing blanks, KEGGID) and the column list of metabolite IDs. This test
%       writes a small file by hand (empty fields, an empty charge, a comma inside a field, skipped lines)
%       and checks every field; expected values are the fields written (hand derivation).
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns; severity audit T009a): an alternative name keeps the blank that follows
%       '/' (defect below), so no assertion about the function is made; the checks described
%       above are the plan for the test once the defect is resolved.
%
% Function under test:
%     src/base/io/utilities/readSimPhenyCMPD.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, a hand-written text file in a temporary folder.
%
% Coverage exemptions:
%     every line - readSimPhenyCMPD is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers, severity audit T009a)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A file without metabolite lines stops with an error
%       SEVERITY: limitation
%       TRIGGER: readSimPhenyCMPD on an empty file (or one without lines of nine fields)
%       OBSERVED: "Unrecognized function or variable 'mets'." (mets and metInfo are only
%         created when a metabolite line is read)
%       EXPECTED: empty outputs (no metabolite)
%       LINES: 46
%     - DEFECT: Alternative names keep the blank that follows a '/'
%       SEVERITY: wrong-result
%       TRIGGER: a line whose eighth field is "adenosine triphosphate / ATP"
%       OBSERVED: altNames is {'adenosine triphosphate'; ' ATP'} (deblank removes trailing
%         blanks only)
%       EXPECTED: {'adenosine triphosphate'; 'ATP'}, the names without the blanks around the
%         separator that the deblank loop is meant to remove. Severity audit 2026-11-15: the
%         deblank loop (lines 39-40) shows the names are meant to be stripped of the blanks
%         around "/"; " ATP" is returned in metInfo.altNames - a wrong value in a result
%         field, not in a message
%       LINES: 40
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15; severity audit
%       2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testReadSimPhenyCMPD'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
