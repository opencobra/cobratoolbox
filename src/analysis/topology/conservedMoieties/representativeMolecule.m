function [MMN] = representativeMolecule(MMN)
% For each moiety, identify a set of representative molecules, based on
% various criteria

%make sure to sort by the index first
MMN.moi = sortrows(MMN.moi,'Name','ascend');
MMN.mol = sortrows(MMN.mol,'Name','ascend');

[nMoiety,~]=size(MMN.L);

minimalMassMetabolite = cell(nMoiety,1);
minimalMassMolFormula = cell(nMoiety,1);
minimalMassFraction = zeros(nMoiety,1);
numMinimalMassMetabolites = zeros(nMoiety,1);
for i=1:nMoiety
    if strcmp('C62H88CoN13O14P',MMN.moi.Formula{i})
        pause(0.1);
    end
    bool=(MMN.L(i,:)~=0)';
    minimumMass=min(MMN.mol.Mass(bool));
    if ~isnan(minimumMass)
        bool2 = bool &  MMN.mol.Mass==minimumMass;
        ind = find(bool2);
        %take the first one as a representative minimal Mass
        minimalMassMetabolite{i} = MMN.mol.Mets{ind(1)};
        minimalMassMolFormula{i} = MMN.mol.Formula{ind(1)};
        numMinimalMassMetabolites(i) = length(ind);
        minimalMassFraction(i)=MMN.moi.Mass(i)/minimumMass;
    else
        warning(['Mass is NaN for metabolites related to moiety ' MMN.moi.Formula{i}])
    end
end


variablesToRemove={'MinimalMassMol','MinimalMassMolFormula','MinimalMassFraction','NumMinimalMassMol'};
for i=1:length(variablesToRemove)
    if any(strcmp(MMN.moi.Properties.VariableNames,variablesToRemove{i}))
        MMN.moi = removevars(MMN.moi,variablesToRemove{i});
    end
end

MMN.moi = addvars(MMN.moi,minimalMassMetabolite,minimalMassMolFormula,minimalMassFraction,numMinimalMassMetabolites, 'NewVariableNames',{'MinimalMassMol','MinimalMassMolFormula','MinimalMassFraction','NumMinimalMassMol'});

