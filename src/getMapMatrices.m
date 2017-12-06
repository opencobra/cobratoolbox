function [map] = getMapMatrices(map)
% Adds 3 matrices to the map structure given as input.
%   S_ID:       Stoechiometric matrix with rows=Metabolites_ID and
%               columns=Reactions_ID in the same order as in the map
%               structure. Contains "-1" if the metabolite is a
%               reactant/substract, "+1" if the metabolite is a product
%               and "0" if it does not participate in the reaction.
%   S_alias:    Stoechiometric matrix with rows=Metabolites_Alias and
%               columns=Reactions_ID in the same order as in the map
%               structure. Contains "-1" if the metabolite is a
%               reactant/substract, "+1" if the metabolite is a product
%               and "0" if it does not participate in the reaction.
%   ID_alias:   Logical matrix with rows=Metabolites_ID and
%               columns=Metabolites_Alias. Contains "+1" if the
%               Metabolite_ID match with the Metabolite_Alias and "0"
%               if it doesn't.
%
% USAGE:
%
%   [map] = getMapMatrices(map)
%
% INPUT:
%   map:        MATLAB structure of the map
%
% OUTPUT:
%   map:        Updated map structure from the input containing
%               the 3 matrices
%
% .. Author: - N.Sompairac - Institut Curie, Paris, 24/07/2017

    % Create a correspondence of species ID and their index for easier access
    % during the matrix filling
    for ind = 1:length(map.specID)
        spec_index_id.(map.specID{ind}) = ind;
    end

    % Create a correspondence of species alias and their index for easier access
    % during the matrix filling
    for ind = 1:length(map.molAlias)
        spec_index_alias.(map.molAlias{ind}) = ind;
    end

    % Initialise the stoechiometric matrices with zeros
    S_matrix_ID = zeros(length(map.specID),length(map.rxnID));
    S_matrix_alias = zeros(length(map.molAlias),length(map.rxnID));

    % Loop over reactions to fill the matrix
    for rxn = 1:length(map.rxnID)
        % Loop over base reactants
        for x = 1:length(map.rxnBaseReactantID{rxn})
            S_matrix_ID(spec_index_id.(map.rxnBaseReactantID{rxn}{x}),rxn) = -1;
            S_matrix_alias(spec_index_alias.(map.rxnBaseReactantAlias{rxn}{x}),rxn) = -1;
        end
        % Loop over reactants
        for x = 1:length(map.rxnReactantID{rxn})
            S_matrix_ID(spec_index_id.(map.rxnReactantID{rxn}{x}),rxn) = -1;
            S_matrix_alias(spec_index_alias.(map.rxnReactantAlias{rxn}{x}),rxn) = -1;
        end
        % Loop over base products
        for x = 1:length(map.rxnBaseProductID{rxn})
            S_matrix_ID(spec_index_id.(map.rxnBaseProductID{rxn}{x}),rxn) = 1;
            S_matrix_alias(spec_index_alias.(map.rxnBaseProductAlias{rxn}{x}),rxn) = 1;
        end
        % Loop over products
        for x = 1:length(map.rxnProductID{rxn})
            S_matrix_ID(spec_index_id.(map.rxnProductID{rxn}{x}),rxn) = 1;
            S_matrix_alias(spec_index_alias.(map.rxnProductAlias{rxn}{x}),rxn) = 1;
        end
    end
    
    % Initialise the species ID/Alias matrix with zeros
    ID_alias_matrix = zeros(length(map.specID), length(map.molAlias));

    % Loop over species IDs corresponding to a certain alias
    for id = 1:length(map.molID)
        ID_alias_matrix(spec_index_id.(map.molID{id}), id) = 1;
    end

    map.S_ID = S_matrix_ID;
    map.S_alias = S_matrix_alias;
    map.ID_alias = ID_alias_matrix;

end