function Stats = TmodelStats(Tmodel, varargin)
% Provides information on `Tmodel`. Can also be used on a normal
% model. Called  by `mergeModelsBorg`, calls `TmodelFields`.
%
% USAGE:
%
%    Stats = TmodelStats(Tmodel, [Stats]) ;
%
% INPUTS:
%    Tmodel:    Model structure
%
% OPTIONAL INPUTS:
%    Stats:     Will add information to current `Stats` structure.
%
% OUTPUTS:
%    Stats:     Stats array that contains weighting information from previous
%               scoring work.
%
% Please cite:
% `Sauls, J. T., & Buescher, J. M. (2014). Assimilating genome-scale
% metabolic reconstructions with modelBorgifier. Bioinformatics
% (Oxford, England), 30(7), 1036?8`. http://doi.org/10.1093/bioinformatics/btt747
%
% ..
%    Edit the above text to modify the response to help addMetInfo
%    Last Modified by GUIDE v2.5 06-Dec-2013 14:19:28
%    This file is published under Creative Commons BY-NC-SA.
%
%    Correspondance:
%    johntsauls@gmail.com
%
%    Developed at:
%    BRAIN Aktiengesellschaft
%    Microbial Production Technologies Unit
%    Quantitative Biology and Sequencing Platform
%    Darmstaeter Str. 34-36
%    64673 Zwingenberg, Germany
%    www.brain-biotech.de

if nargin > 1 % Declare variables. If Stats structure is alread provided.
    Stats = varargin{1} ;
end

% Models included in Tmodel.
if isfield(Tmodel, 'Models')
    modelNames = fieldnames(Tmodel.Models) ;
else
    modelNames = {'model'} ;
end
nModels = length(modelNames) ;

% Get field names.
fields = TmodelFields ;
% Reaction related cell field .
rxnFieldNames = fields{1} ;
% Metabolite related cell field names.
metFieldNames = fields{3} ;

% Number of reactions and metabolites.
nRxns = length(Tmodel.rxns) ;
nMets = length(Tmodel.mets) ;

% Find compartments in model.
% Figure out what compartments are in the model.
compNames = {''} ;
for iMet = 1:length(Tmodel.mets)
    nowComp = Tmodel.mets{iMet}(end - 1) ;
    if ~strcmp(nowComp, compNames)
        if isempty(compNames{1})
            % First compartment found.
            compNames{1} = nowComp ;
        else
            % Additional compartments.
            compNames{length(compNames) + 1, 1} = nowComp ;
        end
    end
end
compNames = sort(compNames) ;


%% Statistics.
% Find availability of reaction information.
Stats.rxnInfo = cell(length(rxnFieldNames), 2) ;
for iField = 1:length(rxnFieldNames)
    Stats.rxnInfo{iField, 1} = rxnFieldNames{iField} ;
    if isfield(Tmodel, rxnFieldNames{iField})
        nowStat = ~cellfun(@isempty, Tmodel.(rxnFieldNames{iField})) ;
        Stats.rxnInfo{iField, 2}(1) = sum(nowStat) ;
        Stats.rxnInfo{iField, 2}(2) = sum(nowStat) / nRxns ;
    else
        Stats.rxnInfo{iField, 2}(1) = 0 ;
        Stats.rxnInfo{iField, 2}(2) = 0 ;
    end
end

% Find availability of metabolite information
Stats.metInfo = cell(length(metFieldNames), 2) ;
for iField = 1:length(metFieldNames)
    Stats.metInfo{iField, 1} = metFieldNames{iField} ;
    if isfield(Tmodel, metFieldNames{iField})
        nowStat = ~cellfun(@isempty, Tmodel.(metFieldNames{iField})) ;
        Stats.metInfo{iField, 2}(1) = sum(nowStat) ;
        Stats.metInfo{iField, 2}(2) = sum(nowStat) / nMets ;
    else
        Stats.metInfo{iField, 2}(1) = 0 ;
        Stats.metInfo{iField, 2}(2) = 0 ;
    end
end

% Frequecy of compartments.
Stats.metsByComp = compNames ;
% Total metabolite with compartment (should be 100%)
Stats.metsByComp{end + 1, 1} = 'Total' ;
Stats.metsByComp{end, 2}(1) = 0 ;
for iComp = 1:length(compNames)
    searchString = ['\[' compNames{iComp} '\]$'] ;
    nMetsInComp = regexp(Tmodel.mets, searchString) ;
    nMetsInComp = sum(~cellfun('isempty', nMetsInComp)) ;
    Stats.metsByComp{iComp, 2}(1) = nMetsInComp ;
    Stats.metsByComp{iComp, 2}(2) = nMetsInComp / nMets ;
    Stats.metsByComp{end, 2}(1) = Stats.metsByComp{end, 2}(1) + nMetsInComp ;
