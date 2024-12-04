function visualizeFluxTimeseriesFromFile(mapXMLFile, fluxDataFile, outputFileNameBase, numCores)
    % Visualize fluxes for multiple time points from a data table file (CSV or XLSX).
    % Supports both sequential and parallel processing based on the availability of the Parallel Computing Toolbox.
    %
    % INPUTS:
    %   mapXMLFile:         The input CellDesigner .xml file for the map.
    %   fluxDataFile:       The input .csv or .xlsx file containing the flux vectors.
    %   outputFileNameBase: (Optional) The base name for the output files.
    %   numCores:           (Optional) Number of cores to use if parallel computing is available. 
    %                       If not provided, all available cores will be used.
    %
    % OUTPUTS:
    %   Saves a CellDesigner XML map with visualized fluxes for each time point.
    %
    % .. Author: - Cyrille C. Thinnes. University of Galway, Ireland, 26/09/2024.

    % Set default output file name base if not provided.
    if nargin < 3 || isempty(outputFileNameBase)
        outputFileNameBase = 'VisualizedFluxOnMap';
    end

    % Parse the map CellDesigner .xml file into MATLAB.
    [xmlInputMap, mapInputMap] = transformXML2Map(mapXMLFile);

    % Read the flux data from the file, preserving original variable names.
    fluxData = readtable(fluxDataFile, 'ReadVariableNames', true, 'VariableNamingRule', 'preserve');

    % Get variable names (headers).
    varNames = fluxData.Properties.VariableNames;

    % Get the reaction IDs from the first column.
    reactionIDs = fluxData{:, 1};

    % Extract time point names from the variable names (starting from the second column).
    timePointNames = varNames(2:end);

    % Check if the Parallel Computing Toolbox is available.
    parallelAvailable = license('test', 'Distrib_Computing_Toolbox');

    if parallelAvailable
        % If the user does not specify the number of cores, use all available cores.
        if nargin < 4 || isempty(numCores)
            numCores = feature('numcores'); % Use all available cores.
        end

        % Start a parallel pool with the specified number of cores.
        poolobj = gcp('nocreate');
        if isempty(poolobj)
            parpool('local', numCores);
        end

        % Parallel loop over each time point (starting from the second column).
        parfor t = 2:length(varNames)
            % Get the flux values for this time point.
            fluxValues = fluxData{:, t};

            % Create a copy of the map for modification.
            mapCopy = mapInputMap; % Each iteration has its own copy of the map.

            % Visualize the flux on the map.
            [mapWithFlux, ~, ~] = addFluxWidthAndColor(mapCopy, reactionIDs, fluxValues);

            % Construct the output file name.
            [~, mapName, ~] = fileparts(mapXMLFile);
            timePointName = timePointNames{t - 1}; % Adjust index since timePointNames starts from 1.

            % Sanitize the timePointName to remove invalid filename characters.
            timePointName = regexprep(timePointName, '[^\w\s-]', ''); % Remove invalid characters.
            timePointName = strrep(timePointName, ' ', '_');          % Replace spaces with underscores.

            outputXMLFile = sprintf('%s_%s_%s.xml', outputFileNameBase, mapName, timePointName);

            % Reconstitute the CellDesigner map with the flux vector.
            transformMap2XML(xmlInputMap, mapWithFlux, outputXMLFile);

            % Display progress message.
            fprintf('Map for time point "%s" saved as: %s\n', timePointName, outputXMLFile);
        end

        % Close the parallel pool after processing is done.
        delete(gcp('nocreate'));
    else
        % If no parallel computing toolbox is available, process sequentially.
        for t = 2:length(varNames)
            % Get the flux values for this time point.
            fluxValues = fluxData{:, t};

            % Create a copy of the map for modification.
            mapCopy = mapInputMap; % Each iteration has its own copy of the map.

            % Visualize the flux on the map.
            [mapWithFlux, ~, ~] = addFluxWidthAndColor(mapCopy, reactionIDs, fluxValues);

            % Construct the output file name.
            [~, mapName, ~] = fileparts(mapXMLFile);
            timePointName = timePointNames{t - 1}; % Adjust index since timePointNames starts from 1.

            % Sanitize the timePointName to remove invalid filename characters.
            timePointName = regexprep(timePointName, '[^\w\s-]', ''); % Remove invalid characters.
            timePointName = strrep(timePointName, ' ', '_');          % Replace spaces with underscores.

            outputXMLFile = sprintf('%s_%s_%s.xml', outputFileNameBase, mapName, timePointName);

            % Reconstitute the CellDesigner map with the flux vector.
            transformMap2XML(xmlInputMap, mapWithFlux, outputXMLFile);

            % Display progress message.
            disp(['Map for time point "', timePointName, '" saved as: ', outputXMLFile]);
        end
    end
end