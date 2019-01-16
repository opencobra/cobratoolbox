function [modelJoint] = createMultipleSpeciesModel(models, varargin)
% Based on the implementation from *Klitgord and Segre 2010, PMID 21124952*.
% The present implementation has been used in *PMID 23022739*, *PMID 25841013*,
% *PMID 25901891*, *PMID 27893703*.
%
% Joins one or more COBRA models with or without another COBRA model
% representing the host. The created setup when a host is entered is
% depicted schematically in Figures 1 and 2 in *PMID 27893703*.
%
% Creates a common space u (lumen) through which all cells can feed and exchange metabolites,
% and separate extracellular spaces for all joined models.
% If a host model is entered, a separate compartment `b` (body fluids) which has no
% connection to extracellular space is created for the host. Metabolites can be transported from
% the lumen to `e`, from `e` to the cytosol and from the cytosol to `b`,
% but not from body fluids to the lumen.
%
% USAGE:
%
%    [modelJoint] = createMultipleSpeciesModel(models, 'nameTagsModels', nameTagsModels, 'modelHost', modelHost, 'nameTagHost', nameTagHost)
%
% INPUTS:
%    models:            cell array of COBRA models(at least one).
%                       Format
%
%                         * models{1,1} = model 1
%                         * models{2,1} = model 2...
%
% OPTIONAL INPUTS:
%    nameTagsModels:    cell array of tags for reaction/metabolite abbreviation
%                       corresponding to each model.
%                       Format
%                         * nameTagsModels{1,1} = 'name tag 1'
%                         * nameTagsModels{2,1} = 'name tag 2'...
%    modelHost:         COBRA model for host
%    nameTagHost:       string of tag for reaction/metabolite abbreviation of host model
%    mergeGenesFlag:    If true, the gene associations in both models are
%                       included in the joined model. If false, empty fields are created
%                       instead (default:false). Note: merging genes is time-consuming
%                       and may crash certain models.
%
% OUTPUT:
%    modelJoint:        model structure for joint model
%
% .. Authors:
%       - Ines Thiele and Almut Heinken, 2011-2018
%       - Almut Heinken, 07.02.2018-included option whether or not genes are
%         merged
%       - Almut Heinken, 21.02.2018-fixed compatibility issue with reconstructions
%         from BIGG Models database that have _e instead of [e] as compartment IDs
%       - Almut Heinken, 06.03.2018-changed to parameter-input pairs
%       - Laurent Heirendt, 16/3/2018 - backward compatibility
%       - Almut Heinken, 15.01.2019-fixed compatibility issue with reconstructions
%         from KBase database that have [e0] instead of [e] as compartment IDs
%
% NOTE:
%    This function assumes, that exchange reactions are identified by
%    containing 'EX' in the reaction name and that no other reactions do have this property!

oldOptionalOrder = {'nameTagsModels', 'modelHost', 'nameTagHost', 'mergeGenesFlag'};

% ensure backward compatibility
if numel(varargin) > 0 && ~ischar(varargin{1})
    tempargin = cell(0);
    for i = 1:numel(varargin)
        if ~isempty(varargin{i})
            tempargin{end + 1} = oldOptionalOrder{i};
            tempargin{end + 1} = varargin{i};
        end
    end
    varargin = tempargin;
end

% Define default input parameters if not specified
parser = inputParser();
parser.addRequired('models', @iscell);
parser.addParameter('nameTagsModels', {}, @iscell);
parser.addParameter('modelHost', {}, @isstruct);
parser.addParameter('nameTagHost', '', @(x) ischar(x) || iscell(x))
parser.addParameter('mergeGenesFlag', false, @(x) isnumeric(x) || islogical(x))

parser.parse(models, varargin{:});

models = parser.Results.models;
nameTagsModels = parser.Results.nameTagsModels;
modelHost = parser.Results.modelHost;
nameTagHost = parser.Results.nameTagHost;
mergeGenesFlag = parser.Results.mergeGenesFlag;

if isempty(models)
   error('Please enter at least one model!')
end
% prepare the model structures and assign name tags for each model structure if not provided
modelNumber = size(models, 1);

if isempty(nameTagsModels)
    % assign default name tags for microbes
    for i = 1:modelNumber
        nameTagsModels{i, 1} = strcat('model', num2str(i), '_');
    end
