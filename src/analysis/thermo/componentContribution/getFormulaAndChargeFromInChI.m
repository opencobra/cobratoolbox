function [formula, nH, charge] = getFormulaAndChargeFromInChI(inchi)
% USAGE:
%
%    [formula, nH, charge] = getFormulaAndChargeFromInChI(inchi)
%
% INPUT:
%    inchi:      Nonstandard IUPAC InChI for a particular pseudoisomer of a
%                metabolite
%
% OUTPUTS:
%    formula:    The chemical formula for the input pseudoisomer
%    nH:         The number of total Hydrogen in the actual protonation form
%    charge:     The charge on the input pseudoisomer (excluding the protonation state)
%

% Get the Formula and the number of protons
[formula, nH] = getFormulaFromInChI(inchi);

% Get the charge of the unprotonated compound.
[~, charge] = getChargeFromInChI(inchi);

end
