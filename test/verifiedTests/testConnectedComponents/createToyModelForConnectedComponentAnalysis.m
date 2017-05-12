function model = createToyModelForConnectedComponentAnalysis()
%createToyModelForConnectedComponentAnalysis creates a toy model for
%connected component analysis
% The model created looks as follows:
%
%
%   <-> A -> B -> C <->
%
%
%              -> F -
%             /      \
%   <-> D -> E -> G ---> H <->
%            ^
%            |
%            v
%           
% And should yield 2 connected components, along with a bunch of exchangers
% which are ignored.

model = createModel();
%Reactions in {Rxn Name, MetaboliteNames, Stoichiometric coefficient} format
Reactions = {'R1',{'A','B'},[-1 1];...
             'R2',{'B','C'},[-1 1];...
             'R3',{'D','E'},[-1 1];...
             'R4',{'E','F'},[-1 1];...
             'R5',{'E','G'},[-1 1];...
             'R6',{'F','G','H'},[-1 -1 1]};
ExchangedMets = {'A','C','D','H','E'};
%Add Reactions
for i = 1:size(Reactions,1)
    %All reactions are irreversible
    model = addReaction(model,Reactions{i,1},Reactions{i,2},Reactions{i,3},0,0,1000);
end

%Add Exchangers
model = addExchangeRxn(model,ExchangedMets,-1000*ones(numel(ExchangedMets),1),1000*ones(numel(ExchangedMets),1));
