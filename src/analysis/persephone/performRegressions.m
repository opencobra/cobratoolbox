function [results,regressions] = performRegressions(data,metadata,formula,exponentiateLogOdds)
% This functions performs linear or logistic regressions on either flux
% data or microbial relative abundances. The function supports control
% variables & moderators in the regression formulae. 
%
% USAGE:
%    results = performRegressions(data,metadata,formula)
% 
% INPUT
% data:     Table with flux or microbiome data. The first column must be the ID
%           column.
% metadata: Metadata table. The first column must be the ID column.
% formula: Must contain either "Flux or "relative_abundance" as predictor.
% exponentiateLogOdds: Logical variable on if a logistic regression estimate
% should be exponentiately to obtain the odds ratios.
%
% .. Author:
%       - Tim Hensen, 2024
%       - Tim Hensen, May 2025, Added support for unnested mixed effect regressions.

if nargin < 4
    exponentiateLogOdds = false;
end

% Check if formula is correct
if contains(formula,'Flux')
    value = 'Flux';
    name = 'Reaction';
elseif contains(formula,'relative_abundance')
    value = 'relative_abundance';
    name = 'Taxa';
else
    error('Please add correct formula input')
end

% Get names of metabolites or taxa
names = data.Properties.VariableNames;
names(matches(names,'ID'))=[];

% Stack
data = stack(data,names,'NewDataVariableName',value,'IndexVariableName',name);
data.ID = strrep(data.ID,'HM_','');
% combine with metadata
if ~isequal(class(data.ID), class(metadata.ID))
    [data.ID, metadata.ID] = deal(string(data.ID), string(metadata.ID));
end

data = innerjoin(data,metadata,'Keys','ID');

% Filter on variables included in the formula

% Find response and predictors 
includedVars = strtrim(strsplit(formula,'[+\|*]','DelimiterType','RegularExpression'));
variables = [strtrim(strsplit(includedVars{1},'~')) includedVars(2:end)];
response = variables(1);
predictors = variables(2:end);
% Remove moderator term (defined by use of ":") from predictors
predictors = predictors(~contains(predictors, ":"));

% Test if a random effect is encoded in the formula
mixedEffectRegression = false;
randomEffect = regexp(formula,'(?<=\|).*?(?=\))','match'); % Find random effect
if ~isempty(randomEffect)
    mixedEffectRegression = true;
    % Add random effect to predictors of interest
    predictors = predictors(~contains(predictors, ["(1",")"])); 
    predictors = [predictors,randomEffect];
end

% Check if regression should be linear or logistic

respVarData = data.(string(response));
if numel(unique(respVarData))==2  
    if ~isa(response,'double')     
        % Convery response variable data to numerical data
        data.(string(response)) = grp2idx(categorical(data.(string(response))))-1;
        responseDistribution = 'binomial';
    else
        responseDistribution = 'binomial';
    end
else
    responseDistribution = 'normal';
end

respVarData = data.(string(response));
if ~isnumeric(respVarData)
    if numel(unique(respVarData)) > 2
        error('Persephone does not support multinomial logistic regressions (see doc fitmnr)')
    else
        error('Make sure that that there is more than one category in the response variable.')
    end
end

% Filter on variables of interest
includedVars = [{name} response predictors];
data = data(:,includedVars);

% Find metabolite groups
[groups,groupnames] = findgroups(data.(name));
groupnames = string(groupnames);
fieldNames = matlab.lang.makeValidName(groupnames);

% Check current matlab version. Perform firth regression for improved
% robustness if the matlab version is above 2024b.

