%% *Verify the COBRA Toolbox*
% *Authors: Ronan Fleming, School of Medicine, University of Galway*
% 
% *Reviewers:* 
%% MATERIALS - EQUIPMENT SETUP
% Please ensure that all the required dependencies (e.g. , |git| and |curl|) 
% of The COBRA Toolbox have been properly installed by following the installation 
% guide <https://opencobra.github.io/cobratoolbox/stable/installation.html here>.
%% PROCEDURE 
%% Check available optimisation solvers 	
% At initialisation, one from a set of available optimisation solvers will be 
% selected as the default solver. If |Gurobi| is installed, it is used as the 
% default solver for LP, QP and MILP problems. Otherwise, the |GLPK| solver is 
% selected by for LP and MILP problems and QPNG is selected for QP problems. Check 
% the currently selected solvers with:

changeCobraSolver
%% ANTICIPATED RESULTS 
% A list of solvers assigned to solve each class of optimisation solver is returned. 				
%% CRITICAL STEP
% A dependency on at least one linear optimisation solver must be satisfied 
% for flux balance analysis. 
%% Verify a basic installation of the COBRA Toolbox
% Test if flux balance analysis works

testFBA

testSolveCobraLP
%% (Optional) Verify and test the entire COBRA Toolbox
%% TIMING ∼30 min
% Optionally test the functionality of The COBRA Toolbox locally, especially 
% if one encounters an error running a function. The test suite runs tailored 
% tests that verify the output and proper execution of core functions on the locally 
% configured system. The full test suite can be invoked by typing:

testCOBRAToolbox=0;
if testCOBRAToolbox
    testAll
end
%% ANTICIPATED RESULTS
% The test suite starts by initialising The COBRA Toolbox and thereafter, all 
% of the tests are run. At the end of the test run, a comprehensive summary table 
% is presented in which the respective tests and their test outcome is shown. 
% On a properly configured system that is compatible with the most recent version 
% of The COBRA Toolbox, all tests should pass.
%% TROUBLESHOOTING
% If some third party dependencies are not properly installed, some tests may 
% fail. The test suite, despite some tests failing, is not interrupted. The tests 
% that fail are listed with a false status in the column Passed. The specific 
% test can then be run individually to determine the exact cause of the error. 
% If the error can be fixed, follow the tutorial on how to contribute to The COBRA 
% Toolbox and contribute a fix.