function [wrongTable, absentModelTable, absentMapTable, duplicateTable] = compareModelMapFormulas(model, map, excelName)
% Checks the errors in a given map using a given base model by
% comparing the reactions formulas. As different errors can exist, the
% output is separated in 4 different tables that can later be exported
% into Excel spreadsheets (see commented lines at the end).
%
% USAGE:
%
%   [wrongTable, absentModelTable, absentMapTable, duplicateTable] = compareModelMapFormulas(model, map, excelName)
%
% INPUTS:
%   model:          COBRA structure of a model
%   map:            MATLAB structure of the map obtained from the
%                   function `transformXML2Map`.
%
% OPTIONAL INPUT:
%   excelName:      Name of the excel file in which to export the info
%
% OUTPUTS:
%   wrongTable:             Table containing the information on wrong
%                           reactions. The fields are arranged as
%                           followed:
%
%                            * rxnName - Name of the reaction in the map
%                            * rxnID - ID of the reaction in the map
%                            * modelFormula - Formula of the reaction from the model
%                            * mapFormula - Formula of the reaction from the map
%
%   absentModelTable:       Table containing the information on
%                           reactions present in the map but absent
%                           from the model. The fields are arranged as
%                           followed:
%
%                            * rxnName - Name of the reaction in the map
%                            * rxnID - ID of the reaction in the map
%                            * mapFormula - Formula of the reaction from the map
%
%   absentMapTable:         Table containing the information on
%                           reactions present in the model but absent
%                           from the map. The fields are arranged as
%                           followed:
%
%                            * rxnName - Name of the reaction in the model
%                            * modelFormula - Formula of the reaction from the model
%
%   duplicateTable:         Table containing the information on
%                           duplicated reactions in the map. The fields
%                           are arranged as followed:
%
%                            * rxnName - Name of the reaction in the model
%                            * rxnID - ID of the reaction in the map
%                            * modelFormula - Formula of the reaction from the model
%                            * mapFormula - Formula of the reaction from the map
%
% .. Author: - N.Sompairac - Institut Curie, Paris, 25/07/2017.

    modelReactionNameList = model.rxns;  % Getting names from model and map
    mapReactionNameList = map.rxnName;

    % Getting the formulas from the model and the map for further comparison
    modelFormulasList = printRxnFormula(model, modelReactionNameList);
    [mapFormulasList, mapReactionNameList] = mapFormula(map, mapReactionNameList);

    % Deleting the stoechiometric numbers from the model formulas
    modelFormulasList = regexprep(modelFormulasList, '[0-9.]+ ', '');

    % Initialising lists that will contain corresponding info on reactions
    wrong = 1;
    wrongList = [];
    dupl = 1;
    duplicateList = [];
    abs = 1;
    absentMapList = [];

    % Looping over the model's reaction names
    for rxn = 1:length(modelReactionNameList)
        % Test if the reaction name is contained in the map
        if any(strcmp(modelReactionNameList{rxn}, mapReactionNameList))
            % Getting the index of the model reaction name in the map list
            index = find(strcmp(modelReactionNameList{rxn}, mapReactionNameList));
            % Test if there is only one reaction with this name in the map
            if length(index) == 1
                % Deleting the stoechiometric numbers from the model formula
                % Splitting the model formula for further comparison
                modelFormulaSplit = strsplit(modelFormulasList{rxn}, {'<=>', '->'});
                leftModel = strtrim(strsplit(modelFormulaSplit{1}, '+'));
                rightModel = strtrim(strsplit(modelFormulaSplit{2}, '+'));
                % Splitting the map formula for further comparison
                mapFormulaSplit = strsplit(mapFormulasList{index}, {'<=>', '->'});
                leftMap = strtrim(strsplit(mapFormulaSplit{1}, '+'));
                rightMap = strtrim(strsplit(mapFormulaSplit{2}, '+'));
                % Testing if the formulas are different and storing the info
                leftTest = setxor(leftModel, leftMap);
                rightTest = setxor(rightModel, rightMap);
                if ~isempty(leftTest) || ~isempty(rightTest)
                    wrongList.name{wrong} = mapReactionNameList{index};
                    wrongList.ID{wrong} = map.rxnID{strcmp(modelReactionNameList{rxn}, map.rxnName)};
                    wrongList.modelFormula{wrong} = modelFormulasList{rxn};
                    wrongList.mapFormula{wrong} = mapFormulasList{index};
                    wrong = wrong + 1;
                end
                % Case where a reaction name is duplicated in the map
            else
                % Finding the IDs of the duplicated reactions in the map
                duplicateIDs = map.rxnID(strcmp(modelReactionNameList{rxn}, map.rxnName));
                % Looping over the duplicates to get the relevant info
                for d = 1:length(index)
                    duplicateList.name{dupl} = modelReactionNameList{rxn};
                    duplicateList.modelFormula{dupl} = modelFormulasList{rxn};
                    duplicateList.mapFormula{dupl} = mapFormulasList{index(d)};
                    duplicateList.ID{dupl} = duplicateIDs{d};
                    dupl = dupl + 1;
                end
            end
            % Case where reactions are absent in the map and present in the model
        else
            absentMapList.name{abs} = modelReactionNameList{rxn};
            absentMapList.modelFormula{abs} = modelFormulasList{rxn};
            abs = abs + 1;
        end
    end

    if ~isempty(wrongList)

        wrongTable = table(wrongList.name', wrongList.ID', wrongList.modelFormula', wrongList.mapFormula');
        wrongTable.Properties.VariableNames = {'rxnName', 'rxnID', 'modelFormula', 'mapFormula'};

    else

        wrongTable = [];

    end

    if ~isempty(duplicateList)
        duplicateTable = table(duplicateList.name', duplicateList.ID', duplicateList.modelFormula', duplicateList.mapFormula');
        duplicateTable.Properties.VariableNames = {'rxnName', 'rxnID', 'modelFormula', 'mapFormula'};
    else
        duplicateTable = [];
    end

    if ~isempty(absentMapList)
        absentMapTable = table(absentMapList.name', absentMapList.modelFormula');
        absentMapTable.Properties.VariableNames = {'rxnName', 'modelFormula'};
    else
        absentMapTable = [];
    end

    % Finding reaction names in the map that are not present in the model
    differentMapRxnNamesList = setdiff(mapReactionNameList, modelReactionNameList);

    if ~isempty(differentMapRxnNamesList)
        % Finding reaction names in the map in case of multiple presence
        differentMapRxnNamesList = map.rxnName(ismember(map.rxnName, differentMapRxnNamesList));
        % Finding reaction ID in the map that are not present in the model
        differentMapRxnIdList = map.rxnID(ismember(map.rxnName, differentMapRxnNamesList));
        % Finding reaction formulas in the map that are not present in the model
        differentMapRxnFormulasList = mapFormulasList(ismember(mapReactionNameList, differentMapRxnNamesList));

        % Storing the relevant info on missing reactions in the model from the map
        absentModelTable = table(differentMapRxnNamesList, differentMapRxnIdList, differentMapRxnFormulasList);
        absentModelTable.Properties.VariableNames = {'rxnName', 'rxnID', 'mapFormula'};
    else
        absentModelTable = [];
    end

    if nargin == 3
        % Commented part to use a possible Excel output.
        fileName = excelName;
        warning('off', 'MATLAB:xlswrite:AddSheet');
        if ~isempty(wrongTable)
            writetable(wrongTable, fileName, 'Sheet', 'wrongReactions')
        end
        if ~isempty(absentMapTable)
            writetable(absentMapTable, fileName, 'Sheet', 'absentFromMapReactions')
        end
        if ~isempty(absentModelTable)
            writetable(absentModelTable, fileName, 'Sheet', 'absentFromModelReactions')
        end
        if ~isempty(duplicateTable)
            writetable(duplicateTable, fileName, 'Sheet', 'duplicatedReactions')
        end
    end

end
