function [Component, Fraction] = printBiomass(model, BiomassNumber)
% Prints the metabolites and their stoichiometric coefficients that
% participate in a given reaction (typically the biomass reaction) and
% returns them as well
%
% USAGE:
%
%    [Component, Fraction] = printBiomass(model, BiomassNumber)
%
% INPUTS:
%    model:            COBRA model structure with fields:
%
%                        * .S - `m` x `n` stoichiometric matrix (used if `.A` is absent)
%                        * .A - stoichiometric/coupling matrix, used in place of `.S` when present
%                        * .mets - `m` x 1 cell array of metabolite identifiers
%    BiomassNumber:    column index of the biomass reaction (or any other
%                      reaction) in `model.S`
%
% OUTPUTS:
%    Component:        cell array of metabolite identifiers with a nonzero
%                      coefficient in reaction `BiomassNumber`
%    Fraction:         stoichiometric coefficients of `Component` in reaction `BiomassNumber`
%
% .. Author: - Ines Thiele, May 2008

if (isfield(model, 'A'))
    model.S = model.A;
end

Component = model.mets(find(model.S(:, BiomassNumber)));
Fraction = model.S(find(model.S(:, BiomassNumber)), BiomassNumber);

for i = 1:length(Component)
    fprintf('%s', Component{i});
    fprintf('\t');
    fprintf('%e', full(Fraction(i)));
    fprintf('\n');
end
