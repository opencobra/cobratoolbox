function report = inspectMosekProb(prob)
% inspectMosekProb
% Numerical and structural inspection of a MOSEK problem struct.
%
% Expected fields may include:
%   a, blc, buc, c, blx, bux, f, g, accs
%
% Output:
%   report.fieldStats   : table of per-field numerical statistics
%   report.sizeStats    : table of shape / sparsity information
%   report.problemChecks: struct of higher-level consistency checks
%
% Example:
%   report = inspectMosekProb(prob);

fields = fieldnames(prob);

% Per-field numerical summary
statsVarNames = { ...
    'nRows','nCols','nElem','nnz','density', ...
    'nFinite','nNaN','nPosInf','nNegInf', ...
    'min','max','mean','sd', ...
    'minAbsNonzero','maxAbs','dynamicRange', ...
    'nZero','nPos','nNeg'};
nStats = numel(statsVarNames);

stats = nan(numel(fields), nStats);

for i = 1:numel(fields)
    x = prob.(fields{i});

    % Skip nonnumeric fields except record their size if possible
    if ~isnumeric(x) && ~islogical(x)
        sz = size(x);
        stats(i,1) = sz(1);
        stats(i,2) = prod(sz(2:end));
        stats(i,3) = numel(x);
        continue
    end

    sz = size(x);
    stats(i,1) = sz(1);
    stats(i,2) = prod(sz(2:end));
    stats(i,3) = numel(x);
    stats(i,4) = nnz(x);

    if numel(x) > 0
        stats(i,5) = nnz(x) / numel(x);
    end

    finiteMask = isfinite(x);
    nanMask    = isnan(x);
    posInfMask = isinf(x) & x > 0;
    negInfMask = isinf(x) & x < 0;

    stats(i,6) = nnz(finiteMask);
    stats(i,7) = nnz(nanMask);
    stats(i,8) = nnz(posInfMask);
    stats(i,9) = nnz(negInfMask);

    if any(finiteMask)
        v = x(finiteMask);

        stats(i,10) = min(v);
        stats(i,11) = max(v);
        stats(i,12) = mean(v);
        stats(i,13) = std(v,0);

        av = abs(v);
        nzMask = av > 0;
        if any(nzMask)
            stats(i,14) = min(av(nzMask));
            stats(i,15) = max(av);
            stats(i,16) = stats(i,15) / stats(i,14);
        else
            stats(i,14) = NaN;
            stats(i,15) = 0;
            stats(i,16) = NaN;
        end

        stats(i,17) = nnz(v == 0);
        stats(i,18) = nnz(v > 0);
        stats(i,19) = nnz(v < 0);
    end
end

fieldStats = array2table(stats, ...
    'VariableNames', statsVarNames, ...
    'RowNames', fields);

% Extra matrix-specific diagnostics for A and F if present
sizeStats = table();

matrixFields = intersect(fields, {'a','f'}, 'stable');
for k = 1:numel(matrixFields)
    name = matrixFields{k};
    M = prob.(name);

    if ~isnumeric(M)
        continue
    end

    rowNnz = full(sum(M ~= 0, 2));
    colNnz = full(sum(M ~= 0, 1))';

    finiteVals = M(isfinite(M));
    if isempty(finiteVals)
        minAbsNZ = NaN;
        maxAbs   = NaN;
    else
        absVals = abs(finiteVals);
        nz = absVals > 0;
        if any(nz)
            minAbsNZ = min(absVals(nz));
        else
            minAbsNZ = NaN;
        end
        maxAbs = max(absVals);
    end

    entry = table( ...
        size(M,1), ...
        size(M,2), ...
        nnz(M), ...
        nnz(M)/numel(M), ...
        min(rowNnz), max(rowNnz), mean(rowNnz), ...
        min(colNnz), max(colNnz), mean(colNnz), ...
        norm(M,1), norm(M,inf), ...
        minAbsNZ, maxAbs, ...
        'VariableNames', { ...
        'nRows','nCols','nnz','density', ...
        'minRowNnz','maxRowNnz','meanRowNnz', ...
        'minColNnz','maxColNnz','meanColNnz', ...
        'norm1','normInf', ...
        'minAbsNonzero','maxAbs'});
    entry.Properties.RowNames = {name};

    sizeStats = [sizeStats; entry];
end

% Higher-level consistency checks
checks = struct();

