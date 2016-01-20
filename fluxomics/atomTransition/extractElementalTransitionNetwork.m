function ETN = extractElementalTransitionNetwork(ATN,elements)
% Extracts specific chemical elements from an atom transition network.
% 
% ETN = extractElementalTransitionNetwork(ATN,elements)
% 
% INPUTS
% ATN      ... An atom transition network
% elements ... A cell array of element symbols, e.g., 'C' for carbon
%             or {'C' 'O'} for carbon and oxygen
% 
% OUTPUT
% ETN      ... An elemental transition network for the specified elements
% 
% June 2015 Hulda S. Haraldsdóttir

% Find rows and columns involving element
abool = ismember(ATN.elements,elements);
tbool = any(ATN.A(abool,:));

% Generate output structure
ETN.A = ATN.A(abool,tbool);
ETN.mets = ATN.mets(abool);
ETN.rxns = ATN.rxns(tbool);
ETN.elements = ATN.elements(abool);
ETN.inputBool = ATN.inputBool(abool);
ETN.outputBool = ATN.outputBool(abool);
ETN.reverseBool = ATN.reverseBool(tbool);