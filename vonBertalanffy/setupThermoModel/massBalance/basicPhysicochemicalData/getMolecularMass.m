function M=getMolecularMass(formulae,isotopeAbundance)
% get mono-isotopic exact molecular mass for a single formula or a cell array of
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
%
% If the ratio of the different isotopes are known exactly, this may be
% provided in the m x 2 cell array of m isotopes, i.e. isotopeAbundance.
%
% By default, this script gives the molecular mass assuming monoisotopic
% exact mass.
%
% INPUT
% formula           single formula or a cell array of formulae
%
% OPTIONAL INPUT
% isotopeAbundance  {(1),0} 
%                   1 = monoisotopic exact mass
%                       i.e. only uses naturally predominant isotope
%                       of each element.
%                   0 = polyisotopic inexact mass
%                       i.e. uses all isotopes of each element weighted
%                       by natural abundance
%                   
%                   or
% 
%                   m x 2 cell arrray with user defined isotope abundance
%                   isotopeAbundance{i,1}= 'Atomic_Symbol';
%                   isotopeAbundance{i,2}= Mass_Number;
%                   isotopeAbundance{i,3}= abundance;
%                   (where sum of abundances of all isotopes of an element
%                   must be one)
%
%                   e.g. Carbon, all as C13
%                   isotopeAbundance{i,1}= 'C'
%                   isotopeAbundance{i,2}= 12;
%                   isotopeAbundance{i,3}= 0;
%                   isotopeAbundance{i+1,1}= 'C'
%                   isotopeAbundance{i+1,2}= 13;
%                   isotopeAbundance{i+1,3}= 1;
%                   isotopeAbundance{i+2,1}= 'C'
%                   isotopeAbundance{i+2,2}= 14;
%                   isotopeAbundance{i+2,3}= 0;
%
% OUTPUT
% M         molecular mass(es) in (gram/Mol)
%
% Exact mass check:
% If you want to double check that the mass given by this script is correct
% then compare it to either
% (1) OpenBabel: echo "InChIstring"|babel -iinchi -  -oreport
% or
% (2) http://www.sisweb.com/referenc/tools/exactmass.htm
% Please report any errors as these are critical for use of this script
% with mass spec machines.
% 
% Ronan Fleming 9 March 09  ronan.mt.fleming@gmail.com
%               15 Sept 09  Support for non-natural isotope distributions

if ~exist('isotopeAbundance','var')
    isotopeAbundance =1;
end

if ischar(formulae)
    tmp=formulae;
    formulae=[];
    formulae{1}=tmp;
end