end
Stats.metsByComp{end, 2}(2) = Stats.metsByComp{end, 2}(1) \ nMets ;

% Exchange reactions. (Reactions which only have 1 metabolite.)
nMetsPerRxn = sum(abs(Tmodel.S), 1) ;
nExchangeRxns = length(find(nMetsPerRxn == 1)) ;
Stats.exhangeRxns(1) = nExchangeRxns ;
Stats.exhangeRxns(2) = nExchangeRxns / nRxns ;

% Determining metabolites ignorant of compartment.
metsNoComp = cell(nMets, 1) ;
for iMet = 1:nMets
    metsNoComp{iMet} = Tmodel.mets{iMet}(1:end - 3) ;
end
[uniqMets, uniqFirst] = unique(metsNoComp, 'first') ;
[uniqMets, uniqLast] = unique(metsNoComp, 'last') ;
% Number of unique metabolites.
nMetsNoComp = length(uniqMets) ;
Stats.uniqueMetabolites = nMetsNoComp ;

% Create logical arrays to be passed to nested function.
if nModels > 1
    for iModel = 1:nModels
        % Reactions.
        arrayRxns.(modelNames{iModel}) = ...
            Tmodel.Models.(modelNames{iModel}).rxns ;
        % Metabolies.
        arrayMets.(modelNames{iModel}) = ...
            Tmodel.Models.(modelNames{iModel}).mets ;

        % Metabolites ignorant of compartment.
        metArrayNoComp.(modelNames{iModel}) = true(nMetsNoComp, 1) ;
        for iMet = 1:length(uniqMets)
            % Mark as 0 mets that are not in the model.
            if ~sum(Tmodel.Models.(modelNames{iModel}).mets( ...
                    uniqFirst(iMet):uniqLast(iMet)))
                metArrayNoComp.(modelNames{iModel})(iMet) = false ;
            end
        end
    end

    % Unique and shared reactions.
    Stats.sharedRxns = sharedEntities(arrayRxns) ;
    Stats.sharedMets = sharedEntities(arrayMets) ;
    Stats.sharedMetsNoComp = sharedEntities(metArrayNoComp) ;
end

    % Nested function for determining shared metabolites and reactions.
    % logicalArrays is a structure that contains logical array to compare.
    function shareMatrix = sharedEntities(logicalArrays)
       shareMatrix = cell(nModels + 1) ;
       shareMatrix{1, 1} = '[Count, %]' ;
       % Sum of logical arrays, used to determine unique entities.
       sumArray = zeros(length(logicalArrays), 1) ;
       for xModel = 1:nModels
           sumArray = sumArray + logicalArrays.(modelNames{xModel}) ;
       end
       for xModel = 1:nModels
           % xModel logical reaction array for cleaner code.
           xModelArray = logicalArrays.(modelNames{xModel}) ;
           nEntsIniModel = sum(xModelArray) ;
           % Put in names for easy reading.
           shareMatrix{xModel + 1, 1} = modelNames{xModel} ;
           shareMatrix{1, xModel + 1} = ['in ' modelNames{xModel}] ;
           for yModel = 1:nModels
               if strcmp(modelNames{xModel}, modelNames{yModel})
                   % If model is being compared to itself, find unique
                   % reactions. Subtract iModels logical array from the
                   % sum of all models's logical array, where this is
                   % zero, those reactions are unique to iModel.
                   nUniqEnts = length(find(sumArray - ...
                                           xModelArray == 0)) ;
                   shareMatrix{xModel + 1,yModel + 1}(1) = nUniqEnts ;
                   shareMatrix{xModel + 1,yModel + 1}(2) = nUniqEnts / ...
                                                       nEntsIniModel ;
               else
                   % How many, what % of its reactions are in jModel.
                   yModelArray = logicalArrays.(modelNames{yModel}) ;
                   nSharedEnts = length(find(xModelArray + ...
                                             yModelArray == 2)) ;
                   shareMatrix{xModel + 1, yModel + 1}(1) = nSharedEnts ;
                   shareMatrix{xModel + 1, yModel + 1}(2) = nSharedEnts /...
                                                       nEntsIniModel;
               end
           end
       end
    end
end
