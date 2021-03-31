function trainingModel = reverseTransformTrainingData(model, trainingModel, use_model_pKas_by_default)
% Calculate the reverse transform for all reactions in trainingModel.

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
        
        model_id = find(trainingModel.Model2TrainingMap == inds(j), 1);
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

trainingModel.dG0 = trainingModel.dG0_prime - reverse_ddG0;
