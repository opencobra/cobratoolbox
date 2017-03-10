function model = addThermoToModel(model,params)
% given a standard COBRA model, add thermodynamic data to it using
% the Component Contribution method
%
% INPUTS
%
% 
% 
% OUTPUTS:
% model 
% .DfG0                 m x 1 array of component contribution estimated
%                       standard Gibbs energies of formation.
% .covf                 m x m estimated covariance matrix for standard
%                       Gibbs energies of formation.
% .uf                   m x 1 array of uncertainty in estimated standard
%                       Gibbs energies of formation. uf will be large for
%                       metabolites that are not covered by component
%                       contributions.

if ~isfield(params,'use_cached_kegg_inchis')
    use_cached_kegg_inchis = true;
    % use_cached_kegg_inchis = false;
else
    use_cached_kegg_inchis=params.use_cached_kegg_inchis;
end

if ~isfield(params,'use_model_pKas_by_default')
    use_model_pKas_by_default = true;
else
    use_model_pKas_by_default=params.use_model_pKas_by_default;
end

% load the training data (from TECRDB, Alberty, etc.)
training_data = loadTrainingData();

% get the InChIs for all the compounds in the training data
% (note that all of them have KEGG IDs)
kegg_inchies = getInchies(training_data.cids, use_cached_kegg_inchis);
inds = ismember(kegg_inchies.cids, training_data.cids);
training_data.std_inchi = kegg_inchies.std_inchi(inds);
training_data.std_inchi_stereo = kegg_inchies.std_inchi_stereo(inds);
training_data.std_inchi_stereo_charge = kegg_inchies.std_inchi_stereo_charge(inds);
training_data.nstd_inchi = kegg_inchies.nstd_inchi(inds);

% use the chemical formulas from the InChIs to verify that each and every
% reaction is balanced.
training_data = balanceReactionsInTrainingData(training_data);

% get the pKas for the compounds in the training data (using ChemAxon)
training_data.kegg_pKa = getTrainingDatapKas(training_data);

% match between the compounds in the model and the KEGG IDs used in the
% training data, and create the group incidence matrix (G) for the
% combined set of all compounds.
training_data = createGroupIncidenceMatrix(model, training_data);

% apply the reverse Legendre transform for the relevant training observations (typically
% apparent reaction Keq from TECRDB)
training_data = reverseTransformTrainingData(model, training_data, use_model_pKas_by_default);

%%
fprintf('Running Component Contribution method\n');
% Estimate standard Gibbs energies of formation
[x, cov_x] = componentContribution(training_data.S, training_data.G, training_data.dG0, training_data.weights);

%%
% Map estimates back to model
model.DfG0 = x(training_data.Model2TrainingMap);
model.covf = cov_x(training_data.Model2TrainingMap, training_data.Model2TrainingMap);
model.uf = diag(sqrt(model.covf));
model.uf(model.uf >= 1e3) = 1e10; % Set large uncertainty in formation energies to inf
model.DrG0 = model.S' * model.DfG0;

% model.ur = sqrt(diag(model.S'*model.covf*model.S));
% model.ur(model.ur >= 1e3) = 1e10; % Set large uncertainty in reaction energies to inf
% model.ur(sum(model.S~=0)==1) = 1e10; % set uncertainty of exchange, demand and sink reactions to inf

% Debug
% model.G = training_data.G(training_data.Model2TrainingMap,:);
% model.groups = training_data.groups;
% model.has_gv = training_data.has_gv(training_data.Model2TrainingMap);