else
    if size(nameTagsModels, 1) ~= modelNumber
        error('Number of name tags and joint models needs to be identical!')
    end
end

if isempty(nameTagHost)
    % assign default name tag for host
    nameTagHost = 'Host_';
end

%% ensure compatibility with reconstructions from BIGG Models database
for i = 1:modelNumber
    model = models{i, 1};
    metIndices =~cellfun(@isempty, regexp(model.mets, '_e$'));
    model.mets(metIndices) = strrep(model.mets(metIndices), '_e', '[e]');
    models{i, 1} = model;
end
if ~isempty(modelHost)
metIndices =~cellfun(@isempty, regexp(modelHost.mets, '_e$'));
modelHost.mets(metIndices) = strrep(modelHost.mets(metIndices), '_e', '[e]');
end

%% Ensure compatibility with reconstructions from KBase database
for i = 1:modelNumber
    model = models{i, 1};
    metIndices =~cellfun(@isempty, regexp(model.mets, '\[e0\]$'));
    model.mets(metIndices) = strrep(model.mets(metIndices), '[e0]', '[e]');
    % need workaround for biomass metabolite, otherwise the resulting joint
    % model will be unable to carry biomass flux
    if ~isempty(find(ismember(model.mets, 'cpd11416[c0]')))
        model = addDemandReaction(model, 'cpd11416[c0]');
    end
    models{i, 1} = model;
end
if ~isempty(modelHost)
metIndices =~cellfun(@isempty, regexp(modelHost.mets, '\[e0\]$'));
modelHost.mets(metIndices) = strrep(modelHost.mets(metIndices), '[e0]', '[e]');
end
%% define some variables
eTag = 'u';
exTag = 'e';
% find exchange reactions for models, but leaves demand and sink reactions
% do this for all models to be added, remove exchange reactions from host while leaving demand and sink reactions
% First, find the minimal number of fields common to all models.
presentinallModels = fieldnames(models{1});
missingFields = {};
for i = 2:modelNumber
    cfields = fieldnames(models{i});
    missingFields = union(missingFields, setxor(cfields, presentinallModels));
    presentinallModels = intersect(presentinallModels, cfields);
end
fprintf('The following fields are missing in several models, they will not be merged:\n');
disp(missingFields);
models = restrictModelsToFields(models, presentinallModels);

modelStorage = cell(modelNumber, 1);
for i = 1:modelNumber
    % a new model each turn
    model = models{i, 1};
    % find exchange reactions and external metabolites
    exmod = model.rxns(strmatch('EX', model.rxns));
    % remove all previously defined exchange reactions
    model = removeRxns(model, exmod);
    % make sure the exchange reactions and changed model are saved under correct name
    modelStorage{i, 1} = model;
end

if ~isempty(modelHost)
    %% with a host
    exmod = modelHost.rxns(strmatch('EX', modelHost.rxns));

    % modelHost = removeRxns(modelHost,ExRH);
    % ExRH = modelHost.rxns(selExcH);
    % ExRH(strmatch('sink',modelHost.rxns(selExcH)))=[];
    % ExRH(strmatch('DM',modelHost.rxns(selExcH)))=[];

    % create a new extracellular space for host
    % find all metabolites in e
    relMetIndex = cellfun(@(x) ~isempty(strfind(x, '[e]')), modelHost.mets);
    relMets = modelHost.mets(relMetIndex);
    relRxns = findRxnsFromMets(modelHost, relMets);  % These are all reactions which are relevant
    rxnIndices = ismember(modelHost.rxns, relRxns);
    Stoich = modelHost.S(:, rxnIndices);
    changedMets = regexprep(modelHost.mets, '\[e\]', '\[b\]');
    modelHost = addMultipleMetabolites(modelHost, setdiff(changedMets, modelHost.mets));
    modelHost = addMultipleReactions(modelHost, strcat(modelHost.rxns(rxnIndices), 'b'), changedMets, Stoich, 'lb', modelHost.lb(rxnIndices), ...
                                    'ub', modelHost.ub(rxnIndices), 'c', modelHost.c(rxnIndices), 'subSystems', repmat({'Host Exchange'}, numel(relRxns), 1));

    % remove exchange reactions from host while leaving demand and sink reactions
    modelHost = removeRxns(modelHost, exmod);

    %% create intercellular space
    % will need to find all extracellular metabolites and duplicate reactions
    % if a host model was input, create the shared compartment for the microbes
    model = modelStorage{1, 1};
    nameTag = nameTagsModels{1, 1};
    [modelJoint, MexGJoint] = createInterSpace(model, nameTag, eTag, exTag);

    % if more than one microbe was input
    if modelNumber > 1
        for i = 1:modelNumber
            model = modelStorage{i, 1};
            nameTag = nameTagsModels{i, 1};
            [model, MexG] = createInterSpace(model, nameTag, eTag, exTag);
            % make sure the changed model is saved under correct name
            modelStorage{i, 1} = model;
            MexGJoint = union(MexG, MexGJoint);
        end
     end

    [modelHost,MexGHost] = createInterSpace(modelHost, nameTagHost, eTag, exTag);
    MexGJoint = union(MexGJoint, MexGHost);

    %% merge the models
    % if more than one microbe was input
    if modelNumber > 1
        for i = 2:modelNumber
            model = modelStorage{i, 1};
            [modelJoint] = mergeTwoModels(modelJoint, model, 1, mergeGenesFlag);
        end
    end
    [modelJoint] = mergeTwoModels(modelJoint,modelHost, 1, mergeGenesFlag);

    modelJoint = addExchangeRxn(modelJoint, unique(MexGJoint));

