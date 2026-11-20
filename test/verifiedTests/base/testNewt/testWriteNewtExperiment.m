% The COBRAToolbox: testWriteNewtExperiment.m
%
% Purpose:
%     - writeNewtExperiment writes a tab-delimited experiment data file for newteditor: a
%       header (version, name, description, colour scale), the sample names and one row of
%       data per metabolite, labelled with the metabolite name. This test checks the file
%       written with every default, with every option given (single sample name as a string),
%       with the name and description taken from the model, and the size check. Expected file
%       contents are written out by hand from the documented format and the defaults in the
%       code.
%
% Function under test:
%     src/base/io/newt/writeNewtExperiment.m
%
% Tier (Constitution III-Coverage):
%     Tier 2 - file output for a one-reaction hand-built model, no solver.
%
% Coverage exemptions:
%     Line 149: unreachable - useM is set to the constant 0 at line 146, so the SBML node
%     identifier branch never runs.
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261113-142115-test-backfill-tiers, 2026-11-16.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testWriteNewtExperiment'));
cd(fileDir);

% declare the requirements of this test. A Tier 2 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

% all files are written to a temporary folder
outputFolder = tempname;
mkdir(outputFolder);

model = createModel({'R1'}, {'reaction one'}, {'a[c] -> b[c]'}, 'printLevel', 0);
model.metNames = {'A name'; 'B name'};
metData = [1 2; 3 4];

%% every default: file name in the current folder, timestamp version, default colour scale

cd(outputFolder);
writeNewtExperiment(model, metData);
cd(fileDir);
fileLines = strsplit(fileread([outputFolder filesep 'newtExpData.txt']), '\n');
% the version is a datestr(now, 30) timestamp, the rest is exact
assert(~isempty(regexp(fileLines{1}, '^version\t\d{8}T\d{6}$', 'once')));
expectedLines = strsplit(sprintf(['name\taModel\ndescription\taDescription\n' ...
    'color\t-100\t#FF0000\t0\t#FF0000\t100\t#0000FF\nnode\texp1\texp2\n' ...
    'A name\t1\t2\nB name\t3\t4\n']), '\n');
assert(isequal(fileLines(2:end), expectedLines));

%% every option given, one sample named by a string

colourScale = struct('minValue', 0, 'minColor', '#FFFFFF', 'zeroValue', 1, ...
    'zeroColor', '#000000', 'maxValue', 100, 'maxColor', '#FF0000');
param = struct('version', '1.0', 'name', 'sample experiment', 'description', 'two samples', ...
    'color', colourScale);
fileName = [outputFolder filesep 'given.txt'];
writeNewtExperiment(model, [1; 3], 'single', fileName, param);
% exact: the header repeats the parameters; one data column
assert(isequal(fileread(fileName), sprintf(['version\t1.0\nname\tsample experiment\n' ...
    'description\ttwo samples\ncolor\t0\t#FFFFFF\t1\t#000000\t100\t#FF0000\n' ...
    'node\tsingle\nA name\t1\nB name\t3\n'])));

%% name and description from the model, sample names from a cell array

model.modelID = 'modelIdentifier';
model.description = 'model description';
fileName = [outputFolder filesep 'fromModel.txt'];
writeNewtExperiment(model, metData, {'s1', 's2'}, fileName);
fileLines = strsplit(fileread(fileName), '\n');
% exact apart from the timestamp version
expectedLines = strsplit(sprintf(['name\tmodelIdentifier\ndescription\tmodel description\n' ...
    'color\t-100\t#FF0000\t0\t#FF0000\t100\t#0000FF\nnode\ts1\ts2\n' ...
    'A name\t1\t2\nB name\t3\t4\n']), '\n');
assert(isequal(fileLines(2:end), expectedLines));

%% the data must have one row per metabolite

assert(verifyCobraFunctionError('writeNewtExperiment', 'inputs', {model, [1; 2; 3], {'s1'}, ...
    [outputFolder filesep 'never.txt']}, 'testMessage', 'size(metData,1) must equal size(model.S,1)'));
% the check comes before the file is opened
assert(~isfile([outputFolder filesep 'never.txt']));

% remove the temporary folder and change the directory
rmdir(outputFolder, 's');
cd(currentDir)
