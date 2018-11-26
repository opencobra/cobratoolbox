function [ compSymbolList, compNameList  ] = getDefaultCompartments( )
%GETDEFAULTCOMPARTMENTS returns the default compartment Symbols and default Compartments 
%
%   USAGE:  [ compSymbolList, compNameList  ] = getDefaultCompartments( )
%
% OUTPUT:
%    compSymbolList:       Default symbols of compartments 
%    compNameList:         Names of the default compartments.
%
% .. Authors: Thomas Pfau May 2017
    compSymbolList = {'c','m','v','x','e','t','g','r','n','p','l','u','y','k'};
    compNameList = {'Cytoplasm','Mitochondrion','Vacuole','Peroxisome','Extracellular','Pool','Golgi','Endoplasmic_reticulum','Nucleus','Periplasm','Lysosome','Lumen','Glycosome','Unknown'};

end

