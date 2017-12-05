function [map_struct] = getMapMatrices(map_struct)

% Adds 3 matrices to the map structure given as input.
%
%   S_ID:       Stoechiometric matrix with rows=Metabolites_ID and
%               columns=Reactions_ID in the same order as in the map
%               structure. Contains "-1" if the metabolite is a
%               reactant/substract, "+1" if the metabolite is a product
%               and "0" if it does not participate in the reaction.
%
%   S_alias:    Stoechiometric matrix with rows=Metabolites_Alias and
%               columns=Reactions_ID in the same order as in the map
%               structure. Contains "-1" if the metabolite is a
%               reactant/substract, "+1" if the metabolite is a product
%               and "0" if it does not participate in the reaction.
%
%   ID_alias:   Logical matrix with rows=Metabolites_ID and
%               columns=Metabolites_Alias. Contains "+1" if the
%               Metabolite_ID match with the Metabolite_Alias and "0"
%               if it doesn't.
%
% USAGE:
%
%   map_struct = getMapMatrices(map_struct)
%
% INPUTS:
%
%   map_struct:     Matlab structure of the map obtained from the
%                   function "transformXML2MatStruct"
% 
% OPTIONAL INPUTS:
%
%   No optional inputs.
%
% OUTPUTS:
%
%   map_struct:     Updated map structure from the input containing
%                   the 3 matrices
%
% .. Author: N.Sompairac - Institut Curie, Paris, 24/07/2017

    % Create a correspondence of species ID and their index for easier access
    % during the matrix filling
    for ind = 1:length(map_struct.specID)
        spec_index_id.(map_struct.specID{ind}) = ind;
    end

    % Create a correspondence of species alias and their index for easier access
    % during the matrix filling
    for ind = 1:length(map_struct.molAlias)
        spec_index_alias.(map_struct.molAlias{ind}) = ind;
    end

    % Initialise the stoechiometric matrices with zeros
    S_matrix_ID = zeros(length(map_struct.specID),length(map_struct.rxnID));
    S_matrix_alias = zeros(length(map_struct.molAlias),length(map_struct.rxnID));

    % Loop over reactions to fill the matrix
    for rxn = 1:length(map_struct.rxnID)
        % Loop over base reactants
        for x = 1:length(map_struct.rxnBaseReactantID{rxn})
            S_matrix_ID(spec_index_id.(map_struct.rxnBaseReactantID{rxn}{x}),rxn) = -1;
            S_matrix_alias(spec_index_alias.(map_struct.rxnBaseReactantAlias{rxn}{x}),rxn) = -1;
        end
        % Loop over reactants
        for x = 1:length(map_struct.rxnReactantID{rxn})
            S_matrix_ID(spec_index_id.(map_struct.rxnReactantID{rxn}{x}),rxn) = -1;
            S_matrix_alias(spec_index_alias.(map_struct.rxnReactantAlias{rxn}{x}),rxn) = -1;
        end
        % Loop over base products
        for x = 1:length(map_struct.rxnBaseProductID{rxn})
            S_matrix_ID(spec_index_id.(map_struct.rxnBaseProductID{rxn}{x}),rxn) = 1;
            S_matrix_alias(spec_index_alias.(map_struct.rxnBaseProductAlias{rxn}{x}),rxn) = 1;
        end
        % Loop over products
        for x = 1:length(map_struct.rxnProductID{rxn})
            S_matrix_ID(spec_index_id.(map_struct.rxnProductID{rxn}{x}),rxn) = 1;
            S_matrix_alias(spec_index_alias.(map_struct.rxnProductAlias{rxn}{x}),rxn) = 1;
        end
    end
    
    % Initialise the species ID/Alias matrix with zeros
    ID_alias_matrix = zeros(length(map_struct.specID), length(map_struct.molAlias));

    % Loop over species IDs corresponding to a certain alias
    for id = 1:length(map_struct.molID)
        ID_alias_matrix(spec_index_id.(map_struct.molID{id}), id) = 1;
    end

    map_struct.S_ID = S_matrix_ID;
    map_struct.S_alias = S_matrix_alias;
    map_struct.ID_alias = ID_alias_matrix;

end