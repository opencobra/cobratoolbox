function analyzerSnapshot(listFile, outFile)
% Records MATLAB code-analyzer message identifiers for each file in a list.
%
% USAGE:
%
%    analyzerSnapshot(listFile, outFile)
%
% INPUTS:
%    listFile:    text file with one .m path per line
%    outFile:     JSON file written with one entry per input file: the path
%                 and the sorted list of analyzer message identifiers
%
% NOTE:
%
%    Used before and after the RunMat-compatibility rewrite: a rewrite is
%    accepted only when its file gains no identifier (FR-011).
%
% .. Author: - RunMat-compatibility feature 20261102-153951-runmat-compat

fileList = strtrim(splitlines(fileread(listFile)));
fileList = fileList(~cellfun(@isempty, fileList));
results = struct('file', fileList, 'ids', []);
for i = 1:numel(fileList)
    messages = checkcode(fileList{i}, '-id', '-struct');
    ids = sort({messages.id});
    results(i).ids = ids;
end
fid = fopen(outFile, 'w');
if fid == -1
    error('analyzerSnapshot:open', 'Cannot open %s for writing', outFile);
end
fwrite(fid, jsonencode(results), 'char');
fclose(fid);
fprintf('analyzerSnapshot: %d files -> %s\n', numel(fileList), outFile);
end
