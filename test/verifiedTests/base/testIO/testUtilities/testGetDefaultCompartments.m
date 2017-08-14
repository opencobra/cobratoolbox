% The COBRAToolbox: testGetDefaultCompartments.m
%
% Purpose:
%     - test the getDefaultCompartments function
%
% Authors:
%     - Jacek Wachowiak

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('getDefaultCompartmentSymbols'));
cd(fileDir);

% test variables
testCompSymbolList = {'c','m','v','x','e','t','g','r','n','p','l','u'};
testCompNameList = {'Cytoplasm','Mitochondrion','Vacuole','Peroxisome','Extracellular','Pool','Golgi','Endoplasmic_reticulum','Nucleus','Periplasm','Lysosome','Unknown'};
% function outputs
[compSymbolList, compNameList] = getDefaultCompartments();

% test
assert(isequal(compSymbolList, testCompSymbolList))
assert(isequal(compNameList, testCompNameList))
% change to old directory
cd(currentDir);
