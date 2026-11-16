% The COBRAToolbox: testGenerateMetaboReport.m
%
% Purpose:
%     - generateMetaboReport reads reportTemplate.html line by line, replaces its ###
%       placeholders with the values and lists of modelProperties.<model>.modelProp2 (as made
%       by generateMetaboScore) and writes reportDir/modelreport_<ModelName>.html for every
%       model, ModelName being the field name or the matching entry of orgNames with
%       underscores read as blanks. Quarantined: no behaviour of generateMetaboReport is
%       asserted until the defects below are fixed.
%
% Function under test:
%     src/reconstruction/metaboRePort/generateMetaboReport.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - a hand-built modelProperties structure and a file in a temporary folder, no
%     solver.
%
% Coverage exemptions:
%     every line - generateMetaboReport is quarantined for the defects below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Template lines are written as fprintf formats, so a percent sign cuts the line
%       SEVERITY: wrong-result
%       TRIGGER: generateMetaboReport(mp, tempname folder) with mp.My_model.modelProp2 holding
%         every field the function reads (numbers 1.234, Details lists {'r1'}, Scores 0.5)
%         and the distributed reportTemplate.html, whose line 2315 ends in
%         'max-height:10%">'
%       OBSERVED: modelreport_My_model.html holds '... background-color:#3c85c9;max-height:10'
%         followed directly by the next template line '<div class="row align-items-end ">':
%         line 454 passes strcat(html{j}, '\n') to fprintf as the format, so '%"' ends the
%         output of that line, its closing '">' and its line break (R2025a, 2026-11-16)
%       EXPECTED: every template line written verbatim apart from the replaced placeholders
%         (for example fprintf(fid, '%s\n', html{j}))
%       LINES: 454
%     - DEFECT: The first template line is not written
%       SEVERITY: wrong-result
%       TRIGGER: the call above
%       OBSERVED: the report starts with '<html lang="en">'; the template's first line
%         '<!DOCTYPE html>' read at line 30 is replaced at line 34 before it is stored, so the
%         page renders in quirks mode (R2025a, 2026-11-16)
%       EXPECTED: the report starts with '<!DOCTYPE html>'
%       LINES: 30, 34
%     - DEFECT: Every template line is printed twice to the console
%       SEVERITY: cosmetic
%       TRIGGER: the call above
%       OBSERVED: about 4,700 lines of HTML, and -1, printed for one model by the debugging
%         disp calls (R2025a, 2026-11-16)
%       EXPECTED: no console output, or output gated by a verbose flag
%       LINES: 33, 35
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testGenerateMetaboReport'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
