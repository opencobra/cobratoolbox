function [minimalMassMetabolite, minimalMassFraction, numMinimalMassMetabolites] = representativeMolecule(L,moietyFormulae,mets)
% For each moiety, identify a set of representative molecules, based on
% various criteria
%
% INPUT
% L                     Matrix to map isomorphism classes to metabolites.
% moietyFormulae        Chemical formula of the moiety (Hill notation)
% mets                  Metabolite abbreviation
%
% OUTPUT
% minimalMassMetabolite       Abbreviation of metabolite with minimal mass relative to the moiety
% minimalMassFraction         Fraction of moiety/metabolite mass 
% numMinimalMassMetabolites   Number of metabolites with minimal mass


[moietyMasses, ~, ~, ~, ~] = getMolecularMass(moietyFormulae);
approxMetMasses = L'*moietyMasses;

[nMoieties,~]=size(L);

minimalMassMetabolite = cell(nMoieties,1);
minimalMassFraction = zeros(nMoieties,1);
numMinimalMassMetabolites = zeros(nMoieties,1);
for i=1:nMoieties
    bool=(L(i,:)~=0)';
    minimumMass=min(approxMetMasses(bool));
    if ~isnan(minimumMass)
        bool2 = bool &  approxMetMasses==minimumMass;
        ind = find(bool2);
        %take the first one as a representative minimal Mass
        minimalMassMetabolite{i} = mets{ind(1)};
        numMinimalMassMetabolites(i) = length(ind);
        minimalMassFraction(i)=moietyMasses(i)/minimumMass;
    else
        warning(['Mass is NaN for metabolites related to moiety ' moietyFormulae{i}])
    end
end

