function [defaultCompartmentSymbolList,defaultCompartmentNameList ] = getDefaultCompartmentSymbols()
%GETDEFAULTCOMPARTMENTSYMBOLS returns the default compartment symbol and
%name lists to use for model IO or compartment matching
%   OUTPUT
%       defaultCompartmentSymbolList    a List of abbreviations of
%                                       compartment names
%
%       defaultCompartmentNameList      a List of names of compartments where element i corresponds 
%                                       to the i-th abbreviation in defaultCompartmentSymbolList
%
%

defaultCompartmentSymbolList = {'c','m','v','x','e','t','g','r','n','p','l','y'};
defaultCompartmentNameList = {'Cytoplasm','Mitochondrion','Vacuole','Peroxisome','Extracellular','Pool','Golgi','Endoplasmic_reticulum','Nucleus','Periplasm','Lysosome','Glycosome'};

end

