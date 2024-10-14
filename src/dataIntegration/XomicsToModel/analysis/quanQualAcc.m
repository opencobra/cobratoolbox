function [comparisonData] = quanQualAcc( validationData,predictedFlux, param)

%param.boundPrecisionLimit

if nargin < 3 || isempty(param)
    param = struct;
end
load(which('Recon3_3.mat'));
model = Recon3_3;
% Add default parameters
if ~isfield(param, 'boundPrecisionLimit')
    feasTol = getCobraSolverParams('LP', 'feasTol');
    param.boundPrecisionLimit = feasTol * 10;
end

if iscell(validationData.mean)
    validationData.mean = str2double(validationData.mean);
end
if iscell(validationData.SD)
    validationData.SD = str2double(validationData.SD);
end

% Experimental mean (experimentalMean < boundPrecisionLimit are considered as zero)
experimentalMean = validationData.mean;

% Identify secretions and uptakes present in the model
exoMetRxnsIdx = ismember(validationData.rxns, model.rxns);

% Secretions
rxnTargetSecList = validationData.rxns((experimentalMean - validationData.SD) > 0 & exoMetRxnsIdx);
rxnTargetSec_mean = validationData.mean((experimentalMean - validationData.SD) > 0 & exoMetRxnsIdx);
rxnTargetSec_SD = validationData.SD((experimentalMean - validationData.SD) > 0 & exoMetRxnsIdx);

% Uptakes
rxnTargetUptList = validationData.rxns((experimentalMean + validationData.SD) < 0 & exoMetRxnsIdx);
rxnTargetUpt_mean = validationData.mean((experimentalMean + validationData.SD) < 0 & exoMetRxnsIdx);
rxnTargetUpt_SD = validationData.SD((experimentalMean + validationData.SD) < 0 & exoMetRxnsIdx);

% Unchanged
rxnTargetUnList = validationData.rxns(exoMetRxnsIdx & ...
    (experimentalMean + validationData.SD) > 0 & ...
    (experimentalMean - validationData.SD) < 0);
rxnTargetUn_mean = validationData.mean(exoMetRxnsIdx & ...
    (experimentalMean + validationData.SD) > 0 & ...
    (experimentalMean - validationData.SD) < 0);
rxnTargetUn_SD = validationData.SD(exoMetRxnsIdx & ...
    (experimentalMean + validationData.SD) > 0 & ...
    (experimentalMean - validationData.SD) < 0);
% Prepare the table with the accuracy data
nRows = length(rxnTargetSecList) + length(rxnTargetUnList) + length(rxnTargetUptList);
varTypes = {'string', 'double', 'double', 'double', 'double', 'double', 'double', 'double'};
varNames = {'rxns', 'mean', 'SD', 'target', 'v', 'predict', 'agree', 'dv'};
fullReport = table('Size', [nRows length(varTypes)], 'VariableTypes', varTypes, 'VariableNames', varNames);

% Analysis of flux predictions
fullReport.rxns = [rxnTargetUptList; rxnTargetUnList; rxnTargetSecList];
fullReport.mean = [rxnTargetUpt_mean; rxnTargetUn_mean; rxnTargetSec_mean];
fullReport.SD = [rxnTargetUpt_SD; rxnTargetUn_SD; rxnTargetSec_SD];

target = sign(fullReport.mean);
%if (experimentalMean + validationData.SD) > 0 & (experimentalMean - validationData.SD) < 0
%consider the value to be unreliable to determine uptake or secretion and
%assign NA
target(ismember(fullReport.rxns,rxnTargetUnList)) = 2;
%mean experimental uptake rates below precision limit
%considered zero
target(abs(fullReport.mean) < param.boundPrecisionLimit) = 0;
fullReport.target = target;

fluxRxn = predictedFlux;
%fullReport.v = fluxRxn(findRxnIDs(model,fullReport.rxns));
[Bout,LIBkey,LOCAkey] = mapAontoB(fluxRxn.rxns,fullReport.rxns,fluxRxn,fullReport);
fullReport.v(LIBkey) = fluxRxn.v(LOCAkey(LIBkey));
predict = sign(fullReport.v);
%if the predicted flux magnitude is below fluxEpsilon,
%the predicted flux is considered zero
predict(abs(predict) < param.boundPrecisionLimit) = 0;
fullReport.predict = predict;

fullReport.agree = fullReport.target == fullReport.predict;
fullReport.dv = abs(fullReport.mean - fullReport.v);

%% Flux prediction accuracy

nRows = 1;
varTypes = {'double', 'double', 'double'};
varNames = {'wEuclidNorm', 'accuracy', 'Spearman'};
comparisonStats = table('Size', [nRows length(varTypes)], 'VariableTypes', varTypes, 'VariableNames', varNames);

%v = fullReport.v;
dv = fullReport.dv;
vExp = fullReport.mean;
bool = ~(isoutlier(dv) | isnan(dv) | isnan(vExp));
w  = sparse(1./(1 + (vExp.^2)));
if any(bool)
    comparisonStats.wEuclidNorm = sqrt(dv(bool)' * diag(w(bool)) * dv(bool));
else
    comparisonStats.wEuclidNorm = NaN;
end
% confusionMatrix
C = confusionmat(fullReport.target, fullReport.predict, 'ORDER',[2,1, 0, -1]);
comparisonStats.qualAccuracy = sum(diag(C), 1) / sum(sum(C, 1));

if isnan(comparisonStats.wEuclidNorm)
    pause(0.1)
end

%spearman rank
[comparisonStats.Spearman,comparisonStats.SpearmanPval] = corr(fullReport.mean(isfinite(fullReport.mean)),fullReport.v(isfinite(fullReport.v)),'Type','Spearman');

comparisonData.fullReport = fullReport;
comparisonData.comparisonStats = comparisonStats;
end