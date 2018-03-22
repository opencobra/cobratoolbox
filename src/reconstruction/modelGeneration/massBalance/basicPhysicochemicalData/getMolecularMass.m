function [Masses, knownMasses, unknownElements, Ematrix, elements] = getMolecularMass(formulae, isotopeAbundance, generalFormula)
% Gets mono-isotopic exact molecular mass for a single formula or a cell array of
% formulae using the atomic weight for each element from NIST
% http://physics.nist.gov/PhysRefData/Compositions/
%
% An atomic weight of an element from a specified source is the ratio of
% the average mass per atom of the element to 1/12 of the mass of an
% atom of 12C.
%
% Note the term "relative atomic mass" is usually reserved for the mass of a
% specific nuclide (or isotope), while "atomic weight" is usually used for the
% weighted mean of the relative atomic mass over all the atoms in the
% sample (polyisotopic mass).
%
% If the ratio of the different isotopes are known exactly, this may be
% provided in the `m` x 3 cell array of m isotopes, i.e. `isotopeAbundance`.
%
% By default, this script gives the molecular mass assuming monoisotopic
% exact mass.
%
% USAGE:
%
%    [Masses, knownMasses, unknownElements, Ematrix, elements] = getMolecularMass(formulae, isotopeAbundance, generalFormula)
%
% INPUT:
%    formulae:             single formula or a cell array of formulae
%
% OPTIONAL INPUTS:
%    isotopeAbundance:    {(1), 0} where:
%
%                         1 = monoisotopic exact mass i.e. only uses naturally predominant isotope
%                         of each element.
%
%                         0 = polyisotopic inexact mass i.e. uses all isotopes of each element weighted
%                         by natural abundance
%
%                         or
%
%                         `m` x 3 cell arrray with user defined isotope abundance:
%                         isotopeAbundance{i, 1} = 'Atomic_Symbol';
%                         isotopeAbundance{i, 2} = Mass_Number;
%                         isotopeAbundance{i, 3} = abundance;
%                         (where sum of abundances of all isotopes of an element must be one)
%    generalFormula       * (default) false to support formulae containing only biological elements.
%                           Return Masses = 0 if a formula contains none of these elements.
%                           (C, O, P, N, S, H, Mg, Na, K, Cl, Ca, Zn, Fe, Cu, Mo, I)
%                         * true to support formulae with brackets, decimal places and any chemical elements
%                           including undefined groups (e.g., '([H2O]2(CuSO4))2Generic_element0.5').
%                           Return Masses = NaN for any formulae with chemical elements of unknown weights
%                           except the reserved formula 'Mass0' for denoting truly massless metabolites (e.g., photon)
%
% OUTPUT:
%    Masses:              molecular mass(es) in (gram/Mol)
%    (the below are non-empty only if general = true)
%    knownWeights:        MWs for the part whose MW is computable ofr each of the formulae
%    unknownElements:     cell arrary of elements without known atomic weights that appear in the formulae
%    Ematrix:             elemental composition matrix (#formulae x #elements)
%    element:             cell array of elements corresponding to the columns of Ematrix
%
% EXAMPLE:
%
%    % e.g. Carbon, all as C13
%    isotopeAbundance{i,1}= 'C'
%    isotopeAbundance{i,2}= 12;
%    isotopeAbundance{i,3}= 0;
%    isotopeAbundance{i+1,1}= 'C'
%    isotopeAbundance{i+1,2}= 13;
%    isotopeAbundance{i+1,3}= 1;
%    isotopeAbundance{i+2,1}= 'C'
%    isotopeAbundance{i+2,2}= 14;
%    isotopeAbundance{i+2,3}= 0;
%
% NOTE:
%
%    Exact mass check:
%    If you want to double check that the mass given by this script is correct
%    then compare it to either
%
%      1. OpenBabel: `echo "InChIstring" | babel -iinchi -  -oreport`  or
%      2. http://www.sisweb.com/referenc/tools/exactmass.htm
%    Please report any errors as these are critical for use of this script
%    with mass spec machines.
%
% .. Author:
%       - Ronan Fleming 9 March 09 ronan.mt.fleming@gmail.com, 15 Sept 09, support for non-natural isotope distributions

if nargin < 3 || isempty(generalFormula)
    generalFormula = false;
end

if nargin < 2 || isempty(isotopeAbundance)
    isotopeAbundance =1;
end

if ischar(formulae)
    formulae = {formulae};
else
    formulae = formulae(:);  % make sure it is a column cell array
end

% get the list of elements and their atomic masses
elementalWeightMatrix = getElementalWeightMatrix(isotopeAbundance);
Masses = zeros(length(formulae),1);

if ~generalFormula
    allBiologicalElements={'C','O','P','N','S','H','Mg','Na','K','Cl','Ca','Zn','Fe','Cu','Mo','I'};
    [~, id] = ismember(allBiologicalElements, elementalWeightMatrix(:, 1));
    for n = 1:length(formulae)
        for a = 1:length(allBiologicalElements)
            %number of atoms in element
            N = numAtomsOfElementInFormula(formulae{n}, allBiologicalElements{a});
            Masses(n) = Masses(n) + N * elementalWeightMatrix{id(a), 2};
        end
    end
    [knownMasses, Ematrix] = deal([]);
    [unknownElements, elements] = deal({});
else
    % get elemental composition matrix
    [Ematrix, elements] = getElementalComposition(formulae, [], 1);
    % atomic mass for each element
    eleMW = nan(numel(elements), 1);
    [yn, id] = ismember(elements, elementalWeightMatrix(:, 1));
    eleMW(yn) = cell2mat(elementalWeightMatrix(id(yn), 2));
    % elements without identified atomic mass.
    eleWoWeight = isnan(eleMW);
    unknownElements = elements(eleWoWeight);
    if all(eleWoWeight)
        % avoid returning empty vector if all elements are undefined
        knownMasses = zeros(numel(formulae), 1);
    else
        knownMasses = Ematrix(:, ~eleWoWeight) * eleMW(~eleWoWeight);
    end
    Masses = knownMasses;
    % reserve the special keyword 'Mass0' to signify truly massless metabolites (e.g., photon)
    Masses((~any(Ematrix(:, ~eleWoWeight), 2) | any(Ematrix(:, eleWoWeight), 2)) ...
        & ~strcmp(formulae, 'Mass0')) = NaN;
    % empty formulae have undefined weights
    Masses(cellfun(@isempty, formulae)) = NaN;
end
end
