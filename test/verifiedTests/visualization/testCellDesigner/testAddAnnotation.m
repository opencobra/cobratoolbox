% The COBRAToolbox: testAddAnnotation.m
%
% Purpose:
%     addAnnotation copies a CellDesigner XML file and adds, after each species or reaction line
%     that matches an infix entry, a notes block with the values of the model fields of that
%     metabolite or reaction. The function is QUARANTINED (Constitution III-Defects, quarantine in
%     back-fill campaigns): every reaction of a createModel model stops with an error (defect
%     below), so no assertion about the function is made.
%
% Function under test:
%     src/visualization/cellDesigner/addAnnotation.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model look-up without a solver; a test would use a createModel model and a small
%     hand-written XML file in a tempname folder.
%
% Coverage exemptions:
%     every line - addAnnotation is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Annotating a reaction of a standard COBRA model stops with an error
%       SEVERITY: error
%       TRIGGER: fin: an XML file with the lines <sbml>, <listOfReactions>, <reaction metaid="re1" id="re1" name="R1">, </reaction>, </listOfReactions>, </sbml>; model = createModel({'R1','R2'}, {'R1','R2'}, {'A -> B','B -> '}); addAnnotation(fin, fullfile(tempname, 'o.xml'), {'R1'}, model)
%       OBSERVED: error "Index exceeds array bounds." in contructItems line 463 (model.rxnGeneMat is 2 x 0); with rmfield(model, 'rxnGeneMat') the error is "Cell elements must be character vectors." at line 465 (strrep on the nested cell model.subSystems), after the warnings "Inputs must be character vectors, cell arrays of character vectors, or string arrays." from strrep on the numeric fields
%       EXPECTED: the output file with a notes block holding the fields of reaction R1 (header: "Retrieves omics data from a COBRA model structure and add them to a CellDesginer XML file")
%       LINES: 463-467
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAddAnnotation'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
