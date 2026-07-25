function [minimalMassMetabolite, minimalMassFraction, numMinimalMassMetabolites] = representativeMolecule(L, moietyFormulae, mets)
% For each moiety, identify a set of representative molecules, based on
% various criteria
%
% USAGE:
%
%    [minimalMassMetabolite, minimalMassFraction, numMinimalMassMetabolites] = representativeMolecule(L, moietyFormulae, mets)
%
% INPUTS:
%    L:                 `nMoieties x nMets` matrix mapping isomorphism classes (moieties) to metabolites
%    moietyFormulae:    `nMoieties x 1` cell array of moiety chemical formulae (Hill notation)
%    mets:              `nMets x 1` cell array of metabolite abbreviations
%
% OUTPUTS:
%    minimalMassMetabolite:        `nMoieties x 1` cell array of the metabolite of minimal mass relative to each moiety
%    minimalMassFraction:          `nMoieties x 1` vector of the moiety/metabolite mass fraction
%    numMinimalMassMetabolites:    `nMoieties x 1` vector of the number of metabolites with minimal mass


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

