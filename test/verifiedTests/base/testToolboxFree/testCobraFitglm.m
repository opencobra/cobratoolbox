% The COBRAToolbox: testCobraFitglm.m
%
% Purpose:
%     - cobraFitglm is the plain-MATLAB replacement for fitglm (Statistics and Machine Learning
%       Toolbox) with table input, normal and binomial distributions and Firth's penalty, as
%       used by performRegressions. This test checks the MathWorks documentation example
%       (logistic regression on the base-MATLAB data set patients, published coefficient table),
%       a PERSEPHONE-like table (continuous flux, string sex with the first-appearance reference,
%       continuous confounder) against statsmodels (normal: OLS; binomial: GLM) and a NumPy
%       implementation of Firth's method, separated data (warning without the penalty, finite
%       estimates with it), rank deficiency, missing values, the iteration limit, and the errors
%       for unsupported options.
%
% Function under test:
%     src/base/utilities/toolboxFree/cobraFitglm.m
%
% Tier (Constitution III-Coverage):
%     Tier 1 - no model, no solver, hand-built inputs (patients.mat ships with base MATLAB).
%
% Coverage exemptions:
%     Line 267 (warning after 1000 Firth iterations): a safeguard; no data set found needs more
%     than 1000 Fisher-scoring iterations (the slowest case below, an observation with leverage
%     near 1, converges well within the limit).
%
% Known defects documented (NOT tested, NOT fixed here):
%     None found.
%
% Authors:
%     - Generated for feature 20261111-152503-toolbox-free-remaining, 2026-11-11.

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testCobraFitglm'));
cd(fileDir);

% declare the requirements of this test. A Tier 1 test needs no solver, MATLAB toolbox
% or particular operating system, so none is listed; the call is the standard opening
% of a COBRA test and the place where a requirement would be added later
prepareTest();

relativeError = @(value, reference) abs(value - reference) ./ abs(reference);

%% MathWorks documentation example: logistic regression on patients (published table)

patientsData = load('patients.mat');
patientsTable = table(patientsData.Age, patientsData.Weight, patientsData.Gender, patientsData.Smoker, ...
    'VariableNames', {'Age', 'Weight', 'Gender', 'Smoker'});
mdl = cobraFitglm(patientsTable, 'Smoker ~ Age*Weight*Gender - Age:Weight:Gender', 'Distribution', 'binomial');
% published (5 significant digits): Estimate, SE, tStat, pValue of the seven coefficients
published = [-8.3351 29.02 -0.28722 0.77394; 0.13764 0.70593 0.19498 0.84541; 0.043269 0.15966 0.27101 0.78638; ...
    2.2859 12.424 0.18399 0.85402; -0.00071959 0.0038964 -0.18468 0.85348; -0.020734 0.20681 -0.10025 0.92014; ...
    -0.01216 0.053168 -0.22871 0.8191];
assert(isequal(mdl.CoefficientNames, {'(Intercept)', 'Age', 'Weight', 'Gender_Female', 'Age:Weight', 'Age:Gender_Female', 'Weight:Gender_Female'}));
assert(max(relativeError(mdl.Coefficients{:, :}, published), [], 'all') < 5e-5);
% 100 observations, 93 error degrees of freedom, dispersion 1, chi^2 vs constant 5.07 (p 0.535)
assert(mdl.NumObservations == 100 && mdl.DFE == 93 && mdl.Dispersion == 1 && ~mdl.DispersionEstimated);
assert(abs(mdl.Deviance0 - mdl.Deviance - 5.0657) < 1e-3);

%% PERSEPHONE-like table: normal distribution against statsmodels OLS

