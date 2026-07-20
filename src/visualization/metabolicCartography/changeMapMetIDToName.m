function changeMapMetIDToName(mapPath, modelPath, outputXMLFile)
    % Replaces VMH metabolite IDs in a CellDesigner map with full names from a COBRA model.
    %
    % USAGE:
    %
    %    changeMapMetIDToName(mapPath, modelPath, outputXMLFile)
    %
    % INPUTS:
    %    mapPath:           Path to CellDesigner XML map file
    %    modelPath:         Path to COBRA .mat model file
    %
    % OPTIONAL INPUT:
    %    outputXMLFile:     Name for the output CellDesigner XML file
    %                       (default: `<mapPath base name>_MetNames.xml`)
    %
    % OUTPUTS:
    %    A map with full metabolite names instead of VMH IDs
    %    as the specified CellDesigner XML file.
    %
    % .. Author: - Cyrille C. Thinnes. University of Galway, Ireland, 30/07/2025.

    % Load model
    model = readCbModel(modelPath);

    % Load map
    [xmlInputMap, mapInputMap] = transformXML2Map(mapPath);

    % Replace matching metabolite IDs with full names
    for i = 1:length(mapInputMap.specName)
        specID = mapInputMap.specName{i};
        matchIdx = find(strcmp(specID, model.mets), 1);
        if ~isempty(matchIdx)
            mapInputMap.specName{i} = model.metNames{matchIdx};
        end
    end

    % Define output name if not provided
    if nargin < 3 || isempty(outputXMLFile)
        [~, baseName, ~] = fileparts(mapPath);
        outputXMLFile = [baseName '_MetNames.xml'];
    end

    % Save updated map
    transformMap2XML(xmlInputMap, mapInputMap, outputXMLFile);
end