function [Component, Fraction] = printBiomass(model, BiomassNumber)
%
% function printBiomass(model,BiomassNumber)
%
% this
%
% model             model structure
% BiomassNumber     reaction number of biomass reaction (or any other
%                   reaction)
%
% Ines Thiele May 2008

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
