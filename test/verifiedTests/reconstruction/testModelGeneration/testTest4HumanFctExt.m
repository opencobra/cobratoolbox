% The COBRAToolbox: testTest4HumanFctExt.m
%
% Purpose:
%     - Tests the testATPYieldFromCsources and test4HumanFctExt functions
%

global CBTDIR

% save current directory
currentDir = pwd;

fileDir = fileparts(which('testTest4HumanFctExt'));
cd(fileDir)

solverOK = changeCobraSolver('gurobi');

% set a tolerance
tol = 1e-6;

if solverOK
    fileName= 'Recon1.0model.mat'; % if using Recon 3 model, amend filename. 
    model = readCbModel([CBTDIR filesep 'test' filesep 'models' filesep fileName]);
    model.csense(1:size(model.S,1),1) = 'E';

    % Set the lower bounds on all biomass reactions and sink/demand reactions to zero.
    model.lb(find(ismember(model.rxns, 'biomass_reaction'))) = 0;
    model.lb(find(ismember(model.rxns, 'biomass_maintenance_noTrTr'))) = 0;
    model.lb(find(ismember(model.rxns, 'biomass_maintenance'))) = 0;
    DMs = strmatch('DM_', model.rxns);
    model.lb(DMs) = 0;
    Sinks = strmatch('sink_', model.rxns);
    model.lb(Sinks) = 0;
    model.ub(Sinks) = 1000;

    % run testATPYieldFromCsources
    [Table_csourcesOri, TestedRxnsC, Perc] = testATPYieldFromCsources(model);
    
    % load reference data
    load('refData_testATPYieldFromCsources.mat');
    
    % tests
    assert(isequal(Table_csourcesOri, ref_Table_csourcesOri))
    assert(isequal(TestedRxnsC, ref_TestedRxnsC))
    assert(isequal(Perc, ref_Perc))

    % run test4HumanFctExt
    [TestSolutionOri, TestSolutionNameClosedSinks, TestedRxnsClosedSinks, PercClosedSinks] = test4HumanFctExt(model, 'all', 0);
    TestedRxns = unique([TestedRxnsC; TestedRxnsClosedSinks]);
    TestedRxnsX = intersect(model.rxns,TestedRxns); 

    % load reference data
    load('refData_testTest4HumanFctExt.mat');

    % test all solutions
    for i = 1:length(TestSolutionOri)
        if ~isnan(TestSolutionOri(i)) && ~isnan(ref_TestSolutionOri(i))
            assert(abs(TestSolutionOri(i) - ref_TestSolutionOri(i)) < tol)
        end
    end

    % test the reaction names
    for i = 1:length(TestSolutionNameClosedSinks)
        assert(isequal(TestSolutionNameClosedSinks{i, 1}, ref_TestSolutionNameClosedSinks{i, 1}))
    end
    assert(isequal(TestedRxnsClosedSinks, ref_TestedRxnsClosedSinks))
    assert(isequal(PercClosedSinks, ref_PercClosedSinks))
    assert(isequal(TestedRxns, ref_TestedRxns))
    assert(isequal(TestedRxnsX, ref_TestedRxnsX))
end

% change back to original directory
cd(currentDir)