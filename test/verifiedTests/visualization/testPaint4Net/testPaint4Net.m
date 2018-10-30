% The COBRAToolbox: testPaint4Net.m
%
% Purpose:
%     - tests the basic functionality of Paint4Net
%
% Authors:
%     - Original file: Agris Pentjuss, Andrejs Kostromins 04.07.2017
%

% Check requirements
requiredToolboxes = {'bioinformatics_toolbox'};  % This is the Global optimization toolbox
solvers = prepareTest('needsLP', true, 'toolboxes', requiredToolboxes, 'useMinimalNumberOfSolvers',true);

% save the current path
currentDir = pwd;

% initialize the test
cd(fileparts(which('testPaint4Net')))

% load the model
load('testPaint4Net.mat');
model = readCbModel('testPaint4Net.mat', 'modelName', 'model');

% Paint4Net uses fluxVariability therefore start the parpool if available.
% The following can be done with any allowed solver, but e.g. pdco will fail, so we will run a few others.
% create a parallel pool
try
    % Shut down any existing pool
    minWorkers = 2;
    myCluster = parcluster(parallel.defaultClusterProfile);
    
    if myCluster.NumWorkers >= minWorkers
        poolobj = gcp('nocreate');  % if no pool, do not create new one.
        if isempty(poolobj)
            parpool(minWorkers);  % launch minWorkers workers
        end
    end
    % parpool is running, don'T test dqqMinos and quadMinos
    solvers = prepareTest('needsLP', true, 'toolboxes', requiredToolboxes, 'excludeSolvers',{'dqqMinos','quadMinos'},'useMinimalNumberOfSolvers',true);
catch
    disp('Trying Non Parallel')
end


