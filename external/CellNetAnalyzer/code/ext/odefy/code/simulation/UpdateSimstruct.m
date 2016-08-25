% UPDATESIMSTRUCT
%   
%   UPDATESIMSTRUCT(OLD_SIMSTRUCT,NEW_SIMSTRUCT) Copy parameter values from
%   OLD_SIMSTRUCT over to NEW_SIMSTRUCT.
%
%   Odefy-internal function

%   Odefy - Copyright (c) CMB, IBIS, Helmholtz Zentrum Muenchen
%   Free for non-commerical use, for more information: see LICENSE.txt
%   http://cmb.helmholtz-muenchen.de/odefy
%
function ret_simstruct = UpdateSimstruct(old_simstruct, new_simstruct)
    if (~IsSimulationStructure(old_simstruct))
       error('First parameter must be a simulation structure'); 
    end
    if (~IsSimulationStructure(new_simstruct))
       error('Second parameter must be a simulation structure'); 
    end

    ret_simstruct = new_simstruct;
    ret_simstruct.timeto = old_simstruct.timeto;
    ret_simstruct.modelname = old_simstruct.modelname;
    
    new_model = ret_simstruct.model;
    old_model = old_simstruct.model;
    
    % Create index mapping of species between new model and old model
    new_old_species_map = zeros(numel(new_model.species));
    for i=1:numel(new_model.species)
        % Find index of species in old model's species vector
        species_name = new_model.species(i);
        for j=1:numel(old_model.species)
            if (strcmp(species_name, old_model.species(j)))
                new_old_species_map(i) = j;
                break
            end
        end
    end
    
    % Foreach species of new model check if it was already in the old model
    common_species = ismember(new_model.species, old_simstruct.model.species);
    
    % Update initial
    for i=1:numel(new_model.species)
       if (common_species(i))
          % Species was already in old model
          % Copy value of old simstruct
          ret_simstruct.initial(i) = old_simstruct.initial(new_old_species_map(i));
       end
    end
    
    % Foreach input species of the new simstruct check
    % if it was already in the old simstruct
    new_input_species_names = GetSpeciesNamesOfInputSpecies(ret_simstruct);
    old_input_species_names = GetSpeciesNamesOfInputSpecies(old_simstruct);
    common_inputspecies = ismember(new_input_species_names, ...
        old_input_species_names);
  
    
    % Update hillmatrix
    for i=1:numel(new_model.species)
        if (common_species(i))
            % Species already in old model
            old_species_index = new_old_species_map(i);
            
            % Copy tau
            ret_simstruct.params(i, 1) = old_simstruct.params(...
                old_species_index, 1);
            
            % Indices of input species of sepcies i
            new_inspecies = new_model.tables(i).inspecies;
            old_inspecies = old_model.tables(old_species_index).inspecies;
            
            % Names of input species of species i
            new_insp_names = GetSpeciesNamesOfIndices(new_model, new_inspecies);
            old_insp_names = GetSpeciesNamesOfIndices(old_model, old_inspecies);
            
            % Get input species that were already present in old simstruct
            common_inspecies = ismember(new_insp_names, old_insp_names);
            
            for j=1:numel(new_inspecies)
                if (common_inspecies(j))
                    % Get index of inspecies in old simstruct
                    old_inspecies_index = GetSpeciesIndexFromName(...
                        new_insp_names{j}, old_model.species);                    
                    
                    % Copy n
                    ret_simstruct.params(i, j*2) = ...
                        old_simstruct.params(old_species_index, ...
                            old_inspecies_index*2);
                    % Copy k
                    ret_simstruct.params(i, j*2+1) = ...
                        old_simstruct.params(old_species_index, ...
                            old_inspecies_index*2 + 1);
                end
            end
        end
    end
end

function r=GetSpeciesNamesOfInputSpecies(simstruct)
    n = numel(simstruct.inputspecies);
    r = cell(n, 1);
    for i=1:n
       r{i} = simstruct.model.species{simstruct.inputspecies(i)};
    end
end

function r=GetSpeciesNamesOfIndices(model, indices)
%GETSPECIESNAMESOFINDICES Convert INDICES to the corresponding species'
%names
    n = numel(indices);
    r = cell(n, 1);
    for i=1:n
       r{i} = model.species{indices(i)};
    end
end