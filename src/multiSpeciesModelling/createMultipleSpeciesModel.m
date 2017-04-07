function [modelJoint] = createMultipleSpeciesModel(models,nameTagsModels,modelHost,nameTagHost)
% Based on the implementation from *Klitgord and Segre 2010, PMID 21124952*.
% The present implementation has been used in *PMID 23022739*, *PMID 25841013*,
% *PMID 25901891*, *PMID 27893703*.
%
% Joins one or more COBRA models with or without another COBRA model
% representing the host.
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
%    [modelJoint] = createMultipleSpeciesModel(models, nameTagsModels, modelHost, nameTagHost)
%
% INPUTS:
%    models:     cell array of COBRA models(at least one).
%                Format
%                   * models{1,1} = model 1
%                   * models{2,1} = model 2...
%
% OPTIONAL INPUTS:
%    nameTagsModels:    cell array of tags for reaction/metabolite abbreviation
%                       corresponding to each model.
%                       Format
%                           * nameTagsModels{1,1} = 'name tag 1'
%                           * nameTagsModels{2,1} = 'name tag 2'...
%    modelHost:         COBRA model for host
%    nameTagHost:       string of tag for reaction/metabolite abbreviation of host model
%
% OUTPUT:
%    modelJoint:        model structure for joint model
%
% .. Authors:
%       - Ines Thiele and Almut Heinken, 2011-2017 Last edited by A.H., 01.03.2017
%


if isempty(models)
   error('Please enter at least one model!')
end
% prepare the model structures and assign name tags for each model structure if not provided
modelNumber = size(models, 1);

if nargin < 2 || isempty(nameTagsModels)
    % assign default name tags for microbes
    for i = 1:modelNumber
        nameTagsModels{i, 1} = strcat('model', num2str(i), '_');
    end
else
    if size(nameTagsModels, 1) ~= modelNumber
        error('Number of name tags and joint models needs to be identical!')
    end
end

if nargin == 3
    % assign default name tag for host
    nameTagHost = 'Host_';
end

%% define some variables
eTag = 'u';
exTag = 'e';
% find exchange reactions for models, but leaves demand and sink reactions
% do this for all models to be added, remove exchange reactions from host while leaving demand and sink reactions

for i = 1:modelNumber
    % a new model each turn
    model = models{i, 1};
    % find exchange reactions and external metabolites
    exmod = model.rxns(strmatch('EX', model.rxns));
    %remove all previously defined exchange reactions
    model = removeRxns(model, exmod);
    % make sure the exchange reactions and changed model are saved under correct name
    modelStorage(i, 1) = model;
end

if nargin >= 3
    %% with a host
    exmod = modelHost.rxns(strmatch('EX', modelHost.rxns));

    % modelHost = removeRxns(modelHost,ExRH);
    % ExRH = modelHost.rxns(selExcH);
    % ExRH(strmatch('sink',modelHost.rxns(selExcH)))=[];
    % ExRH(strmatch('DM',modelHost.rxns(selExcH)))=[];

    % create a new extracellular space for host
    for i = 1:length(modelHost.mets)
        if ~isempty(strfind(modelHost.mets{i}, '[e]'))
            % find all reactions associated - copy and rename
            ERxnind = find(modelHost.S(i, :));
            ERxnForm = printRxnFormula(modelHost, modelHost.rxns(ERxnind), false);
            ERxnForm = regexprep(ERxnForm, '\[e\]', '\[b\]');
            for j = 1:length(ERxnForm)
                [modelHost,rxnIDexists] = addReaction(modelHost,...
                                                      strcat(modelHost.rxns{ERxnind(j)}, 'b'), ERxnForm{j}, [], modelHost.rev(ERxnind(j)), ...
                                                      modelHost.lb(ERxnind(j)), modelHost.ub(ERxnind(j)), modelHost.c(ERxnind(j)), 'Host exchange', '', '', '', false);
            end
        end
    end

    % remove exchange reactions from host while leaving demand and sink reactions
    modelHost = removeRxns(modelHost, exmod);

    %% create intercellular space
    % will need to find all extracellular metabolites and duplicate reactions
    % if a host model was input, create the shared compartment for the microbes
    model = modelStorage(1, 1);
    nameTag = nameTagsModels{1, 1};
    [modelJoint, MexGJoint] = createInterSpace(model, nameTag, eTag, exTag);

    % if more than one microbe was input
    if modelNumber > 1
        for i = 1:modelNumber
            model = modelStorage(i, 1);
            nameTag = nameTagsModels{i, 1};
            [model, MexG] = createInterSpace(model, nameTag, eTag, exTag);
            % make sure the changed model is saved under correct name
            modelStorage(i, 1) = model;
            MexGJoint = union(MexG, MexGJoint);
        end
     end

    [modelHost,MexGHost] = createInterSpace(modelHost, nameTagHost, eTag, exTag);
    MexGJoint = union(MexGJoint, MexGHost);

    %% merge the models
    % if more than one microbe was input
    if modelNumber > 1
        for i = 2:modelNumber
            model = modelStorage(i, 1);
            [modelJoint] = mergeTwoModels(modelJoint, model, 1, 0);
        end
    end
    [modelJoint] = mergeTwoModels(modelJoint,modelHost, 1, 0);

    modelJoint = addExchangeRxn(modelJoint, unique(MexGJoint));

