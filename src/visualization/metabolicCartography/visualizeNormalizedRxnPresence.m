function rxnPrsTable = visualizeNormalizedRxnPresence(mapDir, setColours, numCores)
% Function that takes reconstruction visualizations in CellDesigner XML format and extracts
% reactions with a specific colour that indicates the reaction presence.
% Reaction presence is then stored in a table as 0 or 1 (absent or present). Each
% column represents an individual map. The reaction presence of all maps are then
% summed to obtain a total count of reaction presence over all the maps.
% The reaction presence is then normalized over the total amount of maps
% used, colors and line widths are assigned based on the fraction value, 
% and the newly coloured map is saved in the directory with the XML files 
% used to create it. Parallelization is used if the Parallel Computing Toolbox
% is available.
%
% Usage:
%   rxnPrsTable = visualiseNormalisedRxnPresence(mapDir, setColours, numCores)
%
% Required inputs:
%   mapDir:     The directory with the XML files to be used.
%
% Optional inputs:
%   setColours: Cell array that defines the colour and line width scheme 
%               based on normalised reaction presence. Each row of setColours
%               should contain [fraction, colour, line width]. For example:
%               {1, 'c92a2a', 10; 0.9, 'ff6b6b', 8; ...}.
%               If not provided, a default set of colours and widths will be used.
%   numCores:   (Optional) If the Parallel Computing Toolbox is available, this
%               specifies the number of cores to use for parallel processing.
%               If not provided, all available cores will be used.
%
% Output:
%   rxnPrsTable: Table with for each map the reaction presence.
%
% Authors:
% .. Bram Nap. University of Galway, Ireland, 27/09/2024.
% .. modified by Cyrille C. Thinnes. University of Galway, Ireland,
% 27/09/2024. Reduced the color range and added taking account of rxn line
% width for improved readability of the heatmap. Implemented parallel
% computing capabilities.

% Default colour and line width scheme if none is provided.
if nargin < 2 || isempty(setColours)
    setColours = {
        1, 'c92a2a', 10;     % Red (darkest).
        0.9, 'ff6b6b', 8;    % Red (medium).
        0.7, 'ffc9c9', 7;    % Red (lightest).
        0.5, 'bac8ff', 5;    % Indigo (lightest).
        0.3, '5c7cfa', 3;    % Indigo (medium).
        0.1, '364fc7', 2;    % Indigo (darkest).
        0, 'D3D3D3', 1       % Light gray (for no presence).
    };
end

% Check if the Parallel Computing Toolbox is available.
parallelAvailable = license('test', 'Distrib_Computing_Toolbox');

% Get directory information and file names.
mapDir = dir(mapDir);
mapNames = {mapDir.name};

% Only get the XML files.
mapNames = mapNames(contains(mapNames, '.xml'));

% Initialise the table to save results in.
rxnPrsTable = table();

% The colour code used to colour reactions with (based on the publication).
colourCode2Extract = 'FF4500';

% Alpha code used in the XML file as an addition to the HTML colour code.
colourCodeAddition = 'FF';

% Preallocate a cell array for the parallel results.
rxnPresenceResults = cell(1, numel(mapNames));

% If parallelisation is available and numCores is provided, use it.
if parallelAvailable
    if nargin < 3 || isempty(numCores)
        % Use all available cores if no specific number of cores is provided.
        numCores = feature('numcores');
    end

    % Start a parallel pool with the specified number of cores.
    poolobj = gcp('nocreate');
    if isempty(poolobj)
        parpool('local', numCores);
    end

    % Process each map in parallel.
    parfor i = 1:numel(mapNames)
        % Load the map.
        [~, mapModel] = transformXML2Map(cell2mat(strcat(mapDir(1).folder, filesep, mapNames(i))));
        
        % Obtain a boolean array if the reaction colour for a reaction matches
        % the target colour.
        rxnPresent = strcmp(mapModel.rxnColor, [colourCodeAddition, colourCode2Extract]);
        
        % Store the boolean array in the results array (this avoids direct modification of rxnPrsTable in parfor).
        rxnPresenceResults{i} = rxnPresent;
    end

    % Close the parallel pool after processing.
    delete(gcp('nocreate'));
else
    % If no parallel computing toolbox is available, process sequentially.
    for i = 1:numel(mapNames)
        % Load the map.
        [~, mapModel] = transformXML2Map(cell2mat(strcat(mapDir(1).folder, filesep, mapNames(i))));
        
        % Obtain a boolean array if the reaction colour for a reaction matches
        % the target colour.
        rxnPresent = strcmp(mapModel.rxnColor, [colourCodeAddition, colourCode2Extract]);
        
        % Store the boolean array in the results array.
        rxnPresenceResults{i} = rxnPresent;
    end
end

% After the parallel or sequential loop, assign the results to rxnPrsTable.
for i = 1:numel(mapNames)
    colName = mapNames{i};
    rxnPrsTable.(colName) = rxnPresenceResults{i};
end

% Sum all the rows (reaction presence across maps).
summedRxnPresence = sum(rxnPrsTable{:,:}, 2);

% Normalise the data by the total number of maps.
normRxnPresence = summedRxnPresence / max(size(mapNames));

% Initialise arrays to store the new colour codes and line widths.
newRxnColour = cell(size(summedRxnPresence, 1), 1);
newRxnWidth = cell(size(summedRxnPresence, 1), 1);

% Define the colour and line width thresholds.
for j = 1:size(summedRxnPresence, 1)
    % Loop over the custom or default setColours scheme.
    for i = 1:size(setColours, 1)
        % Assign the final colour for exact matches.
        if normRxnPresence(j) == setColours{i,1}
            newRxnColour{j} = setColours{i,2};
            newRxnWidth{j} = setColours{i,3};
            break;
        % Assign the colour and width for ranges.
        elseif normRxnPresence(j) > setColours{i+1,1} && normRxnPresence(j) <= setColours{i,1}
            newRxnColour{j} = setColours{i,2};
            newRxnWidth{j} = setColours{i,3};
            break;
        end
    end
end

% Load the first map to save results in.
[mapXML, mapModel] = transformXML2Map(cell2mat(strcat(mapDir(1).folder, filesep, mapNames(1))));

% Remove any formatting previously done to the map.
blankMap = unifyMetabolicMapCD(mapModel);

% Set the new reaction colours and line widths.
blankMap.rxnColor = strcat(colourCodeAddition, newRxnColour);
blankMap.rxnWidth = newRxnWidth;

% Set the filename.
nameNormRxnMap = 'normalisedReactionHeatmap.xml';
filename = strcat(mapDir(1).folder, filesep, nameNormRxnMap);

% Save the map with the newly assigned colours and line widths.
transformMap2XML(mapXML, blankMap, filename);
end