% Dimensions
if isfield(prob,'a') && isfield(prob,'c')
    checks.a_num_cols_matches_c = (size(prob.a,2) == numel(prob.c));
end

if isfield(prob,'a') && isfield(prob,'blc')
    checks.a_num_rows_matches_blc = (size(prob.a,1) == numel(prob.blc));
end

if isfield(prob,'a') && isfield(prob,'buc')
    checks.a_num_rows_matches_buc = (size(prob.a,1) == numel(prob.buc));
end

if isfield(prob,'f') && isfield(prob,'c')
    checks.f_num_cols_matches_c = (size(prob.f,2) == numel(prob.c));
end

if isfield(prob,'f') && isfield(prob,'g')
    checks.f_num_rows_matches_g = (size(prob.f,1) == numel(prob.g));
end

if isfield(prob,'blx') && isfield(prob,'c')
    checks.blx_matches_c = (numel(prob.blx) == numel(prob.c));
end

if isfield(prob,'bux') && isfield(prob,'c')
    checks.bux_matches_c = (numel(prob.bux) == numel(prob.c));
end

% Finite-value checks
numericFields = fields(structfun(@(z) isnumeric(z) || islogical(z), prob));
checks.hasNaN = false;
checks.hasInf = false;
for i = 1:numel(numericFields)
    x = prob.(numericFields{i});
    if any(isnan(x(:)))
        checks.hasNaN = true;
    end
    if any(isinf(x(:)))
        checks.hasInf = true;
    end
end

% Bound consistency
if isfield(prob,'blx') && isfield(prob,'bux')
    idx = isfinite(prob.blx) & isfinite(prob.bux);
    checks.nBadVariableBounds = nnz(prob.blx(idx) > prob.bux(idx));
end

if isfield(prob,'blc') && isfield(prob,'buc')
    idx = isfinite(prob.blc) & isfinite(prob.buc);
    checks.nBadLinearBounds = nnz(prob.blc(idx) > prob.buc(idx));
end

% Fixed variables / constraints
if isfield(prob,'blx') && isfield(prob,'bux')
    idx = isfinite(prob.blx) & isfinite(prob.bux);
    checks.nFixedVariables = nnz(prob.blx(idx) == prob.bux(idx));
end

if isfield(prob,'blc') && isfield(prob,'buc')
    idx = isfinite(prob.blc) & isfinite(prob.buc);
    checks.nEqualityConstraints = nnz(prob.blc(idx) == prob.buc(idx));
end

% Large dynamic range flags
checks.warningFieldsDynamicRangeOver1e8 = {};
checks.warningFieldsDynamicRangeOver1e12 = {};
for i = 1:height(fieldStats)
    dr = fieldStats.dynamicRange(i);
    if isfinite(dr) && dr > 1e8
        checks.warningFieldsDynamicRangeOver1e8{end+1,1} = fieldStats.Properties.RowNames{i}; %#ok<AGROW>
    end
    if isfinite(dr) && dr > 1e12
        checks.warningFieldsDynamicRangeOver1e12{end+1,1} = fieldStats.Properties.RowNames{i}; %#ok<AGROW>
    end
end

% Optional rough conditioning diagnostics for square sparse A
if isfield(prob,'a') && isnumeric(prob.a)
    A = prob.a;
    checks.a_is_square = (size(A,1) == size(A,2));
    try
        checks.a_sprank = sprank(A);
    catch
        checks.a_sprank = NaN;
    end
    if checks.a_is_square
        try
            checks.a_condest = condest(A);
        catch
            checks.a_condest = NaN;
        end
    else
        checks.a_condest = NaN;
    end
end

if isfield(prob,'f') && isnumeric(prob.f)
    F = prob.f;
    checks.f_is_square = (size(F,1) == size(F,2));
    try
        checks.f_sprank = sprank(F);
    catch
        checks.f_sprank = NaN;
    end
    if checks.f_is_square
        try
            checks.f_condest = condest(F);
        catch
            checks.f_condest = NaN;
        end
    else
        checks.f_condest = NaN;
    end
end

report = struct();
report.fieldStats = fieldStats;
report.sizeStats = sizeStats;
report.problemChecks = checks;

disp(' ');
disp('Field statistics');
disp(fieldStats);

if ~isempty(sizeStats)
    disp(' ');
    disp('Matrix-specific statistics');
    disp(sizeStats);
end

disp(' ');
disp('Problem checks');
disp(checks);
end