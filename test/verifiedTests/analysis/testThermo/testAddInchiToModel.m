% The COBRAToolbox: testAddInchiToModel.m
%
% Purpose:
%     - addInchiToModel(model, molFileDir, method, printLevel) adds model.inchi (standard,
%       standardWithStereo, standardWithStereoAndCharge and nonstandard InChI strings),
%       model.molBool, model.inchiBool and model.compositeInchiBool from the mol files of the
%       metabolites, either through an intermediate SDF ('sdf', the default; needs Open Babel)
%       or directly from the mol files ('mol'). Quarantined: no behaviour of addInchiToModel is
%       asserted until the defect below is fixed.
%
% Function under test:
%     src/analysis/thermo/inchi/addInchiToModel.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model annotation, no solver; a test would use a hand-built model with mets and
%     mol files written to a tempname folder.
%
% Coverage exemptions:
%     every line - addInchiToModel is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers). Independently of the quarantine, lines 60 and 70-87
%     of the 'sdf' method need Open Babel (the createInChIStruct on the path calls sdf2inchi,
%     which runs the babel program, not installed on the reference machine).
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The method 'mol' stops with Too many input arguments
%       SEVERITY: unusable-option
%       TRIGGER: addInchiToModel(model, molFileDir, 'mol', 0) with model.mets = {'a[c]'; 'b[c]'}
%         and an empty folder molFileDir
%       OBSERVED: MATLAB R2025a, 2026-11-16: "Too many input arguments." (MATLAB:TooManyInputs)
%         at line 64. The createInChIStruct on the MATLAB path is
%         src/analysis/thermo/inchi/old/createInChIStruct.m with the signature
%         inchiStruct = createInChIStruct(mets, sdfFileName); the form with three inputs and two
%         outputs called at line 64 exists only in src/analysis/thermo/inchi/new, which
%         initCobraToolbox removes from the path
%       EXPECTED: model.inchi and model.molBool built from the mol files in molFileDir, as the
%         help text says for the method 'mol'
%       LINES: 64
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAddInchiToModel'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
