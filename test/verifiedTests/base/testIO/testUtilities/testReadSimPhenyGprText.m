% The COBRAToolbox: testReadSimPhenyGprText.m
%
% Purpose:
%     - readSimPhenyGprText parses a SimPheny gene-protein-reaction association text file
%       (tab-separated, one header line, '+' for and, ',' for or) into reaction identifiers,
%       genes, rules, grRules, subsystems and a reaction x gene matrix, and optionally merges
%       them into a model. The function is quarantined for the defect below, so this test
%       asserts nothing about it.
%
% Function under test:
%     src/base/io/utilities/readSimPhenyGprText.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - would need only a hand-written text file in a tempname folder and a hand-built
%     model, no solver.
%
% Coverage exemptions:
%     every line - readSimPhenyGprText is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: the rules of reactions with several genes refer to the wrong genes
%       SEVERITY: wrong-result
%       TRIGGER: a GPR text file with 11 tab-separated columns and one header line whose rows
%                have R1 / b1, R2 / b2+b3 and R3 / b3,b1 in the reaction name (third) and GPRA
%                (ninth) columns; gpraModel = readSimPhenyGprText(file)
%       OBSERVED: MATLAB R2025a: gpraModel.genes = {b1; b2; b3} and gpraModel.rules =
%                 {'x(1)'; 'x(3) & x(3)'; 'x(3) | x(1)'} while gpraModel.rxnGeneMat is right
%                 ([1 0 0; 0 1 1; 1 0 1]). Line 62 renumbers the local gene indices with
%                 strrep one gene at a time: for R2 the first step turns x(1) into x(2) and the
%                 second step turns both x(2) into x(3). Every reaction whose genes are not the
%                 first genes of the sorted gene list in order is affected (and x(1) would
%                 also match inside x(10)); the rules merged into a model (line 82) carry the
%                 same error
%       EXPECTED: gpraModel.rules = {'x(1)'; 'x(2) & x(3)'; 'x(3) | x(1)'}, consistent with
%                 rxnGeneMat and grRules ('b2 and b3')
%       LINES: 61-63
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testReadSimPhenyGprText'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
