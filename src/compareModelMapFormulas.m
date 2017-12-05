function [Wrong_table, Absent_model_table, Absent_map_table, Duplicate_table] = compareModelMapFormulas(model, map, excel_name)

% Checks the errors in a given map using a given base model by
% comparing the reactions formulas. As different errors can exist, the
% output is separated in 4 different tables that can later be exported
% into Excel spreadsheets (see commented lines at the end).
%
% USAGE:
%
%   Wrong_table, Absent_model_table, Absent_map_table, Duplicate_table = compareModelMapFormulas(model, map, excel_name)
%
% INPUTS:
%
%   model:          Matlab structure of a model
%
%   map:            Matlab structure of the map obtained from the
%                   function "transformXML2MatStruct".
% 
% OPTIONAL INPUTS:
%
%   excel_name:     Name of the excel file in which to export the info
%
% OUTPUTS:
%
%   Wrong_table:            Table containing the information on wrong
%                           reactions. The fields are arranged as
%                           followed:
%                           Reaction_Name:  Name of the reaction in the
%                                           map
%                           Reaction_ID:    ID of the reaction in the
%                                           map
%                           Model_formula:  Formula of the reaction
%                                           from the model
%                           Map_Formula:    Formula of the reaction
%                                           from the map
%
%   Absent_model_table:     Table containing the information on
%                           reactions present in the map but absent
%                           from the model. The fields are arranged as
%                           followed:
%                           Reaction_Name:  Name of the reaction in the
%                                           map
%                           Reaction_ID:    ID of the reaction in the
%                                           map
%                           Map_Formula:    Formula of the reaction
%                                           from the map
%
%   Absent_map_table:       Table containing the information on
%                           reactions present in the model but absent
%                           from the map. The fields are arranged as
%                           followed:
%                           Reaction_Name:  Name of the reaction in the
%                                           model
%                           Model_formula:  Formula of the reaction
%                                           from the model
%
%   Duplicate_table:        Table containing the information on
%                           duplicated reactions in the map. The fields
%                           are arranged as followed:
%                           Reaction_Name:  Name of the reaction in the
%                                           model
%                           Reaction_ID:    ID of the reaction in the
%                                           map
%                           Model_formula:  Formula of the reaction
%                                           from the model
%                           Map_Formula:    Formula of the reaction
%                                           from the map
%                   
% .. Author: N.Sompairac - Institut Curie, Paris, 25/07/2017.

    % Getting the names from the model and the map
    model_reaction_name_list = model.rxns;
    map_reaction_name_list = map.rxnName;

    % Getting the formulas from the model and the map for further comparison
    model_formulas_list = printRxnFormula(model, model_reaction_name_list);
    [map_formulas_list, map_reaction_name_list] = MapFormula(map, map_reaction_name_list);

    % Deleting the stoechiometric numbers from the model formulas
    model_formulas_list = regexprep(model_formulas_list, '[0-9.]+ ', '');

    % Initialising lists that will contain corresponding info on reactions
    wrong = 1;
    Wrong_list = [];
    dupl = 1;
    Duplicate_list = [];
    abs = 1;
    Absent_map_list = [];
    
    % Looping over the model's reaction names
    for rxn = 1:length(model_reaction_name_list)
        % Test if the reaction name is contained in the map
        if any(strcmp(model_reaction_name_list{rxn}, map_reaction_name_list))
            %Getting the index of the model reaction name in the map list
            index = find(strcmp(model_reaction_name_list{rxn}, map_reaction_name_list));
            % Test if there is only one reaction with this name in the map
            if length(index) == 1
                % Deleting the stoechiometric numbers from the model formula
                % Splitting the model formula for further comparison
                model_formula_split = strsplit(model_formulas_list{rxn}, {'<=>', '->'});
                left_model = strtrim(strsplit(model_formula_split{1}, '+'));
                right_model = strtrim(strsplit(model_formula_split{2}, '+'));
                % Splitting the map formula for further comparison
                map_formula_split = strsplit(map_formulas_list{index}, {'<=>', '->'});
                left_map = strtrim(strsplit(map_formula_split{1}, '+'));
                right_map = strtrim(strsplit(map_formula_split{2}, '+'));
                % Testing if the formulas are different and storing the info
                left_test = setxor(left_model, left_map);
                right_test = setxor(right_model, right_map);
                if ~isempty(left_test) || ~isempty(right_test)
                    Wrong_list.name{wrong} = map_reaction_name_list{index};
                    Wrong_list.ID{wrong} = map.rxnID{strcmp(model_reaction_name_list{rxn}, map.rxnName)};
                    Wrong_list.model_formula{wrong} = model_formulas_list{rxn};
                    Wrong_list.map_formula{wrong} = map_formulas_list{index};
                    wrong = wrong+1;
                end
            % Case where a reaction name is duplicated in the map    
            else
                % Finding the IDs of the duplicated reactions in the map
                Duplicates_ids = map.rxnID(strcmp(model_reaction_name_list{rxn}, map.rxnName));
                % Looping over the duplicates to get the relevant info
                for d = 1:length(index)
                    Duplicate_list.name{dupl} = model_reaction_name_list{rxn};
                    Duplicate_list.model_formula{dupl} = model_formulas_list{rxn};
                    Duplicate_list.map_formula{dupl} = map_formulas_list{index(d)};
                    Duplicate_list.ID{dupl} = Duplicates_ids{d};
                    dupl = dupl+1;
                end
            end
        % Case where reactions are absent in the map and present in the model
        else
            Absent_map_list.name{abs} = model_reaction_name_list{rxn};
            Absent_map_list.model_formula{abs} = model_formulas_list{rxn};
            abs = abs+1;
        end
    end

    if ~isempty(Wrong_list)
    
        Wrong_table = table(Wrong_list.name', Wrong_list.ID', Wrong_list.model_formula', Wrong_list.map_formula');
        Wrong_table.Properties.VariableNames = {'Reaction_Name', 'Reaction_ID', 'Model_formula', 'Map_Formula'};
    
    else
        
        Wrong_table = [];
        
    end
    
    if ~isempty(Duplicate_list)
        Duplicate_table = table(Duplicate_list.name', Duplicate_list.ID', Duplicate_list.model_formula', Duplicate_list.map_formula');
        Duplicate_table.Properties.VariableNames = {'Reaction_Name', 'Reaction_ID', 'Model_formula', 'Map_Formula'};
    else
        Duplicate_table = [];
    end
    
    if ~isempty(Absent_map_list)
        Absent_map_table = table(Absent_map_list.name', Absent_map_list.model_formula');
        Absent_map_table.Properties.VariableNames = {'Reaction_Name', 'Model_formula'};
    else
        Absent_map_table = [];
    end
    
    % Finding reaction names in the map that are not present in the model
    Different_map_rxn_names_list = setdiff(map_reaction_name_list, model_reaction_name_list);
    
    if ~isempty(Different_map_rxn_names_list)
        % Finding reaction names in the map in case of multiple presence
        Different_map_rxn_names_list = map.rxnName(ismember(map.rxnName, Different_map_rxn_names_list));
        % Finding reaction ID in the map that are not present in the model
        Different_map_rxn_id_list = map.rxnID(ismember(map.rxnName, Different_map_rxn_names_list));
        % Finding reaction formulas in the map that are not present in the model
        Different_map_rxn_formulas_list = map_formulas_list(ismember(map_reaction_name_list, Different_map_rxn_names_list));
        
        % Storing the relevant info on missing reactions in the model from the map
        Absent_model_table = table(Different_map_rxn_names_list, Different_map_rxn_id_list,Different_map_rxn_formulas_list);
        Absent_model_table.Properties.VariableNames = {'Reaction_Name', 'Reaction_ID', 'Map_Formula'};
    else        
        Absent_model_table = []; 
    end
    
    if nargin == 3
        % Commented part to use a possible Excel output.
        filename_out = excel_name;
        warning('off','MATLAB:xlswrite:AddSheet');
        if ~isempty(Wrong_table)
            writetable(Wrong_table, filename_out, 'Sheet', 'Wrong_reactions')
        end
        if ~isempty(Absent_map_table)
            writetable(Absent_map_table, filename_out, 'Sheet', 'Absent_from_map_reactions')
        end
        if ~isempty(Absent_model_table)
            writetable(Absent_model_table, filename_out, 'Sheet', 'Absent_from_model_reactions')
        end
        if ~isempty(Duplicate_table)
            writetable(Duplicate_table, filename_out, 'Sheet', 'Duplicated_reactions')
        end
    end

end