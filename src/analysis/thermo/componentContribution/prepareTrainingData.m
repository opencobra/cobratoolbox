function training_data = prepareTrainingData(model, printLevel, params)
% Given a standard COBRA model, adds thermodynamic data to it using
% the Component Contribution method
%
% USAGE:
%
%    training_data = prepareTrainingData(model, printLevel, params)
%
% INPUT:
%    model:                            COBRA structure
%
% OPTIONAL INPUTS:
%    printLevel:                       verbose level, default = 0
%    params.use_cached_kegg_inchis:
%    params.use_model_pKas_by_default:
%    params.uf:                        maximum uncertainty
%
%
% OUTPUTS:
%    training_data:                    strucutre with fields
%
%                                        * .DfG0 - `m x 1` array of component contribution estimated
%                                          standard Gibbs energies of formation.
%                                        * .covf - `m x m` estimated covariance matrix for standard
%                                          Gibbs energies of formation.
%                                        * .uf - `m x 1` array of uncertainty in estimated standard
%                                          Gibbs energies of formation. uf will be large for
%                                          metabolites that are not covered by component contributions.

if ~exist('printLevel','var')
    printLevel = 0;
end
if ~exist('param','var')
    use_cached_kegg_inchis=true;
    use_model_pKas_by_default=true;
else
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
