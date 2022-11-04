function ETN = extractElementalTransitionNetwork(ATN, elements)
% Extracts specific chemical elements from an atom transition network.
%
% USAGE:
%
%    ETN = extractElementalTransitionNetwork(ATN, elements)
%
% INPUTS:
%    ATN:         An atom transition network
%    elements:    A cell array of element symbols, e.g., 'C' for carbon
%                 or {'C' 'O'} for carbon and oxygen
%
% OUTPUT:
%    ETN:         An elemental transition network for the specified elements
%
% .. Author: - Hulda S. Haraldsdóttir, June 2015

abool = ismember(ATN.elements,elements); % Find rows and columns involving element
tbool = any(ATN.A(abool,:));

% Generate output structure
ETN.A = ATN.A(abool,tbool);
ETN.mets = ATN.mets(abool);
ETN.rxns = ATN.rxns(tbool);
ETN.elements = ATN.elements(abool);
ETN.inputBool = ATN.inputBool(abool);
ETN.outputBool = ATN.outputBool(abool);
ETN.reverseBool = ATN.reverseBool(tbool);
