function [fitresult, gof] = createFitL(xi, rest)
% Create a Gaussian fit of the residual (left) curve used for FPKM discretization
%
% USAGE:
%
%    [fitresult, gof] = createFitL(xi, rest)
%
% INPUTS:
%    xi:            x values (log2(FPKM) grid) for the fit
%    rest:          y values (residual density) to fit
%
% OUTPUTS:
%    fitresult:     structure with the coefficients `a1`, `b1`, `c1` of the Gaussian
%                   a1*exp(-((x-b1)/c1)^2) and the handle `f` that evaluates it
%                   (formerly a `cfit` object; the coefficient fields are the same)
%    gof:           structure with goodness-of-fit information
%
% NOTE:
%    Fitted with cobraFitGauss1 (no Curve Fitting Toolbox needed).
%
% .. Author: - Maria Pires Pacheco, 2016


%% Fit: one-term Gaussian, nonlinear least squares with c1 >= 0
[fitresult, gof] = cobraFitGauss1(xi, rest, 'StartPoint', [0.0442312785349232 -0.515420615759673 2.77989514663167], ...
    'Lower', [-Inf -Inf 0], 'Display', 'off');
end


