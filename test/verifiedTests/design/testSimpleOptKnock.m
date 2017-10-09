% The COBRAToolbox: testSimpleOptKnock.m
%
% Purpose:
%     - test the simpleOptKnock function
%
% Authors:
%     - Jacek Wachowiak
global CBTDIR
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSimpleOptKnock'));
cd(fileDir);

% test variables
model = createModel();
model = addReaction(model,'R1','reactionFormula','A <=>','lowerBound',-20);
model = addReaction(model,'R2','A -> B');
model = addReaction(model,'R3','B -> C + D');
model = addReaction(model,'R4','reactionFormula','D -> E','geneRule','(G1 and G2) and (G3 or G4)');
model = addReaction(model,'R4a','reactionFormula','D -> 0.5 C + 0.5 E','geneRule','(G1 and G2) and (G3 or G4)');
model = addReaction(model,'R5','C -> E');
model = addReaction(model,'R6','reactionFormula','E <=> ', 'objectiveCoef',1);
model = addReaction(model,'R7','reactionFormula','D <=> ','lowerBound',0);

% function outputs
[wtRes, delRes] = simpleOptKnock(model, 'R7', {'R4'})
[wtRes2, delRes2] = simpleOptKnock(model, 'R7', {'R4', 'R4a'})
[wtRes3, delRes3] = simpleOptKnock(model, 'R7', {'G1'}, 1)
[wtRes4, delRes4] = simpleOptKnock(model, 'R7', {'G3', 'G4'}, 1, 0.05, 1)

% tests
assert(isequal(0, 0));


% change to old directory
cd(currentDir);
