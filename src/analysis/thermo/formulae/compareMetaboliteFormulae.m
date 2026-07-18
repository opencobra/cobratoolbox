function compareMetaboliteFormulae(modelT)
% Prints out a tab delimited file with the abbreviations, reconstruction
% metabolite formluae, and group contribution metabolite formulae.
%
% USAGE:
%
%    compareMetaboliteFormulae(modelT)
%
% INPUT:
%    modelT:    output of `setupThermoModel`, with fields:
%
%                 * .S - `m x n` stoichiometric matrix
%                 * .mets - `m x 1` cell array of metabolite identifiers
%                 * .metFormulas - `m x 1` cell array of metabolite formulas

fid=fopen('metaboliteFormulae.txt','w');

[nMet,nRxn]=size(modelT.S);

for m=1:nMet
    fprintf(fid,'%20s%20s\t%20s\n',modelT.mets{m},modelT.metFormulas{m},modelT.met(m).formulaMarvin);
end
fclose(fid);
