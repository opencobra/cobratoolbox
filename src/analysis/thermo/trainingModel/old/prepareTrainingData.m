function [training_data, mappingScore] = prepareTrainingData(model, printLevel, params)
% Given a standard COBRA model, add thermodynamic data to it using the Component Contribution method
%
% Loads the training data, retrieves InChIs and pKa values for the training
% compounds, balances the training reactions, builds the group incidence matrix
% against the model, and applies the reverse Legendre transform.
%
% USAGE:
%
%    [training_data, mappingScore] = prepareTrainingData(model, printLevel, params)
%
% INPUTS:
%    model:            COBRA model structure
%
% OPTIONAL INPUTS:
%    printLevel:       verbose level (default: 0)
%    params:           structure of parameters. Fields used:
%
%                        * .use_cached_kegg_inchis - logical, use cached KEGG InChIs
%                        * .use_model_pKas_by_default - logical, prefer model pKa data
%
% OUTPUTS:
%    training_data:    training-data structure with thermodynamic data and the
%                      group incidence matrix
%    mappingScore:     score of the mapping between the model and the training
%                      data compounds

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
[training_data, mappingScore] = createGroupIncidenceMatrix(model, training_data);

% apply the reverse Legendre transform for the relevant training observations (typically
% apparent reaction Keq from TECRDB)
training_data = reverseTransformTrainingData(model, training_data, use_model_pKas_by_default);

