% The COBRAToolbox: testReactionEq.m
%
% Purpose:
%     - testReactionEq tests the functionality of ReactionEq in the
%     rBioNet extension
%
% Authors:
%     - Stefania Magnusdottir April 2017
%

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testReactionEq'));
cd(fileDir);

% load the reaction database
load([fileDir, filesep 'rxn.mat'])

% check match for made up reaction
matched = ReactionEq('etoh[e] + 2pg[c] -> atp[c] + h[e]', rxn);

% test that no reaction was matched
assert(isempty(matched))

% check match for existing reaction
matched = ReactionEq(rxn{1, 3}, rxn);

% test that reaction was matched
assert(~isempty(matched))

% change the directory
cd(currentDir)
