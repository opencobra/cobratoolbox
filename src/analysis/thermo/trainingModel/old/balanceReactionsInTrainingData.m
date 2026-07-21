function training_data = balanceReactionsInTrainingData(training_data)
% Balance the reactions in the training data by adding water and removing unbalanced reactions
%
% Computes an element-conservation matrix from the nonstandard InChI element
% matrix, adds water molecules to reactions that are unbalanced only in oxygen,
% then removes any reactions that remain unbalanced, pruning the corresponding
% columns of every per-reaction field.
%
% USAGE:
%
%    training_data = balanceReactionsInTrainingData(training_data)
%
% INPUTS:
%    training_data:    training-data structure. Fields used:
%
%                        * .nstd_inchi - `m x 1` nonstandard InChI strings
%                        * .Ematrix - `m x k` element matrix (added/updated here)
%                        * .S - `m x n` stoichiometric matrix
%                        * .cids - `m x 1` compound ids
%                        * .balance - `n x 1` true where the reaction should be balance-checked
%                        * .dG0_prime - `n x 1` standard transformed reaction Gibbs energies
%                        * .T - `n x 1` temperatures
%                        * .I - `n x 1` ionic strengths
%                        * .pH - `n x 1` pH values
%                        * .pMg - `n x 1` pMg values
%                        * .weights - `n x 1` reaction weights
%
% OUTPUTS:
%    training_data:    the training-data structure with balanced reactions and
%                      the unbalanced reactions removed

if ~isfield(training_data, 'Ematrix') || isempty(training_data.Ematrix)
    [MW, Ematrix] = getMolecularWeight(training_data.nstd_inchi, 0);
    training_data.Ematrix = Ematrix(:, 2:end); % remove H, columns are [C, N, O, P, S, e-]
    conserved = training_data.Ematrix' * training_data.S;
    
    % need to check that all elements are balanced (except H, but including e-)
    % if only O is not balanced, add water molecules

    % check all reactions which can be checked (not NaN) and should be checked
    % (i.e. not formation or redox reactions)
    inds = find(~isnan(conserved(1,:)) .* training_data.balance');
    
    % first add water molecules to reactions that need it
    i_h2o = find(training_data.cids == 1);
    training_data.S(i_h2o, inds) = training_data.S(i_h2o, inds) - conserved(3, inds);
    
    % recalculate conservation matrix
    conserved = training_data.Ematrix' * training_data.S;
    
    inds_to_remove = inds(find(any(conserved(:, inds))));
    
    inds = setdiff(1:size(training_data.S, 2), inds_to_remove);
    training_data.S = training_data.S(:, inds);
    training_data.dG0_prime = training_data.dG0_prime(inds);
    training_data.T = training_data.T(inds);
    training_data.I = training_data.I(inds);
    training_data.pH = training_data.pH(inds);
    training_data.pMg = training_data.pMg(inds);
    training_data.weights = training_data.weights(inds);
    training_data.balance = false(size(inds));
end

fprintf('Successfully created balanced training-data structure: %d compounds and %d reactions\n',...
        size(training_data.S, 1), size(training_data.S, 2));
