classdef cobraGeneralizedLinearModel
% Fitted generalized linear model returned by cobraFitglm, with the properties
% and methods of a MathWorks GeneralizedLinearModel that the toolbox and user
% scripts read, without the Statistics and Machine Learning Toolbox
%
% USAGE:
%
%    mdl = cobraFitglm(tbl, formula, ...);   % creates the object
%    mdl.Coefficients                         % table Estimate, SE, tStat, pValue
%    ci = coefCI(mdl);                        % 95% confidence intervals
%    ci = coefCI(mdl, alpha);
%    yPredicted = predict(mdl, newTbl);       % predicted response (probabilities for binomial)
%    disp(mdl)                                % summary
%
% PROPERTIES:
%    Coefficients, CoefficientNames, CoefficientCovariance, NumCoefficients,
%    NumEstimatedCoefficients, NumObservations, DFE, Rsquared (Ordinary, Adjusted, LLR,
%    Deviance, AdjGeneralized), Deviance, LogLikelihood, Dispersion, DispersionEstimated,
%    Distribution (structure with Name), Formula (formula text), Variables (the input table),
%    ObservationInfo (table Weights, Excluded, Missing, Subset), Fitted (table Response,
%    LinearPredictor, Probability), LikelihoodPenalty, Residuals (table Raw, Pearson; the
%    other MathWorks residual types are not provided), NumPredictors, NumVariables, VariableNames
%
% NOTE:
%    Plain-MATLAB stand-in for GeneralizedLinearModel (Statistics and Machine Learning
%    Toolbox), created by cobraFitglm (maintainer decision 2026-11-11: scripts that read the
%    fitted models keep working). Property names, layouts and values follow the MathWorks
%    class; documented differences: the class name (isa(mdl, 'GeneralizedLinearModel') is
%    false), Formula holds the formula text instead of a formula object, and methods other
%    than coefCI, predict and disp (for example plotResiduals, step, anova, compact) are not
%    defined, so calling one raises MATLAB's error naming it; ModelCriterion and the residual types
%    other than Raw and Pearson are not provided. coefCI uses t(DFE) quantiles, as
%    MathWorks does for every distribution. predict accepts a table with the predictor
%    variables, or a numeric matrix with one column per predictor (continuous predictors
%    only), and returns the response scale (probabilities for the binomial model).
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
        Deviance
        LogLikelihood
        Dispersion
        DispersionEstimated
        Distribution
        Formula
        Variables
        ObservationInfo
        Fitted
        LikelihoodPenalty
        Residuals
        NumPredictors
        NumVariables
        VariableNames
    end

    properties (SetAccess = private, Hidden)
        ResponseName
        PredictorNames
        DesignInfo
        Terms
        SSE
        SST
        Deviance0
    end

    methods
        function mdl = cobraGeneralizedLinearModel(values)
            % Creates the object from the structure of results assembled by cobraFitglm
            names = fieldnames(values);
            for k = 1:numel(names)
                mdl.(names{k}) = values.(names{k});
            end
        end

        function ci = coefCI(mdl, alpha)
            % Confidence intervals of the coefficients: Estimate +- tinv(1 - alpha/2, DFE)*SE
            if ~exist('alpha', 'var') || isempty(alpha)
                alpha = 0.05;
            end
            halfWidth = cobraTinv(1 - alpha / 2, mdl.DFE) * mdl.Coefficients.SE;
            ci = [mdl.Coefficients.Estimate - halfWidth, mdl.Coefficients.Estimate + halfWidth];
        end

        function yPredicted = predict(mdl, newData)
            % Predicted response (response scale) for a table or a matrix of predictor values
            if ~istable(newData)
                if ~isnumeric(newData) || size(newData, 2) ~= numel(mdl.PredictorNames) || any([mdl.DesignInfo.isCategorical])
                    error('COBRA:cobraGeneralizedLinearModel:invalidInput', ...
                        'cobraGeneralizedLinearModel.predict: give a table, or a matrix with one column per (continuous) predictor.');
                end
                newData = array2table(newData, 'VariableNames', mdl.PredictorNames);
            end
            parsed = struct('response', mdl.ResponseName, 'terms', {mdl.Terms});
            design = cobraBuildModelDesign(newData, parsed, mdl.DesignInfo);
            eta = design.X * mdl.Coefficients.Estimate;
            if strcmp(mdl.Distribution.Name, 'Binomial')
                yPredicted = 1 ./ (1 + exp(-eta));
            else
                yPredicted = eta;
            end
        end

        function disp(mdl)
            % Summary in the layout of the MathWorks display
            if strcmp(mdl.Distribution.Name, 'Binomial')
                link = 'logit';
            else
                link = 'identity';
            end
            fprintf('Generalized linear regression model (cobraFitglm):\n    %s(%s) ~ %s\n    Distribution = %s\n\n', ...
                link, mdl.ResponseName, strtrim(extractAfter(mdl.Formula, '~')), mdl.Distribution.Name);
            fprintf('Estimated Coefficients:\n');
            disp(mdl.Coefficients);
            fprintf('%d observations, %d error degrees of freedom\n', mdl.NumObservations, mdl.DFE);
            if mdl.DispersionEstimated
                fprintf('Estimated Dispersion: %.4g\n', mdl.Dispersion);
            else
                fprintf('Dispersion: %g\n', mdl.Dispersion);
            end
            dfModel = mdl.NumEstimatedCoefficients - 1;
            if dfModel > 0
                statistic = mdl.Deviance0 - mdl.Deviance;
                if mdl.DispersionEstimated
                    statistic = statistic / mdl.Dispersion;
                end
                fprintf('Chi^2-statistic vs. constant model: %.4g, p-value = %.3g\n', statistic, cobraChi2cdf(statistic, dfModel, 'upper'));
            end
        end
    end
end
