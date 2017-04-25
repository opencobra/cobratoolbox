% The COBRAToolbox: testDetectDeadEnds.m
%
% Purpose:
%     - Tests whether all dead ends are correctly determined from a given
%       model
%
% Authors:
%     - Thomas Pfau, April 2017
%     - CI integration: Laurent Heirendt

% save the current path
currentDir = pwd;

% The testmodel used is structured as follows:
% 
%   <=> A -> F ---> H <=> J ->
%        \     /          ^
%         -> E            |     
%            | \          L   
%            v   -> I     |
%   <=> B -> D       \    v
%        \             -> K <=>
%         -> G <=>
%   <=> C
% Thus, D, L and C are dead ends, and C is also an exchanged metabolite

fileDir = fileparts(which('testDetectDeadEnds'));
cd(fileDir);

% load the test models
load('DeadEndTestModel','model')

%Determine all dead end metabolites
[mets] = detectDeadEnds(model);
assert(all(ismember(model.mets(mets),{'D','L','C'})));

%Only determine those, which are not involved in an exchange reaction
[mets] = detectDeadEnds(model,1);
assert(all(ismember(model.mets(mets),{'D','L'})));

%Clean up after test
clear mets
clear model

cd(currentDir)