for k = 1:length(solvers.LP)
    fprintf(' -- Running testPaint4Net using the solver interface: %s ... ', solvers.LP{k});
    changeCobraSolver(solvers.LP{k}, 'LP', 0);

    [involvedRxns_test, involvedMets_test, deadEnds_test] = draw_by_met(model, {'etoh[c]'}, 'false', 1, 'struc', {''}, sol.x);
    assert(isequal(involvedRxns_test, involvedRxns_etoh) && isequal(involvedMets_test, involvedMets_etoh));
    [involvedRxns_test, involvedMets_test, deadEnds_test] = draw_by_met(model, {'succ[c]'}, 'false', 1, 'struc', {''}, sol.x);
    assert(isequal(involvedRxns_test, involvedRxns_succ) && isequal(involvedMets_test, involvedMets_succ));

    % testing parameter drawMap: allows or denies use biograph viewer

    [involvedRxns_test, involvedMets_test, deadEnds_test] = draw_by_met(model, {'glu-L[c]'}, 'true', 1, 'struc', {''}, sol.x);
    assert(~isempty(findall(0, 'Type', 'Figure')) == 1);  % allows
    delete(findall(0, 'Type', 'figure'))      % close all figures
    [involvedRxns_test, involvedMets_test, deadEnds_test] = draw_by_met(model, {'glu-L[c]'}, 'false', 1, 'struc', {''}, sol.x);
    assert(~isempty(findall(0, 'Type', 'Figure')) == 0);  % denies

    % testing parameter radius on etoh[c] in radius of 1, 2 and 3 reactions from etoh[c]

    [involvedRxns_test_etoh1, involvedMets_test_etoh1, deadEnds_test_etoh1] = draw_by_met(model, {'etoh[c]'}, 'true', 1, 'struc', {''}, sol.x);
    assert(isequal(involvedRxns_test_etoh1, involvedRxns_test_etoh1) && isequal(involvedMets_test_etoh1, involvedMets_etoh1));
    [involvedRxns_test_etoh2, involvedMets_test_etoh2, deadEnds_test_etoh2] = draw_by_met(model, {'etoh[c]'}, 'true', 2, 'struc', {''}, sol.x);
    assert(isequal(involvedRxns_test_etoh2, involvedRxns_test_etoh2) && isequal(involvedMets_test_etoh2, involvedMets_etoh2));
    [involvedRxns_test_etoh3, involvedMets_test_etoh3, deadEnds_test_etoh3] = draw_by_met(model, {'etoh[c]'}, 'true', 3, 'struc', {''}, sol.x);
    assert(isequal(involvedRxns_test_etoh3, involvedRxns_test_etoh3) && isequal(involvedMets_test_etoh3, involvedMets_etoh3));
    delete(findall(0, 'Type', 'figure'))      % close all figures

    % testing parameter direction

    [involvedRxns_none, involvedMets_none, deadEnds_none] = draw_by_met(model, {'acald[c]'}, 'true', 1, 'struc', {''}, sol.x);
    assert(~isempty(findall(0, 'Type', 'Figure')) == 1);
    delete(findall(0, 'Type', 'figure'));     % close all figures
    [involvedRxns_none, involvedMets_none, deadEnds_none] = draw_by_met(model, {'acald[c]'}, 'true', 1, 'sub', {''}, sol.x);
    assert(~isempty(findall(0, 'Type', 'Figure')) == 1);
    delete(findall(0, 'Type', 'figure'));    % close all figures
    [involvedRxns_none, involvedMets_none, deadEnds_none] = draw_by_met(model, {'acald[c]'}, 'true', 1, 'prod', {''}, sol.x);
    assert(~isempty(findall(0, 'Type', 'Figure')) == 1);
    delete(findall(0, 'Type', 'figure'));     % close all figures
    [involvedRxns_none, involvedMets_none, deadEnds_none] = draw_by_met(model, {'acald[c]'}, 'true', 1, 'both', {''}, sol.x);
    assert(~isempty(findall(0, 'Type', 'Figure')) == 1);
    delete(findall(0, 'Type', 'figure'));      % close all figures

    % testing parameter excludeMets

    [involvedRxns_excl, involvedMets_excl, deadEnds_excl] = draw_by_met(model, {'etoh[c]'}, 'true', 1, 'struc', {'acald[c]'}, sol.x);
    assert(isequal(involvedRxns_excl, involvedRxns_Met1) && isequal(involvedMets_excl, involvedMets_Met1));
    [involvedRxns_excl, involvedMets_excl, deadEnds_excl] = draw_by_met(model, {'etoh[c]'}, 'true', 1, 'struc', {'acald[c]', 'nad[c]'}, sol.x);
    assert(isequal(involvedRxns_excl, involvedRxns_Met2) && isequal(involvedMets_excl, involvedMets_Met2));
    [involvedRxns_excl, involvedMets_excl, deadEnds_excl] = draw_by_met(model, {'etoh[c]'}, 'true', 1, 'struc', {'acald[c]', 'nad[c]', 'h[c]'}, sol.x);
    assert(isequal(involvedRxns_excl, involvedRxns_Met3) && isequal(involvedMets_excl, involvedMets_Met3));
    [involvedRxns_excl, involvedMets_excl, deadEnds_excl] = draw_by_met(model, {'etoh[c]'}, 'true', 1, 'struc', {'acald[c]', 'nad[c]', 'h[c]', 'nadh[c]'}, sol.x);
    assert(isequal(involvedRxns_excl, involvedRxns_Met4) && isequal(involvedMets_excl, involvedMets_Met4));
    delete(findall(0, 'Type', 'figure'))  % close all figures

    % test draw_by_rxn functionality

    % testing parameter rxns

    [involvedMets_test_list1, deadEnds_test_list1, deadRxns_test_list1] = draw_by_rxn(model, list1, 'true', 'struc', {''}, {''}, sol.x);
    assert(isequal(deadRxns_test_list1, deadRxns_list1) && isequal(involvedMets_test_list1, involvedMets_list1));

    [involvedMets_test_list2, deadEnds_test_list2, deadRxns_test_list2] = draw_by_rxn(model, list2, 'true', 'struc', {''}, {''}, sol.x);
    assert(isequal(deadRxns_test_list2, deadRxns_list2) && isequal(involvedMets_test_list2, involvedMets_list2));

    [involvedMets_test_list3, deadEnds_test_list3, deadRxns_test_list3] = draw_by_rxn(model, list3, 'true', 'struc', {''}, {''}, sol.x);
    assert(isequal(deadRxns_test_list3, deadRxns_list3) && isequal(involvedMets_test_list3, involvedMets_list3));

    [involvedMets_test_list4, deadEnds_test_list4, deadRxns_test_list4] = draw_by_rxn(model, list4, 'true', 'struc', {''}, {''}, sol.x);
    assert(isequal(deadRxns_test_list4, deadRxns_list4) && isequal(involvedMets_test_list4, involvedMets_list4));

    delete(findall(0, 'Type', 'figure'));  % close all figures

    % testing parameter drawMap

    [involvedMets_test_list4, deadEnds_test_list4, deadRxns_test_list4] = draw_by_rxn(model, list1, 'true', 'struc', {''}, {''}, sol.x);

    assert(~isempty(findall(0, 'Type', 'Figure')) == 1);  % allows
    delete(findall(0, 'Type', 'figure'));  % close all figures

    [involvedMets_test, deadEnds_test, deadRxns_test] = draw_by_rxn(model, list1, 'false', 'struc', {''}, {''}, sol.x);

    assert(~isempty(findall(0, 'Type', 'Figure')) == 0);  % Denies us biograph viewer

    % testing parameter direction

    [involvedMets_test, deadEnds_test, deadRxns_test] = draw_by_rxn(model, list4, 'true', 'struc', {''}, {''}, sol.x);
    assert(~isempty(findall(0, 'Type', 'Figure')) == 1);
    delete(findall(0, 'Type', 'figure'));   % close all figures
    [involvedMets_test, deadEnds_test, deadRxns_test] = draw_by_rxn(model, list4, 'true', 'sub', {''}, {''}, sol.x);
    assert(~isempty(findall(0, 'Type', 'Figure')) == 1);
    delete(findall(0, 'Type', 'figure'));     % close all figures
    [involvedMets_test, deadEnds_test, deadRxns_test] = draw_by_rxn(model, list4, 'true', 'prod', {''}, {''}, sol.x');
    assert(~isempty(findall(0, 'Type', 'Figure')) == 1);
    delete(findall(0, 'Type', 'figure'));     % close all figures
    [involvedMets_test, deadEnds_test, deadRxns_test] = draw_by_rxn(model, list4, 'true', 'both', {''}, {''}, sol.x);
    assert(~isempty(findall(0, 'Type', 'Figure')) == 1);
    delete(findall(0, 'Type', 'figure'));    % close all figures

    % testing parameter initialMet

    [involvedMets_test, deadEnds_test, deadRxns_test] = draw_by_rxn(model, list4, 'true', 'struc', {'etoh[c]'}, {''}, sol.x);
    assert(~isempty(findall(0, 'Type', 'Figure')) == 1);
    delete(findall(0, 'Type', 'figure'));      % close all figures

    [involvedMets_test, deadEnds_test, deadRxns_test] = draw_by_rxn(model, list4, 'true', 'struc', {'atp[c]'}, {''}, sol.x);
    assert(~isempty(findall(0, 'Type', 'Figure')) == 1);
    delete(findall(0, 'Type', 'figure'));      % close all figures

    [involvedMets_test, deadEnds_test, deadRxns_test] = draw_by_rxn(model, list4, 'true', 'struc', {'fru[c]'}, {''}, sol.x);
    assert(~isempty(findall(0, 'Type', 'Figure')) == 1);
    delete(findall(0, 'Type', 'figure'));      % close all figures

    % testing parameter excludeMets

    [involvedMets_test, deadEnds_test, deadRxns_test] = draw_by_rxn(model, list1, 'true', 'struc', {''}, {'etoh[c]'}, sol.x);
    assert(~isempty(findall(0, 'Type', 'Figure')) == 1);
    delete(findall(0, 'Type', 'figure'));      % close all figures

    [involvedMets_test, deadEnds_test, deadRxns_test] = draw_by_rxn(model, list1, 'true', 'struc', {''}, {'atp[c]'}, sol.x);
    assert(~isempty(findall(0, 'Type', 'Figure')) == 1);
    delete(findall(0, 'Type', 'figure'));   % close all figures

    [involvedMets_test, deadEnds_test, deadRxns_test] = draw_by_rxn(model, list1, 'true', 'struc', {''}, {'fru[c]'}, sol.x);
    assert(~isempty(findall(0, 'Type', 'Figure')) == 1);
    delete(findall(0, 'Type', 'figure'));      % close all figures

    [involvedMets_test, deadEnds_test, deadRxns_test] = draw_by_rxn(model, list1, 'true', 'struc', {''}, {'glyc12[c]'}, sol.x);
    assert(~isempty(findall(0, 'Type', 'Figure')) == 1);
    delete(findall(0, 'Type', 'figure'));      % close all figures
end
% output a success message
fprintf('Done.\n');
