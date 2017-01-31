function kegg_pKa = getTrainingDatapKas(training_data, use_cache,debug)

% debug             0: No verbose output
%                   1: Progress information only (no warnings)
%                   2: Progress and warnings

if nargin < 2
    use_cache = true;
end

CACHED_KEGG_PKA_MAT_FNAME = 'cache/kegg_pkas.mat';

% Load relevant pKas (for all compounds in the training data)
if exist(CACHED_KEGG_PKA_MAT_FNAME, 'file') && use_cache
    if debug > 0
        fprintf('Loading the pKa values for the trainin data from: %s\n', CACHED_KEGG_PKA_MAT_FNAME);
    end
    load(CACHED_KEGG_PKA_MAT_FNAME);
else
    if debug > 0
        fprintf('Calculating the pKa values for the trainin data using ChemAxon')
    end
    kegg_pKa = getKeggpKas(training_data.cids, training_data.nstd_inchi);
    save(CACHED_KEGG_PKA_MAT_FNAME, 'kegg_pKa', '-v7');
end
