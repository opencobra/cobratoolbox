function training_data = reverseTransformTrainingData(model, training_data, use_model_pKas_by_default)

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
            model_diss = model.pKa(model_id);
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
        pseudoisomers = [dG0s(:), diss.nHs(:), diss.zs(:)];
        reaction_ddG0s(j) = Transform(pseudoisomers, training_data.pH(i), training_data.I(i), training_data.T(i));
        
    end
    reverse_ddG0(i) = training_data.S(inds, i)' * reaction_ddG0s;
end

training_data.dG0 = training_data.dG0_prime - reverse_ddG0;
