function result = findNonBuiltinCalls(entryFile, varargin)
% traceNonBuiltinCalls
%
% Trace non-built-in / non-MathWorks MATLAB code executed by a given .m or .mlx.
%
% This is a runtime tracer:
%   - resolves the target with which / full path
%   - runs it under the MATLAB profiler
%   - extracts executed files from profiler data
%   - filters out built-ins and MathWorks-installed code under matlabroot
%   - reports user / third-party code only
%
% Basic usage
%   result = findNonBuiltinCalls('myScript.m');
%   result = findNonBuiltinCalls('myLiveScript.mlx');
%
% For a function that needs inputs
%   result = findNonBuiltinCalls('myFunction.m', ...
%       'Runner', @() myFunction(arg1,arg2));
%
% Name-value options
%   'Runner'              function handle to execute instead of run(entryFile)
%   'IncludeMex'          true/false, default true
%   'IncludePFiles'       true/false, default true
%   'ExcludeFolders'      cellstr/string array of folder prefixes to exclude
%   'ReturnMathWorksCode' true/false, default false
%
% Output
%   result is a struct with fields:
%       .entryFile
%       .files               table of executed non-MathWorks files
%       .loadedAfterRun      table of newly loaded non-MathWorks files
%       .profileInfo         raw profile('info') output
%
% Notes
%   - Built-ins are part of the MATLAB executable and generally do not appear
%     as user files with source paths.
%   - "Non built-in" here means "not under matlabroot" and with a real file path.
%   - For parfor / worker execution, client-side profiling may miss worker-side calls.

    p = inputParser;
    addRequired(p, 'entryFile', @(x) ischar(x) || isstring(x));
    addParameter(p, 'Runner', [], @(x) isempty(x) || isa(x, 'function_handle'));
    addParameter(p, 'IncludeMex', true, @(x) islogical(x) && isscalar(x));
    addParameter(p, 'IncludePFiles', true, @(x) islogical(x) && isscalar(x));
    addParameter(p, 'ExcludeFolders', {}, @(x) ischar(x) || isstring(x) || iscellstr(x));
    addParameter(p, 'ReturnMathWorksCode', false, @(x) islogical(x) && isscalar(x));
    parse(p, entryFile, varargin{:});

    entryFile = char(p.Results.entryFile);
    runner = p.Results.Runner;
    includeMex = p.Results.IncludeMex;
    includePFiles = p.Results.IncludePFiles;
    excludeFolders = cellstr(string(p.Results.ExcludeFolders));
    returnMathWorksCode = p.Results.ReturnMathWorksCode;

    resolvedEntry = resolveEntryFile(entryFile);

    if isempty(runner)
        runner = @() runTargetInBaseWorkspace(resolvedEntry);
    end

    [beforeF, beforeM] = inmem('-completenames');

    profile('clear');
    profile('on','-history');
    cleanupObj = onCleanup(@() profile('off'));


    try
        runner();
    catch ME
        pinfo = profile('info');
        result = buildResult(resolvedEntry, pinfo, beforeF, beforeM, ...
            includeMex, includePFiles, excludeFolders, returnMathWorksCode);
        result.error = ME;
        rethrow(ME);
    end

    pinfo = profile('info');
    [afterF, afterM] = inmem('-completenames');

    result = buildResult(resolvedEntry, pinfo, beforeF, beforeM, ...
        includeMex, includePFiles, excludeFolders, returnMathWorksCode, ...
        afterF, afterM);
end


