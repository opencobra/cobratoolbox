function x = testMaps()
%tests the functionality of the functions in testMaps especially drawLine,
%   drawConc, drawFlux
%
%   testMaps
%
%
%

oriFolder = pwd;

mFilePath = mfilename('fullpath');
cd(mFilePath(1:end-length(mfilename)));

mapCoordinateFilename='ecoli_core_map.txt';

map = readCbMap(mapCoordinateFilename);
load('ecoli_core_model.mat');
sol = optimizeCbModel(model);
global CB_MAP_OUTPUT
if ~strcmp(CB_MAP_OUTPUT,'svg')
    f = figure;
end
drawCbMap(map);

%tests drawConc with zero concentrations of metabolites
disp('Testing drawConc with zero concentrations');
conc = zeros(size(model.metNames,1), 1);
drawConc(map, model, conc);
disp(' ');
disp(' ');

disp('Testing drawConc with non-zero concentrations');
conc = rand(size(model.metNames,1),1);
drawConc(map, model, conc);
disp(' ');
disp(' ');

%tests drawFlux with zero fluxes
disp('Testing drawFlux with zero flux');
flux = zeros(size(model.rxns,1), 1);
drawFlux(map, model, flux);
disp(' ');
disp(' ');

%tests drawFlux with non-zero fluxes w/ reaction with zero flux set to
%width of 1
disp('Testing drawFlux with non-zero flux');
flux = sol.x;
drawFlux(map, model, flux, [],'zeroFluxWidth',1);
disp(' ');
disp(' ');

%tests drawFluxVariablity with enlarged arrowheads to denote flux
%directionality
load('testMapsData.mat','minFlux','maxFlux');
display('Testing drawFluxVariability')
drawFluxVariability(map,model,minFlux,maxFlux,[],'rxnDirMultiplier',2.5);
display(' ');
display(' ');


x=1;
if ~strcmp(CB_MAP_OUTPUT,'svg')
    close(f);
end
cd(oriFolder);

end