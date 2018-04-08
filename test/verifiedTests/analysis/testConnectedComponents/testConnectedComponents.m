% The COBRAToolbox: testConnectedComponents.m
%
% Purpose:
%     - tests the Connected Components functionality using a toy model
%
%
% Authors:
%     - Thomas Pfau

%% The model created looks as follows:
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

currentDir = pwd;
testdir = fileparts(which('testConnectedComponents.m'));
cd(testdir)

requiredToolboxes = {'image_toolbox'};

prepareTest('toolboxes',requiredToolboxes);


model = createToyModelForConnectedComponentAnalysis();
[groups,orphans,R,C] = connectedComponents(model);

%The orphan reactions, are the exchangers, which by definition are dropped
%from the connected components.Those are the last 5 reactions)
assert(isequal(orphans,numel(model.rxns)-4:numel(model.rxns)));

assert(isequal(model.rxns(1:2),model.rxns(groups(1).elements)));
assert(isequal(model.rxns(3:6),model.rxns(groups(2).elements)));


[groups,orphans] = connectedComponents(model,'largestComponent',0,1);

assert(isequal(numel(groups),1));
assert(isequal(model.rxns(3:6),model.rxns(groups.elements)));

delete('reactionsNotConnectedByAnything.txt');
delete('reactionAdjacencyOtherThanCofactors.txt')


cd(currentDir)
