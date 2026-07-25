function [dietPerformance] = compareDietPerformance(model, diets, rois, varargin)
% Check the effect of different diets on the possible flux range for a set
% of specified reactions
%
% USAGE:
%
%    [dietPerformance] = compareDietPerformance(model, diets, rois, varargin)
%
% INPUTS:
%    model:            COBRA model in which the reactions of interest are
%                      present
%    diets:            Cell array where each cell holds a cell array with the
%                      metabolite composition of a diet as {'met', value}
%    rois:             Cell array of reactions to investigate under the
%                      different diets
%
% OPTIONAL INPUTS:
%    varargin:         Name-value pairs:
%
%                        * optPercentage - percentage of the objective used
%                          by fluxVariability when solving FVA (default 99)
%                        * microbiotaExcretionBound - value used to constrain
%                          both bounds of Excretion_EX_microbiota_LI_biomass
%                          (default 1)
%                        * dietNames - cell array of names for the diets used
%                          in the output (default Diet1, Diet2, ...)
%
% OUTPUT:
%    dietPerformance:     Table giving, for each diet, the minimum and maximum
%                      flux of each reaction of interest
%
% .. Author: - Bram Nap, 06-2022

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