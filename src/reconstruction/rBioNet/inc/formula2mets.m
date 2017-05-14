function metabolites = formula2mets(formula)
% Takes a rxn formula and produces a list of metabolites
%
% USAGE:
%
%    metabolites = formula2mets(formula)
%
% INPUT:
%    formula:       rxn formula
%
% OUTPUT:
%    metabolites:   list of metabolites
%
% NOTE:
%    uses `parseRxnFormula.m` (Cobra Toolbox)
%
% .. Author: - Stefan G. Thorleifsson 2011
%
% .. rBioNet is published under GNU GENERAL PUBLIC LICENSE 3.0+
% .. Thorleifsson, S. G., Thiele, I., rBioNet: A COBRA toolbox extension for
% .. reconstructing high-quality biochemical networks, Bioinformatics, Accepted.
% .. rbionet@systemsbiology.is
mets = parseRxnFormula(formula);
metabolites = regexprep(mets, '\[.+\]', '');
