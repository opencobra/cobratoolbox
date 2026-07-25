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
%    fitresult:     a `cfit` object representing the Gaussian fit
%    gof:           structure with goodness-of-fit information
%
% See also: FIT, CFIT, SFIT
%
% .. Author: - Maria Pires Pacheco, 2016

%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData(x', hybrid_curve);

% Set up fittype and options.
ft = fittype('gauss1');
opts = fitoptions('Method', 'NonlinearLeastSquares');
opts.Display = 'Off';
opts.Lower = [-Inf -Inf 0];
opts.StartPoint = [0.215494818454649 5.36184523579772 1.10452062242243];

% Fit model to data.

[fitresult, gof] = fit(xData, yData, ft, opts);

end
