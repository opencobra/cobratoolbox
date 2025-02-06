function visualizeReconstructionsOnMap(mapFile, folderPath, numCores)
    % Visualizes genome-scale metabolic reconstructions on a metabolic map.
    % This function processes multiple metabolic reconstructions either sequentially or in parallel, 
    % depending on the availability of the Parallel Computing Toolbox.
    %
    % INPUTS:
    %   mapFile:      The input CellDesigner .xml file for the metabolic map.
    %   folderPath:   Path to the folder containing genome-scale reconstructions (.mat files).
    %   numCores:     (Optional) Number of cores to use if parallel computing is available. 
    %                 If unspecified, all available cores will be used.
    %
    % OUTPUTS:
    %   Saves a CellDesigner XML file for each reconstruction.
    %
    % .. Author: - Cyrille C. Thinnes. University of Galway, Ireland, 26/09/2024.
    
    % Get a list of all .mat files in the specified folder.
    modelFiles = dir(fullfile(folderPath, '*.mat'));

    if isempty(modelFiles)
        error('No .mat files found in the specified folder.');
    end

    % Parse the metabolic map once since it is common to all reconstructions.
    [xmlMicroMap, mapMicroMap] = transformXML2Map(mapFile);
    mapMicroMapUnified = unifyMetabolicMapCD(mapMicroMap); % Erase the colouring of the map.

    % Check if the Parallel Computing Toolbox is available.
    parallelAvailable = license('test', 'Distrib_Computing_Toolbox');

    if parallelAvailable
        % If the user does not specify the number of cores, use all available cores.
        if nargin < 3 || isempty(numCores)
            numCores = feature('numcores'); % Use all available cores.
        end
        
        % Start a parallel pool with the specified number of cores.
        poolobj = gcp('nocreate');
        if isempty(poolobj)
            parpool('local', numCores);
        end

        % Process each reconstruction model file in parallel.
        parfor i = 1:length(modelFiles)
            % Full path to the model file.
            modelFilePath = fullfile(folderPath, modelFiles(i).name);
            
            % Load the model from the .mat file.
            loadedData = load(modelFilePath);
            if isfield(loadedData, 'model')
                model = loadedData.model;
            else
                warning('Model variable not found in file: %s', modelFiles(i).name);
                continue;
            end

            % Modify the map by colouring reactions and nodes based on the model.
            mapMicroMapCurrentRxns = changeRxnColorAndWidth(mapMicroMapUnified, model.rxns, 'ORANGERED', 5);
            mapMicroMapCurrentRxnsAndNodes = addColourNode(mapMicroMapCurrentRxns, model.rxns, 'POWDERBLUE');

            % Create an output file name based on the model file name.
            originalNameWithoutMat = strrep(modelFiles(i).name, '.mat', ''); % Remove '.mat' from the name.
            outputFileName = ['MicroMap_', originalNameWithoutMat, '.xml']; % Prepend 'MicroMap_' and append '.xml'

            % Save the modified map to an XML file.
            transformMap2XML(xmlMicroMap, mapMicroMapCurrentRxnsAndNodes, outputFileName);

            % Display progress message.
            fprintf('Saved map for model "%s" as "%s".\n', modelFiles(i).name, outputFileName);
        end

        % Close the parallel pool after processing is done.
        delete(gcp('nocreate'));
    else
        % If no parallel computing toolbox is available, process sequentially.
        for i = 1:length(modelFiles)
            % Full path to the model file.
            modelFilePath = fullfile(folderPath, modelFiles(i).name);
            
            % Load the model from the .mat file.
            loadedData = load(modelFilePath);
            if isfield(loadedData, 'model')
                model = loadedData.model;
            else
                warning('Model variable not found in file: %s', modelFiles(i).name);
                continue;
            end

            % Modify the map by colouring reactions and nodes based on the model.
            mapMicroMapCurrentRxns = changeRxnColorAndWidth(mapMicroMapUnified, model.rxns, 'ORANGERED', 5);
            mapMicroMapCurrentRxnsAndNodes = addColourNode(mapMicroMapCurrentRxns, model.rxns, 'POWDERBLUE');

            % Create an output file name based on the model file name.
            originalNameWithoutMat = strrep(modelFiles(i).name, '.mat', ''); % Remove '.mat' from the name.
            outputFileName = ['MicroMap_', originalNameWithoutMat, '.xml']; % Prepend 'MicroMap_' and append '.xml'

            % Save the modified map to an XML file.
            transformMap2XML(xmlMicroMap, mapMicroMapCurrentRxnsAndNodes, outputFileName);

            % Display progress message.
            fprintf('Saved map for reconstruction "%s" as "%s".\n', modelFiles(i).name, outputFileName);
        end
    end
end