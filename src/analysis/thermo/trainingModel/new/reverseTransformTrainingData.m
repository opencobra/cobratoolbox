function trainingModel = reverseTransformTrainingData(trainingModel, use_model_pKas_by_default, model)
% Calculate the reverse Legendre transform for all reactions in the training model
%
% Applies the reverse Legendre transform to convert the standard transformed
% reaction Gibbs energies (`.DrGt0`) into standard reaction Gibbs energies
% (`.DrG0`), using either the model or the training-data pseudoisomer/pKa data.
%
% USAGE:
%
%    trainingModel = reverseTransformTrainingData(trainingModel, use_model_pKas_by_default, model)
%
% INPUTS:
%    trainingModel:                training-data structure. Fields used:
%
%                                    * .S - `m x n` stoichiometric matrix of training reactions
%                                    * .cids - `m x 1` compound ids
%                                    * .I - `n x 1` ionic strengths (NaN entries default to 0.25 M)
%                                    * .pMg - `n x 1` pMg values (NaN entries default to 14)
%                                    * .T - `n x 1` temperatures
%                                    * .pH - `n x 1` pH values
%                                    * .kegg_pKa - structure array of KEGG pKa/pseudoisomer data
%                                    * .pseudoisomers - structure array of pseudoisomer data per compound
%                                    * .Model2TrainingMap - map from model to training-data compound indices
%                                    * .DrGt0 - `n x 1` standard transformed reaction Gibbs energy
%
% OPTIONAL INPUTS:
%    use_model_pKas_by_default:    logical, when true use the model pseudoisomer
%                                  data in preference to the training data (default: 0)
%    model:                        COBRA model structure. Field used:
%
%                                    * .pseudoisomers - structure array of model pseudoisomer data
%
% OUTPUTS:
%    trainingModel:                the training model with an added field:
%
%                                    * .DrG0 - `n x 1` standard reaction Gibbs energy


if ~exist('use_model_pKas_by_default','var')
    use_model_pKas_by_default=0;
end

R = 8.31e-3; % kJ/mol/K

fprintf('Performing reverse Legendre transform\n');

% Note that many of the compounds in the training data are missing from the iAF1260
% model and therefore do not have a BiGG abbreviation or a pKa struct. This
% needs to be fixed somehow.
reverse_ddG0 = zeros(size(trainingModel.S, 2), 1);
trainingModel.I(isnan(trainingModel.I)) = 0.25; % default ionic strength is 0.25M
trainingModel.pMg(isnan(trainingModel.pMg)) = 14; % default pMg is 14
for i = 1:size(trainingModel.S, 2) % for each reaction in S
    inds = find(trainingModel.S(:, i));
    reaction_ddG0s = zeros(length(inds), 1);
    for j = 1:length(inds)
        training_diss = [];
        model_diss = [];
        
        if inds(j) <= length(trainingModel.cids)
            if 0
                % find the diss table from the training data structure
                k = find(cell2mat({trainingModel.kegg_pKa.cid}) == trainingModel.cids(inds(j)));
                if ~isempty(k)
                    training_diss = trainingModel.kegg_pKa(k);
                end
            else
                %trainingModel pseudoisomer structure
                training_diss = trainingModel.pseudoisomers(inds(j));
            end
        end
        
        if use_model_pKas_by_default
            model_id = find(trainingModel.Model2TrainingMap == inds(j), 1);
            if ~isempty(model_id)
                model_diss = model.pseudoisomers(model_id);
            else
                model_diss.success = false;
            end
            if model_diss.success
                diss = model_diss;
            else
                diss = training_diss;
            end
        else
            if ~isempty(training_diss)
                diss = training_diss;
            else
                model_id = find(trainingModel.Model2TrainingMap == inds(j), 1);
                if ~isempty(model_id)
                    model_diss = model.pseudoisomers(model_id);
                else
                    model_diss.success = false;
                end
                diss = model_diss;
            end
        end

        if diss.success==0
            continue;
        end
        
        dG0s = cumsum(-[0, diag(diss.pKas, 1)'] * R * trainingModel.T(i) * log(10));
        dG0s = dG0s - dG0s(diss.majorMSpH7);
        pseudoisomers = [dG0s(:), diss.nHs(:), double(diss.zs(:))];
        reaction_ddG0s(j) = Transform(pseudoisomers, trainingModel.pH(i), trainingModel.I(i), trainingModel.T(i));
        
    end
    reverse_ddG0(i) = trainingModel.S(inds, i)' * reaction_ddG0s;
end

trainingModel.DrG0 = trainingModel.DrGt0 - reverse_ddG0;