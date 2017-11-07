function model = createToyModelForPreProcessing()
%createToyModelForPreProcessing creates a toy model to test gene
%preprocessing
% The model created looks as follows:
%
%
%   <-> A <------> B <-----> C <-----> D <->
%            |         |          |
%        G1 and G2     |       G6 or G7
%               G3 and (G4 or G5)

model = createModel();
%Reactions in {Rxn Name, MetaboliteNames, Stoichiometric coefficient, GPR} format
Reactions = {'R1',{'A','B'},[-1 1], 'G1 and G2';...
             'R2',{'B','C'},[-1 1],'G3 and (G4 or G5)';...
             'R3',{'C','D'},[-1 1],'G6 or G7'};
ExchangedMets = {'A','D'};
%Add Reactions
for i = 1:size(Reactions,1)
    %All reactions are irreversible
    model = addReaction(model,Reactions{i,1},'metaboliteList',Reactions{i,2},'stoichCoeffList',Reactions{i,3},'geneRule',Reactions{i,4});
end

%Add Exchangers
model = addExchangeRxn(model,ExchangedMets,-1000*ones(numel(ExchangedMets),1),1000*ones(numel(ExchangedMets),1));
model = changeObjective(model,'EX_D',1);