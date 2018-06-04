function model = createToyModelForMinimizeFlux()
% createToyModelForMinimizeFlux creates a toy model for
% flux minimization analysis
% The model created looks as follows:
%
%
%   <-> A --> B --> C <-> E <->
%        \          ^     ^
%         \         v     v
%           -> D -> F <-> G        
%                   
%           
% When enforcing flux through C -> E, the minimal solution should only
% yield the cycle CEFG
% When maximising, there should be flux via A-->D, as the cycle is cannot
% carry as much flux as a -> A -> D -> F -> G -> E -> conversion.

model = createModel();
%Reactions in {Rxn Name, MetaboliteNames, Stoichiometric coefficient} format
Reactions = {'R1',{'A','B'},[-1 1],0;...             
             'R2',{'B','C'},[-1 1],0;...
             'R3',{'C','E'},[-1 1],1;...
             'R4',{'A','D'},[-1 1],0;...
             'R5',{'D','F'},[-1 1],0;...
             'R6',{'F','G'},[-1 1],1;...
             'R7',{'G','E'},[-1 1],1;...
             'R8',{'F','C'},[-1 1],1;};
ExchangedMets = {'A','E'};
%Add Reactions
for i = 1:size(Reactions,1)
    %All reactions are irreversible
    model = addReaction(model,Reactions{i,1},Reactions{i,2},Reactions{i,3},Reactions{i,4});
end

%Add Exchangers
model = addExchangeRxn(model,ExchangedMets,-1000*ones(numel(ExchangedMets),1),1000*ones(numel(ExchangedMets),1));
model = changeObjective(model,'EX_E',1);