if exist('isotopeAbundance','var')
    isotopeSensitive=1;
    if isnumeric(isotopeAbundance) || islogical(isotopeAbundance)
        if isotopeAbundance
            clear isotopeAbundance
            %Uses only the most naturally predominant isotope of each
            %element
            isotopeSensitive=1;
            i=1;
            %e.g. Carbon, all as C12
            isotopeAbundance{i,1}= 'C';
            isotopeAbundance{i,2}= 12;
            isotopeAbundance{i,3}= 1;
            i=i+1;
            isotopeAbundance{i,1}= 'C';
            isotopeAbundance{i,2}= 13;
            isotopeAbundance{i,3}= 0;
            i=i+1;
            isotopeAbundance{i,1}= 'C';
            isotopeAbundance{i,2}= 14;
            isotopeAbundance{i,3}= 0;
            i=i+1;
            %e.g. Hydrogen, all as H1
            isotopeAbundance{i,1}= 'H';
            isotopeAbundance{i,2}= 1;
            isotopeAbundance{i,3}= 1;
            i=i+1;
            %e.g. Oxygen, all as O16
            isotopeAbundance{i,1}= 'O';
            isotopeAbundance{i,2}= 16;
            isotopeAbundance{i,3}= 1;
            i=i+1;
            isotopeAbundance{i,1}= 'O';
            isotopeAbundance{i,2}= 17;
            isotopeAbundance{i,3}= 0;
            i=i+1;
            isotopeAbundance{i,1}= 'O';
            isotopeAbundance{i,2}= 18;
            isotopeAbundance{i,3}= 0;
            i=i+1;
            %e.g. Nitrogen, all as N14
            isotopeAbundance{i,1}= 'N';
            isotopeAbundance{i,2}= 14;
            isotopeAbundance{i,3}= 1;
            i=i+1;
            isotopeAbundance{i,1}= 'N';
            isotopeAbundance{i,2}= 15;
            isotopeAbundance{i,3}= 0;
            i=i+1;
            %e.g. Sulphur, all as S32 (94% naturally S32)
            isotopeAbundance{i,1}= 'S';
            isotopeAbundance{i,2}= 32;
            isotopeAbundance{i,3}= 1;
            i=i+1;
            isotopeAbundance{i,1}= 'S';
            isotopeAbundance{i,2}= 33;
            isotopeAbundance{i,3}= 0;
            i=i+1;
            isotopeAbundance{i,1}= 'S';
            isotopeAbundance{i,2}= 34;
            isotopeAbundance{i,3}= 0;
            i=i+1;
            isotopeAbundance{i,1}= 'S';
            isotopeAbundance{i,2}= 35;
            isotopeAbundance{i,3}= 0;
            i=i+1;
            %e.g. Magnesium, all as Mg24, (79 % naturally Mg24)
            isotopeAbundance{i,1}= 'Mg';
            isotopeAbundance{i,2}= 24;
            isotopeAbundance{i,3}= 1;
            i=i+1;
            isotopeAbundance{i,1}= 'Mg';
            isotopeAbundance{i,2}= 25;
            isotopeAbundance{i,3}= 0;
            i=i+1;
            isotopeAbundance{i,1}= 'Mg';
            isotopeAbundance{i,2}= 26;
            isotopeAbundance{i,3}= 0;
            i=i+1;
            %e.g. Magnesium, all as Mg24, (93% naturally K39)
            isotopeAbundance{i,1}= 'K';
            isotopeAbundance{i,2}= 39;
            isotopeAbundance{i,3}= 1;
            i=i+1;
            isotopeAbundance{i,1}= 'K';
            isotopeAbundance{i,2}= 40;
            isotopeAbundance{i,3}= 0;
            i=i+1;
            isotopeAbundance{i,1}= 'K';
            isotopeAbundance{i,2}= 41;
            isotopeAbundance{i,3}= 0;
            i=i+1;
            %e.g. Chlorine, all as Cl35 (75.78 naturally Cl35)
            isotopeAbundance{i,1}= 'Cl';
            isotopeAbundance{i,2}= 35;
            isotopeAbundance{i,3}= 1;
            i=i+1;
            isotopeAbundance{i,1}= 'Cl';
            isotopeAbundance{i,2}= 37;
            isotopeAbundance{i,3}= 0;
            i=i+1;
            %e.g. Calcium, all as Ca40 (96% naturally Ca40)
            isotopeAbundance{i,1}= 'Ca';
            isotopeAbundance{i,2}= 40;
            isotopeAbundance{i,3}= 1;
            i=i+1;
            isotopeAbundance{i,1}= 'Ca';
            isotopeAbundance{i,2}= 42;
            isotopeAbundance{i,3}= 0;
            i=i+1;
            isotopeAbundance{i,1}= 'Ca';
            isotopeAbundance{i,2}= 43;
            isotopeAbundance{i,3}= 0;
            i=i+1;
            isotopeAbundance{i,1}= 'Ca';
            isotopeAbundance{i,2}= 44;
            isotopeAbundance{i,3}= 0;
            i=i+1;
            isotopeAbundance{i,1}= 'Ca';
            isotopeAbundance{i,2}= 46;
            isotopeAbundance{i,3}= 0;
            i=i+1;
            isotopeAbundance{i,1}= 'Ca';
            isotopeAbundance{i,2}= 48;
            isotopeAbundance{i,3}= 0;
            i=i+1;
            % Zinc, all as Zn64 (48% naturally Zn64)
            isotopeAbundance{i,1}= 'Zn';
            isotopeAbundance{i,2}= 64;
            isotopeAbundance{i,3}= 1;
            i=i+1;
            isotopeAbundance{i,1}= 'Zn';
            isotopeAbundance{i,2}= 66;
            isotopeAbundance{i,3}= 0;
            i=i+1;
            isotopeAbundance{i,1}= 'Zn';
            isotopeAbundance{i,2}= 67;
            isotopeAbundance{i,3}= 0;
            i=i+1;
            isotopeAbundance{i,1}= 'Zn';
            isotopeAbundance{i,2}= 68;
            isotopeAbundance{i,3}= 0;
            i=i+1;
            isotopeAbundance{i,1}= 'Zn';
            isotopeAbundance{i,2}= 70;
            isotopeAbundance{i,3}= 0;
            i=i+1;
            % Copper, all as Cu63 (69% naturally Cu63)
            isotopeAbundance{i,1}= 'Cu';
            isotopeAbundance{i,2}= 63;
            isotopeAbundance{i,3}= 0;
            i=i+1;
            isotopeAbundance{i,1}= 'Cu';
            isotopeAbundance{i,2}= 65;
            isotopeAbundance{i,3}= 0;
            i=i+1;
            % Molybdenum, all as Mo98 (24% naturally Mo98)
            isotopeAbundance{i,1}= 'Mo';
            isotopeAbundance{i,2}= 92;
            isotopeAbundance{i,3}= 0;
            i=i+1;
            isotopeAbundance{i,1}= 'Mo';
            isotopeAbundance{i,2}= 94;
            isotopeAbundance{i,3}= 0;
            i=i+1;
            isotopeAbundance{i,1}= 'Mo';
            isotopeAbundance{i,2}= 95;
            isotopeAbundance{i,3}= 0;
            i=i+1;
            isotopeAbundance{i,1}= 'Mo';
            isotopeAbundance{i,2}= 96;
            isotopeAbundance{i,3}= 0;
            i=i+1;
            isotopeAbundance{i,1}= 'Mo';
            isotopeAbundance{i,2}= 97;
            isotopeAbundance{i,3}= 0;
            i=i+1;
            isotopeAbundance{i,1}= 'Mo';
            isotopeAbundance{i,2}= 98;
            isotopeAbundance{i,3}= 1;
            i=i+1;
            isotopeAbundance{i,1}= 'Mo';
            isotopeAbundance{i,2}= 100;
            isotopeAbundance{i,3}= 0;
            i=i+1;
            % Phosphorus
            isotopeAbundance{i,1}= 'P';
            isotopeAbundance{i,2}= 31;
            isotopeAbundance{i,3}= 1;
            i=i+1;
            %Sodium
            isotopeAbundance{i,1}= 'Na';
            isotopeAbundance{i,2}= 23;
            isotopeAbundance{i,3}= 1;
            i=i+1;
            %Iron
            isotopeAbundance{i,1}= 'Fe';
            isotopeAbundance{i,2}= 54;
            isotopeAbundance{i,3}= 0;
            i=i+1;
            isotopeAbundance{i,1}= 'Fe';
            isotopeAbundance{i,2}= 56;
            isotopeAbundance{i,3}= 1;
            i=i+1;
            isotopeAbundance{i,1}= 'Fe';
            isotopeAbundance{i,2}= 57;
            isotopeAbundance{i,3}= 0;
            i=i+1;
            isotopeAbundance{i,1}= 'Fe';
            isotopeAbundance{i,2}= 58;
            isotopeAbundance{i,3}= 0;
            i=i+1;
            %Iodine
            isotopeAbundance{i,1}= 'I';
            isotopeAbundance{i,2}= 127;
            isotopeAbundance{i,3}= 1;
            i=i+1;
        end
    end