% references/g3_regression.py (section glm), statsmodels 0.15.0 OLS on the same deterministic data
i = (1:40)';
flux = sin(0.7 * i) * 3 + i / 10;
age = 20 + mod(7 * i, 31);
isFemale = mod(5 * i, 3) == 0;
sex = repmat("male", 40, 1);
sex(isFemale) = "female";
yNormal = 1.5 + 0.8 * flux - 0.03 * age + 0.6 * isFemale + 0.5 * cos(1.3 * i);
yBinary = double((0.9 * flux - 0.05 * (age - 35) + 0.4 * isFemale + 1.2 * sin(2.1 * i)) > 0.5);
tbl = table(flux, sex, age, yNormal, yBinary, 'VariableNames', {'Flux', 'Sex', 'Age', 'yNormal', 'yBinary'});
mdl = cobraFitglm(tbl, 'yNormal~Flux+Sex+Age', 'Distribution', 'normal');
assert(isequal(mdl.CoefficientNames, {'(Intercept)', 'Flux', 'Sex_female', 'Age'}));
assert(max(relativeError(mdl.Coefficients.Estimate', [1.700173031696861 0.8020632764291107 0.5795626982549485 -0.03566297698337158])) < 1e-12);
assert(max(relativeError(mdl.Coefficients.SE', [0.24730543264027224 0.02381240279507773 0.12360163654319209 0.006482090447278631])) < 1e-12);
assert(max(relativeError(mdl.Coefficients.pValue', [4.794502647368535e-08 8.125383149003535e-29 3.8711445751689075e-05 3.2212070664319324e-06])) < 1e-9);
assert(relativeError(mdl.Rsquared.Ordinary, 0.9709472595920903) < 1e-12 && relativeError(mdl.Rsquared.Adjusted, 0.9685261978914311) < 1e-12);
assert(mdl.DFE == 36 && mdl.DispersionEstimated && strcmp(mdl.Distribution.Name, 'Normal'));

%% binomial distribution against statsmodels GLM (normal-distribution p-values)

% statsmodels 0.15.0 GLM(Binomial): estimates, SE, pValue; deviance 12.328198483196868; R^2 from raw
% residuals 0.7768801547133798, adjusted 0.7582868342728282. IRLS stops when the change of b is
% below 1e-6 relative (MathWorks rule), statsmodels at its own tolerance: 1e-5 relative
mdl = cobraFitglm(tbl, 'yBinary ~ Flux + Sex + Age', 'Distribution', 'binomial');
assert(max(relativeError(mdl.Coefficients.Estimate', [-3.2100204615757253 2.6003549239955523 2.9464614160464024 -0.0002219030264077465])) < 1e-5);
assert(max(relativeError(mdl.Coefficients.SE', [3.570288103462165 1.064252452147396 2.1142575549201448 0.08049560767756372])) < 1e-5);
% a two-sided normal p-value at t = 2.4 multiplies a relative error of t by about 15, hence 1e-4
assert(max(relativeError(mdl.Coefficients.pValue', [0.3686032128865543 0.014551098406540453 0.16343384302168018 0.9978004666388162])) < 1e-4);
assert(relativeError(mdl.Deviance, 12.328198483196868) < 1e-9 && relativeError(mdl.Rsquared.Adjusted, 0.7582868342728282) < 1e-8);
assert(relativeError(mdl.LogLikelihood, -6.164099241598428) < 1e-9);

%% Firth's penalty against a NumPy implementation of the modified score (Heinze and Schemper 2002)

% references/g3_regression.py: estimates [-1.9159293240354487 1.6391823409708777 1.824613905130556
% -0.002782886094598586], SE (inverse Fisher information) [2.7092745366140987 0.5729590205732012
% 1.5389438686429653 0.06468119092373772]; the stopping rule allows about 1e-6 relative
mdl = cobraFitglm(tbl, 'yBinary ~ Flux + Sex + Age', 'Distribution', 'binomial', 'LikelihoodPenalty', 'jeffreys-prior');
assert(max(relativeError(mdl.Coefficients.Estimate', [-1.9159293240354487 1.6391823409708777 1.824613905130556 -0.002782886094598586])) < 1e-6);
assert(max(relativeError(mdl.Coefficients.SE', [2.7092745366140987 0.5729590205732012 1.5389438686429653 0.06468119092373772])) < 1e-6);
assert(strcmp(mdl.LikelihoodPenalty, 'jeffreys-prior'));
% an observation with leverage near 1 (x = 100): the Fisher-scoring iteration converges linearly;
% NumPy reference [-0.32205593 0.01691805] (references/g3_regression.py, section separation);
% with linear convergence the error exceeds the last step (1e-6 relative), hence 1e-4
highLeverage = table([1; 2; 3; 4; 5; 6; 7; 8; 9; 100], [0; 0; 0; 0; 1; 0; 1; 1; 1; 1], 'VariableNames', {'x', 'y'});
lastwarn('');
mdl = cobraFitglm(highLeverage, 'y ~ x', 'Distribution', 'binomial', 'LikelihoodPenalty', 'jeffreys-prior');
[warningMessage, ~] = lastwarn;
assert(isempty(warningMessage) && max(relativeError(mdl.Coefficients.Estimate', [-0.32205593 0.01691805])) < 1e-4);
% for the normal distribution the penalty does not change the least-squares estimates
mdlPenalized = cobraFitglm(tbl, 'yNormal ~ Flux + Sex + Age', 'Distribution', 'normal', 'LikelihoodPenalty', 'jeffreys-prior');
mdlPlain = cobraFitglm(tbl, 'yNormal ~ Flux + Sex + Age');
assert(isequal(mdlPenalized.Coefficients, mdlPlain.Coefficients));

%% separated data: warning without the penalty, finite estimates with it

separated = table((1:10)', double((1:10)' > 5), 'VariableNames', {'x', 'y'});
lastwarn('');
cobraFitglm(separated, 'y ~ x', 'Distribution', 'binomial');
[~, warningId] = lastwarn;
assert(any(strcmp(warningId, {'COBRA:cobraFitglm:PerfectSeparation', 'COBRA:cobraFitglm:IterationLimit'})));
% references/g3_regression.py (section separation): Firth estimates [-5.338572631293112 0.9706495693260205]
lastwarn('');
mdl = cobraFitglm(separated, 'y ~ x', 'Distribution', 'binomial', 'LikelihoodPenalty', 'jeffreys-prior');
[warningMessage, ~] = lastwarn;
assert(isempty(warningMessage) && max(relativeError(mdl.Coefficients.Estimate', [-5.338572631293112 0.9706495693260205])) < 1e-6);
% a tie at the class boundary (x = 1 has both classes) with separated ends also warns
lastwarn('');
cobraFitglm(table([0; 0; 1; 1; 2; 2], [0; 0; 0; 1; 1; 1], 'VariableNames', {'x', 'y'}), 'y ~ x', 'Distribution', 'binomial');
[~, warningId] = lastwarn;
assert(~isempty(warningId));

%% intercept-only model (all terms removed), rank deficiency, missing values, empty data

mdl = cobraFitglm(tbl, 'yNormal ~ Flux - Flux');
assert(strcmp(mdl.Formula, 'yNormal ~ 1') && isequal(mdl.CoefficientNames, {'(Intercept)'}) && abs(mdl.Coefficients.Estimate - mean(yNormal)) < 1e-12);

collinear = table((1:6)', 2 * (1:6)', [1.1; 2.3; 2.9; 4.2; 5.1; 5.8], 'VariableNames', {'a', 'b', 'y'});
lastwarn('');
mdl = cobraFitglm(collinear, 'y ~ a + b');
[~, warningId] = lastwarn;
assert(strcmp(warningId, 'COBRA:cobraFitglm:RankDeficient') && mdl.NumEstimatedCoefficients == 2 && mdl.DFE == 4);
% one of the two collinear coefficients is dropped (estimate 0, SE 0, NaN statistics); which one
% follows the column pivoting (the MathWorks choice is UNCONFIRMED)
dropped = find(mdl.Coefficients.SE == 0);
assert(isscalar(dropped) && ismember(dropped, [2 3]) && mdl.Coefficients.Estimate(dropped) == 0 && isnan(mdl.Coefficients.pValue(dropped)));
% the fitted values are those of the full-rank model y ~ a
assert(max(abs(mdl.Fitted.Response - cobraFitglm(collinear, 'y ~ a').Fitted.Response)) < 1e-12);
withMissing = tbl;
withMissing.Flux(3) = NaN;
withMissing.Sex(5) = missing;
mdl = cobraFitglm(withMissing, 'yNormal ~ Flux + Sex + Age');
assert(mdl.NumObservations == 38 && isequal(find(mdl.ObservationInfo.Missing)', [3 5]) && height(mdl.Variables) == 40);
assert(verifyCobraFunctionError('cobraFitglm', 'inputs', {table(NaN, 1, 'VariableNames', {'x', 'y'}), 'y ~ x'}, ...
    'testMessage', 'cobraFitglm: no observations without missing values.'));

%% errors: unsupported options and values, mixed models, matrix input, binomial response

assert(verifyCobraFunctionError('cobraFitglm', 'inputs', {tbl, 'yNormal ~ Flux', 'Link', 'log'}, ...
    'testMessage', 'cobraFitglm: unsupported option ''Link''.'));
assert(verifyCobraFunctionError('cobraFitglm', 'inputs', {tbl, 'yNormal ~ Flux', 'Distribution'}, ...
    'testMessage', 'cobraFitglm: unsupported option ''Distribution'' (options are name-value pairs).'));
assert(verifyCobraFunctionError('cobraFitglm', 'inputs', {tbl, 'yNormal ~ Flux', 'Distribution', 'poisson'}, ...
    'testMessage', 'cobraFitglm: unsupported option ''Distribution'' value ''poisson'' (use ''normal'' or ''binomial'').'));
assert(verifyCobraFunctionError('cobraFitglm', 'inputs', {tbl, 'yNormal ~ Flux', 'LikelihoodPenalty', 1}, ...
    'testMessage', 'cobraFitglm: unsupported option ''LikelihoodPenalty'' value ''double'' (use ''none'' or ''jeffreys-prior'').'));
assert(verifyCobraFunctionError('cobraFitglm', 'inputs', {tbl, 'yNormal ~ Flux + (1|Sex)'}, ...
    'testMessage', 'cobraFitglm: unsupported option ''random-effects term (1|Sex)'' (mixed models need fitglme).'));
assert(verifyCobraFunctionError('cobraFitglm', 'inputs', {[1 2; 3 4], 'y ~ x'}, ...
    'testMessage', 'cobraFitglm: unsupported option ''matrix input'' (tbl must be a table).'));
assert(verifyCobraFunctionError('cobraFitglm', 'inputs', {tbl, 'yNormal ~ Flux', 'Distribution', 'binomial'}, ...
    'testMessage', 'cobraFitglm: a binomial response must be 0 or 1 (or logical).'));

%% parity with fitglm (only where the Statistics and Machine Learning Toolbox is installed)

if exist('fitglm', 'file') == 2 && license('test', 'Statistics_Toolbox')
    for distribution = {'normal', 'binomial'}
        response = 'yNormal';
        if strcmp(distribution{1}, 'binomial')
            response = 'yBinary';
        end
        formula = [response ' ~ Flux + Sex + Age'];
        mdl = cobraFitglm(tbl, formula, 'Distribution', distribution{1});
        mdlToolbox = fitglm(tbl, formula, 'Distribution', distribution{1});
        assert(isequal(mdl.CoefficientNames, mdlToolbox.CoefficientNames));
        assert(max(abs(mdl.Coefficients{:, :} - mdlToolbox.Coefficients{:, :}) ./ abs(mdlToolbox.Coefficients{:, :}), [], 'all') < 1e-5);
        assert(abs(mdl.Rsquared.Adjusted - mdlToolbox.Rsquared.Adjusted) < 1e-6);
        mdl = cobraFitglm(tbl, formula, 'Distribution', distribution{1}, 'LikelihoodPenalty', 'jeffreys-prior');
        mdlToolbox = fitglm(tbl, formula, 'Distribution', distribution{1}, 'LikelihoodPenalty', 'jeffreys-prior');
        assert(max(abs(mdl.Coefficients{:, :} - mdlToolbox.Coefficients{:, :}) ./ abs(mdlToolbox.Coefficients{:, :}), [], 'all') < 1e-5);
    end
    fprintf('parity with fitglm: passed\n');
else
    fprintf('skipped: Statistics and Machine Learning Toolbox not installed\n');
end

% change the directory
cd(currentDir)
