function lookupFilePath = generatePanAGORA2database()
% Create lookup file for checking which reactions and metabolites are
% present in which AGORA2 strains
%
% OUTPUT
% lookupFilePath        Path to the generated lookup file
%
% Authors:  Tim Hensen, 2024

% Step 1: Find paths to all agora2 strains
inputDir = 'C:\Users\mspg\Documents\parkinson_recreated\ApolloAgora2panSpecies';
agoraDir = what(inputDir);
agoraDir = what('AGORA2');

if isempty(agoraDir)
    error('AGORA2 has not been found')
end

% Find paths to AGORA2 strains
agoraPaths = string(strcat(agoraDir.path,filesep, agoraDir.mat));
strains = erase(agoraDir.mat,'.mat');
strains = strains(1:3);

tic
% Preallocate cell arrays to store strain data
strainData = cell(1, length(strains));

% Start parallel pool on all but two cores
if feature('numCores') > 5
    poolobj = gcp('nocreate');
    if isempty(poolobj)
        parpool(feature('numCores')-2)
    end
end

disp('Obtain reaction and metabolite content for each strain')
for (i = 1:length(strains))
    disp(i)
    % Step 2: load each strain
    model = load(agoraPaths(i));
    model = model.(string(fieldnames(model)));

    % Step 3: Create structure with strain as fieldname and reactions as field content
    strainData{i}.strain = strains(i);
    strainData{i}.rxns = model.rxns;
    strainData{i}.mets = model.mets;
    strainData{i}.S = model.S;
    % strainData{i}.genes = model.genes;
end

% Concatenate strain data into database struct
database = struct;
for i = 1:length(strains)
    fname = strcat('strain_', string(i));
    database.(fname) = strainData{i};
end

toc
%%
% Step 4: Summarise structure to COBRA-like structure
disp('Process strain contents into an efficient data structure')

% Create structure
agoraStruct = struct;

% Find all unique rxns, mets, and genes, and strains
disp('Find the union of reactions, metabolites, and strains')
agoraStruct.rxns = obtainUnion(database, "rxns");
agoraStruct.mets = obtainUnion(database, "mets");
agoraStruct.strains = obtainUnion(database, "strain");
%agoraStruct.genes = obtainUnion(database, "genes"); % TODO: First need to remove
%strain names before this can be enabled

% for each strain, indicate if a rxns, met, or gene is present
disp('Generate sparse matrix indicating which strains contains which reactions and metabolites.')
agoraStruct.rxnPresence = presenceMatrix(database, agoraStruct,"rxns");
agoraStruct.metabolitePresence = presenceMatrix(database, agoraStruct,"mets");
%agoraStruct.genePresence = presenceMatrix(database, agoraStruct,"genes");
%%
% Save agora2 struct
disp('Save file in current directory')
lookupFilePath = [pwd filesep 'AGORA2_lookupFile.mat'];
save(lookupFilePath,'agoraStruct')
end


function union_values = obtainUnion(database, type)
% Get fieldnames
field_names = fieldnames(database);
% Extract vectors from each field using cellfun
all_vectors_cell = cellfun(@(field) database.(field).(type), field_names, 'UniformOutput', false);
% Combine all vectors into one array
combined_vectors = cat(1, all_vectors_cell{:});
% Find the unique values in the combined array
union_values = unique(combined_vectors);
end


function matrix = presenceMatrix(database, agoraStruct,type)
% Create matrix 
matrix = zeros(length(agoraStruct.strains), length(agoraStruct.(type)));
% Check which reactions, metabolites, or genes in AGORA2 are present in the
% current strain
fname = fieldnames(database);
for i=1:length(fname)
    matrix(i,:) = matches(agoraStruct.(type),database.(fname{i}).(type));
end
matrix = sparse(matrix);
end

