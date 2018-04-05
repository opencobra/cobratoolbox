% The COBRAToolbox: testSolveCobraNLP.m
%
% Purpose:
%     - testSolveCobraNLP tests the solveCobraNLP function and its different methods
%
% Authors:
%     - Original file: * Joseph Kang 11/16/09
%                      * Richard Que (02/11/10) NLP Support
%     - CI integration: Laurent Heirendt, March 2017
%
% Note:
%     - The tomlab_snopt solver must be tested with a valid license

% save the current path
currentDir = pwd;

% initialize the test
fileDir = fileparts(which('testSolveCobraNLP'));
cd(fileDir);

% define the tolerance
tol = 1e-4;

% define the solver packages to be used to run this test
global SOLVERS
UseIfAvailable = fieldnames(SOLVERS); %We will simply use all available solvers that are MIQP solvers.
solverPkgs = prepareTest('needsNLP',true,'useSolversIfAvailable',UseIfAvailable);

for k = 1:length(solverPkgs.NLP)

    % change the COBRA solver (NLP)
    solverOK = changeCobraSolver(solverPkgs.NLP{k}, 'NLP');


    if solverOK == 1
        fprintf('   Testing solveCobraNLP using %s ... ', solverPkgs.NLP{k});

        % setup NLP problem -- http://tomopt.com/docs/quickguide/quickguide008.php
        Name = 'RBB Problem';
        NLPproblem.A = [];
        NLPproblem.b = [];
        NLPproblem.csense = [];
        NLPproblem.lb = [-10; -10];
        NLPproblem.ub = [2; 2];
        NLPproblem.objFunction = 'NLP_objFunction';
        NLPproblem.x0 = [-1.2 1];
        NLPproblem.fLowBnd = 0;
        NLPproblem.gradFunction = 'NLP_gradFunction';
        NLPproblem.H = 'NLP_H';
        NLPproblem.c = 'NLP_c';
        NLPproblem.dc = 'NLP_dc';
        NLPproblem.d2c = 'NLP_d2c';
        NLPproblem.c_L = -1000;
        NLPproblem.c_U = 0;
        NLPproblem.osense = 1;

        % Solve, silent printing, problem name = 'RBB Problem' and warnings off.
        NLPsolution = solveCobraNLP(NLPproblem, 'printLevel', 0, 'PbName', Name, 'warning', 0);

        % check the results
        assert(abs(NLPsolution.obj) < tol)
        for i = 1:2
            assert(abs(NLPsolution.full(i) - 1) < tol)
        end

        % output a success message
        fprintf('Done.\n');
    end
end

% change the directory
cd(currentDir)

% this test is only available with tomlab_snopt
%{
sampleNLP; % run sampleNLP script
assert(abs(NLPsolution.obj - 0.0117) < tol)
assert(all(abs(NLPsolution.full - [2071.06780547;2928.93219453;0.00482843;0.00682843]) < tol))
%}
