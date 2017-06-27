function x = testMinSpan()

% This function tests the ability to determine the MinSpan vectors of the
% E.coli core model by:
% 1) Loading the E.coli core model (e_coli_core.mat)
% 2) Calculating the MinSpan for the E.coli core model

initCobraToolbox();

% Load E.coli core model
load e_coli_core
if ~exist('e_coli_core')
    error('Unable to load E. coli core model');
end

% Remove biomass equation for MinSpan calculation
bmName = {'BIOMASS_Ecoli_core_w_GAM'};
e_coli_core = removeRxns(e_coli_core, bmName);

[m, n] = size(e_coli_core.S);
assert(m == 72 & n == 94, ...
    'Unable to setup input for MinSpan determination');

% Setup parameters and run detMinSpan
params.saveIntV = 0; % Do not save intermediate output
minSpanVectors = detMinSpan(e_coli_core, params);

% Check size of vectors and number of entries
[r, c] = size(minSpanVectors);
numEntries = nnz(minSpanVectors);

assert(r == 94 & c == 23, 'MinSpan vector matrix wrong size');
assert(numEntries > 479, 'MinSpan vector matrix is not minimal');

x = true;