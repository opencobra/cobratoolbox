function model = createToyModelForLifting(Coupling)
% Creates a toy model for lifting.
%
% OUTPUT
%    model              A toy model with the very large coefficients that
%                       get transformed by lifting.                       
%
% ..Author       
%       - Thomas Pfau Sept 2017

model = createModel();
%Reactions in {Rxn Name, MetaboliteNames, Stoichiometric coefficient} format
Reactions = {'R1',{'A','B'},[-1 1e10];...
             'R2',{'B', 'D','C'},[-1e5 1e7 1];...
             'R3',{'C','D','E','CouplingMet'},[-1, -1e7, 1, -1];...
             'R4',{'F','G','CouplingMet'},[-1, 1, 1e5]};
ExchangedMets = {'A','E','F','G'};
%Add Reactions
for i = 1:size(Reactions,1)
    %All reactions are irreversible
    model = addReaction(model,Reactions{i,1},Reactions{i,2},Reactions{i,3},0,0,1e6);
end
couplingPos = ismember(model.mets,'CouplingMet');
model.csense(couplingPos) = 'G'; %(there has to be at least 0 coupling met.)
%The model can have at most 0.01 units of CouplingMet.
model = changeRxnBounds(model,'R4',1e-2,'u');
if ~Coupling
    model = removeMetabolites(model,'CouplingMet');
end

%Add Exchangers
model = addExchangeRxn(model,ExchangedMets,-1e6*ones(numel(ExchangedMets),1),1e6*ones(numel(ExchangedMets),1));

model = changeObjective(model,'EX_E',1);