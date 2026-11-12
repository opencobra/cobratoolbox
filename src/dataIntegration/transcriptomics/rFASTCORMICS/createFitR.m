function [fitresult, gof] = createFitR(x, hybrid_curve)
% Create a Gaussian fit of the hybrid (right) curve used for FPKM discretization
%
% USAGE:
%
%    [fitresult, gof] = createFitR(x, hybrid_curve)
%
% INPUTS:
%    x:             x values (log2(FPKM) grid) for the fit
%    hybrid_curve:    y values (hybrid density curve) to fit
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
[fitresult, gof] = cobraFitGauss1(x', hybrid_curve, 'StartPoint', [0.215494818454649 5.36184523579772 1.10452062242243], ...
    'Lower', [-Inf -Inf 0], 'Display', 'off');

end
