function dumpCallGraph(repoRoot, outFile)
% Writes the static call graph of src/ (outside old/, deprecated/, external/) as tab-separated
% lines "caller<TAB>callee name<TAB>kind", where caller is the repository-relative file and
% kind is "call" (from getcallinfo). Lines "FILE<TAB>path<TAB>type" give each file's type
% (function, script or class) and "LOCAL<TAB>path<TAB>name" its local functions.
%
% USAGE:
%    dumpCallGraph(repoRoot, outFile)
%
% NOTE:
%    Measurement tool of feature 20261113-142115-test-backfill-tiers (not part of the toolbox).
%
% Author: generated for feature 20261113-142115-test-backfill-tiers, 2026-11-13.
files = dir(fullfile(repoRoot, 'src', '**', '*.m'));
fid = fopen(outFile, 'w');
closeFile = onCleanup(@() fclose(fid));
for k = 1:numel(files)
    path = fullfile(files(k).folder, files(k).name);
    rel = strrep(path, [repoRoot filesep], '');
    parts = strsplit(rel, filesep);
    if any(ismember(parts, {'old', 'deprecated', 'external'}))
        continue
    end
    try
        info = getcallinfo(path);
    catch ME
        fprintf(fid, 'PARSEFAIL\t%s\t%s\n', rel, regexprep(ME.message, '\s+', ' '));
        continue
    end
    fprintf(fid, 'FILE\t%s\t%s\n', rel, char(info(1).type));
    names = {};
    for i = 1:numel(info)
        if i > 1
            fprintf(fid, 'LOCAL\t%s\t%s\n', rel, info(i).name);
        end
        c = info(i).calls;
        names = [names, c.fcnCalls.names, c.innerCalls.names, c.dotCalls.names]; %#ok<AGROW>
    end
    names = setdiff(unique(names), {info.name});
    for n = 1:numel(names)
        fprintf(fid, '%s\t%s\tcall\n', rel, names{n});
    end
end
end
