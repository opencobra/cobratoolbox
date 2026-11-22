% The COBRAToolbox: testReadInDietFromVMH.m
%
% Purpose:
%     - readInDietFromVMH({fileName}) reads a diet spreadsheet downloaded from the VMH nutrition
%       tool (flux values in column 1, exchange reactions EX_<met>(e) in column 6, one header
%       row) and returns the diet in the whole-body model format: Diet_EX_<met>[d] with the
%       flux value as text. The test writes such a spreadsheet into a tempname folder and checks
%       the reaction names and the values.
%
% Function under test:
%     src/analysis/wholeBody/PSCMToolbox/setConstraints/readInDietFromVMH.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver; one small spreadsheet written to a tempname folder.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: Flux values are rounded to the default precision of num2str
%       SEVERITY: limitation
%       TRIGGER: a spreadsheet with the header row {'Flux', 'b', 'c', 'd', 'e', 'Reaction'} and
%         the rows {0.123456789, 'x', 'y', 'z', 'w', 'EX_glc_D(e)'} and
%         {0.5, 'x', 'y', 'z', 'w', 'EX_o2(e)'}, then readInDietFromVMH({fileName})
%       OBSERVED: (R2025a, 2026-11-15) {'Diet_EX_glc_D[d]', '0.12346'; 'Diet_EX_o2[d]', '    0.5'}:
%         num2str of the flux column keeps about five significant digits (relative to the
%         largest value) and pads the shorter values with leading spaces
%       EXPECTED: the flux values as given in the spreadsheet (e.g. '0.123456789')
%       LINES: 32
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-15.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testReadInDietFromVMH'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% a diet spreadsheet in the layout of the VMH download: a header row, the flux in column 1 and
% the exchange reaction in column 6. The values have at most five significant digits, which
% num2str keeps (see the limitation above)
tempFolder = tempname;
mkdir(tempFolder);
dietFile = fullfile(tempFolder, 'vmhDiet.xlsx');
writecell({'Flux', 'Unit', 'Name', 'Group', 'Note', 'Reaction'; ...
    1.5, 'mmol/day', 'glucose', 'sugar', '', 'EX_glc_D(e)'; ...
    20, 'mmol/day', 'oxygen', 'gas', '', 'EX_o2(e)'; ...
    0.0101, 'mmol/day', 'thiamin', 'vitamin', '', 'EX_thm(e)'; ...
    14.875, 'mmol/day', 'L-alanine', 'amino acid', '', 'EX_ala_L(e)'}, dietFile);

%% reaction names in the whole-body format and the flux values as text

dietFormulation = readInDietFromVMH({dietFile});
% one row per diet item, the EX_<met>(e) exchanges renamed to Diet_EX_<met>[d]
assert(isequal(size(dietFormulation), [4, 2]));
assert(isequal(dietFormulation(:, 1), {'Diet_EX_glc_D[d]'; 'Diet_EX_o2[d]'; 'Diet_EX_thm[d]'; 'Diet_EX_ala_L[d]'}));
% the values are text; read back they are the values of the spreadsheet exactly (decimal text
% with at most five significant digits parses to the same double as the literal)
assert(iscellstr(dietFormulation(:, 2)));
assert(isequal(str2double(dietFormulation(:, 2)), [1.5; 20; 0.0101; 14.875]));

rmdir(tempFolder, 's');

% change the directory
cd(currentDir)
