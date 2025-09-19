function smallFBAsolutionPaths = slimDownFBAresults(FBAsolutionDir)
% This function prunes FBA solution results obtained in 
% optimiseRxnMultipleWBM.m and saves the slimmed down solution results in a
% new folder. The function first creates a new folder and generates paths
% for the flux results in that folder. Then, only the following data is
% loaded: 'rxns','ID','sex','f', and'stat'. If microbiome data was available:
% 'speciesBIO','shadowPriceBIO', and 'relAbundances'. Then, the solutions
% are saved to the new paths.
%
% INPUT
% FBAsolutionDir            Character array with path to FBA solutions.
%
% OUTPUT
% smallFBAsolutionPaths     Path to slimmed down FBA results
%
% AUTHOR: Tim Hensen, October 2024

% Create new folder name
newFolder = [FBAsolutionDir '_SLIM'];

% Check if new folder exists
if exist(newFolder,'dir') ~= 7
    mkdir(newFolder)
end

% Find .mat files in the FBA folder
fbaDirData = what(FBAsolutionDir);
fbaPaths = string(append(FBAsolutionDir, filesep, fbaDirData.mat));
newFbaPaths = string(append(newFolder, filesep, fbaDirData.mat));

warning('off')
for i = 1:length(newFbaPaths)
    disp(strcat("Slim down solution: ", string(i)))
    % Load results
    solution = load(fbaPaths(i),'rxns','ID','sex','f','stat','speciesBIO','shadowPriceBIO','relAbundances');

    % Save updated main 
    save(newFbaPaths(i),'-struct', 'solution')
end
warning('on')

% Set output
smallFBAsolutionPaths = newFbaPaths;
end