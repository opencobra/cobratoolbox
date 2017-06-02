function model = createToyModelForMDFBA()
%createToyModelForMDFBA creates a toy model for
%MDFBA
% The model created looks as follows:
%
%
%   <-> A -> B ---> C --> E <->
%        \     /       \
%         -> D <--      v
%                 \---- F
%           
% A normal FBA maximizing the production of E should not yield any flux
% through A -> D
% MDFBA should show this flux.

model = createModel();
%Reactions in {Rxn Name, MetaboliteNames, Stoichiometric coefficient} format
Reactions = {'R1',{'A','B'},[-1 1];...
             'R2',{'B', 'D','C'},[-1 -1 1];...
             'R3',{'C','E','F'},[-1 1 1];...
             'R4',{'A','D'},[-1 1];...
             'R5',{'F','D'},[-1 1];}
ExchangedMets = {'A','E'};
%Add Reactions
for i = 1:size(Reactions,1)
    %All reactions are irreversible
    model = addReaction(model,Reactions{i,1},Reactions{i,2},Reactions{i,3},0,0,1000);
end

%Add Exchangers
model = addExchangeRxn(model,ExchangedMets,-1000*ones(numel(ExchangedMets),1),1000*ones(numel(ExchangedMets),1));
