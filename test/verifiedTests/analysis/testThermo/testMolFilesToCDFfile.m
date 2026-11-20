% The COBRAToolbox: testMolFilesToCDFfile.m
%
% Purpose:
%     - molFilesToCDFfile(model, cdfFileName) looks in the current folder for a mol file named
%       after each metabolite identifier without its three-character compartment suffix
%       (atp[c] -> atp.mol), copies the mol files line by line, in model order and separated by
%       '$$$$' lines, into <cdfFileName>.cdf, and returns the identifiers that had a mol file.
%       The test writes small mol files into a temporary folder and compares the returned list
%       and the whole content of the .cdf file with the text expected from those files.
%
% Function under test:
%     src/analysis/thermo/molFiles/molFilesToCDFfile.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - file-based look-up for model metabolites, no solver; a hand-built model
%     structure with the only field read (mets) and mol files in a tempname folder.
%
% Coverage exemptions:
%     None. Every executable line is reached below.
%
% Known defects documented (NOT tested, NOT fixed here):
%     - DEFECT: The share of metabolites without mol files is printed as a fraction labelled percentage
%       SEVERITY: cosmetic
%       TRIGGER: model.mets = {'a[c]'; 'b[c]'; 'c[c]'; 'd[c]'} with only a.mol in the current
%         folder, molFilesToCDFfile(model, 'x')
%       OBSERVED: MATLAB R2025a, 2026-11-16: "Percentage of metabolites without mol files: 0.75"
%         (num2str(noMolFileCount/nMet)); the returned list and the .cdf file are correct, so no
%         input is skipped and the console text is not asserted
%       EXPECTED: "Percentage of metabolites without mol files: 75" (or the value labelled as a
%         fraction), as mol2sdf prints "75.0%"
%       LINES: 77
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMolFilesToCDFfile'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% the function reads and writes in the current folder: work in a temporary folder
workDir = tempname;
mkdir(workDir);
cd(workDir);

% two mol files (a.mol with an empty line, c.mol); there is no b.mol
molA = {'a'; '  test'; ''; '  0  0  0  0  0  0  0  0  0  0999 V2000'; 'M  END'};
molC = {'c'; '  test'; '  0  0  0  0  0  0  0  0  0  0999 V2000'; 'M  END'};
writeLines('a.mol', molA);
writeLines('c.mol', molC);

%% metabolites with and without mol files, the same mol file in two compartments

% a[c], c[e] and a[e] have a mol file (a.mol is used twice), b[c] has none; the returned list
% keeps model order and the full identifiers
model.mets = {'a[c]'; 'b[c]'; 'c[e]'; 'a[e]'};
metList = molFilesToCDFfile(model, 'structures');
assert(isequal(metList, {'a[c]'; 'c[e]'; 'a[e]'}));

% the first mol file is copied as it is, every later one is preceded by a '$$$$' line;
% exact text comparison, line by line
expectedLines = [molA; {'$$$$'}; molC; {'$$$$'}; molA];
assert(exist('structures.cdf', 'file') == 2);
assert(strcmp(fileread('structures.cdf'), sprintf('%s\n', expectedLines{:})));

%% no metabolite has a mol file

% the list stays empty and the .cdf file is created empty
model.mets = {'b[c]'; 'x[m]'};
metList = molFilesToCDFfile(model, 'empty');
assert(iscell(metList) && isempty(metList));
assert(exist('empty.cdf', 'file') == 2 && isempty(fileread('empty.cdf')));

% remove the temporary folder and change the directory
cd(fileDir);
rmdir(workDir, 's');
cd(currentDir)


function writeLines(fileName, textLines)
% Write a cell array of lines to a text file, each line ending with a newline.
fid = fopen(fileName, 'w');
fprintf(fid, '%s\n', textLines{:});
fclose(fid);
end
