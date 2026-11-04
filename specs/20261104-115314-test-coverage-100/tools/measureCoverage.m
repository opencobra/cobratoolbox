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
%
% Author: generated for feature 20261104-115314-test-coverage-100, 2026-11-04.

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

for i = 1:numel(pairs)
    parts = strsplit(strtrim(pairs{i}), '|');
    testFile = fullfile(root, parts{1});
    srcFile = fullfile(root, parts{2});
    record = struct('test', parts{1}, 'source', parts{2}, 'status', '', 'seconds', NaN, ...
        'message', '', 'lines', [], 'hits', []);
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
    record.message = strrep(strrep(record.message, [root filesep], ''), matlabroot, '<matlabroot>');
    cd(fullfile(root, 'test'));
    fid = fopen(outFile, 'a');
    fprintf(fid, '%s\n', jsonencode(record));
    fclose(fid);
    fprintf('COVREC %d/%d %s %s %.0fs\n', i, numel(pairs), record.status, parts{1}, record.seconds);
end
end
