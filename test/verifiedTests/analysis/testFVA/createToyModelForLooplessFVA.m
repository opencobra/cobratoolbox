function model = createToyModelForLooplessFVA()
% Create a toy model that has a loop and will give different solutions when
% minimizing the 0-, 1- and 2-norms respectively
%
%    <=> B
%         \    <=> F <=>
% <=> A ----> D ------> E <=>
%      2 2/
%       2/
%   <=> C

model = createModel();
Reactions = {'R1', 'A + B -> D'; ...
             'R2', '2 A + 2 C -> 2 D';...
             'R3', 'D -> E';...
             'R4', 'D <=> F';...
             'R5', 'F <=> E';...
             'Ex_A', 'A <=>'; ...
             'Ex_B', 'B <=>'; ...
             'Ex_C', 'C <=>'; ...
             'Ex_E', 'E <=>'};
         
%Add Reactions
for i = 1:size(Reactions,1)
    %All reactions are irreversible
    model = addReaction(model, Reactions{i,1}, 'reactionFormula', Reactions{i,2}, 'printLevel', -1);
end

% uptake bound for A = 1
model = changeRxnBounds(model, 'Ex_A', -1, 'l');
% max production of E
model = changeObjective(model, 'Ex_E', 1);
end