% The COBRAToolbox: testDefaultLookMap.m
%
% Purpose:
%     - defaultLookMap gives a CellDesigner map structure a default look: black reaction lines
%       of width 1 (also the secondary reactant and product lines of a map with the complete
%       structure), a default colour and size for simple molecules, one colour per group of
%       secondary metabolites (Recon3 and PD map names), the type ION for ions and
%       SIMPLE_MOLECULE for other secondary metabolites, and a common look for proteins; with
%       the complete structure the included species are treated as well. The function is
%       QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): with the
%       complete structure, an included species named as an ion changes the type of the main
%       species that has the same index; no assertion about the function is made.
%
% Function under test:
%     src/visualization/metabolicCartography/defaultLookMap.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; a test would use a hand-built map structure.
%
% Coverage exemptions:
%     every line - defaultLookMap is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: An included species named as an ion makes the main species of the same index an ION
%       SEVERITY: wrong-result
%       TRIGGER: a map with the complete structure (field rxnReactantLineColor present) with
%         specID = {'s1'; 's2'; 's3'}, specName = {'glc[c]'; 'hk'; 'cplx'},
%         specType = {'SIMPLE_MOLECULE'; 'PROTEIN'; 'COMPLEX'}, specIncID = {'s4'},
%         specIncName = {'Na_plus_'}, specIncType = {'ION'} (full map in the notes of the
%         feature's result record), then newmap = defaultLookMap(map)
%       OBSERVED: (R2025a, 2026-11-15) newmap.specType = {'ION', 'PROTEIN', 'COMPLEX'}: line 166
%         writes newmap.specType{m}, where m indexes specIncName, so glc[c] (species 1) becomes
%         an ION; with more included ions than species, specType also grows
%       EXPECTED: newmap.specType{1} stays 'SIMPLE_MOLECULE' and newmap.specIncType{1} is 'ION'
%         (as lines 188-190 do for included non-ions)
%       LINES: 165-167
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testDefaultLookMap'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
