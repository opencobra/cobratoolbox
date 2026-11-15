function measureCoverage(listFile, outFile)
% Measure, for each test in a list, the line coverage of its function under test.
%
% USAGE:
%    measureCoverage(listFile, outFile)
%
% INPUTS:
%    listFile:  text file, one line per test: `<test path>|<source path>` (repository-relative)
%    outFile:   JSON-lines file to append one record per test to
%
% NOTE:
%    Each test script is run once, whole, through `runScriptFile` (as `test/testAll.m` does),
%    inside a temporary function-based test so that MATLAB's code-coverage plugin, restricted
%    to the function under test, records the lines executed. Records: test, source, status
%    (passed / failed / skipped / error), seconds, executable line numbers and hit counts.
%    Feature 20261104-115314-test-coverage-100 (measurement tool; not part of the toolbox).
%    Feature 20261113-142115-test-backfill-tiers adds the field `leftover`: what the test left
%    behind (MATLAB path entries, global variables, open figures, working folder, files in
%    tempdir), compared before and after each test (FR-011); empty when nothing was left.
%
% Author: generated for feature 20261104-115314-test-coverage-100, 2026-11-04; leftover check
%    added for feature 20261113-142115-test-backfill-tiers, 2026-11-13.

import matlab.unittest.TestRunner
import matlab.unittest.TestSuite
import matlab.unittest.plugins.CodeCoveragePlugin
import matlab.unittest.plugins.codecoverage.CoberturaFormat

global CBTDIR COVSTATUS
root = CBTDIR;
pairs = strsplit(strtrim(fileread(listFile)), newline);
wrapperDir = tempname;
mkdir(wrapperDir);
cleanWrapper = onCleanup(@() rmdir(wrapperDir, 's'));
addpath(wrapperDir);

% MATLAB's graphics create session folders in tempdir the first time a figure with axes, text and
% an image is drawn; draw one before the first test so that they are not reported as leftovers
warmUp = figure('Visible', 'off');
plot(1:3); hold on; image(magic(4)); title('warm-up'); drawnow;
warmUpFile = [tempname '.png'];
exportgraphics(gca, warmUpFile);
delete(warmUpFile);
close(warmUp);
% reading XML makes MATLAB's Java create its attach socket .java_pid<pid> in tempdir once per
% session: read one XML document before the first test so that it is not reported as a leftover
warmUpXml = [tempname '.xml'];
fid = fopen(warmUpXml, 'w');
fprintf(fid, '<?xml version="1.0"?><warmup/>');
fclose(fid);
xmlread(warmUpXml);
delete(warmUpXml);

for i = 1:numel(pairs)
    parts = strsplit(strtrim(pairs{i}), '|');
    testFile = fullfile(root, parts{1});
    srcFile = fullfile(root, parts{2});
    record = struct('test', parts{1}, 'source', parts{2}, 'status', '', 'seconds', NaN, ...
        'message', '', 'lines', [], 'hits', [], 'leftover', '');
    stateBefore = captureState();
    xmlFile = [tempname '.xml'];
    % wrapper test that runs the whole script once
    wrapperName = sprintf('covWrap%d', i);
    fid = fopen(fullfile(wrapperDir, [wrapperName '.m']), 'w');
    fprintf(fid, ['function tests = %s\ntests = functiontests(localfunctions);\nend\n' ...
        'function testRun(testCase)\nglobal COVSTATUS\nres = runScriptFile(''%s'');\n' ...
        'COVSTATUS = res;\nend\n'], wrapperName, strrep(testFile, '''', ''''''));
    fclose(fid);
    rehash
    COVSTATUS = [];
    t0 = tic;
    try
        suite = TestSuite.fromFile(fullfile(wrapperDir, [wrapperName '.m']));
        runner = TestRunner.withNoPlugins;
        runner.addPlugin(CodeCoveragePlugin.forFile(srcFile, 'Producing', CoberturaFormat(xmlFile)));
        runner.run(suite);
        record.seconds = toc(t0);
        if isstruct(COVSTATUS) && isfield(COVSTATUS, 'status')
            record.status = COVSTATUS.status;
            if ~strcmp(COVSTATUS.status, 'passed')
                record.message = COVSTATUS.statusMessage;
            end
        else
            record.status = 'error';
        end
        if exist(xmlFile, 'file')
            txt = fileread(xmlFile);
            delete(xmlFile);
            tok = regexp(txt, '<line hits="(\d+)" number="(\d+)"', 'tokens');
            record.hits = cellfun(@(t) str2double(t{1}), tok);
            record.lines = cellfun(@(t) str2double(t{2}), tok);
        end
    catch ME
        record.seconds = toc(t0);
        record.status = 'error';
        record.message = sprintf('%s (%s:%d)', ME.message, ME.stack(1).name, ME.stack(1).line);
    end
    record.leftover = compareState(stateBefore, captureState(), xmlFile);
    record.message = strrep(strrep(record.message, [root filesep], ''), matlabroot, '<matlabroot>');
    close all force
    cd(fullfile(root, 'test'));
    fid = fopen(outFile, 'a');
    fprintf(fid, '%s\n', jsonencode(record));
    fclose(fid);
    fprintf('COVREC %d/%d %s %s %.0fs\n', i, numel(pairs), record.status, parts{1}, record.seconds);
end
end

function state = captureState()
% Snapshot of the state a test must leave unchanged
state.path = strsplit(path, pathsep);
state.globals = who('global');
state.figures = numel(findall(groot, 'Type', 'figure'));
state.folder = pwd;
listing = dir(tempdir);
state.temp = {listing.name};
end

function text = compareState(before, after, ignoredFile)
% Describes what changed between two snapshots (ignores the coverage report and the wrapper)
changes = {};
added = setdiff(after.path, before.path);
removed = setdiff(before.path, after.path);
if ~isempty(added) || ~isempty(removed)
    changes{end + 1} = sprintf('path +%d -%d', numel(added), numel(removed));
end
% globals created by the harness itself (prepareTest, getCobraTestMode, runScriptFile)
harnessGlobals = {'COVSTATUS'; 'CBT_TEST_MODE'; 'CBT_MISSING_REQUIREMENTS_ERROR_ID'; 'OPT_PROB_TYPES'};
newGlobals = setdiff(after.globals, [before.globals; harnessGlobals]);
if ~isempty(newGlobals)
    changes{end + 1} = ['globals ' strjoin(newGlobals', ',')];
end
if after.figures > before.figures
    changes{end + 1} = sprintf('figures +%d', after.figures - before.figures);
end
newTemp = setdiff(after.temp, before.temp);
[~, ignoredName, ignoredExt] = fileparts(ignoredFile);
newTemp = setdiff(newTemp, {[ignoredName ignoredExt]});
% the test runner creates one transient folder named by a GUID per run, and MATLAB's graphics
% renderer creates its own folders once per session at the first figure that draws axes
newTemp = newTemp(cellfun(@isempty, regexp(newTemp, ...
    '^([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}|[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}|\.org\.chromium\.Chromium\..*)$', 'once')));
if ~isempty(newTemp)
    changes{end + 1} = ['tempdir ' strjoin(newTemp, ',')];
end
text = strjoin(changes, '; ');
end
