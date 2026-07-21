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
%    fitresult:     a `cfit` object representing the Gaussian fit
%    gof:           structure with goodness-of-fit information
%
% See also: FIT, CFIT, SFIT
%
% .. Author: - Maria Pires Pacheco, 2016


%% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( xi, rest );

% Set up fittype and options.
ft = fittype( 'gauss1' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Lower = [-Inf -Inf 0];
opts.StartPoint = [0.0442312785349232 -0.515420615759673 2.77989514663167];

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );
end