else
    isotopeSensitive=0;
end


allBiologicalElements={'C','O','P','N','S','H','Mg','Na','K','Cl','Ca','Zn','Fe','Cu','Mo','I'};

atomicWeights=parse_Atomic_Weights_and_Isotopic_Compositions_for_All_Elements;

M=zeros(length(formulae),1);

for n=1:length(formulae)
    %molecular formula
    formula=formulae{n};
    for a=1:length(allBiologicalElements)
        %number of atoms in element
        N=numAtomsOfElementInFormula(formula,allBiologicalElements{a});
        if N~=0
            %             fprintf('%d\t%s\n',N,allBiologicalElements{a})
            %index of element
            ind=strmatch(allBiologicalElements{a}, atomicWeights.AtomicSymbol, 'exact');
            if isotopeSensitive
                indIso=strmatch(allBiologicalElements{a}, isotopeAbundance(:,1), 'exact');
                if length(ind)~=length(indIso)
                    fprintf('%s\n',['Isotopic distribution for ' allBiologicalElements{a} ' is incomplete'])
                end
                weight=0;
                for q = 1:length(ind)
                    weight = weight + isotopeAbundance{indIso(q),3}*atomicWeights.data(ind(q)).RelativeAtomicMass;
                end
            else
                if length(ind)>1
                    %uses the first isotope by default
                    weight=atomicWeights.data(ind(1)).StandardAtomicWeight;
                else
                    weight=atomicWeights.data(ind).StandardAtomicWeight;
                end
            end
            %mass contribution from this element
            M(n)=M(n)+N*weight;
        end
    end
end