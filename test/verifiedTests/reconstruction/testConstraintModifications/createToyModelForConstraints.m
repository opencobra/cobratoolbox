function model = createToyModelForConstraints()
% createToyModelForConstraints creates a toy model for
% including coupling constraints for functional testing.
% The model created looks as follows:
%
%
%   <-> A -----> B ---> C --> E <->
%        \       ^      ^
%         \     /      /
%          -> D  ---> F
%
%      H -> I -> J 
%       ^        /
%        \      /
%           ---  
%
model = createModel();
%Reactions in {Rxn Name, MetaboliteNames, Stoichiometric coefficient} format
Reactions = {'R1',{'A','B'},[-1 1],-1000,1000;...
             'R2',{'A', 'D'},[-1 2],0,1000;...
             'R3',{'D','B'},[-1 1 ],0,30;...
             'R4',{'B','C'},[-1 1],0,20;...
             'R5',{'C','E'},[-1 1],0,1000;...
             'R6',{'D','F'},[-1 1],0,20;...
             'R7',{'F','C'},[-1 1],0,30;...
             'R8',{'H','I'},[-1 1],0,1000;...
             'R9',{'I','J'},[-1 1],0,1000;...
             'R10',{'J','H'},[-1 1],0,1000;...
             };             
ExchangedMets = {'A','E'};
%Add Reactions
for i = 1:size(Reactions,1)
    %All reactions are irreversible
    model = addReaction(model,Reactions{i,1},'metaboliteList',Reactions{i,2},'stoichCoeffList',Reactions{i,3},'lowerBound',Reactions{i,4},'upperBound',Reactions{i,5});
end
model = changeGeneAssociation(model,'R3','G1 or G2');
model = changeGeneAssociation(model,'R4','G3 or G5');
model = changeGeneAssociation(model,'R7','G4 and (G1 or G2)');
model = changeGeneAssociation(model,'R4','(G3 or G5) and G6');


%Add Exchangers
model = addExchangeRxn(model,ExchangedMets,-1000*ones(numel(ExchangedMets),1),1000*ones(numel(ExchangedMets),1));
model = changeObjective(model,'EX_E',1);
model = addCOBRAConstraints(model,{'R3','R7'},5, 'c',[1,1],'dsense','G','ConstraintID','R3_and_R7_above_5');
model = addCOBRAConstraints(model,{'R4','R6'},30, 'c',[1,1],'dsense','L','ConstraintID','R4_and_R6_lowerthan_30');