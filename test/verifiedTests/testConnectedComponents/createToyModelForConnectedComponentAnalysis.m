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
model = addReaction(model,'R1',{'A','B'},[-1 1], 0,0,1000);
model = addReaction(model,'R2',{'B','C'},[-1 1], 0,0,1000);
model = addReaction(model,'R3',{'D','E'},[-1 1], 0,0,1000);
model = addReaction(model,'R4',{'E','F'},[-1 1], 0,0,1000);
model = addReaction(model,'R5',{'E','G'},[-1 1], 0,0,1000);
model = addReaction(model,'R6',{'F','G','H'},[-1 -1 1], 0,0,1000);
model = addExchangeRxn(model,{'A'});
model = addExchangeRxn(model,{'C'});
model = addExchangeRxn(model,{'D'});
model = addExchangeRxn(model,{'H'});
model = addExchangeRxn(model,{'E'});