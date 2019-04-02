% The COBRAToolbox: testGetDefaultCompartmentSymbols.m
%
% Purpose:
%     - test the getDefaultCompartmentSymbols function
%
% Authors:
%     - Jacek Wachowiak

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('getDefaultCompartmentSymbols'));
cd(fileDir);

% test variables
testCompSymbolList = {'c','m','v','x','e','t','g','r','n','p','l','u','y','k'};
testCompNameList = {'Cytoplasm','Mitochondrion','Vacuole','Peroxisome','Extracellular','Pool','Golgi','Endoplasmic_reticulum','Nucleus','Periplasm','Lysosome','Lumen','Glycosome','Unknown'};

% function outputs
[defaultCompartmentSymbolList, defaultCompartmentNameList] = getDefaultCompartmentSymbols();

% test
assert(isequal(defaultCompartmentSymbolList, testCompSymbolList))
assert(isequal(defaultCompartmentNameList, testCompNameList))

% change to old directory
cd(currentDir);
