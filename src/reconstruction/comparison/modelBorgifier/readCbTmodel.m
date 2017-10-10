function Model = readCbTmodel(modelName, Tmodel, varargin)
% Creates COBRA format of a specific model from `Tmodel`.
% (composite database).
% Called by `mergeModelsBorg`, `driveModelBorgifier`, calls `TmodelFields`, `orderModelFieldsBorg`, `organizeModelCool`, `buildRxnEquations`, `ismatlab`, `parseBoolean`.
%
% USAGE:
%
%    Model = readCbTmodel(modelName, Tmodel)
%
% INPUTS:
%    modelName:           Name of an available model (i.e. iAF1260). Available names
%                         can be found by looking in `Tmodel.Models`
%    Tmodel:              Otherwise `Tmodel` will be loaded from path below.
%
% OPTIONAL INPUTS:
%    emptyArrayChoice:    "y" or "n" to remove empty arrays or not
%    'Verbose':           Print progress stamps.
%
% OUTPUTS:
%    Model:         Model in COBRA format.
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

verbose = false ;  % Varaging.
emptyArrayChoice = [] ;
if ~isempty(varargin)
    if sum(strcmp('Verbose', varargin))
        verbose = true ;
    end
    if sum(strcmp('y', varargin))
        emptyArrayChoice = 'y' ;
    end
    if sum(strcmp('n', varargin))
        emptyArrayChoice = 'n' ;
    end
end

%% Declare variables.
% Check to see if model exists.
TmodelNames = fieldnames(Tmodel.Models) ;
modelCheck = 0 ;
while ~modelCheck
    modelCheck = sum(strcmp(modelName, TmodelNames)) ;
    if modelCheck
        if verbose ; fprintf('Extracting %s from Tmodel\n', modelName) ; end
        modelCheck = 1 ;
    else
        fprintf('ERROR: Model %s not found in Tmodel\n', modelName)
        % Print available model names and allow user to rechoose.
        fprintf('The available models are :\n')
        for iName = 1:length(TmodelNames)
            fprintf([TmodelNames{iName} '\n'])
        end
        modelName = input('Input desired model: ', 's') ;
    end
end

% Set name.
Model.description = modelName ;

otherModels = find(cellfun(@isempty, (strfind(TmodelNames, modelName)))) ;

% Get field names.
fields = TmodelFields ;
% Reaction related cell field names.
rxnFields = fields{1} ;
% Reaction related double Fields (which are kept model specific).
rNumFields = fields{2} ;
% Metabolite related cell field names.
metFields = fields{3} ;
% Metabolite related double field names.
mNumFields = fields{4} ;
% All fields that will end up in the Model.
allFields = fields{5} ;

% Identity arrays for desired model.
rxnLog = Tmodel.Models.(modelName).rxns ;
metLog = Tmodel.Models.(modelName).mets ;

%% Extract reaction information.
for iF = 1:length(rxnFields)
    Model.(rxnFields{iF}) = Tmodel.(rxnFields{iF})(rxnLog) ;
end
for iF = 1:length(rNumFields)
    Model.(rNumFields{iF}) = Tmodel.(rNumFields{iF}).(modelName)(rxnLog);
end

% Remove information from other models for grRules.
% Find where the rull starts for the model.
% searchStringStart = ['(?<=(^|\|)' modelName ':).*'] ;
grRulesStart = regexp(Model.grRules, modelName ) ; %searchStringStart) ;
fixGrRulesStart = @(startpos, shift) not(isempty(startpos)) * (startpos + shift) ;
grRulesStart = cellfun(@(startpos, shift)fixGrRulesStart(startpos, shift), ...
                        grRulesStart, repmat({length(modelName) + 1}, ...
                        size(grRulesStart)), 'Uniformoutput',false) ;
ruleIndexes = find(~cellfun(@isempty,grRulesStart)) ;
% Find where information for other models starts, if it is after the
% information for this model.
searchStringEnd = ['(?<=' modelName '.*).('] ;
for iMo = 1:length(otherModels)
    if iMo ~= 1
        searchStringEnd = [searchStringEnd '|'] ;
    end
    searchStringEnd = [searchStringEnd '\|'...
                        TmodelNames{otherModels(iMo)}] ;
end
searchStringEnd = [searchStringEnd '):'] ;
grRulesEnd = regexpi(Model.grRules,searchStringEnd, 'once') ;
% Clear gene rules and rebuild.
grRulesHold = Model.grRules ;
Model.grRules(:) = {''} ;
% Only include information from between the index where information starts
% and where it end.
for iRxn = 1:length(ruleIndexes)
    % if there was no ending index, set it as the length of the string.
    if isempty(grRulesEnd{ruleIndexes(iRxn)})
        grRulesEnd{ruleIndexes(iRxn)} = ...
            length(grRulesHold{ruleIndexes(iRxn)}) ;
    end
    Model.grRules{ruleIndexes(iRxn)} = ...
        grRulesHold{ruleIndexes(iRxn)} ...
            (grRulesStart{ruleIndexes(iRxn)}: ...
            grRulesEnd{ruleIndexes(iRxn)}) ;