else
    %% without a host
     % create the shared compartment for the microbes
    model = modelStorage{1, 1};
    nameTag = nameTagsModels{1, 1};
    [modelJoint, MexGJoint] = createInterSpace(model, nameTag, eTag, exTag);
     if modelNumber > 1
        for i = 2:modelNumber
            model = modelStorage{i, 1};
            nameTag = nameTagsModels{i, 1};
            [model, MexG] = createInterSpace(model, nameTag, eTag, exTag);
            modelStorage{i, 1}=model;
            MexGJoint = union(MexG, MexGJoint);
        end
     end

     if modelNumber > 1
        for i = 2:modelNumber
            model = modelStorage{i, 1};
            [modelJoint] = mergeTwoModels(modelJoint, model, 1, mergeGenesFlag);
        end
     end

    modelJoint = addExchangeRxn(modelJoint, unique(MexGJoint));
end
end

%%
function [modelNew,MexG] = createInterSpace(model, nameTag, eTag, exTag)
% create intercellular space
% will need to find all extracellular metabolites and duplicate reactions using them
modelNew = model;
% add name tag to all metabolites and reactions in model
modelNew.mets = strcat(nameTag, model.mets);
modelNew.rxns = strcat(nameTag, model.rxns);
% Get the relevant metabolites
relMetsIndex = cellfun(@(x) ~isempty(strfind(x,'biomass[c]')) || ~isempty(strfind(x,['[', exTag, ']'])),modelNew.mets);
relMets = modelNew.mets(relMetsIndex);
% Define the names of the interspace metabolites
MexG = regexprep(strrep(relMets,nameTag,''),strcat('\[', exTag, '\]'), strcat('\[', eTag, '\]'));
varinput = {};
% Add metNames and metFormulas, if present in the original model
if isfield(modelNew,'metNames')
    varinput{end+1} = 'metNames';
    varinput{end+1} = modelNew.metNames(relMetsIndex);
end
if isfield(modelNew,'metFormulas')
    varinput{end+1} = 'metFormulas';
    varinput{end+1} = modelNew.metFormulas(relMetsIndex);
end
% Add all new Metabolites
modelNew = addMultipleMetabolites(modelNew, MexG, varinput{:});

nExchange = numel(relMets);
% Set the exchanger Stoichiometries (met[e] -> met[u])
stoich = [-speye(nExchange);speye(nExchange)];
% Set the names of the exchangers
rxnNames =  strcat(nameTag, 'IEX_', MexG, 'tr');
% Set the bounds
lbs = repmat(-1000,nExchange,1);
ubs = repmat(1000,nExchange,1);
% Set the subSystem
subSystems = repmat({'Transport, intercellular'},nExchange,1);
% Add all Reactions in one go.
modelNew = addMultipleReactions(modelNew,rxnNames,[relMets;MexG],stoich,'lb',lbs,'ub',ubs,'subSystems',subSystems);

end
