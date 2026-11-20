% The COBRAToolbox: testCompareMetaboliteFormulae.m
%
% Purpose:
%     - compareMetaboliteFormulae writes metaboliteFormulae.txt in the current folder, one line
%       per metabolite with its identifier, its reconstruction formula (metFormulas) and its
%       group contribution formula (met(m).formulaMarvin). A test would compare the file
%       written in a tempname folder with the text worked out from a hand-built modelT.
%     - The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%       campaigns): the file is not tab delimited as documented (defect below), so this file
%       makes no assertion about the function.
%
% Function under test:
%     src/analysis/thermo/formulae/compareMetaboliteFormulae.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - hand-built model fields and a text file, no solver.
%
% Coverage exemptions:
%     every line - compareMetaboliteFormulae is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The identifier and the reconstruction formula are not tab separated
%       SEVERITY: wrong-result
%       TRIGGER: compareMetaboliteFormulae(modelT) with modelT.S = [-1; 1], mets {'a[c]';
%       'averyveryverylongmetaboliteid[c]'}, metFormulas {'C6H12O6'; 'H2O'} and formulaMarvin
%       'C6H12O6', 'H2O'
%       OBSERVED: the lines "                a[c]             C6H12O6<TAB>             C6H12O6"
%       and "averyveryverylongmetaboliteid[c]                 H2O<TAB>                 H2O"
%       (MATLAB R2025a): the format '%20s%20s\t%20s\n' of line 21 has a tab only between the
%       second and third field, so splitting a line on tabs gives two fields, not three
%       EXPECTED: a tab delimited file with the three columns, as the description says
%       LINES: 21
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCompareMetaboliteFormulae'));
cd(fileDir);

% declare the requirements of this test. The function is quarantined, so this file needs no
% solver, MATLAB toolbox or particular operating system; the call is the standard opening of
% a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
