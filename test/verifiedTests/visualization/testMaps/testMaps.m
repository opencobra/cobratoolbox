% The COBRAToolbox: testMaps.m
%
% Purpose:
%     - tests the functionality of drawFluxVariability and drawFlux
%     functions
%
% Authors:
%     - Farid Zare, 04/06/2025: Enhanced formatting and documentation.
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testMaps'));
cd(fileDir);

fprintf('   Testing testMaps ... \n')

mapCoordinateFilename='ecoli_core_map.txt';

map = readCbMap(mapCoordinateFilename);
load('ecoli_core_model.mat');
sol = optimizeCbModel(model);
global CB_MAP_OUTPUT
CB_MAP_OUTPUT = 'svg';

drawCbMap(map);

%tests drawConc with zero concentrations of metabolites
disp('Testing drawConc with zero concentrations');
conc = zeros(size(model.metNames,1), 1);
drawConc(map, model, conc);

disp('Testing drawConc with non-zero concentrations');
conc = rand(size(model.metNames,1),1);
drawConc(map, model, conc);

%tests drawFlux with zero fluxes
disp('Testing drawFlux with zero flux');
flux = zeros(size(model.rxns,1), 1);
drawFlux(map, model, flux);
% Check and remove 'target.svg' if it exists
assert(exist('target.svg', 'file') == 2)
delete('target.svg');

%tests drawFlux with non-zero fluxes w/ reaction with zero flux set to
%width of 1
disp('Testing drawFlux with non-zero flux');
flux = sol.x;
drawFlux(map, model, flux, [],'zeroFluxWidth',1);
% Check and remove 'target.svg' if it exists
assert(exist('target.svg', 'file') == 2)
delete('target.svg');

%tests drawFluxVariablity with enlarged arrowheads to denote flux
%directionality
load('testMapsData.mat','minFlux','maxFlux');
disp('Testing drawFluxVariability')
drawFluxVariability(map,model,minFlux,maxFlux,[],'rxnDirMultiplier',2.5);
% Check and remove 'target.svg' if it exists
assert(exist('target.svg', 'file') == 2)
delete('target.svg');

x=1;
if ~strcmp(CB_MAP_OUTPUT,'svg')
    close(f);
end

% output a success message
fprintf('Done.\n');

% change the directory
cd(currentDir)

