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


solverPkgs = prepareTest('requireOneSolverOf', {'ibm_cplex','gurobi'});

% set a tolerance
tol = 1e-4;

%Configure model for test
fileName= 'Recon1.0model.mat'; % if using Recon 3 model, amend filename.
model = getDistributedModel(fileName);
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

for k = 1:numel(solverPkgs.LP)
    fprintf('Testing HumanFctExt with solver %s\n',solverPkgs.LP{k});
    changeCobraSolver(solverPkgs.LP{k});
    
    % run testATPYieldFromCsources
    [Table_csourcesOri, TestedRxnsC, Perc] = testATPYieldFromCsources(model, 'Recon3');

    % load reference data
    load('refData_testATPYieldFromCsources.mat');

    % tests
    for i = 1:size(Table_csourcesOri, 1)
        for j = 1:size(Table_csourcesOri, 2)
            if ~isempty(Table_csourcesOri{i, j}) && ~isempty(ref_Table_csourcesOri{i, j})
                if ~isempty(Table_csourcesOri{i, j}) && ~isempty(ref_Table_csourcesOri{i, j}) && ~isnumeric(Table_csourcesOri{i, j}) && ~isnumeric(ref_Table_csourcesOri{i, j})
                    fprintf('%i - %i: %s : %s\n', i, j, Table_csourcesOri{i, j}, ref_Table_csourcesOri{i, j});
                    assert(isequal(Table_csourcesOri{i, j}, ref_Table_csourcesOri{i, j}));
                else
                    fprintf('%i - %i: %1.2f : %1.2f\n', i, j, Table_csourcesOri{i, j}, ref_Table_csourcesOri{i, j});
                    if i ~= 8 && j ~= 3
                        assert(abs(Table_csourcesOri{i, j} - ref_Table_csourcesOri{i, j}) < tol);
                    end
                end
            end
        end
    end

    % Note: the reactions cannot be tested, as they depend on the tolerance of the machine and the solver;
    %       the tested reacions are selected based on the solution vector itself
    % assert(isequal(sort(TestedRxnsC), sort(ref_TestedRxnsC)))
    % assert(isequal(Perc, ref_Perc))

    % run test4HumanFctExt
    [TestSolutionOri, TestSolutionNameClosedSinks, TestedRxnsClosedSinks, PercClosedSinks] = test4HumanFctExt(model, 'all', 0);

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

    % Note: the reactions cannot be tested, as they depend on the tolerance of the machine and the solver;
    %       the tested reacions are selected based on the solution vector itself
    % TestedRxns = unique([TestedRxnsC; TestedRxnsClosedSinks]);
    % TestedRxnsX = intersect(model.rxns,TestedRxns);
    % assert(isequal(TestedRxnsClosedSinks, ref_TestedRxnsClosedSinks))
    % assert(isequal(PercClosedSinks, ref_PercClosedSinks))
    % assert(isequal(TestedRxns, ref_TestedRxns))
    % assert(isequal(TestedRxnsX, ref_TestedRxnsX))
end

% remove all log files
delete '*.log'
delete '*.txt'

% change back to original directory
cd(currentDir)
