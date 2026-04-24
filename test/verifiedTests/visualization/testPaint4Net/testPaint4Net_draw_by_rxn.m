% The COBRAToolbox: testPaint4Net.m
%
% Purpose:
%     - testPaint4Net tests the whether Paint4Net
%     is working correctly
%
% Author:
%     - Original file:
%            Andrejs Kostromins, Biosystems Group, Department of Computer
%            Systems, Latvia University of Agriculture, Liela iela 2,
%            LV-3001 Jelgava, Latvia.
%            Egils Stalidzans, Institute of Microbiology and
%            Biotechnology, University of Latvia, Jelgavas iela 1,
%            LV-1004, Latvia.
%             - Modified for use without BioGraph by:
%                 Rui Afonso Tavares & Reinis Muižnieks 2026
%
% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testPaint4Net.m'));
cd(fileDir);

% get the inputs
load('Paint4Net sample pack/Paint4Net_test_workspace.mat');

% get the outputs
load("testPaint4Net_workspace_expected_results.mat")

% list of solver packages: none needed

%Bioinformatics toolbox Needed for bio_draw_by_rxn & bio_draw_by_met

% run draw_by_rxn
%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Involved_mets, Dead_ends] = draw_by_rxn(model,model.rxns, 'true', 'struc', {''}, {''}, FBAsolution.x);

fprintf('Testing Paint4Net draw_by_rxn...');

% check the first output

assert(isa(Involved_mets, 'cell'), 'Incorrect DataType...')

% Check that the number of reactions being produced in the test is the same
% as that produced from the tutorial pack.
for i=1:length(Involved_mets)
    assert(sum(ismember(Involved_mets{i},Involved_mets_rxn{i}))==length(Involved_mets{i}), 'Reactions do not match expected...');
end


% check the second output

assert(isa(Dead_ends, 'cell'), 'Incorrect DataType...')

for i=1:length(Dead_ends)
    assert(sum(ismember(Dead_ends{i},Dead_ends_rxn{i}))==length(Dead_ends{i}), 'Reactions do not match expected...');
end

% output a success message
fprintf('Done!\n');

% change the directory
cd(currentDir)

clear