else
    %% without a host
     % create the shared compartment for the microbes
    model = modelStorage(1, 1);
    nameTag = nameTagsModels{1, 1};
    [modelJoint, MexGJoint] = createInterSpace(model, nameTag, eTag, exTag);
     if modelNumber > 1
        for i = 2:modelNumber
            model = modelStorage(i, 1);
            nameTag = nameTagsModels{i, 1};
            [model, MexG] = createInterSpace(model, nameTag, eTag, exTag);
            modelStorage(i, 1)=model;
            MexGJoint = union(MexG, MexGJoint);
        end
     end

     if modelNumber > 1
        for i = 2:modelNumber
            model = modelStorage(i, 1);
            [modelJoint] = mergeTwoModels(modelJoint, model, 1);
        end
     end

    modelJoint = addExchangeRxn(modelJoint, unique(MexGJoint));
end
end

%%
function [modelNew,MexG] = createInterSpace(model, nameTag, eTag, exTag)
% create intercellular space
% will need to find all extracellular metabolites and duplicate reactions using them

ExR = [];
SpR = [];
modelNew = model;
cnt = 1;

% add name tag to all metabolites and reactions in model
modelNew.mets = strcat(nameTag, model.mets);
modelNew.rxns = strcat(nameTag, model.rxns);

for i = 1:length(modelNew.mets)
    if ~isempty(strfind(modelNew.mets{i}, strcat('[', exTag, ']')))
        % add diffusion reactions into extracellular space
        Mex = modelNew.mets{i};
        MexG{cnt} = regexprep(modelNew.mets{i}, strcat('\[', exTag, '\]'), strcat('\[', eTag, '\]'));

        % remove nameTag from metabolites
        MexG{cnt} = regexprep(MexG{cnt}, nameTag, '');
        [modelNew, rxnIDexists] = addReaction(modelNew, ...
                                              strcat(nameTag, 'IEX_', MexG{cnt}, 'tr'), {Mex MexG{cnt}}, [-1 1], 1, ...
                                              -1000, 1000, 0, 'Transport, intercellular', '', '', false, false);
        cnt = cnt + 1;

    elseif ~isempty(strfind(modelNew.mets{i}, 'biomass[c]'))
        % add diffusion reactions into extracellular space
        Mex = modelNew.mets{i};
        MexG{cnt} = regexprep(modelNew.mets{i}, strcat('\[', exTag, '\]'), strcat('\[', eTag, '\]'));

        % remove nameTag from metabolites
        MexG{cnt} = regexprep(MexG{cnt}, nameTag, '');
        [modelNew, rxnIDexists] = addReaction(modelNew,...
                                              strcat(nameTag, 'IEX_', MexG{cnt}, 'tr'), {Mex MexG{cnt}}, [-1 1], 1, ...
                                              -1000, 1000, 0, 'Transport, intercellular', '', '', false, false);

        cnt = cnt + 1;
    else
        continue;
    end
end
% add exchange reactions
end