end

% Clean up rxnID also. This is really key, beacause we need the original
% IDs to compare the removed model to the model before it was merged.
if ismatlab
    searchString = ['(?<=(^|\|)' modelName ':)[^\|]*'] ;
    IDs = regexpi(Model.rxnID, searchString, 'match') ;
else
    for ir = 1:length(Model.rxnID)
        nowID = Model.rxnID{ir} ;
        startpos = min(strfind(nowID, modelName) + length(modelName) + 1) ;
        endpos =   strfind(nowID, '|') -1 ;
        endpos = min(endpos(endpos > startpos)) ;
        IDs{ir} = nowID(startpos:endpos) ;
    end
end
IDIndexes = find(~cellfun(@isempty, IDs)) ;
for iRxn = 1:length(IDIndexes)
    Model.rxnID{IDIndexes(iRxn)} = char(IDs{iRxn}) ;
end

%% Extract metabolite information.
Model.mets = Tmodel.mets(metLog) ;
for iF = 1:length(metFields)
    Model.(metFields{iF}) = Tmodel.(metFields{iF})(metLog) ;
end
for iF = 1:length(mNumFields)
    Model.(mNumFields{iF}) = Tmodel.(mNumFields{iF})(metLog) ;
end

% Clean up metID
if ismatlab
    searchString = ['(?<=(^|\|)' modelName ':)[^\|]*'] ;
    IDs = regexpi(Model.metID, searchString, 'match') ;
else
    for ir = 1:length(Model.metID)
        nowID = Model.metID{ir} ;
        startpos = min(strfind(nowID, modelName) + length(modelName) + 1) ;
        endpos =   strfind(nowID, '|') -1 ;
        endpos = min(endpos(endpos > startpos)) ;
        IDs{ir} = nowID(startpos:endpos) ;
    end
end
IDIndexes = find(~cellfun(@isempty, IDs)) ;
for iMet = 1:length(IDIndexes)
    Model.metID{IDIndexes(iMet)} = char(IDs{iMet}) ;
end

%% Construct S Matrix.
Model.S = Tmodel.S(metLog, rxnLog) ;

%% Rebuild reaction equations (as bounds are different per Model)
Model = buildRxnEquations(Model) ;

%% Extract gene information.
if isfield(Tmodel.Models.(modelName), 'genes')

    nRxns = length(Model.rxns) ;

    allGenes = Tmodel.Models.(modelName).genes ;
    Model.genes = allGenes ; % put in model for saving.
    genesByRxn = cell(nRxns, 1) ;

    % Construct rules cell array
    rules = cell(nRxns, 1) ;
    rules(:) = {''} ;

    % Convert grRules to rules format and pull out genes per reaction.
    for iRxn = 1:nRxns
       [genesByRxn{iRxn}, rules{iRxn}] = parseBoolean(Model.grRules{iRxn});
    end

    % Construct gene to rxn mapping.
    rxnGeneMat = sparse(nRxns,length(allGenes)) ;

    % but only make the rules if there are grRules.
    if sum(rxnGeneMat) > 0
        fprintf('Building rxnGeneMat.\n');
        for i = 1:nRxns
            if iscell(genesByRxn{i})
                [~, geneInd] = ismember(genesByRxn{i}, allGenes);
            else
                [~, geneInd] = ismember(num2cell(genesByRxn{i}), allGenes);
            end

            if geneInd > 0
                rxnGeneMat(i, geneInd) = 1;
                for j = 1:length(geneInd)
                    rules{i} = strrep(rules{i}, ['x(' num2str(j) ')'], ...
                        ['x(' num2str(geneInd(j)) '_TMP_)']);
                end
                rules{i} = strrep(rules{i}, '_TMP_', '');
            else
                rules{i} = '' ;
            end
        end

        % Put things in the model.
        Model.rules = rules ;
        Model.rxnGeneMat = rxnGeneMat ;
    end
end

%% Remove all empty cell arrays.
if isempty(emptyArrayChoice)
    choice = input('Remove empty cell arrays? (y/n): ', 's') ;
else
    choice = emptyArrayChoice ;
end
if strcmpi(choice,'y') || strcmpi(choice, 'yes')
    if verbose ; fprintf('Removing empty cell arrays:\n') ; end
    for iF = 1:length(allFields)
        % Only remove the cell array fields.
        if isfield(Model, allFields{iF})
            if iscell(Model.(allFields{iF}))
                if cellfun(@isempty, Model.(allFields{iF}))
                    Model = rmfield(Model, allFields{iF}) ;
                    if verbose ; fprintf([allFields{iF} '\n']) ; end
                end
            end
        end
    end
end

%% Order model.
Model = orderModelFieldsBorg(Model) ;
Model = organizeModelCool(Model) ;
