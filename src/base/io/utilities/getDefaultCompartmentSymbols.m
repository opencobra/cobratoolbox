function [defaultCompartmentSymbolList, defaultCompartmentNameList] = getDefaultCompartmentSymbols()
% Returns the default compartment symbol and
% name lists to use for model IO or compartment matching
% USAGE:
%
%    [defaultCompartmentSymbolList, defaultCompartmentNameList] = getDefaultCompartmentSymbols()
%
% OUTPUT:
%    defaultCompartmentSymbolList:    a List of abbreviations of
%                                     compartment names
%
%    defaultCompartmentNameList:      a List of names of compartments where element `i` corresponds
%                                     to the `i`-th abbreviation in `defaultCompartmentSymbolList`
%
% .. Author: - Thomas Pfau May 2017

[defaultCompartmentSymbolList,defaultCompartmentNameList] = getDefaultCompartments();

end
