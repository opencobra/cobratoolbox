function mappingScore = getMappingScores(model, training_data)
% finds the best mapping between the model compounds and the training data (KEGG) compounds
% INPUTS
%
% OUTPUTS
%
FIXED_MAPPING_TSV_FNAME = 'data/fixed_mappings.tsv';
if ~exist(FIXED_MAPPING_TSV_FNAME, 'file')
    error(['file not found: ', FIXED_MAPPING_TSV_FNAME]);
end

missingStereo = checkForMissingStereo(model, training_data);
if ~isempty(missingStereo)
    fprintf('Warning: Estimation inaccuracy may result from missing stereo in InChI for:\n');
    for n = 1:length(missingStereo)
        fprintf('%d.\t%s\n', n, missingStereo{n});
    end
end

fprintf('Mapping model metabolites to nist compounds\n');

% Map model metabolites to NIST data
fid = fopen(FIXED_MAPPING_TSV_FNAME, 'r');
fgetl(fid); % skip headers: "CID", "metabolite"
fixedMappings = textscan(fid, '%d%s', 'delimiter', '\t');
fclose(fid);

% create a matrix that has the matching scores for each model met and nist compound
mappingScore = sparse(size(model.mets, 1), size(training_data.cids, 2));
for n = 1:length(model.mets)
    met = model.mets{n}(1:end-3); % the name of the metabolite without the compartment
    mappingScore(n, strcmp(training_data.std_inchi, model.inchi.standard{n})) = 1;
    mappingScore(n, strcmp(training_data.std_inchi_stereo, model.inchi.standardWithStereo{n})) = 2;
    mappingScore(n, strcmp(training_data.std_inchi_stereo_charge, model.inchi.standardWithStereoAndCharge{n})) = 3;
    training_data_idx = find(strcmp(met, fixedMappings{2}), 1);
    if ~isempty(training_data_idx)
        mappingScore(n, training_data.cids == fixedMappings{1}(training_data_idx)) = 4;
    end
end
