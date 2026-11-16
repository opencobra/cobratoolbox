% The COBRAToolbox: testWebCGMtoTabDelimitedFile.m
%
% Purpose:
%     - webCGMtoTabDelimitedFile(model, webCGMoutputFile, gcmMetList) reads a local webCGM
%       output file (one line per metabolite of gcmMetList found in the model, after a header)
%       and writes a tab-delimited file of group contribution data (abbreviation, formula,
%       delta G of formation, its uncertainty, charge) for createGroupContributionStruct,
%       skipping metabolites with X or R in the formula or trna in the identifier and printing
%       those without data (NONE). It reads only a local file, so no line needs the internet.
%       Quarantined: no behaviour of webCGMtoTabDelimitedFile is asserted until the defects
%       below are fixed.
%
% Function under test:
%     src/analysis/thermo/groupContribution/jankowski/webCGMtoTabDelimitedFile.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - reporting for a model, no solver; a test would use a hand-built model with mets
%     and metFormulas and a webCGM output file written to a tempname folder.
%
% Coverage exemptions:
%     every line - webCGMtoTabDelimitedFile is quarantined for the defect below (feature
%     20261113-142115-test-backfill-tiers)
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: A metabolite without group contribution data stops the call or is reported under another name
%       SEVERITY: error
%       TRIGGER: a NONE line for the first mapped metabolite: model.S = zeros(2, 1), model.mets =
%         {'a[c]'; 'b[c]'}, model.metFormulas = {'C2H4'; 'C3H6'}, a file with the lines
%         'header', 'NONE;no groups', '-10.5;1.2;g1|g2|-1;0;C2H3', and
%         webCGMtoTabDelimitedFile(model, 'web.txt', {'a[c]'; 'b[c]'})
%       OBSERVED: MATLAB R2025a, 2026-11-16: "Unrecognized function or variable 'metAbbr'."
%         (MATLAB:UndefinedFunction) at line 136; metAbbr is assigned only at line 138, in the
%         other branch. With the two data lines swapped (NONE second) the call ends and line 136
%         prints "a[c]<tab>;no groups", the identifier of the previous metabolite instead of b[c]
%       EXPECTED: the metabolite without data is left out of the output file and its own
%         identifier is printed with the reason, as the comments at lines 85 and 134-135 say
%       LINES: 136
%     - DEFECT: The output file is named gc_data_webGCM.txt, not gc_data_webCGM.txt as documented
%       SEVERITY: wrong-result
%       TRIGGER: any call, for example the call above with the NONE line second
%       OBSERVED: MATLAB R2025a, 2026-11-16: exist('gc_data_webGCM.txt', 'file') = 2 and
%         exist('gc_data_webCGM.txt', 'file') = 0 in the current folder after the call; line 44
%         opens 'gc_data_webGCM.txt'
%       EXPECTED: the data in gc_data_webCGM.txt, the file named in the OUTPUT section
%       LINES: 44
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testWebCGMtoTabDelimitedFile'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% change the directory
cd(currentDir)
