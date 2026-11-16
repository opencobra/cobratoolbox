% The COBRAToolbox: testIsSameCobraModel.m
%
% Purpose:
%     isSameCobraModel compares the common fields of two COBRA models and returns whether they
%     are the same, the number of differences per field and the common fields. The function is
%     QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): models of different
%     sizes stop with an error, logical fields are never compared and text fields are compared
%     without their punctuation (defects below), so no assertion about the function is made.
%
% Function under test:
%     src/reconstruction/refinement/isSameCobraModel.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model comparison without a solver; a test would use createModel models.
%
% Coverage exemptions:
%     every line - isSameCobraModel is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Two models with different numbers of reactions stop with an error
%       SEVERITY: error
%       TRIGGER: m1 = createModel({'R1','R2','EX_A','EX_C'}, {'R1','R2','EX_A','EX_C'}, {'A -> B','B <=> C','A <=> ','C -> '}); m2 = createModel({'R1','R2','EX_A'}, {'R1','R2','EX_A'}, {'A -> B','B <=> C','A <=> '}); [isSame, nDiff] = isSameCobraModel(m1, m2)
%       OBSERVED: error "Arrays have incompatible sizes for this operation." (value1 == value2 on numeric fields of different sizes; strcmp on cell fields of different sizes fails in the same way)
%       EXPECTED: isSame = false with the differing fields counted ("Checks if two COBRA models are the same")
%       LINES: 109, 121
%     - DEFECT: Logical fields are never compared
%       SEVERITY: wrong-result
%       TRIGGER: m1 as above; a = m1; a.myFlag = true(4,1); b = m1; b.myFlag = false(4,1); isSameCobraModel(a, b)
%       OBSERVED: isSame = true (a logical value is neither numeric, cellstr nor char, so nDiff stays 0)
%       EXPECTED: false: the common field myFlag differs in 4 positions (OUTPUTS: "True if all common fields are identical")
%       LINES: 108-124
%     - DEFECT: Text fields are compared with every non-word character removed, not only white space
%       SEVERITY: wrong-result
%       TRIGGER: a = m1; a.rxnNames{1} = 'R-1'; isSameCobraModel(m1, a)
%       OBSERVED: isSame = true ('R-1' and 'R1' are equal after regexprep(value, '[^\w'']', ''))
%       EXPECTED: false: rxnNames{1} differs (code comment: "replace all whitespaces")
%       LINES: 103-106
%     - DEFECT: The message for differing nested subSystems names prints 0 positions
%       SEVERITY: cosmetic
%       TRIGGER: a = m1; a.subSystems = {{'A'};{'B'};{'A'};{'A'}}; b = m1; b.subSystems = {{'A'};{'A'};{'A'};{'A'}}; isSameCobraModel(a, b, 1)
%       OBSERVED: prints "Field subSystems differs in 0 positions between the models" (nDiff(i) is printed before it is assigned)
%       EXPECTED: the number of differing subSystem names
%       LINES: 86
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testIsSameCobraModel'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