function runTargetInBaseWorkspace(resolvedEntry)
    oldDir = pwd;
    cleanupObj = onCleanup(@() cd(oldDir));

    targetDir = fileparts(resolvedEntry);
    if ~isempty(targetDir)
        cd(targetDir);
    end

    safePath = strrep(resolvedEntry, '''', '''''');
    evalin('base', sprintf('run(''%s'')', safePath));
end

function resolved = resolveEntryFile(entryFile)

    entryFile = char(string(entryFile));

    resolved = which(entryFile);

    if isempty(resolved)
        if isfile(entryFile)
            resolved = char(java.io.File(entryFile).getCanonicalPath());
        else
            error('traceNonBuiltinCalls:NotFound', ...
                'Could not resolve file: %s', entryFile);
        end
    end

    [~,~,ext] = fileparts(resolved);
    if ~ismember(lower(ext), {'.m','.mlx','.p'})
        error('traceNonBuiltinCalls:BadExtension', ...
            'Expected .m, .mlx, or .p file, got: %s', resolved);
    end
end

function result = buildResult(resolvedEntry, pinfo, beforeF, beforeM, ...
    includeMex, includePFiles, excludeFolders, returnMathWorksCode, ...
    afterF, afterM)

    if nargin < 9
        afterF = {};
        afterM = {};
    end

    executedFiles = extractExecutedFilesFromProfile(pinfo);
    executedFiles = unique(executedFiles(:), 'stable');

    filesTbl = makeFileTable(executedFiles, includeMex, includePFiles, ...
        excludeFolders, returnMathWorksCode);

    newlyLoaded = setdiff([afterF(:); afterM(:)], [beforeF(:); beforeM(:)], 'stable');
    loadedTbl = makeFileTable(newlyLoaded, includeMex, includePFiles, ...
        excludeFolders, returnMathWorksCode);

    result = struct();
    result.entryFile = resolvedEntry;
    result.files = filesTbl;
    result.loadedAfterRun = loadedTbl;
    result.profileInfo = pinfo;
end


function files = extractExecutedFilesFromProfile(pinfo)
    files = {};

    if isempty(pinfo)
        return
    end

    if isstruct(pinfo) && isfield(pinfo, 'FunctionTable')
        ft = pinfo.FunctionTable;
    elseif isobject(pinfo) && isprop(pinfo, 'FunctionTable')
        ft = pinfo.FunctionTable;
    else
        ft = [];
    end

    if isempty(ft)
        return
    end

    for i = 1:numel(ft)
        candidate = '';

        if isstruct(ft)
            row = ft(i);
            if isfield(row, 'FileName') && ~isempty(row.FileName)
                candidate = row.FileName;
            elseif isfield(row, 'CompleteName') && ~isempty(row.CompleteName)
                candidate = row.CompleteName;
            elseif isfield(row, 'FunctionName') && ~isempty(row.FunctionName)
                tmp = which(row.FunctionName);
                if ~isempty(tmp)
                    candidate = tmp;
                end
            end
        else
            row = ft(i);
            try
                if isprop(row, 'FileName') && ~isempty(row.FileName)
                    candidate = row.FileName;
                elseif isprop(row, 'CompleteName') && ~isempty(row.CompleteName)
                    candidate = row.CompleteName;
                elseif isprop(row, 'FunctionName') && ~isempty(row.FunctionName)
                    tmp = which(row.FunctionName);
                    if ~isempty(tmp)
                        candidate = tmp;
                    end
                end
            catch
            end
        end

        if isstring(candidate)
            candidate = char(candidate);
        end

        if ischar(candidate) && ~isempty(candidate)
            files{end+1,1} = candidate; %#ok<AGROW>
        end
    end
end


function tbl = makeFileTable(files, includeMex, includePFiles, ...
    excludeFolders, returnMathWorksCode)

    if isempty(files)
        tbl = table(strings(0,1), strings(0,1), strings(0,1), strings(0,1), ...
            false(0,1), false(0,1), ...
            'VariableNames', {'Name','Ext','Folder','FullPath','IsMex','IsPFile'});
        return
    end

    files = files(:);
    keep = false(size(files));

    names = strings(size(files));
    exts = strings(size(files));
    folders = strings(size(files));
    fullpaths = strings(size(files));
    isMex = false(size(files));
    isP = false(size(files));

    mr = matlabroot;

    for i = 1:numel(files)
        f = files{i};

        if isempty(f) || ~(ischar(f) || isstring(f))
            continue
        end

        f = char(f);

        if exist(f, 'file') ~= 2 && exist(f, 'file') ~= 3
            continue
        end

        [folder, name, ext] = fileparts(f);
        extLower = lower(ext);

        mexExts = {'.mexw64','.mexa64','.mexmaci64','.mex'};
        isMex_i = ismember(extLower, mexExts);
        isP_i = strcmp(extLower, '.p');

        if isMex_i && ~includeMex
            continue
        end
        if isP_i && ~includePFiles
            continue
        end

        isMathWorksCode = startsWith(lower(f), lower(mr));

        if ~returnMathWorksCode && isMathWorksCode
            continue
        end

        excluded = false;
        for j = 1:numel(excludeFolders)
            prefix = char(excludeFolders{j});
            if startsWith(lower(f), lower(prefix))
                excluded = true;
                break
            end
        end
        if excluded
            continue
        end

        keep(i) = true;
        names(i) = string(name);
        exts(i) = string(ext);
        folders(i) = string(folder);
        fullpaths(i) = string(f);
        isMex(i) = isMex_i;
        isP(i) = isP_i;
    end

    tbl = table(names(keep), exts(keep), folders(keep), fullpaths(keep), ...
        isMex(keep), isP(keep), ...
        'VariableNames', {'Name','Ext','Folder','FullPath','IsMex','IsPFile'});

    if ~isempty(tbl)
        tbl = unique(tbl, 'rows', 'stable');
        tbl = sortrows(tbl, {'Folder','Name'});
    end
end