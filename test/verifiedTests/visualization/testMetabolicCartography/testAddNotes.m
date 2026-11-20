% The COBRAToolbox: testAddNotes.m
%
% Purpose:
%     - addNotes appends to the notes of a CellDesigner map a summary of each metabolite
%       (full name, abbreviation, formula, charge) and of each reaction (formula, confidence
%       score, bounds, subsystem, map reaction type) taken from a COBRA model. The function is
%       QUARANTINED (Constitution III-Defects, quarantine in back-fill campaigns): it fails on
%       models whose subSystems are cell arrays of cells (the format createModel writes) and
%       writes numeric confidence scores as control characters (defects below); no assertion
%       about the function is made.
%
% Function under test:
%     src/visualization/metabolicCartography/addNotes.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - model manipulation, no solver; a test would use a two-reaction model from
%     createModel and a hand-built map.
%
% Coverage exemptions:
%     every line - addNotes is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Subsystems stored as cells of cells raise an error
%       SEVERITY: error
%       TRIGGER: model = createModel({'R1'; 'R2'}, {'R one'; 'R two'}, {'a[c] -> b[c]'; 'b[c] <=> c[c]'});
%         model.metNames = {'Alpha'; 'Beta'; 'Gamma'}; model.metFormulas = {'C'; 'H2'; 'O'};
%         model.metCharge = [0; -1; 2]; model.rxnConfidenceScores = [3; 0];
%         model.subSystems = {{'S1'}; {'S2'}}; map.specName = {'a[c]'; 'b[c]'; 'Glycolysis'};
%         map.specNotes = {''; ''; ''}; map.rxnName = {'R1'; 'R2'};
%         map.rxnType = {'STATE_TRANSITION'; 'TRANSPORT'}; map.rxnNotes = {''; ''};
%         addNotes(model, map)
%       OBSERVED: (R2025a, 2026-11-16) error "Cell elements must be character arrays." from
%         char(model.subSystems(idsModel)) at line 105; createModel writes subSystems in this
%         format
%       EXPECTED: the reaction notes with 'Subsystem: S1' and 'Subsystem: S2'
%       LINES: 105
%     - DEFECT: Numeric confidence scores are written as control characters
%       SEVERITY: wrong-result
%       TRIGGER: the call above with model.subSystems = {'S1'; 'S2'}
%       OBSERVED: (R2025a, 2026-11-16) the note of R1 reads 'Mechanical Confidence Score: '
%         followed by char(3) (a control character) and that of R2 by char(0): line 102 applies
%         char to the numeric score (the COBRA field definition makes rxnConfidenceScores
%         numeric); with scores {'3'; '0'} the notes read 'Score: 3' and 'Score: 0'
%       EXPECTED: 'Mechanical Confidence Score: 3' and 'Mechanical Confidence Score: 0'
%       LINES: 102
%     - DEFECT: A metabolite shown twice in the map gets its note twice in each copy
%       SEVERITY: cosmetic
%       TRIGGER: the call above with map.specName = {'a[c]'; 'b[c]'; 'b[c]'; 'Glycolysis'} and
%         four specNotes
%       OBSERVED: (R2025a, 2026-11-16) both b[c] notes hold the summary of b[c] twice: the
%         metabolite is listed once per copy and each pass writes into every copy
%       EXPECTED: one summary per copy
%       LINES: 67-76
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testAddNotes'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