% Find current matlab version
matlabVersion = ver;
matlabVersion = str2double(string({matlabVersion.Version}'));

firthRegression = false;
if matlabVersion(1)>=24.2 % Check if the current matlab version is greater than 2024b
    firthRegression = true;
end

% Perform regressions
regressions = struct;
for i = 1:length(unique(groups))
    lastwarn('')
    if mixedEffectRegression == true % Perform mixed effect regression
        try % If no fit could be found, fitglme does not output an empty variable. This is hardcoded here.
            mdl = fitglme(data(groups==i,:),formula,'Distribution',responseDistribution);
        catch ME
            mdl = {};
        end
    end

    if mixedEffectRegression == false && firthRegression == true % Perform regression with jeffreys-prior penalty for improved robustness
        mdl = fitglm(data(groups==i,:),formula,'Distribution',responseDistribution,'LikelihoodPenalty','jeffreys-prior'); % Firth's regression
    end

    if mixedEffectRegression == false && firthRegression == false % Perform regression
        mdl = fitglm(data(groups==i,:),formula,'Distribution',responseDistribution);
    end     

    % If no good fit could be found, do not save the result
    warnMsg = lastwarn;
    if ~isempty(warnMsg)
        regressions.(fieldNames(i)) = {};
    else
        regressions.(fieldNames(i)) = mdl;
    end
end

% Assuming a logistic regression, create the following table

% Create empty table
varNames = {name,'Formula','Predictor','Regression type','N','estimate','low','high','SE','tStat','pValue','FDR','R2'};
varTypes = [repmat({'string'},1,4),repmat({'double'},1,length(varNames)-4)];
generalTable = table('Size',[length(groupnames),length(varNames)],'VariableTypes',varTypes,'VariableNames',varNames);

% Prefill table
% formula4table = [mdl.Formula.ResponseName, '~', mdl.Formula.LinearPredictor];
generalTable.Formula = repmat(formula,length(generalTable.(string(name))),1);
generalTable.('Regression type') = repmat(string(responseDistribution),length(generalTable.(string(name))),1);

% Find the first non empty field in the regressions variable
nonEmptyResults = find(~structfun(@isempty,regressions));

% Preallocate structure
results = struct;
predictor = 'NotDefined';

% Get the number of predictors in the data
if ~isempty(nonEmptyResults)
    predictors = regressions.(fieldNames(nonEmptyResults(1))).CoefficientNames(2:end);


    for j=2:length(predictors)+1
        % Populate tables 
        predictorTable = generalTable;
        for i=1:length(fieldNames)
            mdl = regressions.(fieldNames(i));
            % Check if a result could be found
            if ~isempty(mdl)
                % Find predictor name
                predictor = string(matlab.lang.makeValidName(mdl.CoefficientNames(j)));
            
                % Add feature name
                predictorTable.(name)(i) = string(mdl.Variables.(name)(1));
                
                % Add sample number
                predictorTable.N(i) = mdl.NumObservations;
                % Add regression estimate
                if mixedEffectRegression == true
                    predictorTable{i,{'estimate','SE','tStat','pValue'}} = ...
                        double(mdl.Coefficients(j, {'Estimate','SE','tStat','pValue'}));
                else
                    predictorTable{i,{'estimate','SE','tStat','pValue'}} = mdl.Coefficients{j,:};
                end
                % Add 95% CI for predictor
                ci=coefCI(mdl);
                predictorTable{i,{'low','high'}} = ci(j,:);
                % Calculate odds ratios if responseDistribution = 'binomial'
                if matches(responseDistribution,'binomial')
                    if exponentiateLogOdds
                        predictorTable{i,{'estimate','low','high'}} = exp(predictorTable{i,{'estimate','low','high'}});
                    else
                        predictorTable{i,{'estimate','low','high'}} = predictorTable{i,{'estimate','low','high'}};
                    end
                end
    
                % Add adjusted R2
                predictorTable.R2(i) = mdl.Rsquared.Adjusted;
            else
                % Make the missing data nans
                predictorTable{i,{'N','estimate','low','high','SE','tStat','pValue','FDR','R2'}}=nan;
                predictorTable.(name)(i) = fieldNames(i);
            end
        end
        
        % Add FDR values 
        % predictorTable.FDR = mafdr(predictorTable.pValue,'BHFDR',true);
        predictorTable.FDR = fdrBHadjustment(predictorTable.pValue); % Local alternative. 

        % Sort by significance
        predictorTable = sortrows(predictorTable,'pValue','ascend');
    
        % Add predictor
        predictorTable.Predictor = repmat(predictor,length(predictorTable.(string(name))),1);
    
        % Add result to structure
        results.(predictor) = predictorTable;
    end

else
    results.(predictor) = {'No results'};
    warning('None of the variables could be investigated.')
end
end