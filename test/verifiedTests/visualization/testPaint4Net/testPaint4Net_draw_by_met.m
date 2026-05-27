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

% run draw_by_met
%%%%%%%%%%%%%%%%%%%%%%%%%%%
[directionRxns, Involved_mets, deadEnds] = draw_by_met(model, {'etoh[c]'},'true', 1, 'both', {''}, FBAsolution.x)

% check the first output

assert(isa(directionRxns, 'cell'), 'Incorrect DataType...')

for i=1:length(directionRxns)
    assert(sum(ismember(directionRxns{i},directionRxns_met{i}))==length(directionRxns{i}));
end

% check the second output

assert(isa(Involved_mets, 'cell'), 'Incorrect DataType...')

for i=1:length(Involved_mets)
    assert(sum(ismember(Involved_mets{i},Involved_mets_met{i}))==length(Involved_mets_met{i}));
end

% check the third output

assert(isa(deadEnds, 'cell'), 'Incorrect DataType...')

for i=1:length(deadEnds)
    assert(sum(ismember(deadEnds{i},deadEnds_met{i}))==length(deadEnds{i}));
end


% output a success message
fprintf('Done!\n');

% change the directory
cd(currentDir)

clear
