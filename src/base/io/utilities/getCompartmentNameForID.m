function compName = getCompartmentNameForID(compID)
% Get the default Compartment name for the given compartment ID.
% USAGE: 
%    compName = getCompartmentNameForID(compID)
% 
% INPUT:
%    compID:                The ID of the compartment
%
% OUTPUT:
%    compName:              The name of the compartment (if it is available
%                           in the `getDefaultCompartments()` function.
%                           Otherwise the compID will be returned.

[compSymbols,compNames] = getDefaultCompartments();
[pres] = ismember(compSymbols,compID);
if any(pres)
    compName = compNames{pres};
else
    compName = compID;
end
