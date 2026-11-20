% The COBRAToolbox: testAddMiriam.m
%
% Purpose:
%     addMiriam copies a CellDesigner XML file and adds, after the extension block of each species
%     or reaction that matches an infix entry, an RDF block with the MIRIAM URNs of the listed model
%     fields. The function is QUARANTINED (Constitution III-Defects, quarantine in back-fill
%     campaigns): every matched species receives the annotation of the last infix entry, and the
%     documented miriam_path option stops with an error (defects below), so no assertion about the
%     function is made.
%
% Function under test:
%     src/visualization/cellDesigner/addMiriam.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model look-up without a solver; a test would use a hand-built model, MIRIAM.mat
%     and a small hand-written XML file in a tempname folder.
%
% Coverage exemptions:
%     every line - addMiriam is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Every matched species receives the MIRIAM entries of the last infix entry
%       SEVERITY: wrong-result
%       TRIGGER: fin: an XML file with <sbml>, <listOfSpecies>, then for A and B: <species metaid="s1" id="s1" name="A">, <celldesigner:extension>, </celldesigner:extension>, </species> (s2, B likewise), </listOfSpecies>, </sbml>; model = struct('S', sparse([-1 0; 1 -1]), 'rxns', {{'R1';'R2'}}, 'mets', {{'A';'B'}}, 'metChEBIID', {{'15422';'16027'}}); [f, v] = addMiriam(fin, fullfile(tempname, 'm.xml'), {'A','B'}, model, 'name', {'metChEBIID','ChEBI','bqbiol:is'})
%       OBSERVED: the block after species A is <rdf:Description rdf:about="#A"> with <rdf:li rdf:resource="urn:miriam:chebi:16027"/>, the ChEBI ID of B (constructItems is called with infix(in), where in is the last value of the earlier loop, not the matched entry)
%       EXPECTED: urn:miriam:chebi:15422 for A and urn:miriam:chebi:16027 for B
%       LINES: 280-298, 327
%     - DEFECT: The documented option miriam_path stops with an error
%       SEVERITY: unusable-option
%       TRIGGER: same file and model; addMiriam(fin, fullfile(tempname, 'm.xml'), {'A'}, model, 'name', {'metChEBIID','ChEBI','bqbiol:is'}, which('MIRIAM.mat'))
%       OBSERVED: error "Unrecognized function or variable 'miriam'." at line 327 (miriam is loaded only when nargin < 7)
%       EXPECTED: the registry loaded from miriam_path (OPTIONAL INPUT: "miriam_path: the file path of the miriam registry's dataset")
%       LINES: 49-60
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAddMiriam'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
