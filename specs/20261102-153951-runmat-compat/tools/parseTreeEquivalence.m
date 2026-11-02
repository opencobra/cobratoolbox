function result = parseTreeEquivalence(beforeRoot, afterRoot, listFile, outFile)
% Compares MATLAB's parse tree of each listed file before and after a rewrite.
%
% USAGE:
%
%    result = parseTreeEquivalence(beforeRoot, afterRoot, listFile, outFile)
%
% INPUTS:
%    beforeRoot:  folder holding the original files
%    afterRoot:   folder holding the rewritten files (same relative paths)
%    listFile:    text file with one relative .m path per line
%    outFile:     JSON file written with one entry per file
%
% OUTPUT:
%    result:      struct array with fields file, equal, nodesBefore, nodesAfter
%
% NOTE:
%
%    A rewrite that only makes separators or function terminators explicit
%    leaves the sequence of node kinds and node strings unchanged; any file
%    whose tree differs is rejected from the mechanical rewrite (FR-010).
%
% .. Author: - RunMat-compatibility feature 20261102-153951-runmat-compat

fileList = strtrim(splitlines(fileread(listFile)));
fileList = fileList(~cellfun(@isempty, fileList));
result = struct('file', fileList, 'equal', false, 'nodesBefore', 0, 'nodesAfter', 0);
for i = 1:numel(fileList)
    treeBefore = mtree(fullfile(beforeRoot, fileList{i}), '-file');
    treeAfter = mtree(fullfile(afterRoot, fileList{i}), '-file');
    result(i).nodesBefore = count(treeBefore);
    result(i).nodesAfter = count(treeAfter);
    result(i).equal = isequal(kinds(treeBefore), kinds(treeAfter)) && ...
        isequal(strings(treeBefore), strings(treeAfter));
end
fid = fopen(outFile, 'w');
if fid == -1
    error('parseTreeEquivalence:open', 'Cannot open %s for writing', outFile);
end
fwrite(fid, jsonencode(result), 'char');
fclose(fid);
fprintf('parseTreeEquivalence: %d of %d files equal -> %s\n', sum([result.equal]), numel(result), outFile);
end
