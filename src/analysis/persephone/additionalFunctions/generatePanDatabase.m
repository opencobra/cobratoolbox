function lookupFilePath = generatePanDatabase(inputDir)
% Create lookup file for checking which reactions and metabolites are
% present in which AGORA2 models
%
% OUTPUT
% lookupFilePath        Path to the generated lookup file
%
% Authors:  Tim Hensen, 2024

% Step 1: Find paths to all agora2 models
if isempty(inputDir)
    inputDir = 'AGORA2';
end
modelDir = what(inputDir);

if isempty(modelDir)
    error('Models could not be found')
end

% Find paths to AGORA2 models
modelPaths = string(strcat(modelDir.path,filesep, modelDir.mat));
models = erase(modelDir.mat,'.mat');


% Preallocate cell arrays to store strain data
strainData = cell(1, length(models));

% Start parallel pool on all but two cores
if feature('numCores') > 5
    poolobj = gcp('nocreate');
    if isempty(poolobj)
        parpool(feature('numCores')-4)
    end
end

disp('Obtain reaction and metabolite content for each strain')
parfor (i = 1:length(models))
    disp(i)
    % Step 2: load each strain
    model = load(modelPaths(i));
    model = model.(string(fieldnames(model)));

    % Step 3: Create structure with strain as fieldname and reactions as field content
    strainData{i}.strain = models(i);
    strainData{i}.rxns = erase(model.rxns,append(models{i},'_'));

    % Remove taxon name from metabolite VMHID if present
    mets = erase(model.mets,append(models{i},'_'));


    strainData{i}.mets = mets;
    strainData{i}.S = model.S;
end

% Concatenate strain data into database struct
database = struct;
for i = 1:length(models)
    fname = string(models(i));
    database.(fname) = strainData{i};
end

%%
% Step 4: Create s-matrix of all models combined
disp('Create s-matrix of all models combined')

% Get model names 
modelNames = string(fieldnames(database));

% Get the basis model for the merged s-matrix
panModel = database.(modelNames(1));
%
% Merge the s-matrices of all models
tic
for i=2:length(modelNames)
    %%
    panModel = mergeStoichiometry(panModel, database.(modelNames(i)));
end
toc

% Remove the newMets and newRxns fields
panModel = rmfield(panModel,{'newMets','newRxns'});

%%
% Step 5: Annotate which models contains which reactions and metabolites in
% the merged s-matrix
disp('Annotate merged reactions and metabolites with their original model associations')

% Find which model contains which reactions and metabolites
panModel.modelNames = modelNames;

% Preallocate matrices
panModel.modelNames = modelNames;
numReconstructions = length(modelNames);

% Preallocate local sparse matrices for parallel iterations
rxnPresenceLocal = cell(numReconstructions, 1);
metPresenceLocal = cell(numReconstructions, 1);
panRxns = panModel.rxns;
panMets = panModel.mets;

tic
parfor i = 1:numReconstructions

    % Get model information
    modelInfo = database.(modelNames{i});

    % Find the index of the reaction in database.(modelNames(i)).rxns that
    % is present in panModel.rxns
    [~, locBrxns] = ismember(panRxns, modelInfo.rxns);
    rxnPresenceLocal{i} = locBrxns > 0;

    % Find the index of the metabolite in database.(modelNames(i)).mets
    % that is present in panModel.mets
    [~, locBmets] = ismember(panMets, modelInfo.mets);
    metPresenceLocal{i} = locBmets > 0;

    if i == 1000 || i == 2000 || i == 4000 || i == 6000
        disp(i);
    end
end
toc

% Combine results into the sparse matrices
for i = 1:numReconstructions
    panModel.rxnPresenceInModel(:, i) = rxnPresenceLocal{i};
    panModel.metPresenceInModel(:, i) = metPresenceLocal{i};
end

%%
% Save pan model structure
disp('Save file in current directory')
lookupFilePath = [pwd filesep 'panModel_lookupFile_PD_recreated.mat'];
save(lookupFilePath,'panModel')
end

function model = mergeStoichiometry(model1, model2)
% This function merges the s-matrix from model1 with that of model2. The
% function output contains a structure with 1) the merged s-matrix, 2) a
% list of ordered reactions that map onto each column in the s-matrix, and
% 3) a list of ordered metabolites (VMH IDs) that map onto each row of the
% s-matrix.

% Set model1 as the baseline for the merged model. 
model = struct;
model.rxns = model1.rxns;
model.mets = model1.mets;
model.S = model1.S;

%%% Add metabolites %%%

% Find all metabolites in model 2 that are not in model 1
metsToAdd = setdiff(model2.mets, model.mets); 

% Add metabolites in model 2 that are not in model 1, to model.mets
model.mets = [model.mets; metsToAdd]; 

% Track which metabolites are new
model.newMets = [false(size(model.S,1),1) ; true(numel(metsToAdd),1)];

% Find for model 1 and model 2:
[~,m1RxnIntersectIndex,... % The index of reactions in model 1 that are also in model 2
    m2RxnIntersectIndex... % The index of reactions in model 2 that are also in model 1
    ] = intersect(model.rxns, ... % All reactions in model 1
    model2.rxns, ... % All reactions in model 2
    'stable' ... % Ensure that the reaction order of model 1 is preserved
    );

% Update the model.S as follows:
model.S(model.newMets,... % for all metabolites in model 1 that are not in model 2
    m1RxnIntersectIndex... % and all reactions that overlap between model 1 and model 2.
    ) = model2.S(... % Add the part of the s-matrix from model 2 for  
    matches(model2.mets,metsToAdd),... % all metabolites in model 2 that are not in model 1
    m2RxnIntersectIndex... % and for all reactions both in model 1 and model 2
    ); 

%%% Add reactions %%%

% Find all reactions in model 2 that are not in model 1
rxnsToAdd = setdiff(model2.rxns, model.rxns); 

% Add reactions in model 2 that are not in model 1, to model.rxns
model.rxns = [model.rxns; rxnsToAdd]; 

% Add information on which reactions are new
model.newRxns = [false(size(model.S,2),1) ; true(numel(rxnsToAdd),1)];

% Find for model 1 and model 2:
[~,m1MetIntersectIndex,... % The index of metabolites in model 1 that are also in model 2
    m2MetIntersectIndex... % The index of metabolites in model 2 that are also in model 1
    ] = intersect(model.mets, ... All metabolites in model 1 and model 2
    model2.mets, ... All metabolites in model model 2
    'stable' ... % Ensure that the metabolite order of model 1 is preserved
    );

% Update the model.S as follows:
model.S(m1MetIntersectIndex,... % for all reactions that overlap between model 1 and model 2.
    model.newRxns... % and all reactions in model 1 that are not in model 2
    ) = model2.S(... % Add the part of the s-matrix from model 2 for  
    m2MetIntersectIndex,... % and for all metabolites both in model 1 and model 2
    matches(model2.rxns,rxnsToAdd)... % and for all reactions in model 2 that are not in model 1
    ); 
end


