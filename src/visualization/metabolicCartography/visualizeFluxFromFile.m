function visualizeFluxFromFile(mapXMLFile, fluxCSVFile, outputXMLFile)
    % This function takes a CellDesigner map XML file and a flux vector table file (e.g., CSV or XLSX),
    % visualizes the flux on the map, and saves the output map as a CellDesigner XML file.
    %
    % INPUTS:
    %   mapXMLFile:   The input CellDesigner .xml file for the map.
    %   fluxCSVFile:  The input file containing the flux vector, e.g., CSV
    %   or XLSX.
    %   outputXMLFile: (Optional) The output .xml file name for the updated map.
    %
    % OUTPUTS:
    %   The map with visualized flux saved as the specified CellDesigner XML file.
    
    % .. Author: - Cyrille C. Thinnes. University of Galway, Ireland, 24/09/2024.
    
    % Set default output XML file name if not provided.
    if nargin < 3 || isempty(outputXMLFile)
        outputXMLFile = 'VisualizedFluxOnMap.xml';
    end

    % Parse the map CellDesigner .xml file into Matlab.
    [xmlInputMap, mapInputMap] = transformXML2Map(mapXMLFile);

    % Visualise the flux vector to highlight flux magnitude and sign.
    mapWidthAndColourFlux = addFluxFromFileWidthAndColor(mapInputMap, fluxCSVFile);

    % Reconstitute the CellDesigner map with the flux vector.
    transformMap2XML(xmlInputMap, mapWidthAndColourFlux, outputXMLFile);

    % Display success message
    disp(['Map with flux visualisation saved as: ', outputXMLFile]);
end