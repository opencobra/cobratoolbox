function result = parseTreeEquivalence(beforeRoot, afterRoot, listFile, outFile, mode)
% Compares MATLAB's parse tree of each listed file before and after a rewrite.
%
% USAGE:
%
%    result = parseTreeEquivalence(beforeRoot, afterRoot, listFile, outFile)
%    result = parseTreeEquivalence(beforeRoot, afterRoot, listFile, outFile, mode)
%
% INPUTS:
%    beforeRoot:  folder holding the original files
%    afterRoot:   folder holding the rewritten files (same relative paths)
%    listFile:    text file with one relative .m path per line
%    outFile:     JSON file written with one entry per file
%
% OPTIONAL INPUT:
%    mode:        'strict' (default): node kinds and strings must be identical;
%                 'catch': the rewritten tree may differ only by inserted CATCH
%                 nodes, which is how an added empty `catch` appears (FR-003)
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

if nargin < 5
    mode = 'strict';
end
fileList = strtrim(splitlines(fileread(listFile)));
fileList = fileList(~cellfun(@isempty, fileList));
result = struct('file', fileList, 'equal', false, 'nodesBefore', 0, 'nodesAfter', 0);
for i = 1:numel(fileList)
    treeBefore = mtree(fullfile(beforeRoot, fileList{i}), '-file');
    treeAfter = mtree(fullfile(afterRoot, fileList{i}), '-file');
    result(i).nodesBefore = count(treeBefore);
    result(i).nodesAfter = count(treeAfter);
    if strcmp(mode, 'catch')
        result(i).equal = equalExceptCatch(treeBefore, treeAfter);
    else
        result(i).equal = isequal(kinds(treeBefore), kinds(treeAfter)) && ...
            isequal(strings(treeBefore), strings(treeAfter));
    end
end
fid = fopen(outFile, 'w');
if fid == -1
    error('parseTreeEquivalence:open', 'Cannot open %s for writing', outFile);
end
fwrite(fid, jsonencode(result), 'char');
fclose(fid);
fprintf('parseTreeEquivalence: %d of %d files equal -> %s\n', sum([result.equal]), numel(result), outFile);
end

function equal = equalExceptCatch(treeBefore, treeAfter)
% True when the after-tree is the before-tree with only CATCH nodes inserted.
kindsBefore = kinds(treeBefore);
kindsAfter = kinds(treeAfter);
stringsBefore = strings(treeBefore);
stringsAfter = strings(treeAfter);
isInserted = false(size(kindsAfter));
j = 1;
for k = 1:numel(kindsAfter)
    if j <= numel(kindsBefore) && strcmp(kindsAfter{k}, kindsBefore{j}) && ...
            isequal(stringsAfter{k}, stringsBefore{j})
        j = j + 1;
    elseif strcmp(kindsAfter{k}, 'CATCH')
        isInserted(k) = true;
    else
        equal = false;
        return
    end
end
equal = j > numel(kindsBefore) && any(isInserted);
end
