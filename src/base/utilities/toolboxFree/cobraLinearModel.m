classdef cobraLinearModel
% Fitted linear regression model returned by cobraFitlm, with the properties
% and methods of a MathWorks LinearModel that the toolbox reads, without the
% Statistics and Machine Learning Toolbox
%
% USAGE:
%
%    mdl = cobraFitlm(x, y);              % creates the object
%    mdl.Coefficients                      % table Estimate, SE, tStat, pValue
%    mdl.Rsquared.Ordinary                 % coefficient of determination
%    ci = coefCI(mdl, alpha);              % confidence intervals
%    yPredicted = predict(mdl, xNew);      % predicted response
%    disp(mdl)                             % summary
%
% PROPERTIES:
%    Coefficients, CoefficientNames, CoefficientCovariance, NumCoefficients,
%    NumEstimatedCoefficients, NumObservations, DFE, Rsquared (Ordinary, Adjusted), SSE, SSR,
%    SST, MSE, RMSE, Formula (formula text), Variables (table x1, ..., y), ObservationInfo,
%    Fitted (column of fitted values), Residuals (table Raw, Pearson), NumPredictors,
%    NumVariables, VariableNames
%
% NOTE:
%    Plain-MATLAB stand-in for LinearModel (Statistics and Machine Learning Toolbox), created
%    by cobraFitlm. Property names, layouts and values follow the MathWorks class (SSR =
%    SST - SSE with an intercept, MSE = SSE/DFE, RMSE = sqrt(MSE)); documented differences:
%    the class name, Formula holds text, and methods other than coefCI, predict and disp are
%    not defined (calling one raises MATLAB's error naming it).
%
% .. Authors:
%     - Generated for feature 20261111-152503-toolbox-free-remaining, 2026-11-11.

    properties (SetAccess = private)
        Coefficients
        CoefficientNames
        CoefficientCovariance
        NumCoefficients
        NumEstimatedCoefficients
        NumObservations
        DFE
        Rsquared
        SSE
        SSR
        SST
        MSE
        RMSE
        Formula
        Variables
        ObservationInfo
        Fitted
        Residuals
        NumPredictors
        NumVariables
        VariableNames
    end

    properties (SetAccess = private, Hidden)
        GeneralizedModel
    end

    methods
        function mdl = cobraLinearModel(generalizedModel)
            % Creates the object from the normal-distribution fit of cobraFitglm
            mdl.GeneralizedModel = generalizedModel;
            names = {'Coefficients', 'CoefficientNames', 'CoefficientCovariance', 'NumCoefficients', ...
                'NumEstimatedCoefficients', 'NumObservations', 'DFE', 'Formula', 'Variables', 'ObservationInfo', ...
                'Residuals', 'NumPredictors', 'NumVariables', 'VariableNames'};
            for k = 1:numel(names)
                mdl.(names{k}) = generalizedModel.(names{k});
            end
            mdl.SSE = generalizedModel.SSE;
            mdl.SST = generalizedModel.SST;
            mdl.SSR = mdl.SST - mdl.SSE;
            mdl.MSE = mdl.SSE / mdl.DFE;
            mdl.RMSE = sqrt(mdl.MSE);
            mdl.Rsquared = struct('Ordinary', generalizedModel.Rsquared.Ordinary, 'Adjusted', generalizedModel.Rsquared.Adjusted);
            mdl.Fitted = generalizedModel.Fitted.Response;
        end

        function ci = coefCI(mdl, alpha)
            % Confidence intervals of the coefficients: Estimate +- tinv(1 - alpha/2, DFE)*SE
            if ~exist('alpha', 'var') || isempty(alpha)
                alpha = 0.05;
            end
            ci = coefCI(mdl.GeneralizedModel, alpha);
        end

        function yPredicted = predict(mdl, newData)
            % Predicted response for a table or a matrix of predictor values
            yPredicted = predict(mdl.GeneralizedModel, newData);
        end

        function disp(mdl)
            % Summary in the layout of the MathWorks display
            fprintf('Linear regression model (cobraFitlm):\n    %s\n\nEstimated Coefficients:\n', mdl.Formula);
            disp(mdl.Coefficients);
            fprintf('Number of observations: %d, Error degrees of freedom: %d\n', mdl.NumObservations, mdl.DFE);
            fprintf('Root Mean Squared Error: %.4g\n', mdl.RMSE);
            fprintf('R-squared: %.4g,  Adjusted R-Squared: %.4g\n', mdl.Rsquared.Ordinary, mdl.Rsquared.Adjusted);
        end
    end
end
