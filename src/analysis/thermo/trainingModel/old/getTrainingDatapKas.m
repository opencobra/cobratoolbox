function kegg_pKa = getTrainingDatapKas(training_data, use_cache)
% Get the pKa values for the compounds in the training data, using ChemAxon
%
% Loads cached pKa values when available, otherwise computes them with
% `getKeggpKas` for every compound in the training data and caches the result.
%
% USAGE:
%
%    kegg_pKa = getTrainingDatapKas(training_data, use_cache)
%
% INPUTS:
%    training_data:    training-data structure. Fields used:
%
%                        * .cids - `m x 1` KEGG compound ids
%                        * .nstd_inchi - `m x 1` nonstandard InChI strings
%
% OPTIONAL INPUT:
%    use_cache:        logical, when true (default) load previously cached pKa
%                      values from disk instead of recomputing them
%
% OUTPUTS:
%    kegg_pKa:         structure array of pKa/pseudoisomer data, one entry per
%                      compound (see getKeggpKas)

if nargin < 2
    use_cache = true;
end

CACHED_KEGG_PKA_MAT_FNAME = 'cache/kegg_pkas.mat';

% Load relevant pKas (for all compounds in the training data)
if exist(CACHED_KEGG_PKA_MAT_FNAME, 'file') && use_cache
    fprintf('Loading the pKa values for the training data from: %s\n', CACHED_KEGG_PKA_MAT_FNAME);
    load(CACHED_KEGG_PKA_MAT_FNAME);
else
    fprintf('Calculating the pKa values for the training data using ChemAxon')
    kegg_pKa = getKeggpKas(training_data.cids, training_data.nstd_inchi);
    save(CACHED_KEGG_PKA_MAT_FNAME, 'kegg_pKa', '-v7');
end
