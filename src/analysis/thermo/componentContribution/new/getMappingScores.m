function mappingScore = getMappingScores(model, trainingModel)
% Finds the best mapping between the model metabolites and the training
% model metabolites, the higher the confidence score, the more reliable the mapping
%
% USAGE:
%
%    mappingScore = getMappingScores(model, trainingModel)
%
% INPUTS:
%    model:            model in a COBRA structure
%                      *.mets
%                      *.metKEGGID
%                      *.model.inchi.standard
%                      *.model.inchi.standardWithStereo
%                      *.model.inchi.standardWithStereoAndCharge
%
%    trainingModel:    training model in a COBRA structure
%                      *.mets
%                      *.metKEGGID
%                      *.inchi.standard
%                      *.inchi.standardWithStereo
%                      *.inchi.standardWithStereoAndCharge
%
%
% OUTPUT:
%    mappingScore:     nMet x nTrainingMet sparse matrix giving best mapping

%TODO remove dependency on fixed mappings
FIXED_MAPPING_TSV_FNAME = 'data/fixed_mappings.tsv';
if ~exist(FIXED_MAPPING_TSV_FNAME, 'file')
    error(['file not found: ', FIXED_MAPPING_TSV_FNAME]);
end

missingStereo = checkForMissingStereo(model, trainingModel);
if ~isempty(missingStereo)
    fprintf('Warning: Estimation inaccuracy may result from missing stereo in InChI for:\n');
    for n = 1:length(missingStereo)
        fprintf('%d.\t%s\n', n, missingStereo{n});
    end
end

fprintf('Mapping model metabolites to training model metabolites\n');

% Map model metabolites to NIST data
fid = fopen(FIXED_MAPPING_TSV_FNAME, 'r');
fgetl(fid); % skip headers: "CID", "metabolite"
fixedMappings = textscan(fid, '%d%s', 'delimiter', '\t');
fclose(fid);

fixedCid = fixedMappings{1};
if isnumeric(fixedCid)
    eval(['fixedCid = {' regexprep(sprintf('''C%05d''; ',fixedCid),'(;\s)$','') '};']);
end
fixedMet = fixedMappings{2};

% create a matrix that has the matching scores for each model met and nist compound
mappingScore = sparse(size(model.mets, 1), length(trainingModel.metKEGGID));
for n = 1:length(model.mets)
    met = model.mets{n}(1:end-3); % the name of the metabolite without the compartment
    mappingScore(n, strcmp(trainingModel.inchi.standard, model.inchi.standard{n})) = 1;
    mappingScore(n, strcmp(trainingModel.inchi.standardWithStereo, model.inchi.standardWithStereo{n})) = 2;
    mappingScore(n, strcmp(trainingModel.inchi.standardWithStereoAndCharge, model.inchi.standardWithStereoAndCharge{n})) = 3;
    training_data_idx = find(strcmp(met, fixedMet), 1);
    if ~isempty(training_data_idx)
        %mappingScore(n, trainingModel.metKEGGID == fixedMappings{1}(training_data_idx)) = 4;
        mappingScore(n, ismember(trainingModel.metKEGGID,fixedCid{training_data_idx})) = 4;
    end
end
