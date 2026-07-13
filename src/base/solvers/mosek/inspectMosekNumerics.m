function report = inspectMosekNumerics(prob)
% inspectMosekNumerics
% Inspect numerical properties of a MOSEK problem structure.
%
% USAGE:
%    report = inspectMosekNumerics(prob)
%
% INPUTS:
%    prob:       MOSEK problem structure. Typical fields include:
%                .a    - linear constraint matrix
%                .blc  - lower linear constraint bounds
%                .buc  - upper linear constraint bounds
%                .c    - objective vector
%                .blx  - lower variable bounds
%                .bux  - upper variable bounds
%                .f    - affine conic constraint matrix
%                .g    - affine conic constraint offset
%
% OUTPUTS:
%    report:     Structure containing numerical diagnostics for the problem
%                data. Depending on which fields are present in prob, this
%                may include:
%                .A_size
%                .A_nnz
%                .A_density
%                .A_abs_min_nonzero
%                .A_abs_max
%                .A_dynamic_range
%                .A_row_norm_inf_min
%                .A_row_norm_inf_max
%                .A_col_norm_inf_min
%                .A_col_norm_inf_max
%                .blc_abs_min, .blc_abs_max, .blc_dynamic_range
%                .buc_abs_min, .buc_abs_max, .buc_dynamic_range
%                .c_abs_min,   .c_abs_max,   .c_dynamic_range
%                .blx_abs_min, .blx_abs_max, .blx_dynamic_range
%                .bux_abs_min, .bux_abs_max, .bux_dynamic_range
%                .f_abs_min,   .f_abs_max,   .f_dynamic_range
%                .g_abs_min,   .g_abs_max,   .g_dynamic_range
%                .nBadVarBounds
%                .nBadConBounds
%
% This routine is written to reduce unnecessary full-array calls to
% isfinite, which can dominate runtime on very large problem instances.
% It uses a fast path that assumes data are finite and only falls back
% to explicit finite filtering if non-finite values are detected.
%
% EXAMPLE:
%    report = inspectMosekNumerics(prob);
%
% Author:
%    Ronan Fleming / ChatGPT
%
% NOTE:
%    Intended for diagnostic inspection of MOSEK-style problem data.

    report = struct();

    if isfield(prob, 'a') && isnumeric(prob.a)
        A = prob.a;
        report.A_size = size(A);
        report.A_nnz = nnz(A);
        report.A_density = nnz(A) / numel(A);

        if issparse(A)
            av = nonzeros(A);
        else
            av = A(:);
        end

        [absMinNz, absMax, dynRange] = localAbsStats(av, true);
        report.A_abs_min_nonzero = absMinNz;
        report.A_abs_max = absMax;
        report.A_dynamic_range = dynRange;

        % Fast path: row/column infinity norms should already be finite if A is finite.
        rowNormInf = full(max(abs(A), [], 2));
        colNormInf = full(max(abs(A), [], 1)).';

        [rowMin, rowMax] = localFiniteMinMax(rowNormInf);
        [colMin, colMax] = localFiniteMinMax(colNormInf);

        report.A_row_norm_inf_min = rowMin;
        report.A_row_norm_inf_max = rowMax;
        report.A_col_norm_inf_min = colMin;
        report.A_col_norm_inf_max = colMax;
    end

    numFields = {'blc', 'buc', 'c', 'blx', 'bux', 'f', 'g'};

    for j = 1:numel(numFields)
        fn = numFields{j};
        if isfield(prob, fn) && isnumeric(prob.(fn))
            x = prob.(fn);
            tag = matlab.lang.makeValidName(fn);

            [absMinVal, absMaxVal, dynRange] = localAbsStats(x, false);

            report.([tag '_abs_min']) = absMinVal;
            report.([tag '_abs_max']) = absMaxVal;
            report.([tag '_dynamic_range']) = dynRange;
        end
    end

    if isfield(prob, 'blx') && isfield(prob, 'bux') ...
            && isnumeric(prob.blx) && isnumeric(prob.bux)

        blx = prob.blx;
        bux = prob.bux;

        % Faster finite test than repeated extraction passes:
        idx = (blx > -inf) & (blx < inf) & (bux > -inf) & (bux < inf);
        report.nBadVarBounds = nnz(blx(idx) > bux(idx));
    end

    if isfield(prob, 'blc') && isfield(prob, 'buc') ...
            && isnumeric(prob.blc) && isnumeric(prob.buc)

        blc = prob.blc;
        buc = prob.buc;

        idx = (blc > -inf) & (blc < inf) & (buc > -inf) & (buc < inf);
        report.nBadConBounds = nnz(blc(idx) > buc(idx));
    end
end


function [absMinVal, absMaxVal, dynRange] = localAbsStats(x, ignoreZero)
% Fast-path absolute-value statistics with fallback finite filtering only
% when non-finite values are actually encountered.

    if issparse(x)
        v = nonzeros(x);
    else
        v = x(:);
    end

    if isempty(v)
        absMinVal = NaN;
        absMaxVal = NaN;
        dynRange = NaN;
        return
    end

    ax = abs(v);

    if ignoreZero
        axnz = ax(ax > 0);

        if isempty(axnz)
            absMinVal = NaN;
            absMaxVal = NaN;
            dynRange = NaN;
            return
        end

        absMinVal = min(axnz);
        absMaxVal = max(ax);

        % Fallback only if the fast path encountered non-finite values.
        if ~isfinite(absMinVal) || ~isfinite(absMaxVal)
            ax = ax(isfinite(ax) & ax > 0);

            if isempty(ax)
                absMinVal = NaN;
                absMaxVal = NaN;
                dynRange = NaN;
            else
                absMinVal = min(ax);
                absMaxVal = max(ax);
                dynRange = absMaxVal / absMinVal;
            end
        else
            dynRange = absMaxVal / absMinVal;
        end

    else
        absMaxVal = max(ax);
        axnz = ax(ax > 0);

        if isempty(axnz)
            if isfinite(absMaxVal)
                absMinVal = 0;
                dynRange = NaN;
            else
                axf = ax(isfinite(ax));
                if isempty(axf)
                    absMinVal = NaN;
                    absMaxVal = NaN;
                    dynRange = NaN;
                else
                    absMaxVal = max(axf);
                    axnz = axf(axf > 0);
                    if isempty(axnz)
                        absMinVal = 0;
                        dynRange = NaN;
                    else
                        absMinVal = min(axnz);
                        dynRange = absMaxVal / absMinVal;
                    end
                end
            end
            return
        end

        absMinVal = min(axnz);

        if ~isfinite(absMinVal) || ~isfinite(absMaxVal)
            axf = ax(isfinite(ax));
            if isempty(axf)
                absMinVal = NaN;
                absMaxVal = NaN;
                dynRange = NaN;
            else
                absMaxVal = max(axf);
                axnz = axf(axf > 0);
                if isempty(axnz)
                    absMinVal = 0;
                    dynRange = NaN;
                else
                    absMinVal = min(axnz);
                    dynRange = absMaxVal / absMinVal;
                end
            end
        else
            dynRange = absMaxVal / absMinVal;
        end
    end
end


function [xmin, xmax] = localFiniteMinMax(x)
% Fast-path min/max with fallback finite filtering only if needed.

    if isempty(x)
        xmin = NaN;
        xmax = NaN;
        return
    end

    xmin = min(x);
    xmax = max(x);

    if ~isfinite(xmin) || ~isfinite(xmax)
        x = x(isfinite(x));
        if isempty(x)
            xmin = NaN;
            xmax = NaN;
        else
            xmin = min(x);
            xmax = max(x);
        end
    end
end