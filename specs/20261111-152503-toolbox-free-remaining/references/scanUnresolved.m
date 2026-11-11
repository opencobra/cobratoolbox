function scanUnresolved(repoRoot, outFile)
% List every called name in src/ and test/verifiedTests/ that does not resolve
% on this MATLAB installation (candidates for toolbox functions).
cd(repoRoot);
roots = {'src', fullfile('test', 'verifiedTests')};
fid = fopen(outFile, 'w');
cache = containers.Map();
for r = 1:numel(roots)
    files = dir(fullfile(repoRoot, roots{r}, '**', '*.m'));
    for k = 1:numel(files)
        f = fullfile(files(k).folder, files(k).name);
        try
            info = getcallinfo(f);
        catch ME
            fprintf(fid, 'PARSEFAIL\t%s\t%s\n', f, ME.message);
            continue
        end
        localNames = {info.name};
        names = {};
        for i = 1:numel(info)
            c = info(i).calls;
            names = [names, c.fcnCalls.names, c.innerCalls.names]; %#ok<AGROW>
        end
        names = setdiff(unique(names), localNames);
        for n = 1:numel(names)
            nm = names{n};
            if isempty(nm) || contains(nm, '.')
                continue
            end
            if ~isKey(cache, nm)
                cache(nm) = isCallable(nm);
            end
            if ~cache(nm)
                fprintf(fid, '%s\t%s\n', nm, strrep(f, [repoRoot filesep], ''));
            end
        end
    end
end
fclose(fid);
end

function tf = isCallable(nm)
% True when nm resolves to a function, built-in or class with exactly this case.
% exist() alone is not enough: it matches folders (7) and, on a case-insensitive
% lookup, a file of a different case (HeatMap -> heatmap.m).
e = exist(nm); %#ok<EXIST>
if e == 5
    tf = true;
    return
end
if ~any(e == [2 3 6 8])
    tf = false;
    return
end
w = which(nm);
[~, base] = fileparts(w);
tf = strcmp(base, nm) || contains(w, 'built-in');
end
