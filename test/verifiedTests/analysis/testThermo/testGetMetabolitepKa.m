% The COBRAToolbox: testGetMetabolitepKa.m
%
% Purpose:
%     - getMetabolitepKa lists the mol files of molfiledir and, for each metabolite of mets (compartment
%       suffix '[c]' removed, duplicates once) that has a mol file, calls ChemAxon cxcalc to
%       write <met>_pkas.txt into pkadir - on Windows only (ispc); elsewhere it only prints the
%       metabolite indices. The function is QUARANTINED (Constitution III-Defects,
%       quarantine in back-fill campaigns): the mol-file list is parsed from the
%       concatenated directory listing, so existing mol files are not recognised (defect
%       below); no assertion about the function is made.
%
% Function under test:
%     src/analysis/thermo/protons/getMetabolitepKa.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use hand-built mol-file folders in a
%     tempname folder. The cxcalc call needs Windows and ChemAxon cxcalc (not installed).
%
% Coverage exemptions:
%     every line - getMetabolitepKa is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Mol files are missed when another file precedes them or their name holds
%       a dot or 'mol'
%       SEVERITY: wrong-result
%       TRIGGER: molfiledir holding A.txt, B.mol, C.mol, glc.D.mol, xmol.mol;
%         getMetabolitepKa({'B[c]'; 'C[c]'; 'C[e]'; 'glc.D[c]'; 'xmol[c]'}, molDir, outDir)
%       OBSERVED: with ispc and system replaced by recording stubs (MATLAB R2025a), only
%         'cxcalc -o <outDir>/C_pkas.txt pka -M true -a 20 -b 20 <molDir>/C.mol' is issued; B (preceded by A.txt in the
%         concatenated listing '...A.txtB.molC.mol...'), glc.D (dots removed: 'glcD') and
%         xmol (the unescaped '.' of '.mol' also matches 'xmol') get no call.
%       EXPECTED: one cxcalc call for every metabolite whose <id>.mol file exists
%       LINES: 18-20
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGetMetabolitepKa'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
