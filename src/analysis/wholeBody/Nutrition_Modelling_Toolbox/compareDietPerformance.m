function [dietPerformance] = compareDietPerformance(model, diets,rois, varargin)
% Function to check the effect of different diets on the possible flux
% range for specified reactions.
%
% [dietPerformance] = compareDietPerformance(model, diets, rois, varargin)
% 
% Example: [dietPerformance] = compareDietPerformance(model, diets, rois,
% 'optPercentage', 0.95, 'microbiotaExcretionBound', 0.5)
%
% INPUTS:
%   model:          COBRA model where the rois are present
%   diets:          Cell array where each cell contains an cell array with
%                   The metabolite composition of the diet {'met', value}
%   rois:           Cell array with reactions to investigate under
%                   different diets
%
% OPTIONAL INPUTS:
%   optPercentage:  Integer, used in fluxVariability to indicate the
%                   percentage of the objective for which FVA is solved.  
%                   Defaults to 99
%   microbiotaExretionBound: Integer, used to constrain both bounds of 
%                   Excretion_EX_microbiota_LI_biomass. Defaults to 1
%   dietNames:      Cell array with names for diets in that will be used in
%                   the output. Defaults to Diet1, Diet2 etcetc.
% OUTPUT:
%   dietPerformance:    Table for each given diet, the min and max flux for
%                   each roi.
%
% .. Authors: - Bram Nap 06-2022 

% Initialise the inputs
parser = inputParser();
parser.addRequired('model', @isstruct);
parser.addRequired('diets', @iscell);
parser.addRequired('rois', @iscell);
parser.addParameter('optPercentage', 99, @isnumeric);
parser.addParameter('microbiotaExcretionBound', 1, @isnumeric);
parser.addParameter('dietNames', cell(0), @iscell);

parser.parse(model, diets, rois, varargin{:});

model = parser.Results.model;
diets = parser.Results.diets;
rois = parser.Results.rois;
optPercentage = parser.Results.optPercentage;
microbiotaExcretionBound = parser.Results.microbiotaExcretionBound;
dietNames = parser.Results.dietNames;

% If the dietNames are not specified, create general names
if isempty(dietNames)
    for i = 1:length(diets)
        dietNames(i) = {['Diet' + string(i)]};
    end
    % Required to prevent errors
    dietNames = string(dietNames);
end

% Initialise array to store results in
dietPerformance = cell(2*length(rois), length(diets)+2);

% Loop over the diets
for i = 1:length(diets)
    diet = diets{i};
    
    % Constrain the model to the diet and microbiota exchange bounds
    modelDiet = setFoodConstraints(model, diet);
    modelDiet = changeRxnBounds(modelDiet, 'Excretion_EX_microbiota_LI_biomass',microbiotaExcretionBound,'b');
    
    % Solve with FVA and store results
    [minFlux, maxFlux] = fluxVariability(modelDiet, optPercentage, 'max', rois);
    for j = 1:length(rois)
        dietPerformance(j*2-1:j*2,1) = {rois(j)};
        dietPerformance(j*2-1:j*2,2) = {{'min'};{'max'}};
        dietPerformance(j*2-1:j*2,i+2) = {minFlux(j); maxFlux(j)};
    end
end

% Create the final table
dietPerformance = cell2table(dietPerformance);
dietPerformance.Properties.VariableNames(1:2) = {'Reactions', 'MinMax'};
dietPerformance.Properties.VariableNames(3:end) = dietNames;

end