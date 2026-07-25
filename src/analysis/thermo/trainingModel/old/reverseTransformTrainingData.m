function training_data = reverseTransformTrainingData(model, training_data, use_model_pKas_by_default)
% Calculate the reverse Legendre transform for all reactions in the training data
%
% Applies the reverse Legendre transform to convert the standard transformed
% reaction Gibbs energies (`.dG0_prime`) into standard reaction Gibbs energies
% (`.dG0`), using either the model or the training-data pseudoisomer/pKa data.
%
% USAGE:
%
%    training_data = reverseTransformTrainingData(model, training_data, use_model_pKas_by_default)
%
% INPUTS:
%    model:                        COBRA model structure. Field used:
%
%                                    * .pseudoisomers - structure array of model pseudoisomer data
%
%    training_data:                training-data structure. Fields used:
%
%                                    * .S - `m x n` stoichiometric matrix of training reactions
%                                    * .cids - `m x 1` compound ids
%                                    * .I - `n x 1` ionic strengths (NaN entries default to 0.25 M)
%                                    * .pMg - `n x 1` pMg values (NaN entries default to 14)
%                                    * .T - `n x 1` temperatures
%                                    * .pH - `n x 1` pH values
%                                    * .kegg_pKa - structure array of KEGG pKa/pseudoisomer data
%                                    * .Model2TrainingMap - map from model to training-data compound indices
%                                    * .dG0_prime - `n x 1` standard transformed reaction Gibbs energy
%
%    use_model_pKas_by_default:    logical, when true use the model pseudoisomer
%                                  data in preference to the training data
%
% OUTPUTS:
%    training_data:                the training data with an added field:
%
%                                    * .dG0 - `n x 1` standard reaction Gibbs energy

R = 8.31e-3; % kJ/mol/K

fprintf('Performing reverse transform\n');

% Calculate the reverse transform for all reactions in training_data.
% Note that many of the compounds in the training data are missing from the iAF1260
% model and therefore do not have a BiGG abbreviation or a pKa struct. This
% needs to be fixed somehow.
reverse_ddG0 = zeros(size(training_data.S, 2), 1);
training_data.I(isnan(training_data.I)) = 0.25; % default ionic strength is 0.25M
training_data.pMg(isnan(training_data.pMg)) = 14; % default pMg is 14
for i = 1:size(training_data.S, 2) % for each reaction in S
    inds = find(training_data.S(:, i));
    reaction_ddG0s = zeros(length(inds), 1);
    for j = 1:length(inds)
        training_diss = [];
        model_diss = [];

        if inds(j) <= length(training_data.cids)
            % find the diss table from the training data structure
            k = find(cell2mat({training_data.kegg_pKa.cid}) == training_data.cids(inds(j)));
            if ~isempty(k)
                training_diss = training_data.kegg_pKa(k);
            end
        end
        
        model_id = find(training_data.Model2TrainingMap == inds(j), 1);
        if ~isempty(model_id)
            model_diss = model.pseudoisomers(model_id);
        else
            model_diss.success = false;
        end
        
        if use_model_pKas_by_default
            if model_diss.success
                diss = model_diss;
            else
                diss = training_diss;
            end
        else
            if ~isempty(training_diss)
                diss = training_diss;
            else
                diss = model_diss;
            end
        end
        
        if isempty(diss)
            continue;
        end
        
        dG0s = cumsum(-[0, diag(diss.pKas, 1)'] * R * training_data.T(i) * log(10));
        dG0s = dG0s - dG0s(diss.majorMSpH7);
        pseudoisomers = [dG0s(:), diss.nHs(:), double(diss.zs(:))];
        reaction_ddG0s(j) = Transform(pseudoisomers, training_data.pH(i), training_data.I(i), training_data.T(i));
        
    end
    reverse_ddG0(i) = training_data.S(inds, i)' * reaction_ddG0s;
end

training_data.dG0 = training_data.dG0_prime - reverse_ddG0;
