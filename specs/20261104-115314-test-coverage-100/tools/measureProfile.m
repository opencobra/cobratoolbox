function measureProfile(listFile, outFile)
% Measure line coverage with the profiler, for functions the coverage plugin cannot read.
%
% USAGE:
%    measureProfile(listFile, outFile)
%
% INPUTS:
%    listFile:  text file, one line per test: `<test path>|<source path>` (repository-relative)
%    outFile:   JSON-lines file to append one record per test to
%
% NOTE:
%    MATLAB's coverage collector returns no lines for a function that calls a script. The
%    profiler records those lines; executable lines come from `callstats('file_lines', ...)`.
%    Records have the fields of measureCoverage plus `method: profiler`.
%    Feature 20261104-115314-test-coverage-100 (measurement tool; not part of the toolbox).
%
% Author: generated for feature 20261104-115314-test-coverage-100, 2026-11-04.

global CBTDIR
root = CBTDIR;
pairs = strsplit(strtrim(fileread(listFile)), newline);
for i = 1:numel(pairs)
    parts = strsplit(strtrim(pairs{i}), '|');
    srcFile = fullfile(root, parts{2});
    record = struct('test', parts{1}, 'source', parts{2}, 'status', '', 'seconds', NaN, ...
        'message', '', 'lines', [], 'hits', [], 'method', 'profiler');
    t0 = tic;
    profile('clear');
    profile('on');
    result = runScriptFile(fullfile(root, parts{1}));
    profile('off');
    record.seconds = toc(t0);
    record.status = result.status;
    if ~strcmp(result.status, 'passed')
        record.message = strrep(strrep(result.statusMessage, [root filesep], ''), matlabroot, '<matlabroot>');
    end
    info = profile('info');
    executable = callstats('file_lines', srcFile);
    executable = unique(executable(:)');
    executable = executable(executable > 0);
    entries = info.FunctionTable(strcmp({info.FunctionTable.FileName}, srcFile));
    executed = zeros(0, 2);
    for k = 1:numel(entries)
        executed = [executed; entries(k).ExecutedLines(:, 1:2)]; %#ok<AGROW>
    end
    hits = zeros(size(executable));
    for k = 1:size(executed, 1)
        hits(executable == executed(k, 1)) = hits(executable == executed(k, 1)) + executed(k, 2);
    end
    record.lines = executable;
    record.hits = hits;
    cd(fullfile(root, 'test'));
    fid = fopen(outFile, 'a');
    fprintf(fid, '%s\n', jsonencode(record));
    fclose(fid);
    fprintf('COVREC %d/%d %s %s lines %d hit %d\n', i, numel(pairs), record.status, parts{1}, ...
        numel(executable), nnz(hits));
end
end
