function [MMN] = representativeMolecule(MMN)
% For each moiety, identify a set of representative molecules, based on
% various criteria
%
% USAGE:
%
%    [MMN] = representativeMolecule(MMN)
%
% INPUT:
%    MMN:    moiety-molecule network structure with fields:
%
%              * .L - `nMoiety x nMet` matrix mapping moieties to metabolites
%              * .mol - table of molecule information, with variables `Mass` and `Mets`
%
% OUTPUT:
%    MMN:    input structure returned with an added or updated field:
%
%              * .moi - moiety table with added representative-molecule variables
%                (`MinimalMassMol`, `minimalMassFraction`, `NumMinimalMassMol`)
%

[nMoiety,~]=size(MMN.L);

minimalMassMetabolite = cell(nMoiety,1);
fractMinimalMass = zeros(nMoiety,1);
numMinimalMassMetabolites = zeros(nMoiety,1);
for i=1:nMoiety
    bool=(MMN.L(i,:)~=0)';
    minimumMass=min(MMN.mol.Mass(bool));
    bool2 = bool &  MMN.mol.Mass==minimumMass;
    ind = find(bool2);
    %take the first one as a representative minimal Mass
    minimalMassMetabolite{i} = MMN.mol.Mets{ind(1)};
    numMinimalMassMetabolites(i) = length(ind);
    fractMinimalMass(i)=minimumMass/MMN.mol.Mass(ind(1));
end


MMN.moi = addvars(MMN.moi,minimalMassMetabolite,fractMinimalMass,numMinimalMassMetabolites, 'NewVariableNames',{'MinimalMassMol','minimalMassFraction','NumMinimalMassMol'});

